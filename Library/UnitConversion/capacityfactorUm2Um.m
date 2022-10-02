function [zOut_d, bSupp, cUMsupp] = capacityfactorUm2Um(zIn_d, sUMin, sUMout, varargin)


% [zOut_d, bSupp] = coastdownUm2Um(zIn_d, sUMin, sUMout, varargin)
% 
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

%%% sostituzione sinonimi con una sola unità di misura
cSin = {'rpm/lbft^0.5', 'rpm/lbft0.5','rpm/lbft0.50';...
    '10^-6Nm/rpm^2', '10-6Nm/rpm^2', '10-6Nm/rpm2';...
    'Nm^0.5/rpm', 'Nm0.5/rpm', 'Nm0.50/rpm'};
    
cStd = {'rpm/lbft^0.5';...
        '10^-6Nm/rpm^2';...
        'Nm^0.5/rpm'};
    
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



% fattore di passaggio da mi a km
% [rpm/lbft^0.5] --> [10^-6Nm/rpm^2]


%%% unifico la grandezza in ingresso
% porto in [10^-6Nm/rpm^2]
switch sUMin
    case 'rpm/lbft^0.5'
        k = 1.3558 * 10^6;
        zIn_d = k ./ (zIn_d).^2;
    case '10^-6Nm/rpm^2'
        k = 1;
        zIn_d = k .* zIn_d;
    case 'Nm^0.5/rpm'
        k = 10^6;
        zIn_d = k .* (zIn_d).^2;
end

%%% trasformo per uscita
switch sUMout
   case 'rpm/lbft^0.5'
        k = 1.3558 * 10^6;
        zOut_d = k^0.5 ./ (zIn_d).^0.5;
    case '10^-6Nm/rpm^2'
        k = 1;
        zOut_d = k .* zIn_d;
    case 'Nm^0.5/rpm'
        k = 10^6;
        zOut_d = (zIn_d).^0.5 ./ k^0.5;
end
return