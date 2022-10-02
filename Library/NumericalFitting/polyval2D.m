function Z_d = polyval2D(p, x_i, y_i)

% Z_d = polyval2D(x_i, y_i, p)
% valuta gli ingressi x_i, y_i (vettori/scalari/matrici) con il polinomio p 
% comprendente tutti i termini misti 
%
% esempio:
% supposto g = 3:
% Z_d = p(1)*x_i^3 + p(2)*x_i^2*y_i + p(3)*x_i*y_i^2 + p(4)*y_i^3 +
%       p(5)*x_i^2 + p(6)*x_i*y_i   + p(7)*y_i^2 +
%       p(8)*x_i   + p(9)*y_i + 
%       p(10)

% gestione ingressi matrice / vettori
xDim = dimensione(x_i);
yDim = dimensione(y_i);
if xDim == 2 && yDim == 2
   if all(size(x_i) == size(y_i))
      % matrici
      X_i = x_i;
      Y_i = y_i;
   else
      disp('Errore: vettori x_i e y_i male specificati')
      Z_d = [];
      return
   end
else
   % vettori o scalari
   if length(x_i) == length(y_i) && all(size(x_i) == size(y_i))
      X_i = x_i(:);
      Y_i = y_i(:);
   else
      [Y_i, X_i] = meshgrid(y_i(:),x_i(:));
   end
end

% grado del polinomio dal numero di coefficienti;
g = 0;
l = length(p);
while l > 0
   g = g+1;
   l = l-g;
end
g = g-1;

% calcolo della matrice dalla somma dei termini del polinomiot
Z_d = zeros(size(X_i));
nc = 1;
for i = 1:g+1
   for j = 1:g-i+2
      gx = g-i-j+2;
      gy = g-i+1-gx;
      Z_d = Z_d + p(nc) * X_i.^gx .* Y_i.^gy;
      nc = nc+1;
   end
end


return

function n = dimensione(x)

[rx, cx] = size(x);
if rx == 1 && cx == 1
   n = 0;
elseif (rx > 1 && cx == 1) || (rx == 1 && cx > 1) 
   n = 1;
else
   n = 2;
end

return