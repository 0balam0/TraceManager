% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 3-05-2005: creazione
% % -------------CALL FUNCTION--------------------------
%     % % PARAMETRI INPUT

function [r] = strCmpInMatrix(Matrix,String)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try 
    r=[];
    m=lower(strvcat(Matrix));
    String=lower(String);
    [row,col] = size (m);
    for w=1:1:row
        StrMat=strtrim(m(w,1:end));
        c = strcmpi(StrMat,String);
        if c ~= 0
            r(w)=w;
        end;
    end;     
    r=r';
% % GESTIONE ERRORI
catch
    gestErr2(THIS_FUNCTION);
end

return;