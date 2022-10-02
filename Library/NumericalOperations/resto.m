function [r, d] = resto(n, base)

% [r, d] = resto(n, base)
% dà il resto r e il quoto d della divisione n / base
n = double(n);
base = double(base);

d = floor(n./base);
r = n - base.*d;

return