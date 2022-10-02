function deploySmkModel_dll_forAVL()

b64bit = strcmp(computer,'PCWIN64');
ext = '_win32';
if b64bit
    ext = '_win64';
end

uiwait(msgbox({'Ricorda: ', ''...
        'Ogni modello da compilare deve avere il nome "exe_modelName_open.mdl"','',...
        'Per ogni modello da compilare deve esistere nella directory corrente'...
        'un file da cui estrarre le variabili da tunare dal nome "wsp_modelName.mat"'},...
        'requisiti per compilazione',...
        'modal'));

% selezione modelli da compilare
[filename] = uigetfile({'*.mdl','Simulink model (*.mdl)';'*.slx','Simulink model (*.slx)'}, 'seleziona i modelli da compilare', 'MultiSelect','on');
if isnumeric(filename) && filename==0 % se premo "annulla"
   return
end
if ischar(filename) % cell array dei modelli
   filename = {filename};
end
cModelName = cell(length(filename),1);
cModelExt = cell(size(cModelName));
for i=1:length(filename)
   s0 = filename{i}(5:end);
   [dum, cModelName{i}, cModelExt{i}] = fileparts(s0);
end

% memorizzo e cancello il wsp base vecchio 
% tWspBaseOld = wsp2struct('wsp','base');
evalin('base', 'clear') 
% ciclo sui modelli da compilare
for i = 1:length(cModelName)
    %
    % apro il modello simulink e lo salvo senza link, lavoro solo su quello
   
    [sModel, sWsp, sPar, bErr] = modelLoad(cModelName{i});
    if bErr
        continue
    end

    fin=length(sModel)-4;   
    sModel=sModel(1:fin);
    %
    % sostituzione dei modelli referenced con sottosistemi atomici per la
    % compilazione senza licenza Simulink
    ReferencedModelReplacement(sModel);

    % aggiornamento variabili tunable e conversione in oggetti parametro
   cRefVars = refreshTunVars(sModel);
    % tunablevars2parameterobjects(sModel); serve solo se mantengo i sistemi
    % reference nel modello
    
    % settaggi di ert_shrlib
    idmaxlength = str2num(256);
    set_param(sModel,'SystemTargetFile','ert_shrlib.tlc',...%'TemplateMakeFile','ert_default_tmf',...
    'SupportContinuousTime','on', 'SupportVariableSizeSignals','on', 'MaxIdLength',idmaxlength,...
     'UpdateModelReferenceTargets','IfOutOfDateOrStructuralChange', 'LifeSpan','inf',...
     'GenerateReport','off','ParameterTunabilityLossMsg','warning',...
     'StartTime','0','StopTime','100000', 'FixedStep','MDL_t_sample');
   
    Logged_Bus_Outputs(sModel) %%%add logged signal bus output - DLL purpose  

    save_system(sModel) %%% Necessario??? 
   
    % compilazione
    load_system(sModel);   

  
    
    rtwbuild(sModel);
    
    if ~b64bit
        cd([sModel,'_ert_shrlib_rtw'])
        system([sModel,'.bat']);   %DLL generation
        cd('..');
    end
    
    libname = [sModel,ext];
    
    incPath = fullfile(pwd, [sModel, '_ert_shrlib_rtw']);
    hfile   = fullfile(incPath, [sModel, '.h']);
    
    sProtofile=['pF_',sModel];
    
    if b64bit
