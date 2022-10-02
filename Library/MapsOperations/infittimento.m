function  y2 = infittimento(y1, yMin, yMax, num2)
% y2 = INFITTIMENTO(y1, yMin, yMax, num2)
% Variante di INFITTIMENTO, che accetta alcuni casi respinti dalla
%  funzione originale
% Ricorda:
%  > y2 non può avere meno elementi di y1, quale che sia il valore di num2
%  > yMin e yMax devono definire un intervallo uguale o più esteso di
%    quello di partenza

y1 = sort(y1(:));
y2 = [];

if length(y1) == num2
    % same size --> same data
    y2 = y1;
    
elseif yMin==y1(1) && yMax==y1(end)
    if length(y1)>num2
        % y1 va bene così
        y2 = y1;
        disp('Funzione infittimento: ')
        disp('Warning: output data size cannot be smaller than input data')
    else
        % provvisoriamente, inserisco i punti da aggiungere fra il
        % penultimo e l'ultimo punto
        n_add = num2-length(y1);
        dy = (y1(end)-y1(end-1))/(n_add+1);
        y3 = [y1(end-1) : dy : y1(end)]';
        y2 = [y1(1:end-1); y3(2:end)];
    end
    
else
    y2 = infittimentoBase(y1, yMin, yMax, num2);
    
end

return

function y2 = infittimentoBase(y1, yMin, yMax, dim)

% y2 = infittimento(y1, yMin, yMax, dim)
%
% scrive i valori del vettore y1 in y2, vettore fatto in modo tale che la
% sua dimensione sia dim e con limiti yMin e yMax.
% tipico per uso in calibrazioni (dimensione fissa dei vettori)

y1 = sort(y1);
y2 = zeros(dim,1);

% controlli
if yMin > y1(1)
   disp('funzione INFITTIMENTO: Errore: yMin deve essere minore o uguale a y1(1)')
   y2 = [];
   return
end
if yMax < y1(end)
   disp('funzione INFITTIMENTO: Errore: yMax deve essere maggiore o uguale a y1(end)')
   y2 = [];
   return
end

% generazione
if yMin == y1(1)
   % impongo coincidenza a sx
   y2(1:length(y1)) = y1;
   y2(length(y1):end) = linspace(y1(end), yMax, length(y2)-length(y1)+1);
   if yMax == y1(end)
      disp('funzione INFITTIMENTO: Errore: yMax deve essere maggiore di y1(end)')
      y2 = [];
      return
   end
   
elseif yMax == y1(end)
   % impongo coincidenza a dx
   y2(1:end-length(y1)+1) = linspace(yMin, y1(1), length(y2)-length(y1)+1);
   y2(end-length(y1)+1:end) = y1;
   if yMin == y1(1)
      disp('funzione INFITTIMENTO: Errore: yMin deve essere minore di y1(1)')
      y2 = [];
      return
   end
   
else
   % spazio a sx e a dx
   n = floor((dim-length(y1))/2);
   y2(1:n+1) = linspace(yMin, y1(1), n+1);
   y2(n+1:length(y1)+n+1-1) = y1;
   n2 = dim - (length(y1)+n+1-1);
   y2(length(y1)+n+1-1:end) = linspace(y1(end), yMax, n2+1);
end

return