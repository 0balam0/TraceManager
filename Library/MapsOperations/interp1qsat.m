function yi = interp1qsat(x, y, xi, varargin)


xMin = min(x);
xMax = max(x);

yi = interp1q(x, y, max(min(xi, xMax), xMin) , varargin{:});

return