% % -------------IMPLEMENTAZIONE FUNCTION--------------------------
% 2015-0115
%   obj='nome-oggetto'
% % -------------FUNCTION--------------------------
function [sString,fIndex]=CmbLst_getValue(handles,obj)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try  
% controlla sia un oggetto esistente
    
    [obj,h1]=getFieldReal(handles,obj);
    if h1>0
        % prende il valore
        sList=strvcat(get(h1,'String'));
        fIndex=get(h1,'Value');
        sString=strtrim(sList(fIndex,:));
        fIndex=fIndex';
    end;
% % GESTIONE ERRORI
catch
    sString='';
    fIndex=-1;
end

return;