function s = eliminaCaratteri(s)
% tolgo caratteri strani dal nome
sChar = '\/.,;:';
for i=1:length(sChar)
   L = length(s);
   a = strfind(s,sChar(i));
   if not(isempty(a))
      idx = setdiff(1:L,a);
      s = s(idx);
   end
end
return
