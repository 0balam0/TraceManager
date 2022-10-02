% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 04-01-2006 : implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [mDati]=cell2Matrice(Cell);
% % -------------FUNCTION--------------------------
function [mDati]=cell2Matrice(Cell)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
   mDati=[];
   [r,c]=size(Cell);
   for i=1:r
      for j=1:c
         if isnumeric(Cell{i,j}) & ~isempty((Cell{i,j}))
            mDati(i,j)=Cell{i,j};
         else
            mDati(i,j)=NaN;
         end
      end
   end
   
% % GESTIONE ERRORI 
catch
   [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




