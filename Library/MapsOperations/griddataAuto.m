function [xI,yI,zI] = griddataAuto(xSc,ySc,zSc,nx,ny)
%%% griddata automatico: dà in out matrice ZI asociata ai vettori xI e yI,
%%% di dimensioni nx e ny a partire dai dati sparsi xSc, ySc e zSc
%%% griddata ha in ingresso dati normalizzati xè così è più robusto nella
%%% generazione dell'out
minXSc = min(xSc); % minimi e massimi dei 3 vettori di dati sparsi
maxXSc = max(xSc);
minYSc = min(ySc);
maxYSc = max(ySc);
minZSc = min(zSc);
maxZSc = max(zSc);
xI = linspace(minXSc,maxXSc,nx); % vettori infittiti
yI = linspace(minYSc,maxYSc,ny);
xNormSc = interp1([minXSc maxXSc], [0 1], xSc); % normalizzazione fra 0 e 1 di ogni vettore di dati sparsi 
yNormSc = interp1([minYSc maxYSc], [0 1], ySc);
zNormSc = interp1([minZSc maxZSc], [0 1], zSc);
xNormI = interp1([minXSc maxXSc], [0 1], xI); % vettori infittiti normalizzati
yNormI = interp1([minYSc maxYSc], [0 1], yI);
zG = griddata(xNormSc,yNormSc,zNormSc,xNormI',yNormI)';
zI = interp1([0 1], [minZSc maxZSc], zG);
return
%