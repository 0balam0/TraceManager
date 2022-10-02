function v = exponFit(x,y)

% fit di funzione del tipo:
% y = a * exp(b*x)
% che trasformo in retta semilogaritmica
% log(y) = log(a) + b*x
%
% INPUT:
% x, y: dati sparsi
%
% OUTPUT:
% v: coefficienti del fit, in ordine descrescente

X = x;
Y = log(y);

p = polyfitQ(X, Y, 1);

v(1) = p(1);
v(2) = exp(p(2));

return