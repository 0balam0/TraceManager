% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 04-01-2006 : implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [mStrings,mCells]=stringSplit(string,sep);
% % -------------FUNCTION--------------------------
function [mStrings,mCells]=stringSplit(string,sep)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
    [mStrings,mCells]=splitString(string,sep);
% % GESTIONE ERRORI 
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




