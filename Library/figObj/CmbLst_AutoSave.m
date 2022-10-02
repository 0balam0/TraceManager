% % -------------IMPLEMENTAZIONE FUNCTION--------------------------
% 2015-0115
%   obj='nome-oggetto', che corrisponde al nome del file
% % -------------FUNCTION--------------------------
function [sFile,sList]=CmbLst_AutoSave(handles,obj)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
% controlla sia un oggetto esistente
    sFile=[obj '.ini'];
    
    [obj,h1]=getFieldReal(handles,obj);
    
    if h1>0
        sList=get(h1,'string');
        writeArrayInAFile(sFile,sList);
    end
    
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end

return;