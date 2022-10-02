% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 01-03-2005: creazione
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     matrixAddRow(handles,obj,string);
% % -------------FUNCTION--------------------------
function matrix=matrixAddRow(matrix,row,string)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
    l=length(string);
    [r,c]=size(matrix);
    if row > r
        for i=(r+1):1:(row-1);
            matrix(i,:)=char(' ');
        end;
        matrix=char(matrix,string);
%         row=r;
    end
    if r==0
        row=1;
    end;
    if row~=0
        m1=matrix(1:row-1,:);
        m2=matrix(row:r,:);
        if isempty(m1)==0
            matrix=m1;
            matrix=char(matrix,string);
        else
            matrix=char(string);
        end;

        if isempty(m2)==0
            matrix=char(matrix,m2);
        end;
    else
        matrix=char(matrix,string);
    end
% % GESTIONE ERRORI
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




