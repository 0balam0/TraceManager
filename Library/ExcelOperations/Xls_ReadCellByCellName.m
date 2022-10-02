% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 09-07-2009 : implementazione della funzione dpe/piu
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati e tutti i parametri sono necessari
%     [nameXlsFile,pathXlsFile] = uigetfile('*.xls','Selezione FeEF');
%     sPathFile=fullfile(pathXlsFile,nameXlsFile);
%     [CellDati]=Xls_ReadCellByCellName(sPathFile,'NomeFoglio','nome1|nome2')
%     i nomi dei campi vanno dati con il separatore '|'
%     se un campo manca il cellarray è vuoto da li in poi.
% % -------------FUNCTION--------------------------


function [CellDati]=Xls_ReadCellByCellName(sPathFile,sSheet,sCellNames)

try
    %Apertura oggetto Excel application
    hExcel = actxserver('excel.application');
    file=hExcel.Workbooks.Open(sPathFile);

    Foglio=hExcel.Worksheets.Item(sSheet);
 
    [mStrings,mCells]=splitString(sCellNames,'|');

    [r,c]=size(mStrings);
    CellDati{r}=[];
    for i=1:r
        sName=mStrings(i,:);
        rowS=Foglio.Range(sName).Row;
        colS=Foglio.Range(sName).Column;
        CellDati{i}=Foglio.get('Cells', rowS,colS).value;
    end
    hExcel.Quit;
    delete(hExcel);
catch
    hExcel.Quit;
end

