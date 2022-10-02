function [j] = restoIdx(i, L)

% [j] = restoIdx(i, L)
% dà l'indice j di un vettore di lunghezza L che deve essere usato
% ricorsivamente in un ciclo all'iterazione i

j = resto(i,L);

j(j==0) = L;

return