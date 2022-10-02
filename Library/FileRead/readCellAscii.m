function [cInt, cData] = readCellAscii(sFileIn, varargin)

%%% gestione opzioni varargin

% init 
cInt = {};
cData = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% varargin management
nRowsHead = 2; % default for header rows
delim = 9; %9: tab; 32: space
bString = false;
if not(isempty(varargin))
    % header length
    a = find(strcmpi(varargin, 'nRowsHead'));
    if not(isempty(a))
        nRowsHead = varargin{a+1};
    end
end

% determino se sFileIn è una stringa o un file
if isempty(sFileIn)
    cInt = {''};
    cData = {''};
   return
else
   if bString
      % scansione di una stringa
      bFile = false;
   else
      % scansione di un file
      if exist(sFileIn, 'file') == 2
         % ile file esiste
         bFile = true;
      else
         disp(['Warning: filescan: file "', sFileIn, '" doesn''t exist or may be its name is not Windows compliant'])
         cInt = {''};
         cData = {''};
         return
      end
   end
end

if bFile
   fid = fopen(sFileIn, 'r'); %se apro con opz 'rt', taglia tutti i \r
   if fid==-1
      if not(isempty(sFileIn))
         sStatus1 = ['Errore: non è stato possibile accedere in sola lettura al file "',sFileIn,'": controllare l''esistenza del file'];
         disp(sStatus1);
      end
      cInt = {''};
      cData = {''};
      return
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---ricerca delle sezioni del file---
%
%%% metto il file in una stringa
if bFile
   sFile = fscanf(fid, '%c');
   fclose(fid);
else
   sFile = sFileIn;
end


%%% posizioni in bites di inizio riga:
% in posFile(i) ci deve essere l'inizio di riga(i):
% sLine = sFile(posFile(i):posFile(i+1)-1)
% posFile ha righe+1 di sFile di elementi
% posFile(end) deve essere length(sFile)+1
posFile = find(sFile(:)==10)+1; % 10: \n
posFile(2:end+1) = posFile;
posFile(1) = 1;
%
if posFile(end)-1 > length(sFile);
   posFile = posFile(1:end-1);
elseif posFile(end)-1 < length(sFile)
   posFile(end+1) = length(sFile)+1;
end

%%% metto in XMP i dati
% estraggo la prima colonna (dice rapidamente quante righe ci sono)

primaRiga = int8(sFile(posFile(1):posFile(2)-1));
nCol = sum(primaRiga==delim)+1;
cAll = estraiCellArray(sFile, posFile, nCol);
%
if size(cAll,1)>0
    cInt = cAll(1:min(size(cAll,1),nRowsHead), :);
end
if size(cAll,1)>2
    cData = cAll(nRowsHead+1:end, :);
end


return

function c = estraiCellArray(sFile, posFile, nCol)

delim = 9; % tab
c = cell(length(posFile)-1, nCol);

if length(posFile)==2
    % in case only one line is contained into file
    c0 = stringDivide(sFile, delim);
    % scrivo su cella di out
    c(1,:) = c0;
else
    % ciclo sulle righe
    for i = 1:length(posFile)-1
        % stringa della riga
        s0 = sFile(posFile(i):posFile(i+1)-1);
        % tolgo delimitatori finale
        s0 = s0(1:end-2);
        % divido una riga in "parole"
        c0 = stringDivide(s0, delim, 'lastDelRem', false);
        % scrivo su cella di out
        c(i,1:length(c0)) = c0;
    end
end


return