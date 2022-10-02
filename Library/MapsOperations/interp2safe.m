function [zi] = interp2safe(x, y, Z, xi, yi, varargin)

% output 
zi = [];

dimX = dimEff(x);
dimY = dimEff(y);

if dimX ~= dimY
    % error
    return
end
% input breakpoint dimension
dimIn = dimX;


if dimIn == 1
    % transforms 1D input bp into 2D for safe function behaviour
%     x = x(:);
%     y = y(:);
    Lx = length(x);
    Ly = length(y);
    
    
    
    [rZ, cZ] = size(Z);
    
    if Lx == cZ && Ly == rZ
        
        % old wrong synthax
        dimXi = dimEff(xi);
        dimYi = dimEff(yi);
        
        % same dimensions on input bp
        if dimXi == 0 && dimYi==1
            xi = xi * ones(size(yi));
        elseif dimXi == 1 && dimYi==0
            yi = yi * ones(size(xi));
        elseif dimXi == 1 && dimYi==1
            [rXi, cXi] = size(xi);
            [rYi, cYi] = size(yi);
            if rXi > 1 && cYi>1 || rYi > 1 && cXi>1
                % want to generate a 2d input matrix
                [xi, yi] = meshgrid(xi, yi);
            end
        end

        [Y, X] = meshgrid(y,x);
        zi = interp2check(Y, X, Z', yi, xi, varargin{:});
        
    elseif Lx == rZ && Ly == cZ
        % right synthax
        [X,Y] = meshgrid(x,y);
        zi = interp2check(X, Y, Z, xi, yi, varargin{:});
        
    else
        % wrong dimensions
        zi = [];
    end
    
    
elseif dimIn == 2
    % input were provided as 2-D
    x1 = x(1,:)';
    y1 = y(:,1);
    zi = interp2safe(x1, y1, Z, xi, yi, varargin{:});
end

return

function zi = interp2check(X, Y, Z, xi, yi, varargin)


dimXi = dimEff(xi);
dimYi = dimEff(yi);

% same dimensions on input bp
if dimXi == 0 && dimYi==1
    xi = xi * ones(size(yi));
elseif dimXi == 1 && dimYi==0
    yi = yi * ones(size(xi));
end

xiUni = unique(xi);

if dimEff(xiUni) == 0 && dimEff(xi) == 2
    zi = interp2(Y', X', Z', yi, xi, varargin{:});
else
    zi = interp2(X, Y, Z, xi, yi, varargin{:});
end


return

