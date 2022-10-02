% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 04-01-2006 : implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [mNCells]=cell2Vertical(mCells);
% % -------------FUNCTION--------------------------
function [mNCells]=cell2Vertical(mCells)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
    [nRows,nCol]=size(mCells);
    if nRows==1 
        mNCells=mCells';
    else
        mNCells=mCells;
    end
% % GESTIONE ERRORI 
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




