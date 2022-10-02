function zOut_d = concMassUm2Um(zIn_d, sUMin, sUMout, varargin)

zOut_d = [];
%
% detects in
a = strfind(sUMin, '/');
if isempty(a) || numel(a)>1 || a==1 || a == length(sUMin)
    return
end
sMassIn = sUMin(1:a-1);
sVolumeIn = sUMin(a+1:end);
%
% detects out
a = strfind(sUMout, '/');
if isempty(a) || numel(a)>1 || a==1 || a == length(sUMout)
    return
end
sMassOut = sUMout(1:a-1);
sVolumeOut = sUMout(a+1:end);
%
% conversion
k_mass = 1;
if ~strcmp(sMassIn, sMassOut)
    k_mass = massUm2Um(1, sMassIn, sMassOut);
end
k_volume = 1;
if ~strcmp(sVolumeIn, sVolumeOut)
    k_volume = volumeUm2Um(1, sVolumeIn, sVolumeOut);
end
if isempty(k_mass) || isempty(k_volume)
    return
end
zOut_d = zIn_d * k_mass / k_volume;

return