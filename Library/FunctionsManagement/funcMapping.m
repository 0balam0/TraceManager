function cFunc = funcMapping(sFileIn)
% lists functions in input M file

fid = fopen(sFileIn);
sF = fscanf(fid, '%c');
%%% posizioni in bites di inizio riga:
% in posFile(i) ci deve essere l'inizio di riga(i):
posBegLine = posBeginLine(sF);
nLines = length(posBegLine)-1;


% ricerco le funzioni nel file corrente
cFunc = cell(nLines,1);
bFunc = false(size(cFunc));
count = 0;
sFunctionLabel = 'function ';

%
% scan line by line
for j = 1:length(bFunc)
    % 
    sLine = sF(posBegLine(j):posBegLine(j+1)-3);
    sLineTrim = strtrim(sLine);
    if length(sLineTrim)>length(sFunctionLabel) && strcmp(sLineTrim(1:length(sFunctionLabel)),sFunctionLabel)
        %
        sLineTrim = sLineTrim(length(sFunctionLabel)+1:end);
        % estraggo nome della funzione corrente
        a1 = strfind(sLineTrim, '=');
        if isempty(a1)
            a1 = 0;
        end
        b1 = strfind(sLineTrim, '(');
        if isempty(b1)
            b1 = length(sLineTrim);
        end
        sFunc = strtrim(sLineTrim(a1+1:b1-1));
        %
        % update
        cFunc{j,1} = sFunc;
        count = count+1;
        bFunc(j) = true;
    else
        continue
    end
    
end
fclose(fid);
cFunc = cFunc(bFunc,:);

return