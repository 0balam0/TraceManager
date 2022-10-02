function provaBarDiagram

% input necessari al grafico
Y = [105 120 136 99 85]; % dati in Y
yLimite = [0 130]; % limite asse Y
cCol = listaColori; % colori per ogni barra
cColors = cCol(1:length(Y));
cLabels = {'vehicle 1', 'veh 2', 'veh 3 with CO2 technologies', 'veh 4', 'veh 5'}; % label delle barre
barWidth = 0.4; % ampiezza barre

% creazione grafico
[hFig, hAx, hP, hT] = barDiagram(Y, cColors, cLabels, barWidth, yLimite);

% fomattazione grarico
set(hAx, 'yTick', [yLimite(1): 10: yLimite(2)]) % spaziatura asse Y
set(hAx, 'FontWeight', 'demi') % marcatura etichette Y
ylabel('CO2 values [g/km]', 'fontweight', 'bold', 'fontsize', 12) % etichetta asse Y
% formattazione label delle barre
for i = 1:length(hT)
    set(hT(i), 'fontweight', 'bold')
end

return