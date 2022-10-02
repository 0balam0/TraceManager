function p  = polyfitQ(x, y, n)
% quick version of Matlab command polyfit
%
% output
% p: polynomial coefficients
% 
% input: 
% x: x-data
% y: x-data
% n: degree of polynomial to be used


x = x(:);
y = y(:);
% 
nData = length(x); % numerosità dei dati da fittare
M = ones(nData, n+1); % matrice dei coefficienti

for i = 1:n
   M(:,i) = x.^(n+1-i);
end
  
p = M\y;
p = p';

return