% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 15-02-2005: implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'� la struttura dei dati ed � sempre nello stesso modo
%     [Output]=gestField(tStruttura,sField,Default,DispON);
% % -------------FUNCTION--------------------------
function Output=gestField(varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
    
    tStruttura = varargin{1};
    sField = varargin{2};
    Default = varargin{3};
    if nargin >3
        DispON=varargin{4};
    else
        DispON='ON';
    end
    
    [sFieldName,fFieldVal]=getFieldReal(tStruttura,sField,DispON);
    if isempty(fFieldVal)
        Output=Default;
    else
        Output=fFieldVal;
    end

% % GESTIONE ERRORI
catch
    [Output]=gestErr2(THIS_FUNCTION);
end

return;




