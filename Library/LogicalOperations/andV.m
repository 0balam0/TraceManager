function bA = andV(bVin)
% Anr logico sugli elementi di un vettore o matrice
% La funzione andV d� true se la matrice (1D o 2D) in ingresso ha tutti
% i suoi elementi true; altrimenti d� false
%
% ex: andV([true false true]) d� false

bV = logical(bVin);
[r,c] = size(bV);
bA = true;
for i = 1:r
    for j = 1:c
        if bV(i,j) == false
            bA = false;
            return
        end
    end
end
return