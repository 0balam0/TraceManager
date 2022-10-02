% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 21-09-2005: mi da la dir di livello superiore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [pathUp]=pathGoUp(path);
% % -------------FUNCTION--------------------------
function [pathUp]=pathGoUp(path)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
    vSep=findstr(path,filesep)';
    [nRows,nCol]=size(vSep);
    if nRows==0
        pathUp=path;
        return;
    end
    r1=1;
    r2=vSep(1);
    pathUp=path(r1:r2-1);
    r1=1+r2;
    for i=2:nRows
        r2=vSep(i);
        pathUp=[pathUp,filesep,path(r1:r2-1)];
        r1=1+r2;
    end
    
    
% % GESTIONE ERRORI
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




