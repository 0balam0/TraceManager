% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 04-01-2006 : implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [mNCells]=cellGetCol(mCells,Col);
% % -------------FUNCTION--------------------------
function [mNCells]=cellGetCol(mCells,Col)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
    [r,c]=size(mCells);
    mNCells=cell(r,1);
    for i=1:r
        mNCells{i,1}=mCells{i,Col};
    end
% % GESTIONE ERRORI 
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




