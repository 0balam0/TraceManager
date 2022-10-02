function [zOut_d, bSupp, cUMsupp] = pressureUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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
cSin = {'kgcm2', 'kgcm^2', 'kg/cm^2', 'kg/cm2', 'at';...
        'hPa',   'mbar',   '',        '',       ''};
cStd = {'at';...
        'mbar'};
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
cUMsupp = {'bar', 'mbar', 'Pa', 'at', 'atm', 'psi','kPa'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattori di passaggio
k_atm2bar = atm2bar(1);
k_at2bar = at2bar(1);
k_psi2bar = psi2bar(1);

%%% unifico la grandezza in ingresso
% porto in bar
switch sUMin
    case 'bar'
        k = 1;
    case 'mbar'
        k = 1e-3;
    case lower('kPa')
        k = 1e-2;
    case lower('Pa')
        k = 1e-5;
    case 'at'
        k = k_at2bar;
    case 'atm'
        k = k_atm2bar;
    case 'psi'
        k = k_psi2bar;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'bar'
        k = 1;
    case 'mbar'
        k = 1 / 1e-3;
    case lower('Pa')
        k = 1 / 1e-5;
    case lower('kPa')
        k = 1 / 1e-2;
    case 'at'
        k = 1 / k_at2bar;
    case 'atm'
        k = 1 / k_atm2bar;
    case 'psi'
        k = 1 / k_psi2bar;
end
zOut_d = zIn_d * k;


return
%

