function vi = interp4sat(x, y, z, k, v, xi, yi, zi, ki, varargin)


xMin = min(x);
xMax = max(x);

yMin = min(y);
yMax = max(y);

zMin = min(z);
zMax = max(z);

kMin = min(k);
kMax = max(k);

vi = interpn(x, y, z, k, v, max(min(xi, xMax), xMin) , max(min(yi, yMax), yMin), max(min(zi, zMax), zMin), max(min(ki, kMax), kMin), varargin{:});

return