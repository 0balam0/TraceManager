function [tTH, warningOut] = completaHistory(tTH, names, tTH_old)
% aggiunta campi v0 e t0 per l'offset verticale della grandezza
% in più aggiungo il campo d (descrizione), non sempre presente
% e i campi colore e label per legenda
extStrInfo = false; %estrai informazioni
warningOut = {}; % warning in output
if nargin == 1
    cF = fieldnames(tTH);
elseif nargin > 1
    if isempty(names) % se è vuota non serve a nulla
        cF = fieldnames(tTH);
    else % se è piena allora sono nomi da normalizzare
        cF = names;
    end
    if nargin == 3
        if ~isempty(tTH_old)
            extStrInfo = true;
        end
    end
end

stdValue = struct('u', '-', 'd', '-', 't0', 0, 'g0', 1, 'color', []);
stdNames = fieldnames(stdValue);

for i = 1:length(cF)
    sF = cF{i};
    for j=1:length(stdNames)
        stdName = stdNames{j};
        if ~isfield(tTH.(sF), stdName) % non esiste il campo allora lo crea
            tTH.(sF).(stdName) = stdValue.(stdName);
        end
    end
    %% casi particolari
    if isempty(tTH.(sF).u) % alcune tTH hanno unit vuoto
        tTH.(sF).u = '-';
    end
    if ~isfield(tTH.(sF), 'old_u')
        tTH.(sF).old_u = tTH.(sF).u;
    end
    if isempty(tTH.(sF).old_u) % alcune tTH hanno unit vuoto % utile quando si caricano configurazioni vecchie
        tTH.(sF).old_u = '-';
    end
    if not(isfield(tTH.(sF), 'label'))
        tTH.(sF).('label') = sF;
    end
    %% Se è stata passata una tTH da cui prendere le informazioni sulla grafica
    if extStrInfo
        if isfield(tTH_old, sF)
            valNames = fieldnames(tTH_old.(sF));
            valNames(strcmp(valNames,'v')) = []; % cancello le informazioni su v
            valNames(strcmp(valNames,'u')) = []; % cancello le informazioni su u 
            valNames(strcmp(valNames,'old_u')) = []; % cancello le informazioni su old_u
            for j=1:length(valNames) 
                tTH.(sF).(valNames{j}) = tTH_old.(sF).(valNames{j});
            end
            if strcmp(valNames,'g0') % se è stato copiato anche il gain allora 
                if str2num(tTH_old.(sF).g0) ~= 1
                    warningOut{end+1} = stprintf('For %s, the gain is copied but not the unit of measure. Check the coherence of the signal!');
                end
            end
        end
    end

end


% atri campi rimossi
%    % nuovo formato a più sample times
%    if not(isfield(tTH.(sF), 'xAxis'))
%       tTH.(sF).('xAxis') = 'time';
%    end
%    if not(isfield(tTH.(sF), 'xAxis_org'))
%       tTH.(sF).('xAxis_org') = 'time';
%    end