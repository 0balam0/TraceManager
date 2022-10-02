function Cal = readCsvCal(FileCsv)

Cal=struct();

fidR = fopen(FileCsv);
if (fidR == -1)
    disp('Unable to open file for reading')
    return
end

try
    Cal = Leggi_calibrazioni(fidR);
catch %#ok<CTCH>
    fclose(fidR);
    disp('Error in file reading')
    disp(lasterr) %#ok<LERR>
    return
end
fclose(fidR);

return

function Cal = Leggi_calibrazioni(fidR)


%%% parametri utili
keywords = {'VALUE', 'AXIS_PTS', 'VAL_BLK', 'CURVE', 'MAP', 'X_AXIS_PTS', 'Y_AXIS_PTS'};
nKW = length(keywords);


%%% Leggo riga per riga
bSaveInt = true;   % flag salvataggio intestazione
intestazione = {};
calib = struct();
n = 0;
while 1     % ciclo indefinito fino al termine del file
    n = n+1;
    lineHere = fgetl(fidR);
    if ~ischar(lineHere)    % end of file..
        break
    end
    
    if bSaveInt
        intestazione = [intestazione; {lineHere}];
    end
    
    if n==1
        line2ndLast = lineHere;
        continue
    elseif n==2
        lineLast = lineHere;
        continue
    elseif n==3
        lineCurr = lineHere;
    else
        line2ndLast = lineLast;     % dal passo precedente..
        lineLast = lineCurr;
        lineCurr = lineHere;
    end
    
    % cerco una keyword
    bKW = false(nKW,1);
    for nw = 1:nKW
        bKW(nw) = any(strfind(lineCurr, keywords{nw})==1);
    end
    if ~any(bKW)
        continue
    end
    
    % trovo linea con nome variabile
    if ~isempty(strfind(lineLast, '* format'))
        varName = line2ndLast;
        if bSaveInt
            intestazione = intestazione(1:end-3);
        end
    else
        varName = lineLast;
        if bSaveInt
            intestazione = intestazione(1:end-2);
        end
    end
    varName = strrep(varName, ';', '');
    varName = strrep(varName, ',', '');
    varName = strrep(varName, '.', '_');    % formato "VECTOR"
    keyword = keywords{bKW};
    
    calib = calibUpdater(calib, varName, lineCurr, keyword, fidR);
    bSaveInt = false;    % d'ora in poi non aggiorno più l'intestazione
end

Cal.intestazione = intestazione;
Cal.calib = calib;

return

function calib = calibUpdater(calib, varName, lineCurr, keyword, fidR)

if ~isfield(calib, varName)
    % variabili "stand-alone"
    Variable = struct('CLASS',  '',...
        'VALUE',    [],...
        'HBK_NAME', '',...
        'HBK_VALUE',[],...
        'VBK_NAME', '',...
        'VBK_VALUE',[],...
        'FUNCTION', '');
else
    % breakpoint vectors
    Variable = calib.(varName);
end

