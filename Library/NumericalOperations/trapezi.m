function [z, zAvg, Dx] = trapezi(x, y, bX)

% [z, zAvg, Dx] = trapezi(x, y, bX)
% calcola l'integrale z e il suo valor medio zAvg della funzione y(x)
% bX è un booleano della lughezza di x che indica i soli intervalli di y 
% da considerare nel calcolo di z e di zAvg;
% Dx è la somma degli intervalli x presi come base per il calcolo del valor
% medio

% integrazione
z = trapz(x, y.*double(bX));
% valor medio
dx = gradient(x);
Dx = sum(dx(bX));
zAvg = z / Dx;

return