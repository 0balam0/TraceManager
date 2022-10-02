function dim = dimEff(mIn)
% dimensioni non singolari (effettive) della matrice in ingresso, come se
% fosse la lookUp-table 0-D, 1-D, 2-D, 3-D...
%
%%% esempio di dim :
% -1 se mIn == [] (vuoto)
%  0 se mIn == 5 (scalare)
%  1 se mIn == ones(1,2) (vettore)
%  2 se mIn == ones(3,1,5) (mtrice 3-D con una dimensione singolare, cioè effettivamente una 2-D)
%  3 se mIn == ones(3,2,5) (mtrice 3-D)

s = size(mIn);
s = s(s>0);

if isempty(s)
   dim = -1;
elseif all(s==1)
   dim = 0;
else
   bReduced = false;
   while not(bReduced)
      s = s(s>1);
      if not(isempty(s))
         bReduced = all(s>1);
      else
         bReduced = true;
      end
   end
   dim = length(s);
end

return