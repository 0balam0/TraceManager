function vi = interp3sat(x, y, z, v, xi, yi, zi, varargin)


xMin = min(x);
xMax = max(x);

yMin = min(y);
yMax = max(y);

zMin = min(z);
zMax = max(z);

vi = interp3(x, y, z, v, max(min(xi, xMax), xMin) , max(min(yi, yMax), yMin), max(min(zi, zMax), zMin), varargin{:});

return