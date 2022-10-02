function deploySmkModel_ModRef_vs3()
%
% compila i modelli Simulink selezionati da interfaccia.
% La compilazione è effettuata mediante RSIM.tlc secondo le modalità
% consuete di impiego per SimuDynS.
% Prima della compilazione viene forzato l'aggiornamento delle variabili
% tunable a tutte quelle a cui il modello fa riferimento dal workspace
% Per ogni modello da compilare deve esistere nella directory corrente
% un file da cui estrarre le variabili da tunare dal nome
% "wsp_modelName.mat"


% promemoria di modelli e relativi file di workspace da cui trarre le
% variabili da tunare
uiwait(msgbox({'Ricorda: ', ''...
        'Ogni modello da compilare deve avere il nome "exe_modelName_open.mdl"','',...
        'Per ogni modello da compilare deve esistere nella directory corrente'...
        'un file da cui estrarre le variabili da tunare dal nome "wsp_modelName.mat"'},...
        'requisiti per compilazione',...
        'modal'));

%
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

%
% memorizzo e cancello il wsp base vecchio 
% tWspBaseOld = wsp2struct('wsp','base');
evalin('base', 'clear') 
%

% ciclo sui modelli da compilare
for i = 1:length(cModelName)
   %
   % apro il modello simulink e lo salvo senza link, lavoro solo su quello
   [sModel, sWsp, sPar, bErr] = modelLoad(cModelName{i});
   if bErr
       continue
   end
   % 
   % sostituzione dei modelli referenced con sottosistemi atomici per la
   % compilazione senza licenza Simulink
   ReferencedModelReplacement(sModel);
   
   cToMatFilenames = ToMatFilenameList(sModel);
   
   % aggiornamento variabili tunable e conversione in oggetti parametro
   cRefVars = refreshTunVars(sModel);
   % tunablevars2parameterobjects(sModel); serve solo se mantengo i sistemi
   % reference nel modello
   
   % settaggi di RSIM
   t_stopMax = 100000;
   set_param(sModel, 'rtwSystemTargetFile', 'rsim.tlc', 'rtwTemplateMakeFile','rsim_default_tmf', ...
                     'RSIM_PARAMETER_LOADING', 'on', 'MatFileLogging', 'on', 'StopTime',num2str(t_stopMax));
   save_system(sModel)
   % compilazione
   rtwbuild(sModel);
   % salvataggio variabili tunable su file
   parameters_Simulation = rsimgetrtp(sModel,'AddTunableParamInfo','on');
   save(sPar, 'parameters_Simulation', 'cToMatFilenames')
   %
   close_system(sModel)
   delete([sModel, cModelExt{i}]) % cancello il modello derivante dall'orginale
   % cancello directory di compilazione del modello specifico
   rmdir([sModel, '_rsim_rtw'],'s')
   if strcmp(sModel(end-3:end),'_sdl') % se modello SimDriveline
      delete(['drive_exe_', sModel(5:end), '_1.c'])
      delete(['drive_exe_', sModel(5:end), '_1.h'])
   end
end
%
% cancello altre directory di compilazione
if isdir('rtwgen_tlc')
   rmdir('rtwgen_tlc','s')
end
if isdir('sfprj')
   rmdir('sfprj','s')
end
%
% ripristino il wsp base originale
evalin('base', 'clear') 
% assignin2('base', tWspBaseOld)
%
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
sModel = ['exe_', sBase];
sWsp = ['wsp_', sBase];
sPar = ['par_', sBase];
% salvo senza link
save_system(sModel0, sModel, 'BreakUserLinks', true);
%
% carico le variabili necessarie al modelli Simulink nel wsp base (solo lì va bene)
tLoad = load(sWsp);
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
    sValNames = get(hModRef, 'ParameterArgumentValues');
    cVars = stringDivide(sVarNames, ',');
    cVals = stringDivide(sValNames, ',');
    slSetMask(hNewSubsys, cVars, cVals);
 
    % cancello il link al modello reference
    delete_block(sModRef)
    
    % chiudo tutti i blocchi su cui ho lavorato
    close_system(sPar)
    close_system(sModRefName)
end

return

function cToFileNames = ToMatFilenameList(sModel)

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
cToFile = find_system(sModel, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'blocktype', 'ToFile');
if ischar(cToFile)
    cToFile{1} = cToFile;
end

%
% ciclo sui modelli reference
cToFileNames = cell(size(cToFile));
for j = 1:length(cToFile);
    % apertura modello referenced
    sToFile = cToFile{j};
    sFileName = get_param(sToFile, 'Filename');
    [dum, sN] = fileparts(sFileName);
    cToFileNames{j} = sN;
end

return