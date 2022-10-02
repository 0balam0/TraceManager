function [zOut_d, bSupp, cUMsupp] = torqueUm2Um(zIn_d, sUMin, sUMout, varargin)
 
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
cSin = {'lbft','lb-ft','ftlb','ft-lb'};
cStd = {'lbft'};
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
cUMsupp = {'Nm', 'kgm', 'lbft'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da lbft a Nm
k_lbft2Nm = lbft2Nm(1);
k_kg2N = kg2N(1);

%%% unifico la grandezza in ingresso
% porto in Nm
switch sUMin
    case lower('Nm')
        k = 1;
    case 'kgm'
        k = k_kg2N;
    case 'lbft'
        k = k_lbft2Nm;
end
zIn_d = zIn_d * k;

%%% trasformo per uscita
switch sUMout
    case lower('Nm')
        k = 1;
    case 'kgm'
        k = 1 / k_kg2N;
    case 'lbft'
        k = 1 / k_lbft2Nm;
end
zOut_d = zIn_d * k;


return
%