[notfound,warnings] = coder.loadlibrary(libname,hfile,...
            'includepath',fullfile(pwd, [sModel, '_ert_shrlib_rtw']),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\simscape\engine\sli\c'),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\common\foundation\core\c'),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\simscape\compiler\core\c'),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\network_engine\c'),...
            'includepath',fullfile(matlabroot,'simulink','include'),...
            'includepath',fullfile(matlabroot,'rtw\c\src'),...
            'mfilename', sProtofile);
    else
        
        [notfound,warnings] = loadlibrary(libname,hfile,...
            'includepath',fullfile(pwd, [sModel, '_ert_shrlib_rtw']),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\simscape\engine\sli\c'),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\common\foundation\core\c'),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\simscape\compiler\core\c'),...
            'includepath',fullfile(matlabroot,'toolbox\physmod\network_engine\c'),...
            'includepath',fullfile(matlabroot,'simulink','include'),...
            'includepath',fullfile(matlabroot,'rtw\c\src'),...
            'mfilename', sProtofile);
    end
    %check possible problem of par name.
    parameter=['P_',sModel,'_T_'];
    a=libstruct(parameter);   %%%%%%
    par  = calllib(libname,[sModel,'_P']);

    d=fieldnames(par.value);
    f=fieldnames(a);
    
    if (length(d) ~= length(f))
        disp('WARNING: check the following par');
        par_not_in_struct=setdiff(d,f)        
    end
    clear ('a');
    clear('par');
    unloadlibrary(libname);
    
    clear function;
    bdclose('all');
    delete([sModel, '.mdl']) % cancello il modello derivante dall'orginale
    delete([sModel,'_sfun.mexw32']);
    rmdir([pwd,'\',sModel,'_ert_shrlib_rtw'],'s');
end
% ripristino il wsp base originale
evalin('base', 'clear')
clear all

return

function [sModel, sWsp, sPar, bErr] = modelLoad(sModelName)

% apro il modello simulink e lo salvo senza link, lavoro solo su quello
% il modello da compilare deve avere il suffisso "_open", che verrà
% eliminato quando lo si compila.
bErr = false;
sModel0 = ['exe_', sModelName];
open_system(sModel0)
s0 = '_open';
idx = strfind(sModelName, s0);
if isempty(idx)
    disp(['Error: model "', sModel0, '" needs to have the "', s0, '" suffix.'])
    close_system(sModel0)
    bErr = true;
    return
end
% tolgo suffisso open ai modelli e al wsp
sBase = sModelName(1:idx-1); 
sModel = ['exe_', sBase,'.mdl'];
sWsp = ['wsp_', sBase];
sPar = ['par_', sBase];

% salvo senza link
save_system(sModel0, sModel, 'BreakUserLinks', true);
%
% carico le variabili necessarie al modelli Simulink nel wsp base (solo lì va bene)
% fin=length(sModel)-4;   
% sModel=sModel(1:fin);
% step_time_mod=get_param(sModel,'FixedStep');
%     
tLoad = load(sWsp);
% tLoad.step_time_mod=get_param(sModel,'FixedStep');
% save(sWsp);
assignin2('base', tLoad)

return

function [] = ReferencedModelReplacement(sModel)

%%% sostituisce i modelli reference presenti nel modello da compilare con
%%% sottostistemi atomici
%%% La sostituzione è necessaria perchè altrimenti RSIM compila il modello
%%% di base più i modelli reference in un eseguibile bisognoso della
%%% licenza Simulink (forza i solutori di simulink e non quelli di RTW).
%%% Attenzione: la corrispondenza tra i parametri del modello reference e
%%% il wsp di base verrà persa, pertanto il modello reference prenderà le
%%% sue variabili direttamente dal wsp di base (non posso istanziare più volte con
%%% parametri diversi lo stesso modello reference)

% cerco modelli reference
cModRef = find_system(sModel, 'FollowLinks', 'on', 'blocktype', 'ModelReference');
if ischar(cModRef)
    cModRef{1} = cModRef;
end

%
% ciclo sui modelli reference
for j = 1:length(cModRef);
    % apertura modello referenced
    sModRef = cModRef{j};
    hModRef = get_param(sModRef, 'handle');
    sModRefName = get_param(sModRef, 'ModelName');
    sPar = get_param(sModRef, 'parent');
    hPar = get_param(sPar, 'handle');
    open_system(sPar)
    open_system(sModRefName)
    
    % aggiungo il sottosistema che dovrà rimpiazzare il modello reference
    hNewSubsys = add_block('built-in/SubSystem', [sPar, '/modelReference_',sModRefName]);
    set_param(hNewSubsys, 'TreatAsAtomicUnit', 'on');
    
    % cancello il contenuto del sottosistema
    Simulink.SubSystem.deleteContents(hNewSubsys)
    
    % copio il contenuto del modello reference nel nuovo sottosistema
    Simulink.BlockDiagram.copyContentsToSubSystem(sModRefName, hNewSubsys)  
    
    % cancello il link al modello reference
    tLH = get_param(sModRef, 'LineHandles');
    tPC = get_param(sModRef, 'PortConnectivity');
    tPH = get_param(sModRef, 'PortHandles');
    tPHnew = get_param(hNewSubsys, 'PortHandles');
    
    % cancello le connessioni vecchie
    hAllOldLines = [tLH.Inport, tLH.Outport];
    delete_line(hAllOldLines);
    
    %%% aggiungo le connessioni nuove di ingresso
    for k0 = 1:length(tPH.Inport)
        % ricerco in port connectivity la porta corrispondente al ciclo
        % esterno
        for l = 1:length(tPC)
            if strcmpi(tPC(l).Type, num2str(k0)) && not(isempty(tPC(l).SrcBlock))
                k = l;
                break
            end
        end
        % sorgente
        hSourceBlock = tPC(k).SrcBlock;
        nPort = tPC(k).SrcPort+1;
        tPHSource = get_param(hSourceBlock, 'PortHandles');
        hSourcePort = tPHSource.Outport(nPort);
        % destinazione
        hDestPort = tPHnew.Inport(k0);
        % aggiungo la linea
        add_line(hPar, hSourcePort, hDestPort)
    end
    
    %%% aggiungo le connessioni nuove di uscita
    for k0 = 1:length(tPH.Outport)
        % ricerco in port connectivity la porta corrispondente al ciclo
        % esterno
        for l = 1:length(tPC)
            if strcmpi(tPC(l).Type, num2str(k0)) && not(isempty(tPC(l).DstBlock))
                k = l;
                break
            end
        end
        % sorgente
        hSourcePort = tPHnew.Outport(k0);
        % destinazione
        hDestBlock = tPC(k).DstBlock;
        nPort = tPC(k).DstPort+1;
        tPHDest = get_param(hDestBlock, 'PortHandles');
        hDestPort = tPHDest.Inport(nPort);
        % aggiungo la linea
        add_line(hPar, hSourcePort, hDestPort)
    end
    
    % posiziono il sottosistema al posto del link al model reference
    set_param(hNewSubsys, 'Position', get_param(sModRef, 'Position'));
    
    % mask the copy of the referenced model, to emulate the replacement of
    % the variables
    sVarNames = get(hModRef, 'ParameterArgumentNames');
    if ~isempty(sVarNames)
        sValNames = get(hModRef, 'ParameterArgumentValues');
        cVars = stringDivide(sVarNames, ',');
        cVals = stringDivide(sValNames, ',');
        slSetMask(hNewSubsys, cVars, cVals);
    end
 
    % cancello il link al modello reference
    delete_block(sModRef)
    
    % chiudo tutti i blocchi su cui ho lavorato
    close_system(sPar)
    close_system(sModRefName)
end

return

 function cToFileNames = ToMatFilenameList(sModel)
% 
% %%% sostituisce i modelli reference presenti nel modello da compilare con
% %%% sottostistemi atomici
% %%% La sostituzione è necessaria perchè altrimenti RSIM compila il modello
% %%% di base più i modelli reference in un eseguibile bisognoso della
% %%% licenza Simulink (forza i solutori di simulink e non quelli di RTW).
% %%% Attenzione: la corrispondenza tra i parametri del modello reference e
% %%% il wsp di base verrà persa, pertanto il modello reference prenderà le
% %%% sue variabili direttamente dal wsp di base (non posso istanziare più volte con
% %%% parametri diversi lo stesso modello reference)
% 
% % cerco modelli reference
% cToFile = find_system(sModel, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'blocktype', 'ToFile');
% if ischar(cToFile)
%     cToFile{1} = cToFile;
% end
% 
% %
% % ciclo sui modelli reference
% cToFileNames = cell(size(cToFile));
% for j = 1:length(cToFile);
%     % apertura modello referenced
%     sToFile = cToFile{j};
%     sFileName = get_param(sToFile, 'Filename');
%     [dum, sN] = fileparts(sFileName);
%     cToFileNames{j} = sN;
% end
% 
  return

function Logged_Bus_Outputs(sModel)

 pattern='LB_';
 cTop_level_block = find_system(sModel, 'Type', 'block_diagram');
 sTop_level_block = cTop_level_block{1};
 hTop_level_block = get_param(sTop_level_block, 'handle');

 idx_tot=1;
 NewBlock='built-in/Mux';     %this mux is used to collect all the output signal value in a single signal.
 NewHandle=LocalCheckBuiltIn(NewBlock);
 hMux=add_block(NewHandle,[sTop_level_block,'/Mux_out']); %out

 hOut_mux=add_block('built-in/Outport',[sTop_level_block,'/M_out']); %To connect the MUX to OUTPORT
 in_hOut_mux=get(hOut_mux,'PortHandles');
 in_hMux=get(hMux,'PortHandles');
 add_line(sTop_level_block,in_hMux.Outport,in_hOut_mux.Inport);

 %find all SubSystem in the first level depth.
 hSubsys=find_system(hTop_level_block,'SearchDepth',1,'BlockType','SubSystem');
 KeepSIDOpt={};
 for i=1:length(hSubsys)
     name_subsys=get(hSubsys(i),'Name'); %save the Name of Subsystem for construct the path
     cChild_sys=get(hSubsys(i),'Blocks');
     ind=strncmpi(cChild_sys,pattern,3);%search outport in Blocks with name that  begin with 'LB_' /only accessing to "Blocks" parameters you can view the outport name.
     LB_term=sum(ind);
     if (LB_term > 0)
         ind=find(ind);
         Multiple_term=length(ind);
         for pLB=1:Multiple_term
             cPort_name=cChild_sys(ind(pLB));
             if ~isempty(cPort_name)
                 %search the terminator block connected to LB_ port
                 sPort_name=cPort_name{1};
                 path_log_port=[sTop_level_block,'/',name_subsys,'/',sPort_name];
                 hlog_port = get_param(path_log_port,'handle');   %handle of the outport
                 idx=str2double(get(hlog_port,'Port'));   %the id (Port #) to select outport of subSystem
                 HP=get(hSubsys(i),'PortHandles'); %handles of subsystem in/out ports.
                 hLine=get(HP.Outport(idx),'Line');
                 hTerm=get(hLine,'DstBlockHandle');

                 NewBlock='built-in/BusSelector';       %creation of new block(BusSelector) that will substitute terminator block -the purpose of this is to catch the input signals name of the bus.
                 NewHandle=LocalCheckBuiltIn(NewBlock);
                 a=slInternal('replace_block',hTerm,NewHandle,KeepSIDOpt{:}); %call internal function to substitute block
                 hBusSelector=get_param(a,'handle');
                 sig_logged = get(hBusSelector,'InputSignals');
                 [length_sig_bus,sig_logged_toout]=control_signal_bus(sig_logged,sPort_name); %in this function there is a control of InputSignals because in case of Bus_of_Bus the fild of sig_logged is a struct of cell array.
                 %in the sig_logged_toout output there is the conversion of signal in MATLAB_style.

                 %a=replace_block(hTop_level_block,'BusSelector','Goto','noprompt');
                 NewBlock='built-in/Goto';        %after getting the inputsignals name the bus selector is replaced by a Goto block.
                 NewHandle=LocalCheckBuiltIn(NewBlock);
                 a=slInternal('replace_block',hBusSelector,NewHandle,KeepSIDOpt{:});

                 hGoto=get_param(a,'handle');
                 set(hGoto,'Name',sPort_name);
                 set(hGoto,'GotoTag',sPort_name);

                 idx_out=1; %index for taking into account the possibility to have Bus_of_bus. -> Because in case of Bus_of_Bus we have to work with a struct and not with simply cell array. -> we need to Expand the bus_struct

                 len_in_Mux_out=(length_sig_bus+idx_tot)-1; %%%set number of mux input.
                 set(hMux,'Inputs',num2str(len_in_Mux_out));
                 in_hMux=get(hMux,'PortHandles');

                 if length_sig_bus == 1 %%error if i try to use bus selector because the input is not a bus.
                     hFr(idx_out)=add_block('built-in/From',[sTop_level_block,'/From_',sPort_name,'sigbus',num2str(idx_out)]);
                     hOut(idx_out)=add_block('built-in/Outport',[sTop_level_block,'/',sig_logged_toout{idx_out}]);
                     hmux_single(idx_out)=add_block('built-in/Mux',[sTop_level_block,'/mux_in',num2str(idx_tot)]);
                     set(hmux_single(idx_out),'Inputs','1');
                     
                     set(hFr(idx_out),'GotoTag',sPort_name); %connect to block Goto with TAG
                     out_fr=get(hFr(idx_out),'PortHandles'); %information needed for create line
                     out_hmuxsingle=get(hmux_single(idx_out),'PortHandles');
                     in_hOut=get(hOut(idx_out),'PortHandles'); %information needed for create line
                     
                     add_line(sTop_level_block,out_fr.Outport,out_hmuxsingle.Inport);
                     add_line(sTop_level_block,out_hmuxsingle.Outport,in_hOut.Inport);
                     add_line(sTop_level_block,out_hmuxsingle.Outport,in_hMux.Inport(idx_tot));
                     idx_tot=idx_tot+1;
                 else
                     
                     for j=1:length(sig_logged) %%% generation of an outports for each signal
                         %- For each signal we need FROM block, BusSelector and an Outport with the name of signal to log.
                         
                         hFr(idx_out)=add_block('built-in/From',[sTop_level_block,'/From_',sPort_name,'sigbus',num2str(idx_out)]);
                         hBs(idx_out)=add_block('built-in/BusSelector',[sTop_level_block,'/BS_',sPort_name,'sigbus',num2str(idx_out)]);
                         hOut(idx_out)=add_block('built-in/Outport',[sTop_level_block,'/',sig_logged_toout{idx_out}]);
                         hConv(idx_out)=add_block('built-in/DataTypeConversion',[sTop_level_block,'/double',num2str(idx_tot)]);
                         set(hConv(idx_out),'OutDataTypeStr','double');
                         
                         set(hFr(idx_out),'GotoTag',sPort_name); %connect to block Goto with TAG
                         out_fr=get(hFr(idx_out),'PortHandles'); %information needed for create line
                         in_Bs=get(hBs(idx_out),'PortHandles'); %information needed for create line
                         in_hOut=get(hOut(idx_out),'PortHandles'); %information needed for create line
                         ph_hConv=get(hConv(idx_out),'PortHandles');
                         add_line(sTop_level_block,out_fr.Outport,in_Bs.Inport);
                         inp_sig_bs = get(hBs(idx_out),'InputSignals'); %after the connection between From block with BusSelector, we can get the InputSignals.
                         %add control
                         str=inp_sig_bs{j};    %%%%in case of struct of cell array, we have to expand all the signals in the struct
                         if iscell(str)
                             name_bus_in=str{1};
                             name_sig=str{2};
                             length_B_of_B = length(str{2});
                             
                             for k=1:length_B_of_B
                                 cnt=name_sig{k}; %%% control in the case of 3level depth
                                 if ~iscell(cnt)
                                     str=[name_bus_in,'.',name_sig{k}]; %%%difference with OUTPUT string -> for bus functionality we need '.'
                                     if (k==1 || fl==1) %because the blocks for generate the output are already created
                                         fl=0;
                                         set(hBs(idx_out),'OutputSignals',str);
                                         in_Bs=get(hBs(idx_out),'PortHandles');
                                         add_line(sTop_level_block,in_Bs.Outport,in_hOut.Inport); %connect out of bs with out
                                         add_line(sTop_level_block,in_Bs.Outport,ph_hConv.Inport); %connect out of bs with double conv
                                         add_line(sTop_level_block,ph_hConv.Outport,in_hMux.Inport(idx_tot)); %connect double conv with Mux idx_tot index
                                         idx_tot=idx_tot+1;
                                         idx_out=idx_out+1;
                                     else
                                         hFr(idx_out)=add_block('built-in/From',[sTop_level_block,'/From_',sPort_name,'sigbus',num2str(idx_out)]);
                                         hBs(idx_out)=add_block('built-in/BusSelector',[sTop_level_block,'/BS_',sPort_name,'sigbus',num2str(idx_out)]);
                                         hOut(idx_out)=add_block('built-in/Outport',[sTop_level_block,'/',sig_logged_toout{idx_out}]);
                                         hConv(idx_out)=add_block('built-in/DataTypeConversion',[sTop_level_block,'/double',num2str(idx_tot)]);
                                         set(hConv(idx_out),'OutDataTypeStr','double');
                                         
                                         set(hFr(idx_out),'GotoTag',sPort_name); %connect to block Goto with TAG
                                         out_fr=get(hFr(idx_out),'PortHandles');
                                         in_Bs=get(hBs(idx_out),'PortHandles');
                                         in_hOut=get(hOut(idx_out),'PortHandles');
                                         ph_hConv=get(hConv(idx_out),'PortHandles');
                                         add_line(sTop_level_block,out_fr.Outport,in_Bs.Inport);
                                         set(hBs(idx_out),'OutputSignals',str);
                                         in_Bs=get(hBs(idx_out),'PortHandles');
                                         add_line(sTop_level_block,in_Bs.Outport,in_hOut.Inport);
                                         add_line(sTop_level_block,in_Bs.Outport,ph_hConv.Inport);
                                         add_line(sTop_level_block,ph_hConv.Outport,in_hMux.Inport(idx_tot));
                                         idx_tot=idx_tot+1;
                                         idx_out=idx_out+1;
                                     end
                                 else
                                     if k==1
                                         fl=1;
                                     end
                                 end
                             end
                         else
                             set(hBs(idx_out),'OutputSignals',str); %select signal to put out
                             in_Bs=get(hBs(idx_out),'PortHandles');
                             add_line(sTop_level_block,in_Bs.Outport,in_hOut.Inport); %add connection between BusSelector output and Outport.
                             add_line(sTop_level_block,in_Bs.Outport,ph_hConv.Inport);
                             add_line(sTop_level_block,ph_hConv.Outport,in_hMux.Inport(idx_tot));
                             idx_tot=idx_tot+1;
                             idx_out=idx_out+1;
                             
                         end
                     end
                 end
             end
         end
     end
 end
 return

function NewHandle=LocalCheckBuiltIn(NewHandle)

if ~strcmp(NewHandle,'built-in/Subsystem'),
  try
    ValidHandle=get_param(NewHandle,'handle');
  catch E %#ok (E unused)
    ValidHandle=[];
  end

  if isempty(ValidHandle),
    NewHandle={};
  end % if
end % if ~strcmp

function [index,sig_logged_toout]=control_signal_bus(sig_logged,name_outport)
%case of bus_of_bus
index=1; %to add items in sig_logged_toout
for i=1:length(sig_logged)
    str=sig_logged{i};
    if iscell(str) %if str after the transformation in string is still a cell, it means that it's a structure -> (bus_input)
        name_bus_in=str{1};
        name_sig=str{2};
        length_B_of_B = length(str{2});
        
        for j=1:length_B_of_B    %for each signal of the bus_input
            cnt=name_sig{j}; %%% control in the case of 3level depth
            if ~iscell(cnt)
                str=name_sig{j};
                %str=[name_bus_in,'_',name_sig{j}];
                [sStr_to_log] = smkModelConvertSignalName(str,0); %conversion of signal name accepted by matlab. signal_name= S_signame_u_UM
                cStr_to_log={[name_outport,'_',name_bus_in,'_',sStr_to_log]}; %final output form of signal name: LB_NAMEArea_signalName
                sig_logged_toout(index)=cStr_to_log;
                index=index+1;
            end
        end
    else
        [sStr_to_log]=smkModelConvertSignalName(str,0);     
        cStr_to_log={[name_outport,'_',sStr_to_log]};
        sig_logged_toout(index)=cStr_to_log;
        index=index+1;
    end 
end
index=index-1;
return

function [sStr_to_log]=smkModelConvertSignalName(str,sign_for_gof)
pattern='_u';
start_sign='S_';
correspondence={'rad/s' 'rad_s';...
                'km/h' 'km_h';...
                'm/s' 'm_s';...
                'rad/s^2' 'rad_s2';...
                'm/s^2' 'm_s2';...
                'm/s^3' 'm_s3';...
                'm^2/s' 'm2_s';...
                'mm^2/s' 'mm2_s';...
                'Pa*s' 'Pa_s';...
                '°C' 'degC';...
                'J/kgK' 'J_kgK';...
                'kJ/kgK' 'kJ_kgK';...
                'W/m^2K' 'W_m2K';...
                'W/mK' 'W_mK';...
                'W/m2' 'W_m2';...
                '%' 'perc';...
                '1/h' '1_h';...
                'Mp/s' 'Mp_s';...
                '1/s' '1_s';...
                'g/s' 'g_s';...
                'g/h' 'g_h';...
                'kg/s' 'kg_s';...
                'kg/h' 'kg_h';...
                'mm^3' 'mm3';...
                'cm^3' 'cm3';...
                'dm^3' 'dm3';...
                'm^3' 'm3';...
                'mm^3/s' 'mm3_s';...
                'cm^3/s' 'cm3_s';...
                'dm^3/s' 'dm3_s';...
                'm^3/s' 'm3_s';... 
                'mm^3/h' 'mm3_h';...
                'cm^3/h' 'cm3_h';...
                'dm^3/h' 'dm3_h';...
                'm^3/h' 'm3_h';... 
                'g/l' 'g_l';...
                'g/m^3' 'g_m3';...
                'g/m3' 'g_m3';...
                'kg/m^3' 'kg_m3';...
                'kg/m3' 'kg_m3';...
                'Mp/m^3' 'Mp_m3';...
                'mm^2' 'mm2';...
                'cm^2' 'cm2';...
                'dm^2' 'dm2';...
                'm^2' 'm2';...
                'J/Kg' 'J_Kg';...
                'MJ/Kg' 'MJ_Kg';...
                'l/km' 'l_km';...
                'l/100km' 'l_100km';...
                'g/km' 'g_km';...
                'Km/l' 'Km_l';...
                'g/kWh' 'g_kWh';...
                'g/CVh' 'g_CVh';...
                'mg/cc' 'mg_cc';...
                'rpm/s' 'rpm_s';...
                'Nm^05/rpm' 'Nm05_rpm';...
                '0/1' '0_1'};
            
            if ~sign_for_gof
                space_idx=find(isspace(str),1,'last'); %%%last space
                if ~isempty(space_idx)
                    str(length(str))=[];
                    UM=str((space_idx+2):length(str));
                    str([space_idx:length(str)])=[];%% in str nome signal without UM
                    if UM ~= '-'
                        idx_um=strcmpi(UM,correspondence(:,1));
                        corr=correspondence(idx_um,2);
                        if ~isempty(corr)
                            UM=corr;
                            UM=UM{1};  
                        end
                        sStr_to_log=['S_',str,pattern,'_',UM];
                    else
                        sStr_to_log=['S_',str,pattern];
                    end
                else
                    sStr_to_log=['S_',str,pattern];
                end
            else%%%%%%%%%%%%%%%%%%conv_to_gofast
                k=strfind(str,start_sign);
                if ~isempty(k)
                    str([1:k+1])=[];
                     k=strfind(str,pattern);
                     UM=str([k+2:length(str)]);
                     str(k:length(str))=[];
                     if ~isempty(UM)%%%segnale con unità di misura
                         UM(1)=[];
                         idx_um=strcmpi(UM,correspondence(:,2));
                         corr=correspondence(idx_um,1);
                         if ~isempty(corr)
                             UM=corr;
                             UM=UM{1};
                         end
                         sStr_to_log=[str,' [',UM,']'];
                     else
                         sStr_to_log=str; 
                     end
                end
            end
return
