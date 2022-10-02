function conc_j = massFlow2conc(mf_j,sUmMF_j,mm_j, mf,sUmMF,mm, sUmConcOut)
% OUTPUT:
% conc_j: concentration of j-species
%
% INPUT
% mf_j: mass flow of j-species
% sUmMF_j: units of mass flow of j-species
% mm_j: molecular mass of j-species
% mf: total mass flow
% sUmMF: units of input mass flow
% mm: total average molecular mass
% sUmConcOut: desired output concentration flow units

% stretch scalars to vectors
if numel(mm) == 1
    mm = mm * ones(size(mf_j));
end
if numel(mm_j) == 1
    mm_j = mm_j * ones(size(mf_j));
end
%
% conversion
mf_j = massFlowUm2Um(mf_j, sUmMF_j, sUmMF);
conc_j = mf_j./mf .* mm./mm_j;
conc_j = min(max(0,conc_j),1);
conc_j = relativeUm2Um(conc_j, '-', sUmConcOut);

return