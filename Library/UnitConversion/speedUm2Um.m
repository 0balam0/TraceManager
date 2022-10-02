function [zOut_d, bSupp, cUMsupp] = speedUm2Um(zIn_d, sUMin, sUMout, varargin)
 
% bSupp states if requested correction can be correctly supported
% zOut_d is the converted quantity
%
% zIn_d is the quantity to be converted
% sUMin, sUMout are the units

% controllo ingresso vuoto
if isempty(zIn_d)
   zOut_d = zIn_d;
   return
end

% gestione varargin
if not(isempty(varargin)) 
end

% elimino la dipendenza case-sensitive, non dovrebbe dare problemi perchè
% le u.m. sono abbastanza chiare
sUMin = lower(sUMin);
sUMout = lower(sUMout);

%%% sostituzione sinonimi con una sola unità di misura
cSin = {'km/h','kph','kmh';...
        'mph','miph','mi/h'};
cStd = {'km/h';...
        'mph'};
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
cUMsupp = {'mph', 'km/h', 'm/s'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da lb a kg
k_mi2km = mi2km(1);

%%% unifico la grandezza in ingresso
% porto in km/h
switch sUMin
    case 'km/h'
        k = 1;
    case 'm/s'
        k = 3.6;
    case 'mph'
        k = k_mi2km;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'km/h'
        k = 1;
    case 'm/s'
        k = 1/3.6;
    case 'mph'
        k = 1/k_mi2km;
end
zOut_d = zIn_d * k;


return
%

