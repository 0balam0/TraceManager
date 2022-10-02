% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 03-06-2005: implementazione 
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
% % -------------FUNCTION--------------------------
function mArray=putFileInAnArray(File)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
    fid = fopen(File);
    mArray=[];
%     aggiunta per gestire file non esistente
    if fid==-1
       return; 
    end
    while 1
        sLine = fgetl(fid);
        if ~ischar(sLine), break, end;
        mArray=matrixAddRow(mArray,0,sLine);
    end
    fclose(fid);
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end
return;