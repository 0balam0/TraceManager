function [tInfo, cIntest, mDati, sStatus] = filescan(sFileIn, varargin)

%%% [tInfo, cIntest, mDati, cStatus] = FILESCAN(sFileIn, varargin)
% FILESCAN estrae dal file di testo o dalla stringa sFileIn (per il formato vedere sotto)
% le sottoparti di cui è composto:
% tInfo: struttura di informazioni (parametro, valore); i valori sono
% convertiti in numeri
% cIntest: cell array di intestazione dati
% mDati: matrice di dati
% sStatus: stringa di errore
%
% OPZIONI:
% vectConv: {true|false} se vero cerca di convertire i valori specificati nella
%           struttura di informazioni in vettori double; altrimenti eventuali vettori
%           verranno lasciati in stringhe; default: false
% delimiter: delimitore dei campi di testo, in codifica acii (ex: tab è 9);
%            default: tab
% delimiterInfo: delimitore dei campi di una struttura di informazioni, che
%                possono essere diversi dal delimiter conevezionale
% string: {true|false}avverte filescan che si vuole scansionare una stinga e non un
% file
%
%%% PROMEMORIA FORMATI C
% \t: 9
% \r: 13
% \n: 10
% \b: 8 (backspace)
% spazio: 32
% per verificarli: int8(sprintf('\n'))
% oppure: int8(' stringa ')
%
%%% FORMATI DI FILE SUPPORTATI (modalità):
% 1: formato a sezioni (nuovo),  informazioni: Y, dati e intestazione: Y
% 2: formato a sezioni (nuovo), informazioni: Y, dati e intestazione: N
% 3: formato a sezioni (nuovo), informazioni: N, dati e intestazione: Y
% 4.1: formato senza sezioni (vecchio), solo dati con intestazione
% 4.2: formato senza sezioni (vecchio), solo dati senza intestazione
% 4.3: formato senza sezioni (vecchio), solo informazioni
% 4.4: formato senza sezioni (vecchio), solo intestazione

% init
tInfo = struct();
cIntest = cell(1,0); % {''}
mDati = [];
sStatus = '';

%%% gestione opzioni varargin
% default
bVect = false;
delim = 9; % tab
delimInfo = delim;
bString = false;
bNewInfo = false;
nRowsHead = -1; % automatic
dataFormat = -1; % automatic
modeTabInit = -1; % automatic
%
if not(isempty(varargin))
    %
    a = find(strcmpi(varargin,'vectConv'));
    if not(isempty(a))
        bVect = logical(varargin{a+1});
    end
    %
    a = find(strcmpi(varargin,'delimiter'));
    if not(isempty(a))
        delim = varargin{a+1};
    end
    %
    a = find(strcmpi(varargin,'delimiterInfo'));
    if not(isempty(a))
        delimInfo = varargin{a+1};
    end
    %
    a = find(strcmpi(varargin,'string'));
    if not(isempty(a))
        bString = logical(varargin{a+1});
    end
    %
    a = find(strcmpi(varargin,'newInfo'));
    if not(isempty(a))
        bNewInfo = logical(varargin{a+1});
    end
    %
    a = find(strcmpi(varargin,'nRowsHead'));
    if not(isempty(a))
        nRowsHead = varargin{a+1};
    end
    %
    a = find(strcmpi(varargin,'dataFormat'));
    if not(isempty(a))
        dataFormat = varargin{a+1};
    end
    a = find(strcmpi(varargin,'modeTabInit'));
    if not(isempty(a))
        modeTabInit = varargin{a+1};
    end
end

try
    %
    % puts file content in a string
    [sFile, sStatus] = putContentInString(sFileIn, bString);
    if ~isempty(sStatus)
        disp(sStatus)
        return
    end
    %
    % gets infos about structure of the file
    [modo, posFile, posFileS, rInfo, rDati, sStatus] = modeFormatDetection(sFile, sFileIn, delim, dataFormat, nRowsHead, modeTabInit);
    if ~isempty(sStatus)
        disp(sStatus)
        return
    end
    %
    % get all data from file
    [tInfo, cIntest, mDati] = extractContent(modo, sFile, posFileS, posFile, rInfo,delimInfo,bVect,bNewInfo, rDati,delim,nRowsHead);
catch
    % errori vari
    sStatus = ['Error: could not correctly read file "', sFileIn];
