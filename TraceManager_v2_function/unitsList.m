function c = unitsList(tTH, cQ)
% lista delle unità di misura associate ad una certa TH in corrispondenza
% delle grandezze cQ
c = cell(size(cQ));
for i = 1:length(cQ)
    c{i} = tTH.(cQ{i}).u; 
end

return