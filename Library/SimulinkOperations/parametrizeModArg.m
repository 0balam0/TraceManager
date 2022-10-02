function parametrizeModArg(varargin)

%%% gestione varargin
cModelName = {''};
cWspName = {''}; 
if not(isempty(varargin))
    %
    % selezione modelli
    cModelName = varargin{1};
    %
    % workspace di caricamento variabili
    a = find(strcmpi('wspFile', varargin));
    if any(a)
        cWspName = varargin{a+1};
    end
end
% trasformazione in cell arrays
if ischar(cModelName)
    cModelName = {cModelName};
end
if ischar(cWspName)
    cWspName = {cWspName};
end


%%% evenuale selezione manuale
if isempty(cModelName{1})
    
    %%% modelli
    [filename] = uigetfile({'*.mdl','modelli Simulink (*.mdl)';'*.slx','modelli Simulink (*.slx)'}, 'seleziona i modelli', 'MultiSelect','on');
    if isnumeric(filename) && filename==0 % se premo "annulla"
        return
    end
    % cell array dei modelli
    if ischar(filename) 
        filename = {filename};
    end
    % tronco l'estensione mdl
    cModelName = cell(length(filename),1);
    for i = 1:length(filename)
        cModelName{i} = filename{i}(1:end-4);
    end
    
    %%% workspace di caricamento variabili
    [filename] = uigetfile({'*.mat','workspace per modelli Simulink (*.mat)'}, 'seleziona i workspace', 'MultiSelect','on');
    if isnumeric(filename) && filename==0 
        % se premo "annulla" uso il wsp con lo stesso nome del modello
        % (default)
        filename = cModelName;
        for i = 1:length(cModelName)
            filename{i} = [filename{i}, '.mat'];
        end
    end
    % cell array dei modelli
    if ischar(filename) 
        filename = {filename};
    end
    % tronco l'estensione mat
    cWspName = cell(length(filename),1);
    for i = 1:length(filename)
        cWspName{i} = filename{i}(1:end-4);
    end
end

% se ho tanti modelli che attingono da un wsp unico, lo posso fare
if length(cModelName)>1 && length(cWspName)==1
    for i  = 1:length(cModelName)
        cWspName{i} = cWspName{1};
    end
end

%
% memorizzo e cancello il wsp base vecchio 
tWspBaseOld = wsp2struct('wsp','base');
evalin('base', 'clear') 
%

% ciclo sui modelli da compilare
for i = 1:length(cModelName)
   %
   
   % apro il modello simulink (vari comandi basati su get_param lo richiedono)
   sModel = cModelName{i};
   open_system(sModel)
   %
   % carico le variabili necessarie ai modelli Simulink nel wsp base (solo lì va bene)
   sFileWspMod = sModel; % file per salvataggio wsp modello
   tLoad = load(cWspName{i});
   assignin2('base', tLoad)
   % 
   % TODO: che succede se ho fatto un modello di un modello??
%    % cerco modelli reference
%    cModRef = find_system(sModel, 'FollowLinks', 'on', 'blocktype', 'ModelReference');
%    if ischar(cModRef)
%        cModRef{1} = cModRef;
%    end
   %
   % handle al wsp del modello
   hModel = get_param(sModel, 'handle');
   hws = get(hModel, 'modelworkspace');
   
   % estrazione variabili di cui il modello ha bisogno dal workspace (lo
   % forzo a prenderle dal wsp perchè cancello il wsp del modello)
   hws.clear;
   set(hModel, 'ParameterArgumentNames', '')
   %
   cRefVars = getReferencedWSVars(sModel);
   cRefVars = removeStructVars(cRefVars, tLoad);
   [cRefVars] = sort(cRefVars);
   %
   % extract information about which variables will not be tuned
   % written in <CONSTANT> section
   cConst = extractConstantNames(hModel);

   % removes constants from list of variables to be tuned
   cRefVarsArg = setdiff(cRefVars, cConst);
   
   % creazione e assegnazione del workspace del modello
   hws.DataSource = 'Model File'; 
   hws.clear
   for j = 1:length(cRefVarsArg)
       hws.assignin(cRefVarsArg{j}, tLoad.(cRefVarsArg{j}));
   end
   
   % settaggio lista delle variabili tunable, che diventeranno gli argomenti del
   % modello
   sParameterArgumentNames = cell2string(cRefVarsArg,',');
   set(hModel, 'ParameterArgumentNames', sParameterArgumentNames)


%    %
%    TODO: mettere qua dentro i settaggi generali per un modello referenced
%    % settaggi di RSIM
%    t_stopMax = 100000;
%    set_param(sModel, 'rtwSystemTargetFile', 'rsim.tlc', 'rtwTemplateMakeFile','rsim_default_tmf', ...
%                      'RSIM_PARAMETER_LOADING', 'on', 'MatFileLogging', 'on', 'StopTime',num2str(t_stopMax));
   % salvataggio modello
   save_system(sModel)
   close_system(sModel)
   
   % salvataggio wsp del modello su file
   clear tWspMod % per evitare accumulo di campi
   tWspMod = struct();
   for j = 1:length(cRefVars)
       sVar = cRefVars{j};
       tWspMod.(sVar) = tLoad.(sVar); % TODO: pescare la global dal wsp di base
       % tWspMod.(sVar) = evalin('base', sVar);
   end
   save(sFileWspMod, '-struct', 'tWspMod')
  
end
%
% ripristino il wsp base originale
evalin('base', 'clear') 
assignin2('base', tWspBaseOld)
%
return

function cRefVarsOut = removeStructVars(cRefVarsIn, tWsp)

% rimuovo da cRefVars le variabili struttura, che non possono essere
% tunable
cRefVarsOut = cRefVarsIn;
for i = 1:length(cRefVarsIn)
    sVar = cRefVarsIn{i};
    if isstruct(tWsp.(sVar))
        cRefVarsOut{i} = '_';
    end
end
bIdxOk = not(strcmpi(cRefVarsOut, '_'));
cRefVarsOut = cRefVarsOut(bIdxOk);
return

function cConst = extractConstantNames(hModel)

% constant names are currently stored in model description as a list
% identified like:
%
% <CONSTANTS>
% constant1
% constant2
% ...
% </CONSTANTS>

sDescr = get(hModel, 'Description');
cDescr = stringDivide(sDescr, char(10));
idConstStart = find(strcmp(cDescr, '<CONSTANTS>'));
idConstEnd = find(strcmp(cDescr, '</CONSTANTS>'));
cConst = {''};
if ~isempty(idConstStart) && ~isempty(idConstEnd)
    cConst = cDescr(idConstStart:idConstEnd);
end

return
