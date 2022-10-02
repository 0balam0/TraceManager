function [zOut_d, bSupp, cUMsupp] = powerUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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

% %%% sostituzione sinonimi con una sola unità di misura
% se necessario vedi le altre funzioni simili a questa

%%% controllo unità di misura correttamente gestite
% elenco u.m. supportate
cUMsupp = {'CV', 'kW','W','HP', 'Nmrpm'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattori di passaggio
k_CV2kW = CV2kW(1);
k_HP2kW = HP2kW(1);

%%% unifico la grandezza in ingresso
% porto in kW
switch sUMin
    case lower('kW')
        k = 1;
    case lower('W')
        k = 1e-3;
    case lower('CV')
        k = k_CV2kW;
    case lower('HP')
        k = k_HP2kW;
    case lower('Nmrpm')
        k = 1e-3 * pi/30;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case lower('kW')
        k = 1;
    case lower('W')
        k = 1 / 1e-3;
    case lower('CV')
        k = 1 / k_CV2kW;
    case lower('HP')
        k = 1 / k_HP2kW;
    case lower('Nmrpm')
        k = 1e3 * 30/pi;
end
zOut_d = zIn_d * k;


return
%

