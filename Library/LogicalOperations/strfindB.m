function bF = strfindB(cText,cPattern)
% bF = strfindB(cText,cPattern) ("boolean") controlla le ricorrenze di
% cPattern nella matrice o vettore cText, dando in uscita una matrice
% booleana delle dimensioni di cText che indica se la ricorrenza è stata
% trovata o no.   
%
% Se cPattern è un cell array, la funzione dà true per l'elemento cText{i,j}
% se cText{i,j} contiene almeno una ricorrenza fra tutti gli elementi
% specificati in cPattern. 
%
% ex:  strfindB({'11','22','21'},'2') dà [0 1 1]
% ex:  strfindB({'11','22','21'},{'2','1'}) dà [1 1 1]

% controllo sulle classi di dati in ingresso
if ischar(cText)
    cText = {cText};
end
if ischar(cPattern)
    cPattern = {cPattern};
end
if not(iscell(cText)) || not(iscell(cPattern))
    disp('strfindB: errore sulle classi di dati in ingresso')
    return
end
% cicli sulle dimensioni di cText e cPattern
[r,c] = size(cText);
bF = false(r,c);
for i = 1:r
    for j = 1:c
        % controllo se strfind trova una ricorrenza fra quelle di cPattern in cText{i,j}
        bF(i,j) = trovaAlmeno1(cText{i,j},cPattern);
    end
end

return

function b = trovaAlmeno1(sText,cPattern)
[r,c] = size(cPattern);
b = false;
for i = 1:r
    for j = 1:c
        if not(isempty(strfind(sText,cPattern{i,j})))  
            b = true;
            return
        end
    end
end
return