function cOut = str2cell(s)
% converte una sringa di testo in un cell array di "parole".
% Le parole nella stringa sono delimitate da '.
% ex: s = ['''mg/hub''',' ','''mg/str''']; 




if iscell(s)
   % cell array di stringhe
   [r,c] = size(s);
   cOut = cell(r,c);
   for i = 1:r
      for j = 1:c
         cOut{i,j} = conversione(s{i,j});
      end
   end
   
else
   % stringa
   cOut = conversione(s);
end




return

function c = conversione(s)

% apice per identificare la stringa
s1 = '''''';
s1 = s1(1);

idx = find(s==s1);
n = length(idx)/2;

if int32(n) ~= n
   % se dispari esco
   disp('impossibile convertire la stringa')
   return
end

c = cell(n,1);
for i = 1:n
   % ciclo sulle "parole"
   c{i} = s(idx(2*i-1)+1:idx(2*i)-1);
end

% elimino stringhe vuote
c = c(not(strcmpi(c,'')));
return

