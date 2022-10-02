function bFound = findFirstStrInCell(cIn, s)

% looks into cell array of strings "cIn" if each of its strings begins with string
% "s"

bFound = false(size(cIn));
for i = 1:length(cIn)
    sIn = cIn{i};
    if isempty(sIn)
        continue
    end
    if length(sIn)<length(s)
        continue
    end
    bFound(i) = strcmp(sIn(1:length(s)), s);
end


return