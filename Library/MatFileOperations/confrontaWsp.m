function confrontaWsp(sFile1, sFile2)

t1 = load(sFile1);
t2 = load(sFile2);

cNames1 = fieldnames(t1);
cNames2 = fieldnames(t2);



c1 = setdiff(cNames1,cNames2);
disp(['Il wsp1 contiene in più rispetto al wsp2 i seguenti campi: ', c1(:)'])

c2 = setdiff(cNames2,cNames1);
disp(['Il wsp2 contiene in più rispetto al wsp1 i seguenti campi: ', c2(:)'])

cComm = intersect(cNames1,cNames2);
for i = 1:length(cComm)
   v1 = t1.(cComm{i}); 
   v2 = t2.(cComm{i});
   a1 = size(v1);
   a2 = size(v2);
   if any(a1~=a2)
      disp(['La variabile ', cComm{i},' ha dimensioni differenti'])
   else
%       idx = find(v1(:)~=v2(:));
%       if not(isempty(idx))
%          disp(['La variabile ', cComm{i},' ha contenuto differente agli elementi ', num2str(idx(:)')])
%      end
   end
end


return