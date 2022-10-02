function t2D = struct3Dto2Dsel(t3D, page)

% INPUT: 
% t3D: struct 1x1
% page: fetta della 3D desiderata: 
%
% OUTPUT
% t2D: struct 1x1
%
% Trasforma le matrici 3D di t3D in matrici 2D in t2D (se ci sono, se le aspetta
% all'interno del campo "v"), e lascia inalterato il resto
% esempio:
% t2D.var.v = t3D.var.v(:,:, page)


t2D = t3D;
flds = fields(t3D);
% ciclo sui campi
for q = 1:length(flds)
    fld = flds{q};
    var = t3D.(fld);
    if isfield(var,'v')
        if length(size(var.v))==3
            % prendo la fetta desiderata della matrice 3D
            var.v = var.v(:,:,page);
        end
    end
    t2D.(fld) = var;
end

return