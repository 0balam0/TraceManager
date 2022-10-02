function tOutput=writeCellInATXTFile(varargin)

% % COSTANTI
THIS_FUNCTION=mfilename;
ERR_OUT='no error';

tOutput=ERR_OUT;

% SETTAGGIO DEFAULT A SECONDA DEL MODELLO DI INGRESSO DEI DATI
if nargin>1
    Matrix=varargin{1};
    sPathFile=varargin{2};
else
    % %     Gestione del caso con solo i default o exit
    tOutput=['Numero insufficiente di argomenti di input in ',THIS_FUNCTION];
    return;
end
if nargin>2
    sep=varargin{3};
else
    sep=char(9);  %'TAB';
end

% apri file
fid = fopen(sPathFile, 'w');
[nRows,nCol]=size(Matrix);
%
for i = 1:nRows
    if(i == 1727)
    disp('');
    end
    sLine=num2str(Matrix{i,1});
    for j=2:nCol
        val = Matrix{i,j};
        val = val(:)';
        sLine = [sLine, sep, num2str(val)];
    end
    fprintf(fid,'%s',sLine);
    sLine=['\r\n'];
    fprintf(fid,sLine);
end
fclose(fid);

return;