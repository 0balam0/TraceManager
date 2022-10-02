function [A] = ordinaDati(A, col)
% ordina l'insieme di dati contenuti nelle colonne di "A"  sulle colonne 
% indicate nel cell array "col".
% La posizione degli indici di colonna in "col" condiziona la gerarchia 
% nell'ordinamento: chiamata B la parte di A a pari valore di A(col{i},:), 
% l'ordinamento prosegue su B(col{i+1},:) per tutte le B che è possibile 
% identificare (vedi esempio sottostante).
% Come per sortrows, se un indice in "col" è negativo, l'ordinamento 
% della relativa colonna sarà decrescente, altrimenti crescente.
%
% ex: 
% giri =  [2000 2000 2000 1000 1000 1000]';
% pme =   [0    20   10   9    1    4]';
% T_turb =[150  700  500  400  170  300]';
% A = [giri, pme, T_turb];
% A = ordinaDati(A, {1,2});

[A] = ordinaMatrice(A, col, 1);
return

function [M] = ordinaMatrice(M, col, iCol)
%
if iCol<=length(col)
    % ordino la matrice in ingesso
    [M, idx] = sortrows(M,col{abs(iCol)});
    r = size(M,1);
    % indici dei pari valori della colonna corrente da ordinare
    ID = [1; find(diff(M(:,abs(col{abs(iCol)}))))+1; r+1]; 
    % ciclo di ordinamento sulle sottomatrici a pari valore della colonna
    % corrente da ordinare
    for i=1:length(ID)-1
        % sottomatrice da ordinare sulla colonna successiva
        sM = M(ID(i):ID(i+1)-1,:); 
        % ordinamento della sottomatrice in base alla colonna successiva
        [sM] = ordinaMatrice(sM, col, iCol+1);
        % unione della sottomatrice ordinata a quella da cui è stata
        % estratta
        M(ID(i):ID(i+1)-1,:) = sM;
    end
end

return

