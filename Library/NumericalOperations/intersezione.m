function [xi,yi] = intersezione(x1,y1, x2,y2)

% xi e yi sono i punti di intersezione di due curve y1(x1) e y2(x2)
% fornite in ingresso

% vettori colonna
x1 = x1(:);
y1 = y1(:);
x2 = x2(:);
y2 = y2(:);
% ordinamento per ascisse crescenti
[x1, i1] = sort(x1); 
y1 = y1(i1);
[x2, i2] = sort(x2); 
y2 = y2(i2);
% unione ascisse nell'intervallo comune
x_i = union(x1,x2);
x_i = x_i(x_i <= min(x1(end),x2(end)));
x_i = x_i(x_i >= max(x1(1),x2(1)));
if not(isempty(x_i))
   % x_i = unique(max(min(union(x1,x2), min(x1(end),x2(end))), max(x1(1),x2(1))));
   % calcolo differenze ordinate su intervallo comune
   y1_d = interp1(x1, y1, x_i);
   y2_d = interp1(x2, y2, x_i);
   Dy = y2_d-y1_d;
   % riconoscimento intersezione ordinate
   bInv = (abs([0; diff(sign(Dy))]) == 2); 
   % ricerca ascisse di intersezione e relative ordinate
   xi = zeros(size(x_i))*NaN;
   yi = zeros(size(x_i))*NaN;
   for i = 1:length(bInv)
      if Dy(i) == 0
         % ordinate coincidenti
         xi(i) = x_i(i);
         yi(i) = y1_d(i);
      else
         % ordinate diverse
         if bInv(i)
            % alternanza di segno della differenza
            % interpolo per sapere dove la differenza delle ordinate è nulla
            xi(i) = interp1([Dy(i-1) Dy(i)], [x_i(i-1) x_i(i)], 0); 
            yi(i) = interp1([x_i(i-1) x_i(i)], [y1_d(i-1) y1_d(i)], xi(i));
         end
      end
   end
   xi = xi(not(isnan(xi)));
   yi = yi(not(isnan(yi)));
else
   y1_d = [];
   y2_d = [];
   xi = [];
   yi = [];
end

%%%%%%%%%%%%%%
% grafici
bDebugPlot = false;
if bDebugPlot
   plot(x1,y1,'bo--', x2,y2,'ro--', x_i,y1_d,'b+-', x_i,y2_d,'r+-', xi,yi,'k^')
   grid
end

return