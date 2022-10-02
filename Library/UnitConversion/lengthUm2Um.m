function [zOut_d, bSupp, cUMsupp] = lengthUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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
s = 'feet';
sStd = 'ft';
if strcmpi(sUMin,s)
    sUMin = sStd;
end
if strcmpi(sUMout,s)
    sUMout = sStd;
end

%%% controllo unità di misura correttamente gestite
% elenco u.m. supportate
cUMsupp = {'km', 'm', 'mm', 'mi','ft', 'inch', 'yd'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da ft a m
k_ft2m = ft2m(1);
% fattore di passaggio da mi a kg
k_mi2km = mi2km(1);
% fattore di passaggio da inch a m
k_inch2m = inch2m(1);
% fattore di passaggio da yd a m
k_yd2m = yd2m(1);


%%% unifico la grandezza in ingresso
% porto in m
switch sUMin
    case 'km'
        k = 1e3;
    case 'm'
        k = 1;
    case 'mm'
        k = 1e-3;
    case 'mi'
        k = 1e3 * k_mi2km;
    case 'ft'
        k = k_ft2m;
    case 'inch'
        k = k_inch2m;
    case 'yd'
        k = k_yd2m;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'km'
        k = 1e-3;
    case 'm'
        k = 1;
    case 'mm'
        k = 1e3;
    case 'mi'
        k = 1/(1e3 * k_mi2km);
    case 'ft'
        k = 1/k_ft2m;
    case 'inch'
        k =  1/k_inch2m;
    case 'yd'
        k =  1/k_yd2m;
end
zOut_d = zIn_d * k;


return
%

