function [mNCells]=stringTrimCells(mCells)

mNCells = mCells;
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
    [nRows,nCol]=size(mCells);
    for j=1:nRows
        for i=1:nCol
            mNCells{j,i}=strtrim(mCells{j,i});
        end
    end
% % GESTIONE ERRORI 
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




