% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% gg-mm-200a : implementazione 
% % -------------CALL FUNCTION--------------------------  
%     [sNew]=stringReplace(S,sFind,sRepl);
% % -------------FUNCTION--------------------------
function [sNew]=stringReplace(S,sFind,sRepl)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
    k = findstr(S, sFind);
    l=length(sRepl);
    lF=length(sFind);
    sNew=S;
    for i=1: length(k)
        kk = findstr(sNew, sFind);
        k1=kk(1);
        s1=sNew(1:k1-1);
        s2=sNew(k1+lF:end);
        sNew=[s1,sRepl,s2];
    end

% % GESTIONE ERRORI 
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




