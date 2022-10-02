function y = logspace2(x1, x2, n)
% y = logspace2(x1, x2, n)  restituisce n punti logaritimicamente equispaziati
%     fra x1 e x2 (n punti, compresi x1 e x2) - invece, logspace(x1, x2, n)
%     restituisce punti fra 10^x1 e 10^x2
%     
%
% Guenna, 6/04/2011
%
% see also logspace

if x1*x2<=0
   y = linspace(x1, x2, n);
   disp( 'Ho fatto linspace: dati di input incompatibili con logspace')
   return
end
a1 = log10(abs(x1));
a2 = log10(abs(x2));
y = logspace(a1,a2,n) .* sign(x1);

return