function [variable, value] = tData2cell(tData)
% dà in uscita il cell array dei nomi delle variabili e quello dei dati
% della struttura di dati in ingresso "tData"
if isstruct(tData)
    f = fieldnames(tData); 
    if not(isempty(f)) 
        for i=1:length(f)
            variable{i} = f{i};
            value{i} = tData.(f{i});
        end
    else
        bad = true;
    end
else
    bad = true;
end
% gestione casi non attesi
if exist('bad')
    variable = {''};
    value = {[]};
end
return