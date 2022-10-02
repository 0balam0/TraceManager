function [nL,nT,nW,nH] = position_ObjGet(handles,sObj)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try  
    [sObj,h1]=getFieldReal(handles,sObj);
    if h1>0
        obj_Pos=get(h1,'Position');
        [nL,nT,nW,nH] = position_Mat2Stnd(h1,obj_Pos);     
    end;
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end
return;