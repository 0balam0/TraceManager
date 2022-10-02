% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 15-11-2007 : creazione
% [k] = findStrInCell(MyCell,String,Exact)
% in cui 
%     MyCell e la cella con i dati
%     stringa la stringa da cercare,
%     Exact mi dice se fare il controllo esatto o delle occorrenze nella singola riga
%     k= mi dice row e col delle occorrenze
% E' stato aggiunto vargin per la gestione multipla degli input


% % -------------CALL FUNCTION--------------------------
%     % % PARAMETRI INPUT

function [k] = findStrInCell(varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try 
    k=[];
    c=[];
    
    
    MyCell=varargin{1};
    String=num2str(lower(varargin{2}));
    
    if nargin >2
       Exact=lower(varargin{3}) ;
    else
       Exact='' ;
    end
    
    [row,col] = size (MyCell);
    w=0;
    for i=1:1:row
        for j=1:col
            StrMat=lower(num2str(MyCell{i,j}));
            if strcmpi(Exact,'exact')
                c = strcmpi(StrMat,String);
            else 
                c = strfind(StrMat,String);
            end
            
            if c ~= 0
                w=w+1;
                k(w,1)=i;
                k(w,2)=j;
            end;
        end
    end;    
    
% % GESTIONE ERRORI
catch
    gestErr2(THIS_FUNCTION);
end

return;