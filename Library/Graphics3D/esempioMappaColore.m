function esempioMappaColore()

% grafico delle isolivello
hF = figure;
hA = axes;
z = peaks(30);
contourf(hA, z, 20);

% definisco se voglio la mappa di colore diretta o inversa
bDirect = false;
%%% definisco mappa di colore (codifica [R G B])
% verde (essendo la riga pi� bassa della matrice di colore) � associata ai
% valori pi� bassi delle isolivello
% rosso (essendo la riga pi� alta della matrice di colore) � associata ai
% valori pi� alti delle isolivello 
% giallo intermedio
m = [0 1 0;... % verde
     1 1 0;... % giallo
     1 0 0;... % rosso
     ];
% infittimento mappa
M = interp1(linspace(0,1,size(m,1)), m, linspace(0,1,150)); 
% per mappatura di colore rovesciata ribalto la mappa 
if not(bDirect)
    M = M(end:-1:1,:);
end


% impongo la mappa di colore alla figure
set(hF, 'colormap', M) % � come fare: colormap(M)
% eventuale barra di colore
colorbar


return