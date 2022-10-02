function count = writeMatAscii(fid, mIn, sNum, sDel, sDelStart)

% scrive la matrice numerica mIn sul file di testo fid usando come separatore la
% stringa sDel (ex: '\t'), come inizio riga sDelStart (ex: '\t' o '') 
% e come formato la stringa sNum (ex: '%6.3f')

%
[r,c] = size(mIn);
sEnd = '\r\n'; % terminatore di riga
%
%%% crezione della stringa per la formattazione del testo sul file
sFormat = lineFormatPrintf(c, sNum, sDel, sDelStart, sEnd);
%
%%% scrittura su file
mIn_t = mIn'; % traspongo perchè fprintf prende la matrice per colonne
count = fprintf(fid, sFormat, mIn_t); % verifica: s = sprintf(sFormat, mIn_t)
return
%