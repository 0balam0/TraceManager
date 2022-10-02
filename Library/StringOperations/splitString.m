% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 28-02-2005 : implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [mStrings,mCells]=splitString(string,sep);
% % -------------FUNCTION--------------------------
function [mStrings,mCells]=splitString(string,sep)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
%     controllare per avere dei num!
    mStrings=[];
    mCells={};
    if strcmp(upper(sep), 'TAB') 
        nSep=9;
    else
        nSep=abs(sep);
    end
    numString=abs(string);
    vSep=find(numString==nSep)';
    
    [nRows,nCol]=size(vSep);
    r1=1;
    if nRows==0
       mStrings=string;
       mCells{1}=string;
       return;
    end
    r2=vSep(1);
    mStrings=string(r1:r2-1);
    mCells{1}=string(r1:r2-1);
    r1=1+r2;
    for i=2:nRows
        r2=vSep(i);
        mStrings=matrixAddRow(mStrings,0,string(r1:r2-1));
        mCells{i}=string(r1:r2-1);
        r1=1+r2;
    end
    mStrings=matrixAddRow(mStrings,0,string(r1:end));
    mCells{nRows+1}=string(r1:end);
    
% % GESTIONE ERRORI
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




