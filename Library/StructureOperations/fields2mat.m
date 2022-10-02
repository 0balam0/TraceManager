function [m, b] = fields2mat(t,sField)
% raccolglie il contenuto del campo sField della struttura indicizzata t(i)
% nella matrice m. m può essere un cell array se necessario.
% Nella matrice b sono raccolte le indicazioni delle assegnazioni nulle,
% non riconoscibili dalla sola m perchè comparirebbero come zeri

% matrice di out
s = size(t);

b = false(s);
% numero di dimensioni massime gestite
L = 5;
sf = s;
if length(s)<L
   sf(end+1:L) = 1;
end
%
% ciclo sulle dimensioni per controllare dimensioni dati contenuti nella
% struttura
bCell = false;
%
for i1 = 1:sf(1)
   for i2 = 1:sf(2)
      for i3 = 1:sf(3)
         for i4 = 1:sf(4)
            for i5 = 1:sf(5)
               val = t(i1,i2,i3,i4,i5).(sField);
               if numel(val)>1 || iscell(val) || ischar(val)
                  bCell = true;
                  break
               end
            end
            if bCell
               break
            end
         end
         if bCell
            break
         end
      end
      if bCell
         break
      end
   end
   if bCell
      break
   end
end
% 
% 
switch bCell
   case true 
      % trattamento come cell array
      m = cell(s);
      for i1 = 1:sf(1)
         for i2 = 1:sf(2)
            for i3 = 1:sf(3)
               for i4 = 1:sf(4)
                  for i5 = 1:sf(5)
                     val = t(i1,i2,i3,i4,i5).(sField);
                     if not(isempty(val))
                        m{i1,i2,i3,i4,i5} = val;
                     else
                        b(i1,i2,i3,i4,i5) = true;
                     end
                  end
               end
            end
         end
      end
   case  false
      % trattamento come double
      m = zeros(s);
      for i1 = 1:sf(1)
         for i2 = 1:sf(2)
            for i3 = 1:sf(3)
               for i4 = 1:sf(4)
                  for i5 = 1:sf(5)
                     val = t(i1,i2,i3,i4,i5).(sField);
                     if not(isempty(val))
                        m(i1,i2,i3,i4,i5) = val;
                     else
                        b(i1,i2,i3,i4,i5) = true;
                     end
                  end
               end
            end
         end
      end
end

%
% vettori colonna
if max(s) == numel(m) 
   m = m(:);
   b = b(:);
end

return