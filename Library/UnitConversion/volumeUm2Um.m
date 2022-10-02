function [zOut_d, bSupp, cUMsupp] = volumeUm2Um(zIn_d, sUMin, sUMout, varargin)
 
% [zOut_d, bSupp] = volumeUm2Um(zIn_d, sUMin, sUMout, varargin)
% 
% bSupp states if requested correction can be correctly supported
% zOut_d is the converted quantity
%
% zIn_d is the quantity to be converted
% sUMin, sUMout are the units

% conversione volumi ad uso consumi su ciclo
% Guenna 14/06/2011

% controllo ingresso vuoto
if isempty(zIn_d)
   zOut_d = zIn_dM;
   return
end

% gestione varargin
if not(isempty(varargin)) 
end

% elimino la dipendenza case-sensitive, non dovrebbe dare problemi perchè
% le u.m. sono abbastanza chiare
sUMin = lower(sUMin);
sUMout = lower(sUMout);

% TODO: v. se esistono sinonimi, in questo caso prendere codice da
% speedUm2Um

%%% sostituzione sinonimi con una sola unità di misura
cSin = {'l', 'dm3', 'lt';...
        'cm^3', 'cm3', 'ml';...
        'm3','m^3','m^3'};
cStd = {'l';
      'ml';
      'm^3'};
for i = 1:length(cStd)
    if any(strcmpi(cSin(i,:), sUMin))
        sUMin = cStd{i};
    end
    if any(strcmpi(cSin(i,:), sUMout))
        sUMout = cStd{i};
    end
end


%%% controllo unità di misura correttamente gestite
% elenco u.m. supportate
cUMsupp = {'l', 'gal', 'm^3', 'ml'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da gal a l, da galloni a litri 
k_gal2lt = gal2lt(1);
% fattore di passaggio da lb a kg
% k_mi2km = mi2km(1);

%%% unifico la grandezza in ingresso
% porto in litri
switch sUMin
    case 'ml'
        k = 1e-3;
    case 'l'
        k = 1;
    case 'gal'
        k = k_gal2lt;
    case 'm^3'
        k = 1e3;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'ml'
        k = 1e3;
    case 'l'
        k = 1;
    case 'gal'
        k = 1 / k_gal2lt;
    case 'm^3'
        k = 1e-3;
end
zOut_d = zIn_d * k;

return
%