end


return

function [sFile, sStatus] = putContentInString(sFileIn, bString)

% init
sFile = '';
sStatus = '';

% determino se sFileIn è una stringa o un file
if isempty(sFileIn)
    sStatus = 'empty string';
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
         sStatus = ['Warning: filescan: file "', sFileIn, '" doesn''t exist or may be its name is not Windows compliant'];
         return
      end
   end
end

if bFile
   fid = fopen(sFileIn, 'r'); %se apro con opz 'rt', taglia tutti i \r
   if fid==-1
      if not(isempty(sFileIn))
         sStatus = ['Error: could not access "',sFileIn,'": check if file exists'];
      end
      return
   end
end

%
%%% metto il file in una stringa
if bFile
   sFile = fscanf(fid, '%c');
   fclose(fid);
else
   sFile = sFileIn;
end

return

function [modo, posFile, posFileS, rInfo, rDati, sStatus] = modeFormatDetection(sFile, sFileIn, delim, dataFormat, nRowsHead, modeTabInit)

% init
modo = [];
posFile = [];
posFileS = [];
rInfo = [];
rDati = [];
sStatus = '';

% overrides autodetection
bForceFormat = dataFormat>0;
if bForceFormat
    modo = dataFormat;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---ricerca delle sezioni del file---
%
% definizione sezioni di interesse
sSezInfo = 'Info';
sSezDati = 'Dati';
sDelSez = '<>';
%
sSezInfoS = [sDelSez(1), sSezInfo, sDelSez(2)];
sSezInfoE = [sDelSez(1), '/', sSezInfo, sDelSez(2)];
sSezDatiS = [sDelSez(1), sSezDati, sDelSez(2)];
sSezDatiE = [sDelSez(1), '/', sSezDati, sDelSez(2)];

% estraggo la prima colonna (dice rapidamente quante righe ci sono)
c = textscan(sFile, '%s%*[^\n]', 'collectoutput',1, 'delimiter',char(delim)); %prima colonna
c1 = c{:};
%%% posizioni in bites di inizio riga:
% in posFile(i) ci deve essere l'inizio di riga(i):
% sLine = sFile(posFile(i):posFile(i+1)-1)
% posFile ha righe+1 di sFile di elementi
% posFile(end) deve essere length(sFile)+1
posFile = find(sFile==10)+1; % 10: \n
posFile(2:end+1) = posFile;
posFile(1) = 1;
if posFile(end)-1 > length(sFile);
   posFile = posFile(1:end-1);
elseif posFile(end)-1 < length(sFile)
   posFile(end+1) = length(sFile)+1;
end
%%% eliminazione righe finali di sFile vuote
for i = length(posFile)-1:-1:1
   s = strtrim(sFile(posFile(end-1):posFile(end)-1));
   if isempty(s)
      posFile = posFile(1:end-1);
      sFile = sFile(1:posFile(end)-1);
   else
      break
   end
end
c1 = c1(1:length(posFile)-1);

%
%%% ricerca righe inizio-fine sezioni
rInfo = [0 0]'; % riga di inizio-fine sezione informazioni
rDati = [0 0]'; % riga di inizio-fine sezione dati
bInfo = false;
bDati = false;
% tab at beginning of each row
bTabIniz = false(size(c1));
if modeTabInit==0
    bTabIniz = false(size(c1));
elseif modeTabInit==1
    bTabIniz = true(size(c1));
end
%
% ciclo sulle righe
for r  = 1:length(c1)
    s1 = c1{r};
    if modeTabInit==-1
        % autodetect
        bTabIniz(r) = isempty(s1);
    end
    if ~bForceFormat || nRowsHead==-1
        % autodetection of mode format
        if not(bTabIniz(r)) && strcmpi(s1(1),sDelSez(1)) % carattere di inizio o fine sezione
            % struttura di info
            if not(bInfo) && length(s1)>= length(sSezInfoS) && strcmp(s1(1:length(sSezInfoS)), sSezInfoS)
                rInfo(1) = r+1;
                bInfo = true;
            end
            if bInfo && not(bDati) && length(s1)>= length(sSezInfoE) && strcmp(s1(1:length(sSezInfoE)), sSezInfoE)
                rInfo(2) = r-1;
                bInfo = false;
            end
            % struttura di dati
            if not(bDati) && length(s1)>= length(sSezDatiS) && strcmp(s1(1:length(sSezDatiS)), sSezDatiS)
                bDati = true;
                rDati(1) = r+1;
            end
            if bDati && not(bInfo) && length(s1)>= length(sSezDatiE) && strcmp(s1(1:length(sSezDatiE)), sSezDatiE)
                rDati(2) = r-1;
                bDati = false;
            end
        end
    else
        % force of mode format
        switch dataFormat
            case 4.1
                rInfo = [1 nRowsHead]';
                rDati = [nRowsHead+1 length(c1)]';
            otherwise
                disp('TODO: manage other cases')
                return
        end
    end
