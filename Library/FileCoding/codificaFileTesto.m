
function cOut = codificaFileTesto(cFilesIn, key, bCod, bWrite)

% cOut = codificaFileTesto(cFilesIn, key, bCod)
% codifica e decodifica i files di testo (US-ASCII) cFilesIn mediante la chiave key
% (int8 positivi) e li scrive su disco apponendo l'estenzione .cod
% cOut contiene il contenuto dei files
% bCod: se vero codifica, se falso decodifica.
% bWrite: se vero scrive, se falso no

if isempty(cFilesIn)
   [cFilesIn, spath] = uigetfile({'*.*','file di testo con codifica US-ASCII'}, 'seleziona i files da codificare', 'MultiSelect','on');
   if isnumeric(cFilesIn) && isequal(cFilesIn,0)
      % se premo annulla
      return
   end
else
   spath = '';
end
if ischar(cFilesIn)
   cFilesIn = {cFilesIn};
end

cOut = cell(length(cFilesIn),1);
for i = 1:length(cFilesIn)
   
   % legge il file e lo mette in una stringa
   sFileIn = [spath, cFilesIn{i}];
   if not(exist(sFileIn, 'file')==2)
      disp(['Warning: il file "', sFileIn, '" non esiste!'])
      continue
   end
   fid = fopen(sFileIn, 'r');
   sRead = fscanf(fid, '%c');
   fclose(fid);
   
   % codifica il file
   sCod = codifica(int8(sRead), key, bCod);
   cOut{i} = sCod(:)';
    
   % scrive il file di out (se richiesto)
   if bWrite
      if bCod
         sFileOut = [sFileIn, '.cod'];
      else
         sFileOut = [sFileIn, '.dec'];
      end
      fid = fopen(sFileOut, 'w', 'native','US-ASCII');
      fprintf(fid, '%c', char(cOut{i}));
      fclose(fid);
   end
   
end

return