function cOut = estraiParole(sIn)



% raccoglie in cOut le parole (insieme di caratteri alfanumerici) contenute
% in sIn

% 48: 0
% 57: 9
% 65: a
% 90: z
% 97: A
% 122: Z

sIn = sIn(:)';
vIn = int8(sIn);
bWord = not(vIn<48 | vIn>57 & vIn<65 | vIn>90 & vIn<97 | vIn>122);
DW = diff(double([1 bWord]));
% posizioni di inizio parole
posStart = find(DW==1);
if bWord(1)
   posStart = [1 posStart];
end
% posizioni di fine parole
posEnd = find(DW==-1)-1;
if bWord(end)
   posEnd = [posEnd length(sIn)];
end
% compatibilità fine-inizio
if posEnd(1)<posStart(1)
   posEnd = posEnd(2:end);
end

% cell array di out
cOut = cell(length(posStart),1);
for i = 1:length(cOut)
   cOut{i} = sIn(posStart(i):posEnd(i));
end

return