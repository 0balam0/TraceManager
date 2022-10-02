function sFormat = lineFormatPrintf(nElem, sF, sDel, sDelStart, sEnd)

% lineFormatPrintf

% crea la stringa sFormat per la scrittura su file con fprintf (e sprintf)

sFormat = char(zeros([1,length(sF)*nElem + length(sDel)*nElem], 'int8')); 
i2 = 0;
for i = 1:nElem
   i1 = i2(end)+1:i2(end)+length(sF); % ex: [1 2]     [5 6]
   i2 = i1(end)+1:i1(end)+length(sDel); % ex:     [3 4]     [7 8]
   sFormat(i1) = sF;
   sFormat(i2) = sDel;
end
% inizio riga
if not(isempty(sDelStart))
   sFormat(1+length(sDelStart):end+length(sDelStart)) = sFormat;
   sFormat(1:length(sDelStart)) = sDelStart;
end
% tolgo ultimo delimitatore standard
sFormat = sFormat(1:end-length(i2)); 
% fine riga
sFormat(end+1:end+length(sEnd)) = sEnd; 

return