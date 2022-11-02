function c = upgradeUnitsList(tTH) 
% fornisce tutte le unità di misura disponibili fra i vari files letti
% elenco unità disponibili
c = {''};
cF = fieldnames(tTH);
for i = 1:length(cF)
    %
    [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTH.(cF{i}));
    cQ = union(cQint, cQorg);
    %
    cFU = unitsList(tTH.(cF{i}), cQ);
    c = union(c, cFU);
end
%
% aggiorno la lista
c = c(not(strcmpi(c, '')));
c = c(not(strcmpi(c, ' ')));
cDef = {'(no filter)'; '(empty)'};
c = [cDef; c];
return