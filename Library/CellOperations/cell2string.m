function sOut = cell2string(cIn, sDel)

% trasforma il cell array di stringhe cIn in una stringa sOut unica separata dal
% delimitatore sDel

% lunghezza complessiva stringa
L = length(sDel) * (length(cIn)-1);
for j = 1:length(cIn)
    L = L + length(cIn{j});
end
sOut = char(zeros(1,L,'int8'));

% ciclo di assegnazione
idxEnd = 0;
for j = 1:length(cIn)
    idx1 = idxEnd+1;
    if j < length(cIn)
        idxEnd = idx1 + length(cIn{j})  + length(sDel) -1;
        sOut(idx1:idxEnd) = [cIn{j}, sDel];
    else
        idxEnd = idx1 + length(cIn{j}) -1;
        sOut(idx1:idxEnd) = [cIn{j}];
    end
end

return