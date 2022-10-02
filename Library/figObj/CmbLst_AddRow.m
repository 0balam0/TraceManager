function [sList,cList]=CmbLst_AddRow(handles,obj,sRow,nPos)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try  
    [obj,h1]=getFieldReal(handles,obj);
    if h1>0
        s=get(h1,'string');
        [sList,cList]=matrix_AddRow(s,sRow,nPos);
        set(h1,'string',sList);
        set(h1,'value',nPos);
    end;
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end

return;