function writeCellMatAscii(fid, cIn, mIn, bNumeric, sNum, sDel)

% scrive la matrice numerica mIn sul file di testo fid usando come separatore la
% stringa sDel (ex: '\t'), come inizio riga sDelStart (ex: '\t' o '') 
% e come formato la stringa sNum (ex: '%6.3f')

%
r = size(cIn,1);
c = length(bNumeric);
%
%%% crezione della stringa per la formattazione del testo sul file
% sFormat_cIn = lineFormatPrintf(col_cIn, '%s', sDel, sDelStart, sDel);
% sFormat_mIn = lineFormatPrintf(col_mIn, sNum, sDel, sDelStart, '\r\n');
%
%%% scrittura su file
for i = 1:r
    % riga costante
    for j = 1:c
        if bNumeric(j)
            % parte di matrice dati
            fprintf(fid, [sNum, sDel], mIn(i,j));
        else
            % parte di cell array
            fprintf(fid, ['%s', sDel], cIn{i,j});
        end
        if j == c
            fprintf(fid, '%s\r\n','');
        end
    end
end

return