switch keyword
    case {'VALUE', 'AXIS_PTS', 'VAL_BLK'}
        bXYaxis = false;
        val = str2array(lineCurr);
        if iscell(val) % Detects text on .csv row and converts to double
            val=val(2:end);
            val = str2double(val);
        end
        if isempty(val) && ~isempty(strfind(lineCurr, 'FALSE')) % Detecs FALSE / TRUE
            val=0;
        elseif isempty(val) && ~isempty(strfind(lineCurr, 'TRUE'))
            val=1;
        end
        lineCurr = fgetl(fidR);     % mi metto nella riga successiva
    case 'CURVE'
        bXYaxis = false;
         lineCurr = strrep(lineCurr, ',', ';');
        idx = strfind(lineCurr, ';');
        if length(idx)>1
            if idx(2)>idx(1)+1      % ha il suo vettore BK incorporato
                Variable.VBK_NAME = lineCurr(idx(1)+1:idx(2)-1);
                Variable.VBK_VALUE = str2array(lineCurr(idx(2):end));
            end
        end
        lineCurr = fgetl(fidR);
        val = str2array(lineCurr);
        lineCurr = fgetl(fidR);     % mi metto nella riga successiva
    case 'MAP'
        bXYaxis = false;
        vbk_name = '';
            lineCurr = strrep(lineCurr, ',', ';');
        idx = strfind(lineCurr, ';');
        if ~isempty(idx)
            if idx(1)<length(lineCurr)
                vbk_name = strrep(lineCurr(idx(1)+1:end), ';', '');
            end
        end
        lineCurr = fgetl(fidR);
        if ~isempty(vbk_name)   % ha i suoi vettori BK incorporati
            bBK = true;
            Variable.VBK_NAME = vbk_name;
                lineCurr = strrep(lineCurr, ',', ';');
            idx = strfind(lineCurr, ';');
            Variable.HBK_NAME = lineCurr(idx(1)+1:idx(2)-1);
            Variable.VBK_VALUE = str2array(lineCurr(idx(2):end));
        else
            bBK = false;
        end

        % leggo le righe della matrice finché non trovo vuoto oppure
        % "FUNCTION" (dimensioni non pre-allocabili)
        n = 1;
        while 1
            lineCurr = fgetl(fidR);
            lineCurr = strrep(lineCurr, ',', ';');
            if isempty(strrep(lineCurr, ';', '')) || ...
                    any(strfind(lineCurr, 'FUNCTION'))
                break
            end
            val(n,:) = str2array(lineCurr);
            n = n+1;
        end

        % se c'erano i BK incorporati, taglio la prima colonna
        if bBK
            Variable.HBK_VALUE = val(:,1)';
            val = val(:,2:end);
        end
        % e qui sono già alla riga sottostante, non leggo niente!
    case 'X_AXIS_PTS'
        bXYaxis = true;
        val = str2array(lineCurr);
        if iscell(val) % Detects text on .csv row and converts to double
            val=val(2:end);
            val = str2double(val);
        end
        Variable.VBK_VALUE = val;
        Variable.VBK_NAME = '$x'; 
    case 'Y_AXIS_PTS'
        bXYaxis = true;
        val = str2array(lineCurr);
        if iscell(val) % Detects text on .csv row and converts to double
            val=val(2:end);
            val = str2double(val);
        end
        Variable.HBK_VALUE = val;
        Variable.HBK_NAME = '$y'; 
end

if ~bXYaxis
    % scrivo il valore nel campo apposito e la stringa della classe
    Variable.VALUE = val;
    Variable.CLASS = keyword;
    
    % leggo eventuale riga "function" (devo già essere sulla riga seguente
    % i dati (immediatamente sotto)
    lineCurr = strrep(lineCurr,',','');
    if isempty(strrep(lineCurr,';',''))  % posso avere una riga vuota, salto
        lineCurr = fgetl(fidR);
    end
    if any(strfind(lineCurr,'FUNCTION'))
        idx = strfind(lineCurr, ';;');
        if isempty(idx)
            idx = strfind(lineCurr, ',,');
        end
        Variable.FUNCTION = lineCurr(idx(1)+2:end);
    end
end

calib.(varName) = Variable;

return

function array = str2array(str)

% se è testo fa un cell-array riga, se no un normale vettore riga

% NOTA: "str" deve avere un ";" prima del primo valore utile

idx = strfind(str, ';');
if isempty(idx)
    idx = strfind(str, ':,');
    str = strrep(str, ',', ';');
    str = strrep(str, ':', ';');
end

if isempty(idx)    %formato file diverso...
    idx = strfind(str, ';');
end
    str = str(idx(1):end);
    str = [str ';'];

str = strrep(str, '"', '''');   % nel caso, formato stringa matlabense

if any(strfind(str, ''''))     % testo...
    idx = strfind(str, ';');
    didx = diff(idx);
    idOK = find(didx>1);  % indici degli "idx" immediatamente prec. il valore
    Nelem = length(idOK);
    array = cell(1,Nelem);
    for n = 1:Nelem
        indA = idx(idOK(n))+1;
        indB = idx(idOK(n)+1)-1;
        array{n} = str(indA:indB);
    end
else
    array = str2num(str)';
end

return

