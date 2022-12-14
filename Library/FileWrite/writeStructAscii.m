function writeStructAscii(fid, tIn0, sNum, sDel, sDelStart, sFormatReq)

% writeStructAscii2(fid, tIn, sNum, sDel, sDelStart) scrive la struttura
%  tIn sul file di testo fid usando come separatore la stringa sDel (ex: '\t'),
%  come inizio riga sDelStart (ex: '\t' o '') e come formato la stringa
%  sNum (ex: '%6.3f')
% distingue automaticamente il formato PerFECTS (tIn.campo) dal formato
%  GOFAST (tIn.campo.v e tIn.campo.u).

% writeStructAscii2(fid, tIn, sNum, sDel, sDelStart, sFormato) scrive il
%  file con il formato indicato
% sFormatReq: {'2col', '3col'}
% modificato da Guenna e Pettiti, luglio 2013

%
sDel2D = '|';

%
% transforms into 3 colunm format
tIn = updateFormat(tIn0);


cFields = fieldnames(tIn);
sEnd = '\r\n'; % terminatore di riga
%
%%% creazione della stringa per la formattazione del testo sul file
sFormatField = lineFormatPrintf(1, '%s', sDel, sDelStart, '');

% preparazione dei formati di output
sFormatStr = lineFormatPrintf(1, '%s', sDel, sDel, '');
sFormatNum = lineFormatPrintf(1, sNum, sDel, sDel, '');

%
%%% scrittura su file
for i = 1:length(cFields)
    sField = cFields{i};
    %
    % skips x and y breakpoints (have reserved names)
    if length(sField)>=5 && (strcmpi(sField(end-3:end), '_x_i') || strcmpi(sField(end-3:end), '_y_i'))
        continue
    end
    
    val = tIn.(sField);
    %   .v pu? essere numerico (scalare o no) o stringa
    %   .u sempre stringa
    if isnumeric(val.v)
        % gestisco scalarri e vettori, la matrici no
        [r,c] = size(val.v);
        %
        % detects if 1D / 2D matrix with breakpoints
        sFx = [sField, '_x_i'];
        sFy = [sField, '_y_i'];
        b2Dmatrix = false;
        if r>=2 && isfield(tIn, sFx) %  && isfield(tIn, sFy)
            b2Dmatrix = true;
        end
        %
        if b2Dmatrix
            % example format
            %[val][Nm/s][1|2;3|4;5|6]+[row][Nm][50|55|60]+[col][rpm][1000|1250]
            fprintf(fid, [sFormatField, sDel], sField);
            %
            % writes 2D values
            fprintf(fid, '%s%s', '[val]', val.u); % writes units of 2D
            for j = 1:r
                % first row
                if j==1
                    sFormatRow = lineFormatPrintf(c, sNum, sDel2D, '[', ';');
                    fprintf(fid, sFormatRow, val.v(j,:));
                end
                % intermediate rows
                if j>1 && j<r
                    sFormatRow = lineFormatPrintf(c, sNum, sDel2D, '', ';');
                    fprintf(fid, sFormatRow, val.v(j,:));
                end
                % last row
                if j==r
                    sFormatRow = lineFormatPrintf(c, sNum, sDel2D, '', ']');
                    fprintf(fid, sFormatRow, val.v(j,:));
                end
            end
            %
            % writes X breakpoints (rows)
            val_x_i = tIn.(sFx).v;
            units_x_i = tIn.(sFx).u;
            fprintf(fid, '%s', ['+[row]', units_x_i]);
            sFormat = lineFormatPrintf(r, sNum, sDel2D, '[', ']');
            fprintf(fid, sFormat, val_x_i(:)');
            %
            % writes Y breakpoints (cols)
            if isfield(tIn, sFy)
                val_y_i = tIn.(sFy).v;
                units_y_i = tIn.(sFy).u;
                if ~isempty(val_y_i)
                    fprintf(fid, '%s', ['+[col]', units_y_i]);
                    sFormat = lineFormatPrintf(c, sNum, sDel2D, '[', ']');
                    fprintf(fid, sFormat, val_y_i(:)');
                end
            end
            %
            %
            switch sFormatReq
                case '3col'
                    fprintf(fid, [sDel, '%s', sEnd], '[nDmap]');
                case '2col'
                    fprintf(fid, [sDel, sEnd]);
            end
        end
        %
        if ~b2Dmatrix
            % scalars or vectors old style. Why matrix??
            if r==1 && c==1
                % scalari
                switch sFormatReq
                    case '3col'
                        fprintf(fid, [sFormatField sFormatNum sFormatStr sEnd], sField, val.v, val.u);
                    case '2col'
                        fprintf(fid, [sFormatField sFormatNum sEnd], sField, val.v);
                end
                % sprintf([sFormatField sFormatNum], sField,val)
                
            elseif r>1 && c==1 || r==1 && c>1
                % vettori
                switch sFormatReq
                    case '3col'
                        sFormatVect = lineFormatPrintf(max(r,c), sNum, sDel, sDel, '');
                        fprintf(fid, [sFormatField sFormatVect sFormatStr sEnd], sField, val.v, val.u);
                    case '2col'
                        sFormatVect = lineFormatPrintf(max(r,c), sNum, sDel, sDel, '');
                        fprintf(fid, [sFormatField sFormatVect sEnd], sField, val.v);
                end
                % sprintf([sFormatField sFormatVect], sField,val)
                
            elseif r>1 && c>1
                % matrici
                switch sFormatReq
                    case '3col'
                        % ancora da fare
                    case '2col'
                        sFormat1 = [sDel, '[', lineFormatPrintf(c, sNum, sDel, '', ''), ';'];
                        % prima riga
                        sFormatCentr = [sDel, lineFormatPrintf(c, sNum, sDel, '',''), ';'];
                        % righe centrali
                        sFormatEnd = [sDel, lineFormatPrintf(c, sNum, sDel, '', ''), ']', sEnd];
                        % ultima riga
                        sFormatMatr = char(zeros([1,length(sFormat1) +  ...
                            length(sFormatCentr)*(r-2)+ length(sFormatEnd)],'int8'));
                        % metto tutta la matrice in una sola riga: preparo il formato
                        sFormatMatr(1:length(sFormat1)) = sFormat1;
                        idx = length(sFormat1) + (1:1:length(sFormatCentr));
                        for j = 1:r-2
                            sFormatMatr(idx) = sFormatCentr;
                            idx = idx + length(sFormatCentr);
                        end
                        sFormatMatr(end-length(sFormatEnd)+1:end) = sFormatEnd;
                        fprintf(fid, [sFormatField sFormatMatr], sField,val.v');
                end
            end
        end
        
    else
        % valori stringhe
        switch sFormatReq
            case '3col'
                fprintf(fid, [sFormatField sFormatStr sFormatStr sEnd], sField,val.v, val.u);
                % sprintf([sFormatField sFormatStr], sField,val)
            case '2col'
                fprintf(fid, [sFormatField sFormatStr sEnd], sField, val.v);
        end
    end
end

return

function tOut = updateFormat(tIn)

% init
tOut = tIn;

cFields = fieldnames(tIn);
if isempty(cFields)
    return
end

% check if already in new format (3 col)
val = tIn.(cFields{1});
bNewFormatIn = isstruct(val) && isfield(val, 'v') && isfield(val, 'u');
if bNewFormatIn
    return
end

% transforms into new format
clear tOut
for i = 1:length(cFields)
    sF = cFields{i};
    tOut.(sF).v = tIn.(sF); % value
    tOut.(sF).u = ''; % unknown units
end

return


