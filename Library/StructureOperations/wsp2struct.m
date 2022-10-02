function tWsp = wsp2struct(varargin)
%
% WSP2STRUCT memorizza in una struttura il workspace della funzione
% chiamante o quello base di Matlab; ammette dei criteri di ricerca
% variabili in base al nome o alla classe di dati che contengono
%
% sintassi:
% tWsp = wsp2struct
% tWsp = wsp2struct('wsp',wspType); 
% tWsp = wsp2struct('classInclude',cDataType); 
% tWsp = wsp2struct('classExclude',cDataType);
% tWsp = wsp2struct('nameInclude',cNameParts);
% tWsp = wsp2struct('nameExclude',cNameParts);
% tWsp = wsp2struct(...) con una combinazione qualunque delle precedenti
%
% esempi:
% sWspType: {'current','base'}
% cDataType: {'double','logical','struct','uint8','cell','char',...}
% cNameParts: {'mod_','tInput_',...}

% scelta tipo di wsp da cui attingere le variabili da salvare in tWsp
bVarargin = not(isempty(varargin));
sWspType = 'current'; % default
if bVarargin
    pos = find(strcmp(varargin,'wsp'))+1;
    if not(isempty(pos))
        sWspType = varargin{pos}; % 'base' o 'current'
    end
end
if strcmp(sWspType,'current')
    sWspType = 'caller'; % il wsp corrente per la funzione chiamante è il quello della funzione chiamante per la funzione corrente
end
% raccolta informazioni sul wsp da salvare
tWhos = evalin(sWspType,'whos'); % campi: name, size, bytes, class, global, sparse, complex, nesting
if isempty(tWhos)
   tWsp = struct([]);
   return
end
% scelta variabili da includere in base alla classe
bC = true(length(tWhos),1);
cDataType = {};
if bVarargin
    pos = find(strcmp(varargin,'classInclude'))+1;
    if not(isempty(pos))
        cDataType = varargin{pos};
    end
end
if not(isempty(cDataType))
    for i=1:length(tWhos)
        if sum(strcmp(tWhos(i).('class'),cDataType)) >= 1;
            bC(i) = true;
        else
            bC(i) = false;
        end
    end
end
% scelta variabili da escludere in base alla classe
cDataType = {};
if bVarargin
    pos = find(strcmp(varargin,'classExclude'))+1;
    if not(isempty(pos))
        cDataType = varargin{pos};
    end
end
if not(isempty(cDataType))
    for i=1:length(tWhos)
        if sum(strcmp(tWhos(i).('class'),cDataType)) >= 1;
            bC(i) = false;
        else
            bC(i) = true;
        end
    end
end
% scelta variabili da includere in base al nome
cNameParts = {};
bN = true(length(tWhos),1);
if bVarargin
    pos = find(strcmp(varargin,'nameInclude'))+1;
    if not(isempty(pos))
        cNameParts = varargin{pos};
    end
end
if not(isempty(cNameParts))
    for i=1:length(tWhos)
        bN(i) = false;
        for j=1:length(cNameParts)
            if not(isempty(strfind(tWhos(i).name,cNameParts{j})))
                bN(i) = true;
                break
            end
        end
    end
end
% scelta variabili da escludere in base al nome
cNameParts = {};
if bVarargin
    pos = find(strcmp(varargin,'nameExclude'))+1;
    if not(isempty(pos))
        cNameParts = varargin{pos};
    end
end
if not(isempty(cNameParts))
    for i=1:length(tWhos)
        bN(i) = true;
        for j=1:length(cNameParts)
            if not(isempty(strfind(tWhos(i).name,cNameParts{j})))
                bN(i) = false;
                break
            end
        end
    end
end
% creazione della struttura di out
bVar = bC & bN; % variabili (comuni ai criteri di ricerca)da memorizzare nella struttura
for i=1:length(tWhos)
    if bVar(i)
        sVarName = tWhos(i).name;
        sVarNameValid =  validField(sVarName, '_');
        tWsp.(sVarNameValid) = evalin(sWspType,sVarName);
    end
end

return




