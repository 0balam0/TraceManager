function [zOut_d, bSupp, cUMsupp] = energyUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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

% %%% sostituzione sinonimi con una sola unità di misura
% se necessario vedi le altre funzioni simili a questa

%%% controllo unità di misura correttamente gestite
% elenco u.m. supportate
cUMsupp = {'Wh', 'kWh', 'mJ', 'J', 'kJ', 'MJ'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

%%% unifico la grandezza in ingresso
% porto in J (W*s)
switch sUMin
    case 'mJ'
        k = 1e-3;
    case 'J'
        k = 1;
    case 'kJ'
        k = 1e3;
    case 'MJ'
        k = 1e6;
    case 'Wh'
        k = 3.6e3;
    case 'kWh'
        k = 3.6e6;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case 'mJ'
        k = 1/1e-3;
    case 'J'
        k = 1/1;
    case 'kJ'
        k = 1/1e3;
    case 'MJ'
        k = 1/1e6;
    case 'Wh'
        k = 1/3.6e3;
    case 'kWh'
        k = 1/3.6e6;
end
zOut_d = zIn_d * k;


return
%

