function [cVarIn, cVarOut, cVarTot] = getScriptInfo(cScript, sWsp, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% selezione script
%
% controllo cosa ho inserito come argomento cScript
if ischar(cScript)
    cScript = {cScript};
end
if isempty(cScript{1})
    cScript = {};
end
% selezione manuale degli scripts
if isempty(cScript)
    [cScript, sPathScript] = uigetfile({'*.m;*.p'}, 'Select scripts...', 'MultiSelect', 'on');
    if ischar(cScript)
        cScript = {cScript};
    end
    % tolgo estensione per esecuzione
    for i = 1:length(cScript)
        [dum, sF] = fileparts(cScript{i});
        cScript{i} = sF;
    end
else
    [sPathScript] = fileparts(cScript{1});
end
% cambio dir corrente per esecuzione degli script
sCurrDir = cd;
cd(sPathScript);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% selezione WSP caricamento dati
if isempty(sWsp)
    [sWsp, sPathMat] = uigetfile({'*.mat'}, 'Select workspace...', 'MultiSelect', 'off');
    [sWsp] = fullfile(sPathMat, sWsp);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% gestione varargin
sMultiMode = 'union';
if not(isempty(varargin))
    a = find(strcmpi(varargin, 'MultiMode'));
    sMultiMode = varargin{a+1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ciclo ottenimento infos su scripts
cVarIn = {};
cVarOut = {};
for i = 1:length(cScript)
    [cVarIn0, cVarOut0] = getScriptInfoBase(cScript{i}, sWsp);
    % creazione output complessivi
    if i == 1
        cVarIn = cVarIn0;
        cVarOut = cVarOut0;
    else
        switch sMultiMode
            case 'union'
               cVarIn = union(cVarIn, cVarIn0); 
               cVarOut = union(cVarOut, cVarOut0); 
            case 'intersect'
               cVarIn = intersect(cVarIn, cVarIn0); 
               cVarOut = intersect(cVarOut, cVarOut0); 
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cVarTot{nome funzione, nomeVar, {'in'/out}}
Lin = size(cVarIn,1);
Lout = size(cVarOut,1);
cVarTot = cell(Lin + Lout, 3);
cVarTot(:,1) = {cScript{1}};
if Lin > 0
    cVarTot(1:Lin,2) = cVarIn;
    cVarTot(1:Lin,3) = {'in'};
end
if Lout > 0
    cVarTot(Lin+1:end,2) = cVarOut;
    cVarTot(Lin+1:end,3) = {'out'};
end

% ripristino dir corrente
cd(sCurrDir);

return

function [cVarIn, cVarOut] = getScriptInfoBase(sScript, sWsp)

sVarErr = 'firstVariableNeeded';
cVarIn = {};
cVarOut = {};
cWspFnc = {};
iLoop = 0;

while not(isempty(sVarErr))
    iLoop = iLoop+1;
    if iLoop == 1
        cWspFnc = who;
    end
    try eval(sScript)
        
        
        
        %%% script esegue correttamente
        disp('Script run successfully!')
        
        % variabili di out
        cVarOut = who;
        cVarOut = setdiff(cVarOut, cWspFnc);
        cVarOut = setdiff(cVarOut, cVarIn);
        
        sVarErr = '';
        
    catch ME
        %%% script ha errori 
        
        % determino il nome della variabile mancante
        sErr = ME.message;
        sVarErr = '';
        nApici = 39;
        if length(sErr)>30 && strcmpi(sErr(1:30), 'Undefined function or variable')
            sVarErr = sErr;
            a = find(int8(sVarErr)==nApici);
            varNameMissing = sVarErr(a(1)+1:a(end)-1);
        elseif length(sErr)>28 && strcmpi(sErr(1:28), 'Undefined function or method')
            sVarErr = sErr;
            a = find(int8(sVarErr)==nApici);
            a = a(1:2);
            varNameMissing = sVarErr(a(1)+1:a(end)-1);
        elseif length(sErr)>18 && strcmpi(sErr(1:18), 'Undefined variable')
            sVarErr = sErr;
            varNameMissing = sVarErr(20:length(sErr)-1);
        else
            % casi non gestiti
            disp(ME.message)
            sVarErr = '';
        end
        
        % nome della variabile mancante 
        if not(isempty(sVarErr))
            
            cVarIn = [cVarIn; {varNameMissing}];
            disp(['Input Variable needed: ', varNameMissing])
        end
        
        % carico la variabile mancante dal wsp
        if not(isempty(sVarErr))
            tVar = load(sWsp, varNameMissing);
            c = fieldnames(tVar);
            if isempty(c)
                disp(['variable ', varNameMissing, ' is not within supplied WSP'])
                sVarErr = '';
            else
                assignin2('current', {varNameMissing} , {tVar.(c{1})});
            end
            if iLoop ==1;
                cWspFnc = who;
            end
        end
    end
end


return