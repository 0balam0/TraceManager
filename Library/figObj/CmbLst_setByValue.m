% % -------------IMPLEMENTAZIONE FUNCTION--------------------------
% 2015-0115
%   obj='nome-oggetto'
% % -------------FUNCTION--------------------------
function [iValue]=CmbLst_setByValue(handles,obj,sValue)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try  
% controlla sia un oggetto esistente
    [obj,h1]=getFieldReal(handles,obj);
    if h1>0
        matrix=get(h1,'string');
        [r,c]=size(matrix);
        for i=1:r
           s=lower(deblank(matrix(i,:)));
           if strcmpi(sValue,s)
               iValue=i;
           end
        end

        set(h1,'value',iValue);
    end;
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end

return;