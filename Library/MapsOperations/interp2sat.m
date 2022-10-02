function zi = interp2sat(x, y, z, xi, yi, varargin)


xMin = min(x);
xMax = max(x);

yMin = min(y);
yMax = max(y);

zi = interp2safe(x, y, z, max(min(xi, xMax), xMin) , max(min(yi, yMax), yMin), varargin{:});

return