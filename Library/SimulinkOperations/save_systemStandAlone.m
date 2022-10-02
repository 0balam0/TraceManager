function save_systemStandAlone(varargin)

% model names
sModel = '';
sModelNew = '';
if not(isempty(varargin))
   switch length(varargin)
       case 2
           sModel = varargin{1};
           sModelNew = varargin{2};
       case 1
           sModel = varargin{1};
   end
end


% model selection
if isempty(sModel)
    % model selection
    [filename] = uigetfile({'*.mdl','Simulink model (*.mdl)';'*.slx','Simulink model (*.slx)'}, 'select model to be saved', 'MultiSelect','off');
    if isnumeric(filename) && filename==0 % se premo "annulla"
        return
    end
    [sPath, sModel, sExt] = fileparts(filename);
end

% new model name
if isempty(sModelNew)
    [filename] = uiputfile({'*.mdl','Simulink model (*.mdl)';'*.slx','Simulink model (*.slx)'}, 'select new model name');
    if isnumeric(filename) && filename==0 % se premo "annulla"
        return
    end
    [sPath, sModelNew, sExt] = fileparts(filename);
end

% temporary file name
sModelTmp = [sModelNew, '_tmp'];

open_system(sModel);
% save w/o links
save_system(sModel, sModelTmp, 'BreakUserLinks', true);
% replace referenced models
ReferencedModelReplacement(sModelTmp);
% save w/o again (the copy/paste of referenced models can bring to model
% new linked blocks)
% TODO: should be done in recursion mode
save_system(sModelTmp, sModelNew, 'BreakUserLinks', true);
% close new file
close_system(sModelNew)
% delete temporary file
delete([sModelTmp, sExt])

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
 
    % cancello il link al modello reference
    delete_block(sModRef)
    
    % chiudo tutti i blocchi su cui ho lavorato
    close_system(sPar)
    close_system(sModRefName)
end

return
