function cOut = string2cell(sIn, sDel)

% trasforma il cell array di stringhe cIn in una stringa sOut unica separata dal
% delimitatore sDel
% attualmente non considera delimitatori multipli come uno solo

% ricerco delimitatori
sIn = sIn(:)';
posDel = find(int8(sIn) == int8(sDel));

% aggiungo il primo e l'ultimo delimitatore
if isempty(posDel)
    % parola unica
    sIn = [sDel sIn sDel];
else
    % almeno due parole
    if posDel(1) > 1
        sIn = [sDel sIn];
    end
    posDel = find(int8(sIn) == int8(sDel));
    if posDel(end) < length(sIn)
        sIn = [sIn sDel];
    end
end

posDel = find(int8(sIn) == int8(sDel));

% assegno il cell array
Nstrings = length(posDel) - 1;
cOut = cell(Nstrings, 1);
for i = 1:Nstrings
    i1 = posDel(i)+1;
    i2 = posDel(i+1)-1;
    cOut{i} = sIn(i1:i2);
end

return