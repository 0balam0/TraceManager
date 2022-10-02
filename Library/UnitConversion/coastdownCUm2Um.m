function [zOut_d, bSupp, cUMsupp] = coastdownCUm2Um(zIn_d, sUMin, sUMout, varargin)


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
sUMin = lower(sUMin);
sUMout = lower(sUMout);

% TODO: v. se esistono sinonimi, in questo caso prendere codice da
% speedUm2Um



%%% sostituzione sinonimi con una sola unità di misura
cSin = {'N/kph^2','N/(km/h)^2','N/kmh^2';... % N
        'N/mph^2','N/(mi/h)^2','N/(miph)^2';...
        'N/ms^2','N/(m/s)^2','N/(mps)^2';...
        'lbf/kph^2','lbf/(km/h)^2','lbf/kmh^2';... % lbf
        'lbf/mph^2','lbf/(mi/h)^2','lbf/(miph)^2';...
        'lbf/ms^2','lbf/(m/s)^2','lbf/(mps)^2'};
cStd = {'N/(km/h)^2';... % N
        'N/mph^2';...
        'N/(m/s)^2';...
        'lbf/(km/h)^2';... % lbf
        'lbf/mph^2';...
        'lbf/(m/s)^2'};
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

% fattore di passaggio da gal a l, da galloni a litri 
% k_N2lb = gal2lt(1);
% fattore di passaggio da mi a km
k_mi2km = mi2km(1);
k_lbf2N = lbf2N(1);

%%% unifico la grandezza in ingresso
% porto in N/(m/s)
switch sUMin
    case 'N/(km/h)^2'
        k = 3.6^2;
        zIn_d = zIn_d .* k;
    case 'N/mph^2'
        k = (3.6 / k_mi2km)^2;
        zIn_d = zIn_d .* k;
    case 'N/(m/s)^2'
        k = 1;
        zIn_d = zIn_d .* k;
    case 'lbf/(km/h)^2'
        k = k_lbf2N * 3.6^2;
        zIn_d = zIn_d .* k;
    case 'lbf/mph^2'
        k = k_lbf2N * (3.6 / k_mi2km)^2;
        zIn_d = zIn_d .* k;
    case 'lbf/(m/s)^2'
        k = k_lbf2N;
        zIn_d = zIn_d .* k;
end

%%% trasformo per uscita
switch sUMout
   case 'N/(km/h)^2'
        k = 3.6^2;
        zOut_d = zIn_d ./ k;
    case 'N/mph^2'
        k = (3.6 / k_mi2km)^2;
        zOut_d = zIn_d ./ k;
    case 'N/(m/s)^2'
        k = 1;
        zOut_d = zIn_d ./ k;
    case 'lbf/(km/h)^2'
        k = k_lbf2N * 3.6^2;
        zOut_d = zIn_d ./ k;
    case 'lbf/mph^2'
        k = k_lbf2N * (3.6 / k_mi2km)^2;
        zOut_d = zIn_d ./ k;
    case 'lbf/(m/s)^2'
        k = k_lbf2N;
        zOut_d = zIn_d ./ k;
end
return