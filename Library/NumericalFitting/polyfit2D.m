function [p,normr] = polyfit2D(x,y,z, g)

% [p,normr] = polyfit2D(x,y,z, g)
% fitta i dati sparsi (x,y,z) con una superficie di grado g comprendente
% tutti i termini misti e restituisce i coefficienti del polinomio e la
% norma dei residui
%
% modello di regressione:
% supposto g = 3:
% z = p(1)*x^3 + p(2)*x^2*y + p(3)*x*y^2 + p(4)*y^3 +
%     p(5)*x^2 + p(6)*x*y   + p(7)*y^2 +
%     p(8)*x   + p(9)*y + 
%     p(10)



% vettori colonna
x = x(:);
y = y(:);
z = z(:);
% 
% controllo lunghezze dati
bOk =  length(x) == length(y) & length(y) == length(z);
if not(bOk)
   disp('Errore: i vettori x,y,z devono avere la stessa lunghezza!')
   p = [];
   return
end

% colonne della matrice
c = sum(1:1:g+1);
% costruzione della matrice di regressione (vale che M*p = z)
nc = 1;
M = zeros(length(x), c);
for i = 1:g+1
   for j = 1:g-i+2
      gx = g-i-j+2;
      gy = g-i+1-gx;
      M(:,nc) = x.^gx .* y.^gy;
      nc = nc+1;
   end
end

% regressone multipla
p = M\z;

% norma dei residui
normr = norm(z-M*p);


return

