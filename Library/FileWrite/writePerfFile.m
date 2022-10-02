function writePerfFile(sFile, tInfo, cIntest, mDati, varargin)

% scrive il file "sFile" usando formato di Perfects (ex: .PQM, .PED,
% .CM...).
%
% argomenti opzionali
% newFormat: ['true','false']: se true (default) usa il formato a sezioni, se old
%         scrive i soli dati e intestazioni senza struttura di informazioni
% infoFormat; {'2col', '3col'}: 
%               2 col: fields and value
%               3 col: field, value and units

% gestione varargin
bNewFormat = 'true';
sInfoFormat = '3col';
if not(isempty(varargin))
   %
   i = find(strcmpi(varargin(:),'newFormat'));
   if not(isempty(i))
      bNewFormat = varargin{i+1};
   end
   %
   i = find(strcmpi(varargin(:),'infoFormat'));
   if not(isempty(i))
      sInfoFormat = varargin{i+1};
   end
end

%%% scrittura file
sFileCut = cutFileName(sFile); % eventuale troncatura file lunghi 
if not(strcmpi(sFileCut,sFile))
   [dum, s1, sExt1] = fileparts1(sFile);
   [dum, s2, sExt2] = fileparts1(sFileCut);
   disp(['Warning: original file name "', [s1 sExt1],'" will be cut to "', [s2 sExt2], '" because of Windows maximum path length limitation."'])
end
fid = fopen(sFileCut, 'w');
if fid == -1
   % impossibile aprire il file
   disp(['Warning: file "',sFileCut,'" will not be written because of problems in opening file. Make sure the file is not already opened by some other application.'])
   return
end

if bNewFormat
   %%% sezione informazioni
   % start
   fprintf(fid, '%s\r\n', '<Info>');
   % informazioni
   writeStructAscii(fid, tInfo, '%f', '\t', '', sInfoFormat);
   % end
   fprintf(fid, '%s\r\n', '</Info>');
   %
   %%% sezione dati
   % start
   fprintf(fid, '%s\r\n', '<Dati>');
   % intestazione
   writeCellAscii(fid, cIntest, '\t', '');
   % dati
   writeMatAscii(fid, mDati, '%f', '\t', '');
   % end
   fprintf(fid, '%s', '</Dati>');
else
   %%% sezione informazioni
   if isempty(cIntest{1}) && isempty(mDati)
      % informazioni
      writeStructAscii(fid, tInfo, '%f', '\t', '', sInfoFormat);
   elseif isempty(tInfo)
      %%% dati
      % intestazione
      writeCellAscii(fid, cIntest, '\t', '');
      % dati
      writeMatAscii(fid, mDati, '%f', '\t', '');
   end
end
%
fclose(fid);
return
%