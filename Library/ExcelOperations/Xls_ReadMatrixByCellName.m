% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 09-07-2009 : implementazione della funzione dpe/piu
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati e tutti i parametri sono necessari
%     [nameXlsFile,pathXlsFile] = uigetfile('*.xls','Selezione FeEF');
%     sPathFile=fullfile(pathXlsFile,nameXlsFile);
%     [CellDati]=Xls_ReadMatrixByCellName(sPathFile,'NomeFoglio','NomeCellaStart')
% % -------------FUNCTION--------------------------


function [CellDati]=Xls_ReadMatrixByCellName(sPathFile,sSheet,sCellStart)

try
    %Apertura oggetto Excel application
    hExcel = actxserver('excel.application');
    file=hExcel.Workbooks.Open(sPathFile);

    Foglio=hExcel.Worksheets.Item(sSheet);

    %Individuazione punto di partenza per lettura matrice
    rowS=Foglio.Range(sCellStart).Row;
    colS=Foglio.Range(sCellStart).Column;

    %Ciclo per lettura e costruzione matrice
    i=1;
    j=1;
    while isnan(Foglio.get('Cells', rowS-1+i,colS-1+j).value)~=1   %ricerca per collonne fino alla prima vuota
%         lettura della colonna
        while isnan(Foglio.get('Cells', rowS-1+i,colS-1+j).value)~=1   %ricrca per righe fino alla prima vuota
            CellDati{i,j} = Foglio.get('Cells', rowS-1+i,colS-1+j).value;
            i = i+1;
        end
        i=1;
        j = j+1;
    end
    hExcel.Quit;
    delete(hExcel);
catch
    hExcel.Quit;
end

