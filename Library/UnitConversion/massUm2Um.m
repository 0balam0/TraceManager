function [zOut_d, bSupp, cUMsupp] = massUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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

%%% sostituzione sinonimi con una sola unità di misura
cSin = {'lb','lb/cc','lb/c';...
        'kg','kg/cc','kg/c';...
        'g','g/cc','g/c';...
        'mg','mg/cc','mg/c'};
cStd = {'lb';...
        'kg';...
        'g';
        'mg'};
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
cUMsupp = cStd;
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da lb a kg
k_lb2kg = lb2kg(1);

%%% unifico la grandezza in ingresso (kg)
% porto in kg/h
switch sUMin
    case 'kg'
        k = 1;
    case 'g'
        k = 1e-3;
    case 'mg'
        k = 1e-6;
    case 'lb'
        k = k_lb2kg;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'kg'
        k = 1;
    case 'g'
        k = 1e3;
    case 'mg'
        k = 1e6;
    case 'lb'
        k = 1/k_lb2kg;
end
zOut_d = zIn_d * k;


return
%

