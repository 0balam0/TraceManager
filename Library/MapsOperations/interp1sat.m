function yi = interp1sat(x, y, xi, varargin)


xMin = min(x);
xMax = max(x);

yi = interp1(x, y, max(min(xi, xMax), xMin) , varargin{:});

return