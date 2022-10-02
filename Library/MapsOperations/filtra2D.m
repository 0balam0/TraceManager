function zF = filtra2D(x,y,zIn, nFilt)
%
% TODO: a causa NaN nei interp1 metto warning off
warning off


switch nFilt
   case {2,3,5}
      mFilt = ones(nFilt,nFilt)/nFilt^2;
   otherwise
      disp('dimensione di filtraggio non gestita')
      zF = zIn;
      return
end
% filtraggio con filter2
zF = zeros(size(zIn));
switch nFilt
   case 2
      zF(1:end-1,1:end-1) = filter2(mFilt, zIn, 'valid');
   case 3
      zF(2:end-1,2:end-1) = filter2(mFilt, zIn, 'valid');
   case 5
      zF(3:end-2,3:end-2) = filter2(mFilt, zIn, 'valid');
end
% estrapolo bordo y, che il filtro non fa
for j=1:length(y)
   switch nFilt
      case 2
         zF(end,j) = interp1(y(end-2:end-1), zF(end-2:end-1,j), y(end), 'linear', 'extrap');
      case 3
         zF(1,j) = interp1(y(2:3), zF(2:3,j), y(1), 'linear', 'extrap');
         zF(end,j) = interp1(y(end-2:end-1), zF(end-2:end-1,j), y(end), 'linear', 'extrap');
      case 5
         zF(1:2,j) = interp1(y(3:5), zF(3:5,j), y(1:2), 'linear', 'extrap');
         zF(end-1:end,j) = interp1(y(end-4:end-2), zF(end-4:end-2,j), y(end-1:end), 'linear', 'extrap');
   end
end
% estrapolo bordo x, che il filtro non fa
for i=1:length(x)
   switch nFilt
      case 2
         zF(i,end) = interp1(x(end-2:end-1), zF(i,end-2:end-1), x(end), 'linear', 'extrap');
      case 3
         zF(i,1) = interp1(x(2:3), zF(i,2:3), x(1), 'linear', 'extrap');
         zF(i,end) = interp1(x(end-2:end-1), zF(i,end-2:end-1), x(end), 'linear', 'extrap');
      case 5
         zF(i,1:2) = interp1(x(3:5), zF(i,3:5), x(1:2), 'linear', 'extrap');
         zF(i,end-1:end) = interp1(x(end-4:end-2), zF(i,end-4:end-2), x(end-1:end), 'linear', 'extrap');
   end
end

% TODO: a causa NaN nei interp1 metto warning off
warning on

return
%