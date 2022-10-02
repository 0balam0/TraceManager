
function [cIntestazione,cDati]=cell2IntestDati(Cell)
% % COSTANTI
THIS_FUNCTION = mfilename;
% % INIZIO FUNCTION
try 
   % elimino dal cell array tutte le parti vuote
   bEmpty = false(size(Cell));
   [r,c] = size(Cell);
   for i = 1:r
      for j = 1:c
         bEmpty(i,j) = isempty(Cell{i,j});
      end
   end
   bColEmpty = all(bEmpty,1);
   bRowEmpty = all(bEmpty,2);
   CellFull = Cell(not(bRowEmpty),not(bColEmpty));
   %
   % separo la parte numerica da quella di intestazione
   [r,c] = size(CellFull);
   bNumeric = false(size(CellFull));
   for i = 1:r
      for j = 1:c
         bNumeric(i,j) = isnumeric(CellFull{i,j});
      end
   end
   %
   % cerco le righe con soli numeri
   b1 = all(bNumeric,2);
   cDati = CellFull(b1,:);
   cIntestazione = CellFull(not(b1),:);
   
% % GESTIONE ERRORI 
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




