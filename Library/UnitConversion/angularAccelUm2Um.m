function [zOut_d, bSupp, cUMsupp] = angularAccelUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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
cSin = {'rad/s^2', 'rad/s2';...
        'rpm/s', 'rpm/s'};
cStd = {'rad/s^2';...
        'rpm/s'};
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
cUMsupp = {'rad/s^2', 'rpm/s'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da lb a kg
k_rad2rev = rad2rev(1);

%%% unifico la grandezza in ingresso
% porto in rpm
switch sUMin
    case 'rpm/s'
        k = 1;
    case 'rad/s^2'
        k = 60*k_rad2rev;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'rpm/s'
        k = 1;
    case 'rad/s^2'
        k = 1/(k_rad2rev*60);
end
zOut_d = zIn_d * k;


return
%

