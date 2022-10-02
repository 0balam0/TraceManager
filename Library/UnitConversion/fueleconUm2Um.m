function [zOut_d, bSupp, cUMsupp] = fueleconUm2Um(zIn_d, sUMin, sUMout, varargin)
 
% [zOut_d, bSupp] = fueleconUm2Um(zIn_d, sUMin, sUMout, varargin)
% 
% bSupp states if requested correction can be correctly supported
% zOut_d is the converted quantity
%
% zIn_d is the quantity to be converted
% sUMin, sUMout are the units

% conversione consumi e fuel economy
% Guenna 14/06/2011

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
cSin = {'l/100km','l / 100km','l /100km','l/ 100km';...
        'km/l',   'km / l',   'km /l',   'km/ l'};
cStd = {'l/100km';...
        'km/l'};
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
cUMsupp = {'l/100km', 'km/l','mpg'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% fattore di passaggio da gal a l, da galloni a litri 
k_gal2lt = gal2lt(1);
% fattore di passaggio da mi a km
k_mi2km = mi2km(1);

%%% unifico la grandezza in ingresso
% porto in km/l
switch sUMin
   case {'km/l'}
      % ok
   case 'mpg'
      k = k_mi2km ./ k_gal2lt;
      zIn_d = zIn_d .* k;
   case {'l/100km'};
      zIn_d = 100 ./zIn_d;
end

%%% trasformo per uscita
switch sUMout
   case {'km/l'}
      zOut_d = zIn_d;
   case 'mpg'
      k = k_mi2km ./ k_gal2lt;
      zOut_d = zIn_d ./ k;
   case {'l/100km'};
      zOut_d = 100 ./zIn_d;
end

return
%
