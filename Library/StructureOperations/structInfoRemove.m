function tOut = structInfoRemove(tIn)

% INPUT: 
% tIn struct 1x1
% 
% OUTPUT: 
% tOut struct 1x1
%
% Toglie la presenza dei sottocampi "v", se presenti: alloca il contenuto
% nel "parent field", e rimuove la presenza di eventuali altri sottocampi
% oltre a "v"
tOut = struct();

flds = fieldnames(tIn);
if isempty(flds)
    return
end

for q = 1:length(flds)
    fld = flds{q};
    var = tIn.(fld);
    if isfield(var,'v')
        var = var.v;
    end
    tOut.(fld) = var;
end

return