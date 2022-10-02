function [zOut_d, bSupp, cUMsupp] = coastdownAUm2Um(zIn_d, sUMin, sUMout, varargin)


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

% TODO: v. se esistono sinonimi, in questo caso prendere codice da
% speedUm2Um


cStd = {'N';... % N
        'lbf'};
    
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
k_lbf2N = lbf2N(1);

%%% unifico la grandezza in ingresso
% porto in N
switch sUMin
    case 'N'
        k = 1;
        zIn_d = zIn_d .* k;
    case 'lbf'
        k = k_lbf2N;
        zIn_d = zIn_d .* k;
end

%%% trasformo per uscita
switch sUMout
   case 'N'
        k = 1;
        zOut_d = zIn_d ./ k;
    case 'lbf'
        k = k_lbf2N;
        zOut_d = zIn_d ./ k;
end
return
%