end
%
%%% COMPATIBILITA files vecchi (senza sezioni)
if ~bForceFormat
    if rInfo(1)>0 && rDati(1)>0
        % file in formato nuovo
        modo = 1;
    elseif rInfo(1)>0 && rDati(1)==0
        % file in formato nuovo ma con sola sezione info
        modo = 2;
    elseif rInfo(1)==0 && rDati(1)>0
        % file in formato nuovo ma con sola sezione dati
        modo = 3;
    elseif rInfo(1)==0 && rDati(1)==0
        % file in formato vecchio, senza sezioni (penso siano o tutti dati o tutte informazioni)
        modo = 4;
    else
        % file correttamente non trattabile
        sStatus = ['Error: file "',sFileIn,'" has a unexpected format'];
        return
    end
end
%
%%% TAB davanti alle sezioni (suppongo quella di informazioni
%%% coerente con quella di dati
if modo==1 
   % dati e info
   idx = rInfo(1):rInfo(2);
   if isempty(idx)
      idx = rDati(1):rDati(2);
   end
   bTab1 = bTabIniz(idx);
elseif modo==2
   % solo info
   bTab1 = bTabIniz(rInfo(1):rInfo(2));
elseif modo==3
   % solo dati
   bTab1 = bTabIniz(rDati(1):rDati(2));
elseif modo>=4 && modo<5
   bTab1 = bTabIniz;
end
if all(bTab1)
   bTabInizInfo = true;
elseif all(not(bTab1))
   bTabInizInfo = false;
else
   sStatus = ['Error: file "',sFileIn,'" has wrong format becasue of beginning separators'];
   return
end
% gestione del tab (modifico la stringa da scansionare) 
if bTabInizInfo
   % se c'è il tab a inizio delle varie sezioni, leggo le linee del file
   % dal tab in poi
   posFileS = posFile + 1;
else
   posFileS = posFile;
end

% riconoscimento dettagliato dei file vecchi: sono informazioni o dati?
if ~bForceFormat
bErr = false;
if modo==4
   % prima riga
   i = 1;
   sLine = sFile(posFileS(i):posFile(i+1)-1);
   cS1 = textscan(sLine, '%s', 'delimiter',char(delim));
   cF1 = textscan(sLine, '%f', 'delimiter',char(delim));
   nCol1 = length((find(sLine==delim))) + 1;
   % ultima riga
   i = length(c1);
   sLine = sFile(posFileS(i):posFile(i+1)-1);
   cSe = textscan(sLine, '%s', 'delimiter',char(delim));
   cFe = textscan(sLine, '%f', 'delimiter',char(delim));
   nCole = length(find(sLine==delim)) + 1;
   %%% riconoscimento
   if length(cS1{1}) == length(cF1{1})
      % prima riga numerica
      bNum1 = true;
   else
      bNum1 = false;
   end
   if length(cSe{1}) == length(cFe{1})
      % ultima riga numerica
      bNume = true;
   else
      bNume = false;
   end 
   %
   if not(bNum1) && bNume && nCol1==nCole
      % file di dati con intestazione
      modo = 4.1;
   elseif bNum1 && bNume && nCol1==nCole
      % file di dati senza intestazione
      modo = 4.2;
   elseif not(bNum1) && not(bNume) && nCol1==nCole
      if nCol1<=2 % ==2
         % file di informazioni (struttura)
         modo = 4.3;
      else 
         % file di intestazione
         modo = 4.4;
      end
   else
      bErr = true;
   end
end
if bErr
   sStatus = ['Error: file "',sFileIn,'" has a unexpected format'];
   return
end
end
%
% gestione compatibilità con formato vecchio
if modo >=4
   switch modo
      case 4.1
         rDati(1) = 1;
         rDati(2) = length(c1);
      case 4.2
         rDati(1) = 1;
         rDati(2) = length(c1);
      case 4.3
         rInfo(1) = 1;
         rInfo(2) = length(c1);
      case 4.4
         rDati(1) = 1;
         rDati(2) = length(c1);
   end
end

return

function [tInfo, cIntest, mDati] = extractContent(modo, sFile, posFileS, posFile, rInfo,delimInfo,bVect,bNewInfo, rDati,delim,nRowsHead)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---estrazione struttura di informazioni---
%
if modo==1 || modo==2 || modo==4.3
   tInfo = estraiInfoNew(sFile, posFileS, posFile, rInfo, delimInfo, bVect, bNewInfo);
else
   tInfo = struct([]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---estrazione parte di intestazione---
% 
rDatiEff = [];
if modo==1 || modo==3 || modo==4.1 || modo==4.4
   [cIntest, nCol, rDatiEff] = estraiInt(sFile, posFileS, posFile, rDati, delim, nRowsHead);
else
   cIntest = cell(1,0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%---estrazione parte di dati---
%
if modo == 4.2
   % ottengo il numero di colonne considerandolo stringa
   cS = textscan(sFile(posFileS(rDati(2)):posFile(rDati(2)+1)-1), '%s', 'delimiter',char(delim));
   nCol = length(cS{1});
   rDatiEff = rDati(1);
end
%
if (modo==1 || modo==3 || modo==4.1 || modo==4.2) && not(isempty(rDatiEff))
    mDati = estraiDati(sFile, posFileS, posFile, rDati, rDatiEff, nCol, delim);
else
    mDati = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eliminazione colonne di matrice e intestazione vuote causa file salvato in
% modo improprio (ex: PQM)

if (modo==1 || modo==3 || modo==4.1) && not(isempty(rDatiEff))
   [cIntest, mDati] = eliminaColonneVuote(cIntest, mDati, rDatiEff);
end


return

function tInfo = estraiInfoNew(sFile, posFileS, posFile, rInfo, delimInfo, bVect, bNewOutFormat)

% init
tInfo = struct();

% chech if info session is empty
if rInfo(1)>rInfo(2)
    return
end
N_fields = rInfo(2)-rInfo(1)+1;

% check first line to undertand the number of columns in file
i1 = rInfo(1);
sLine = sFile(posFileS(i1):posFile(i1+1)-1);
nColIn = length((find(sLine==delimInfo))) + 1;
% allocates format string
sFormat = '';
for i = 1:nColIn
    sFormat = [sFormat, '%s'];
end

% prepares dimensions for output data
if bNewOutFormat
    nColOut = 3;
else
    nColOut = 2;
end

% keep traces if value was not assigned
bEmptyValue = false(N_fields,1);
% c1 contains data into a cell matrix
c1 = cell(N_fields, nColOut);

% reads row by row
for i = rInfo(1):rInfo(2)
    i1 = i-rInfo(1)+1;
    % put whole row into one cell
    c0 = textscan(sFile(posFileS(i):posFile(i+1)-1), sFormat, 'delimiter',char(delimInfo));
    bEmptyValue(i1) = isempty(c0{2}{1});
    % assings cells into matrix
    for j = 1:nColIn
        c1{i1,j} = c0{j}{1};
    end
end


tab_corr={'[row]' 'x_i' 'x';...
          '[col]' 'y_i' 'y';};

exp_map{1,1} = c1(:,2); % compact second coloumn into one cell
idx_map= find(strncmpi(exp_map{:,1},'[val]',5));
if ~isempty(idx_map)
idx_expand_in = length(c1);
    for k=1:length(idx_map)
        %val
        str = c1{idx_map(k),2};
        str1= strrep(str,'||','|nan|');
        str2= strrep(str1,'|', ' ');
        
        row_name='';
        col_name='';
        idx_xy = strfind(str2,'+[');
        switch length(idx_xy)
            case 0 %case 0-D
               [~,map_um, map_val] = divide_str_intMap(str2); 
            
            case 1 %case 1-D
                idx_expand_in=idx_expand_in+1;
                
                str_xy=str2(idx_xy+1:length(str2));
                [int_name, idx_um, idx_val] = divide_str_intMap(str_xy);
                xy=find(strcmpi(tab_corr,int_name));
                idx_name=tab_corr(strcmpi(tab_corr,int_name),2);
                idx_name = [c1{idx_map(k),1},'_',idx_name{1}];
                
                if xy == 1
                    row_name = idx_name;
                else
                    col_name = idx_name;
                end
                str_map=str2(1:idx_xy(1)-1);
                [~, map_um, map_val] = divide_str_intMap(str_map);
                
                c1{idx_expand_in,1} = idx_name;
                c1{idx_expand_in,2} = idx_val;
                c1{idx_expand_in,3} = idx_um;
                bEmptyValue(idx_expand_in) = 0;
            
            case 2 %case 2-D
                idx_expand_in=idx_expand_in+1;
                %nomi
                row_name = [c1{idx_map(k),1},'_x_i'];
                col_name = [c1{idx_map(k),1},'_y_i'];
                
                str_row=str2(idx_xy(1)+1:idx_xy(2)-1);
                [~, row_um, row_val] = divide_str_intMap(str_row);
                str_col=str2(idx_xy(2)+1:length(str2));
                [~, col_um, col_val] = divide_str_intMap(str_col);
                str_map=str2(1:idx_xy(1)-1);
                [~, map_um, map_val] = divide_str_intMap(str_map);
                  
                %add row e col
                c1{idx_expand_in,1} = row_name;
                c1{idx_expand_in,2} = row_val;
                c1{idx_expand_in,3} = row_um;
                bEmptyValue(idx_expand_in) = 0;
                idx_expand_in=idx_expand_in+1;
                
                c1{idx_expand_in,1} = col_name;
                c1{idx_expand_in,2} = col_val;
                c1{idx_expand_in,3} = col_um;
                bEmptyValue(idx_expand_in) = 0;
    
        end 
        c1{idx_map(k),2} = map_val;
        c1{idx_map(k),3} = map_um;
        c1{idx_map(k),4} = row_name;
        c1{idx_map(k),5} = col_name;
    end
end
% compact rows into one row
c = cell(1, nColOut);
for j = 1:nColOut
    c{1,j} = c1(:,j);
end

% conversion into double of values not empty, if possible (othewise you have
% empty strings)
c{2}(not(bEmptyValue)) = cell2num(c{2}(not(bEmptyValue)), bVect);

% writes output structure
if exist('idx_expand_in','var')
  N_fields=idx_expand_in;
end
for i = 1:N_fields
   % char(48) = '0'; char(57) = '9'
   % char(65) = 'A'; char(90) = 'Z'
   % char(95) = '_'
   % char(97) = 'a'; char(122) = 'z'
   %
   % correct format for fields
   sF = validField(c{1}{i},'_');
   % assigns fields of out
   if bNewOutFormat
       % values and units
       tInfo.(sF).v = c{2}{i};
       tInfo.(sF).u = c{3}{i};
   else
       % only values
       tInfo.(sF) = c{2}{i};
   end
end

if ~isempty(idx_map)
    for i = 1:length(idx_map)
        % char(48) = '0'; char(57) = '9'
        % char(65) = 'A'; char(90) = 'Z'
        % char(95) = '_'
        % char(97) = 'a'; char(122) = 'z'
        %
        % correct format for fields
        sF = validField(c{1}{idx_map(i)},'_');
        % assigns fields of out
        if bNewOutFormat
            % values and units
            tInfo.(sF).v = tInfo.(sF).v;
            tInfo.(sF).u = tInfo.(sF).u;
           tInfo.(sF).x = c1{idx_map(i),4};
           tInfo.(sF).y = c1{idx_map(i),5};
        end
    end
end
return

function [cIntest, nCol, rDatiEff] = estraiInt(sFile, posFileS, posFile, rDati, delim, nRowsHead)

% init
cIntest = {''};
nCol = [];
rDatiEff = [];
bAutoDetect = nRowsHead<=0;

% check if there is a data section
if rDati(1)>rDati(2)
    return
end


rDatiEff = [];
rHeadStart = rDati(1);
rHeadEnd = rDati(2);
if ~bAutoDetect
    % force number of headers rows (zero or negative = auto)
    rHeadEnd = min(rHeadEnd, rHeadStart+nRowsHead-1);
end
%
for i = rHeadStart:rHeadEnd
    % ciclo su tutte le righe di cInt + mDati, scansiono una riga alla
    % volta con textscaN
    i1 = i-rHeadStart+1;
    sLine = sFile(posFileS(i):posFile(i+1)-1);
    cS = textscan(sLine, '%s', 'delimiter',char(delim));
    cF = textscan(sLine, '%f', 'delimiter',char(delim));
    if i1 == 1
        nCol = length((find(sLine==delim))) + 1;
        cIntest = cell(nRowsHead,nCol);
    end
    % controllo uscita
    % controllo convertibilità in double
    if bAutoDetect
        if length(cS{1}) == length(cF{1})
            % se tutti numeri significa che sono nella sezione appena entrato in Dati, quindi esco
            rDatiEff = i;
            break
        end
    end
    %
    % sicurezza contro errore di meno elementi estratti da textscan rispetto ai delimitatori
    cIntest(i1,1:length(cS{1})) = cS{1};
    % se l'ultimo carattere scritto è una stringa allora completo la riga
    % corrente con stringhe vuote
    if ischar(cIntest{i1,length(cS{1})})
        for j = length(cS{1})+1:nCol
            cIntest{i1,j} = '';
        end
    end
end

%
if ~bAutoDetect
    rDatiEff = rHeadEnd+1;
end

return

function mDati = estraiDati(sFile, posFileS, posFile, rDati, rDatiEff, nCol, delim)

sf = '%f';
sFormat = '';
for i = 1:nCol
   sFormat = [sFormat, sf];
end

mDati = zeros(rDati(2)-1-rDatiEff+1, nCol);
v = zeros(1, nCol);
for i = rDatiEff:rDati(2)
    i1 = i-rDatiEff+1;
    % put in row
    sRow = sFile(posFileS(i):posFile(i+1)-1);
    %
    % OLD: textscan was used
    %        c = textscan(sRow, sFormat, 'collectoutput',1, 'delimiter',char(delim));
    %        v = c{1};
    %
    % sscanf returns array of double elements for all row
    val = sscanf(sRow, sFormat);
    if length(val) == nCol
        v = val;
    end
    %
    % in case sscanf fails to extract all expected values,
    % a slower but safer scalar approach is used
    if length(val) < nCol
        cRow = stringDivide(sRow, delim, 'lastDelRem', false);
        for j = 1:nCol
            val = sscanf(cRow{j},'%f');
            v(j) = NaN;
            if ~isempty(val) && length(val)==1
                v(j) = val;
            end
        end
    end
    %
    % record to output array
    mDati(i1,:) = v;
end
%
try
catch ME
   disp(ME.error)
end

return

function [cIntest, mDati] = eliminaColonneVuote(cIntest, mDati, rDatiEff)

%
% colonne vuote dell'intestazione (purtroppo non c'è comando matriciale
% come isnan..., devo fare ciclo)

rInt = size(cIntest,1);
cInt = size(cIntest,2);
bColFullInt = false(1,cInt);
for i = 1:cInt
   for j = 1:rInt
      if not(isempty(cIntest{j,i}))
         bColFullInt(i) = true;
         break
      end
   end
end
bColEmptyInt = not(bColFullInt);
%
% colonne vuote dei dati
if not(isempty(rDatiEff))
   bColEmptyDati = all(isnan(mDati),1);
else
   bColEmptyDati = bColEmptyInt;
end
%
% elimazione colonne vuote comuni da intestazioni e dati
bColEmpty = all([bColEmptyInt; bColEmptyDati],1);
cIntest = cIntest(:,not(bColEmpty));
if not(isempty(rDatiEff))
   mDati = mDati(:,not(bColEmpty));
end
%
% warning a video:
% if any(bColEmpty)
%    disp(['Warning: file ', sFileIn, ' has some empty columns; please resave it.'])
% end

return

% function   [int_um, int_val] = divide_str_intMap(s)
% remain = s;
%   
%   [str, remain] = strtok(remain, ']');
%   [int_um, remain] = strtok(remain, ']'); 
%   int_um=[int_um,']'];
%   [int_val, remain] = strtok(remain, ']');
%    int_val=[int_val,']'];
% return

function   [int_name, int_um, int_val] = divide_str_intMap(s)

remain = s;
[str, remain] = strtok(remain, ']');
int_name=[str,']'];
[int_um, remain] = strtok(remain, ']');
int_um=[int_um,']'];
[int_val, remain] = strtok(remain, ']');
int_val=[int_val,']'];

return







