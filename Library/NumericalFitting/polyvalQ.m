function y  = polyvalQ(p, x)
% quick version of Matlab command polyval
%
% output
% y: value of polynomial at desired input x
% 
% input: 
% x: x-data
% p: coefficients of polynomial

n = length(p);
% 
y = zeros(size(x));
for i = 1:n
   y = y + p(i) * x.^(n-i);
end

return