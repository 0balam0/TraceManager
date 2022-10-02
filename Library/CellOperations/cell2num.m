function [NewCell] = cell2num(Cell0, varargin)

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
        % init
        NewCell{i,j} = Cell{i,j};
        %
        cella = togliQuadre(Cell{i,j});
        if isempty(cella)
            % se è vuoto forzo NaN
            NewCell{i,j} = NaN;
            continue
        end
        % se è vuoto lascio il cell(r,c), che sono numeri vuoti
        % (altrimenti rimarrebbe una stringa vuota)
        sn = str2double(cella);
        if ~isnan(sn)
            % numerico (ex: cella==[10] --> 10 , double)
            NewCell{i,j} = sn;
            continue
        end
        %
        % se non è double (ex: cella=='mamma' o cella==[10] o cella==[10 20]):
        % provo a vedere se è un vettore
        if bVect
            v = string2vect(cella);
        else
            v = NaN;
        end
        if ~isnan(v)
            NewCell{i,j} = v;
            continue
        end
        %
        % se non è un vettore vedo se è una mappa
        if bVect
            map = string2matrix(cella);
            if ~isempty(map) && ~any(any(isnan(map)))
                NewCell{i,j} = map;
            end
        end
    end
end
%
if bChar
   NewCell = NewCell{1};
end
return;

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




