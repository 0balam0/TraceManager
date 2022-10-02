function v = powerFit(x,y)

% fit di funzione del tipo:
% y = a * x^b,
% che trasformo in retta doppio logaritmica
% log(y) = log(a) + b*log(x)
%
% INPUT:
% x, y: dati sparsi
%
% OUTPUT:
% v: coefficienti del fit, in ordine descrescente


X = log(x);
Y = log(y);

p = polyfitQ(X, Y, 1);

v(1) = p(1);
v(2) = exp(p(2));

return