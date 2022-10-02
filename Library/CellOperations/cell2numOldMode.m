function [NewCell] = cell2numOldMode(Cell0, varargin)

% enable modalità di conversione stringhe in vettori (todo: matrici) 
if not(isempty(varargin))
   bVect = varargin{1};
else
   bVect = true; % default: forzo la conversione
end

% accetta anche character array ma solo 1D
bChar = false;
if ischar(Cell0)
   bChar = true;
   Cell{1} = Cell0;
else
   Cell = Cell0;
end

[r,c] = size(Cell);
NewCell = cell(r,c);
% ciclo sulle righe
for i = 1:r
    % ciclo sulle colonne
    for j = 1:c
        cella = togliQuadre(Cell{i,j});
        if isempty(cella)
            % se è vuoto forzo NaN
            NewCell{i,j} = NaN;
        else
            % se è vuoto lascio il cell(r,c), che sono numeri vuoti
            % (altrimenti rimarrebbe una stringa vuota)
            sn = str2double(cella);
            if isnan(sn)
                % se non è double (ex: cella=='mamma' o cella==[10] o cella==[10 20]):
                % provo a vedere se è un vettore
                if bVect
                    v = string2vect(cella);
                else
                    v = NaN;
                end
                
                if isnan(v)   %%%%%se non è un vettore vedo se è una mappa
                    map=str2num(cella);
                    if ~isempty(map)
                        NewCell{i,j}=map;
                    else
                        NewCell{i,j} = Cell{i,j};
                    end
                else
                    NewCell{i,j} = v;
                end
            else
                % numerico (ex: cella==[10] --> 10 , double)
                NewCell{i,j} = sn;
            end
        end
    end
end
%
if bChar
   NewCell = NewCell{1};
end
return;

function v = string2vect(sIn)
% potrebbe essere un vettore numerico, ex: [12 25, 3]
%
% ricerca di separatori tra scalari: spazi e virgole
idx1a = [strfind(sIn,' ') length(sIn)+1];
idx2a = [strfind(sIn,',') length(sIn)+1];
% parti di separatori
idx1 = union([idx1a idx2a],[idx1a idx2a]);
iE = idx1(diff([0 idx1])>=2)-1; % indici di fine parti numeriche
% parti non di separatori (suppongo numeriche)
idx2 = setdiff(1:length(sIn),idx1);
iS = idx2(diff([-1 idx2])>=2); % indici di inizio parti numeriche
v = zeros(1,length(iE));
if length(idx1)<2 || length(idx2)<2
   % non trovo separatori
   v = NaN;
else
   % assegnazione parti numeriche in un vettore
   for k = 1:length(iE)
      v(k) = str2double(sIn(iS(k):iE(k)));
   end
   % controllo sul risultato ottenuto
   if any(isnan(v))
      v = NaN;
   end
end  
return

function sOut = togliQuadre(sIn)

sOut = sIn;
bQuadre = true;
while bQuadre
   if length(sOut)>=2 && strcmp(sOut(1),'[') &&  strcmp(sOut(end),']')
      bQuadre = true;
      sOut = sOut(2:end-1);
   else
      bQuadre = false;
   end
end
return




