%% 2015-1109..dpe
function [cOutput,errore_file]=putTXTFileInACell(varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;
errore_file='ok'; 

% % INIZIO FUNCTION
try 
   cOutput={};
   if nargin>0
      sPathFile=varargin{1};
   else
      [errore_file]=['Numero insufficiente di argomenti di input in ', THIS_FUNCTION];
      return;
   end
   if nargin>1
      sep=varargin{2};
   else
      sep='TAB';
   end
   
   if ~exist(sPathFile)
       errore_file=nText('FILE NOT PRESENT:',2, sPathFile);
       return;
   end
   % apri file
   fID=fopen(sPathFile);

   nRows=0;
   nCols=0;
   Matrix={};
   while  ~feof(fID);
      sLine=fgetl(fID);
      if ~ischar(sLine), break, end;
      nRows=nRows+1;
      [mStrings, mCells]=splitString(sLine,sep);
      [r]=length(mCells);

      if r>0
         for j=1:r
            Matrix{nRows,j}=mCells{j};
         end
      else
          Matrix{nRows,1}='';
      end
   end
  
   cOutput=Matrix;
   status = fclose(fID);
   
% % GESTIONE ERRORI
catch
   [errore_file]=gestErr2(THIS_FUNCTION);
   status = fclose(fID);
end

return
