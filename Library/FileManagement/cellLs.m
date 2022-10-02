function res = cellLs(args)
% Return the result of LS as a cell array

if nargin == 0
    listing = ls();
else
    listing = ls(args);
end

if isempty(listing)
    res = {};
    return;
end

l = length(listing(:,1));
res = cell(l,1);
for i = 1:l
    res{i} = strtrim(listing(i,:));
end