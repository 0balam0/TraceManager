function [zOut_d, bSupp, cUMsupp] = relativeUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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
cSin = {'-','% dec','%/100';...
        '%','perc','percent'};
cStd = {'-';...
        '%';};
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
cUMsupp = {'-', '%', 'ppm'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

%%% unifico la grandezza in ingresso
% porto in reltivo
switch sUMin
    case '-'
        k = 1;
    case '%'
        k = 1e-2;
    case 'ppm'
        k = 1e-6;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case '-'
        k = 1;
    case '%'
        k = 1e2;
    case 'ppm'
        k = 1e6;
end
zOut_d = zIn_d * k;


return
%

