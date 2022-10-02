function [zOut_d, bSupp, cUMsupp] = temperatureUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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
cSin = {'degC', '°C', 'C', 'celsius';...
        'degF', '°F', 'F', 'fahrenheit';...
        'degK', '°K', 'K', 'kelvin'};
cStd = {'C';...
        'F';...
        'K'};
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
cUMsupp = {'C', 'F', 'K'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

%%% fattori di passaggio
% [degC] = ([degF] + offset) * gain
[offsetF, gainF] = degF();
% [degC] = ([degK] + offset)
[offsetK] = degK();

%%% unifico la grandezza in ingresso
% porto in C
switch sUMin
    case 'C'
        offset = 0;
        gain = 1;
    case 'F'
        offset = offsetF;
        gain = gainF;
    case 'K'
        offset = offsetK;
        gain = 1;
end
zIn_d = (zIn_d + offset) * gain;

%%% trasformo per uscita
switch sUMout
    case 'C'
        offset = 0;
        gain = 1;
    case 'F'
        offset = offsetF;
        gain = gainF;
    case 'K' 
        offset = offsetK;
        gain = 1;
end
zOut_d = (zIn_d * 1/gain) - offset;


return
%

