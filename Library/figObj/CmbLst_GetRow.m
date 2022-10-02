function [sVal,iVal]=CmbLst_GetRow(handles,sObj)
% % COSTANTI
THIS_FUNCTION=mfilename;


% % INIZIO FUNCTION
try  
    [sObj,h1]=getFieldReal(handles,sObj);
    if h1>0
        sContents = cellstr(get(h1,'String'));
        sVal=sContents{get(h1,'Value')};
        iVal=get(h1,'Value');
    end;
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end

return;