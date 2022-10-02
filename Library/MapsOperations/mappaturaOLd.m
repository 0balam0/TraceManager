function [z_d, x_2i, y_2i] = mappatura(x,y,z, x_i,y_i, varargin)
% z_d(x_i, y_i) da triplette (x,y,z)
%
% tipicamente:
% x: coppia
% y: rpm


% gestione varargin (sono le opzioni di interp1, applicate nella sola
% direzione del carico; sui giri invece tengo costante).
cMethodX = {'saturate'};
if not(isempty(varargin))
   cMethodX{1} = varargin{1};
   if length(varargin)>=2
      cMethodX{2} = varargin{2};
   end
end
% Y direction extrapolation method
cMethodY = {'saturate'};
if not(isempty(varargin))
    a = find(strcmpi(varargin, 'Ydir'));
    if not(isempty(a))
        cMethodY = varargin(a+1));
    end
end

[y_2i, x_2i] = meshgrid(y_i, x_i);
[yArr, ID, ySet] = trovaGruppi(y, max(y)/100);

z1_d = zeros(length(x_i),length(ID));
z_d = zeros(length(x_i),length(y_i));
% z1_d(x_i, rpmSet)
for i = 1:length(ySet)
   [x1,idx] = unique(x(ID{i}));
   if i>1
      idx = idx + ID{i-1}(end);
   end
   z1 = z(idx);
   % interpolazione
   switch lower(cMethodX{1})
       case 'saturate'
           % interpolazione lineare con saturazione oltre punti exp
           z1_d(:,i) = interp1sat(x1, z1, x_i);
       case 'fit-linear'
           % fit lineare di tutti i punti ed estrapolazione con medesimo fit
           z1_d(:,i) = polyvalQ(polyfitQ(x1, z1, 1), x_i);
       case {'interp / extrap fit-linear',...
             'interp / extrap fit-linear continuous'}
           % interpolazione lineare e estrapolazione lineare con fit
           %
           % punti dentro lo exp
           a = find(x_i>=x1(1) & x_i<=x1(end));
           z1_d(a,i) = interp1(x1, z1, x_i(a));
           p = polyfitQ(x1, z1, 1);
           % punti a sx dello exp
           if a(1)>1
               idx = 1:a(1)-1;
               z1_d(idx,i) = polyvalQ(p, x_i(idx));
               if strcmpi(cMethodX{1}, 'interp / extrap fit-linear continuous')
                   val1 = polyvalQ(p, x1(1));
                   z1_d(idx,i) = z1_d(idx,i) + (z1(1) - val1);
               end
           end
           % punti a dx dello exp
           if a(end)<length(x_i)
               idx = a(end)+1:length(x_i);
               z1_d(idx,i) = polyvalQ(p, x_i(idx));
               if strcmpi(cMethodX{1}, 'interp / extrap fit-linear continuous')
                   valEnd = polyvalQ(p, x1(end));
                   z1_d(idx,i) = z1_d(idx,i) + (z1(end) - valEnd);
               end
           end
           
       otherwise
           % interpolazione lineare con estrapolazione oltre punti exp in base
           % a metodo scelto
           z1_d(:,i) = interp1(x1, z1, x_i, cMethodX{:});
   end
end
% z_d(x_i, y_i)
for j = 1:length(x_i)
   z_d(j,:) = interp1sat(ySet, z1_d(j,:), y_i);
end
return
%