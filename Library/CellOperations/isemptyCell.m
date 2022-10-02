function bEmpty = isemptyCell(cIn)

bEmpty = true(size(cIn));
for i = 1:length(cIn)
    bEmpty(i) = isempty(cIn{i});
end

return