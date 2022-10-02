
function [] = setIsolivelloColoreMedio(hC)
% imposta il colore delle isolivello hC (HGGROUP) al valore medio tra le
% isolivello confinanti (di default il colore è pari a una dei valori di
% isolivello di confine).

hP = findobj(hC,'type','patch');

% raccolta elenco livelli
LevelList = sort(get(hC, 'LevelList'))';
LevelListMax = max(LevelList);
LevelListMin = min(LevelList);

% raccolta colori delle patch
CDataOrg = zeros(size(hP));
for i = 1:length(hP)
    CDataOrg(i) = get(hP(i), 'CData');
end

% setto il colore alla media delle isolivello confinanti
for i = 1:length(hP)
    if CDataOrg(i)> LevelListMin && CDataOrg(i)< LevelListMax
        idx = find(CDataOrg(i)==LevelList);
        if not(isempty(idx))
            idx = idx(1); % TODO: potrebbe essere che trovi più valori??
            set(hP(i), 'CData', mean([LevelList(idx), LevelList(idx+1)]));
        end
    end
end

return