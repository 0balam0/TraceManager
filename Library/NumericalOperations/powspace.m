function y = powspace(d1, d2, n, deg)
% y = powspace(d1, d2, n, deg)
% genera n punti spaziati in modo potenza (grado deg) tra d1 e d2   

y = linspace(d1^(1/deg), d2^(1/deg), n) .^ deg;
return