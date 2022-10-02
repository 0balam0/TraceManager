% % -------------IMPLEMENTAZIONE FUNCTION--------------------------
% 2015-0115
%   obj='nome-oggetto', che corrisponde al nome del file
% % -------------FUNCTION--------------------------
function [sVal,iVal]=CmbLst_AutoSet(handles,obj,varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
% controlla sia un oggetto esistente
    sMatrix=putFileInAnArray([obj '.ini']);
    if isempty(varargin)
        iVal=1;
    else
        iVal=varargin{1};
    end
    [obj,h1]=getFieldReal(handles,obj);
    
    if h1>0
        set(h1,'string',sMatrix);
        if isempty(sMatrix)
            sVal=gestErr2(THIS_FUNCTION,['File ' obj ' is empty']);
            iVal=-1;
        else
            sVal=strtrim(sMatrix(iVal,:));
            set(h1,'value',iVal);
        end
    end
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end

return;