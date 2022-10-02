function mf_j = conc2MassFlow(conc_j,sUmConc,mm_j, mf,sUmMF,mm, sUmMFout)
% OUTPUT: 
% mf_j: mass flow of j-species
%
% INPUT
% conc_j: concetration of j-species
% sUmConc: units of concetration
% mm_j: molecular mass of j-species
% mf: total mass flow
% sUmMF: units of input mass flow
% mm: total average molecular mass
% sUmMFout: desired output mass flow units

% stretch scalars to vectors
if numel(mm) == 1
    mm = mm * ones(size(conc_j));
end
if numel(mm_j) == 1
    mm_j = mm_j * ones(size(conc_j));
end
%
% conversion
conc_j = relativeUm2Um(conc_j, sUmConc, '-');
mf_j = mf .* mm_j./mm .* conc_j;
mf_j = massFlowUm2Um(mf_j, sUmMF, sUmMFout);

return