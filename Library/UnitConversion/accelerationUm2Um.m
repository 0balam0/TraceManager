function [zOut_d, bSupp, cUMsupp] = accelerationUm2Um(zIn_d, sUMin, sUMout, varargin)
 
% bSupp states if requested correction can be correctly supported
% zOut_d is the converted quantity
%
% zIn_d is the quantity to be converted
% sUMin, sUMout are the units

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

% conversion of duplicated units
s = 'm/s2';
sStd = 'm/s^2';
if strcmpi(sUMin,s)
    sUMin = sStd;
end
if strcmpi(sUMout,s)
    sUMout = sStd;
end
% conversion of duplicated units
c = {'ft/s^2','feet/s2','ft/s2'};
sStd = 'feet/s^2';
if any(strcmpi(sUMin,c))
    sUMin = sStd;
end
if any(strcmpi(sUMout,c))
    sUMout = sStd;
end

%%% controllo unità di misura correttamente gestite
% elenco u.m. supportate
cUMsupp = {'m/s^2', 'g', 'feet/s^2', 'mph/s'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da ft a m
k_ft2m = ft2m(1);
% fattore di passaggio da g a m/s^2
k_g2ms2 = g2ms2(1);
% fattore di passaggio da mi a km
k_mi2km = mi2km(1);


%%% unifico la grandezza in ingresso
% porto in m/s^2
switch sUMin
    case 'm/s^2'
        k = 1;
    case 'g'
        k = k_g2ms2;
    case 'feet/s^2'
        k = k_ft2m;
    case 'mph/s'
        k = k_mi2km/3.6;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'm/s^2'
        k = 1;
    case 'g'
        k = 1/k_g2ms2;
    case 'feet/s^2'
        k = 1/k_ft2m;
    case 'mph/s'
        k = 3.6/k_mi2km;
end
zOut_d = zIn_d * k;


return
%