function writeCellAscii(fid, cIn, sDel, sDelStart)

% scrive il cellArray cIn sul file di testo fid usando come separatore la
% stringa sDel (ex: '\t'), come inizio riga sDelStart (ex: '\t' o '') 

%
[r, c] = size(cIn);
sF1 = '%s'; % stringa
sEnd = '\r\n'; % terminatore di riga
%
%%% crezione della stringa per la formattazione del testo sul file
sFormat = lineFormatPrintf(c, sF1, sDel, sDelStart, sEnd);
%
% scrittura su file
for i = 1:r
    fprintf(fid, sFormat, cIn{i,:}); % verifica: s = sprintf(sFormat, cIn_t{:})
end
return