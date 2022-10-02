function  [hFig, hAx, hP, hT] = barDiagram(Y, cYcolors, cAnnotations, barWidth, yLimits)

Y = Y(:);
X = (1:1:length(Y))';
%
% controllo ampiezza colonna
if isempty(barWidth)
    barWidth = 0.8;
else
    if barWidth>1
        disp('Warning: bar width must be less than 1')
        barWidth = 1;
    end
end
w = barWidth/2; % semiampiezza

% controllo specifica colori
if length(cYcolors) == 1
    % un solo colore per tutte le Y
    cCol = cell(size(Y));
    for i= 1:length(Y)
        cCol(i) = cYcolors;
    end
else
    if length(cYcolors) == length(Y)
        % tanti colori quanti dati
        cCol = cYcolors;
    else
        disp('Error: colors and Y data must be same size!')
        return
    end
end
cCol = cCol(:);

% controllo specifica etichette
if length(cYcolors) == length(cAnnotations)
    % tante annotazioni quanti dati
else
    disp('Error: annotations and Y data must be same size!')
end
cAnnotations = cAnnotations(:);


% costruscio figura
hFig = figure;
hAx = axes;

% costruisco oggetti patch
hP = zeros(size(Y));
hT = zeros(size(Y));
% ciclo sui dati
for i = 1:length(Y)
    % coordinate per patch
    [xData, yData] = rectangle(X(i), Y(i) ,w);
    % oggetto patch
    hP(i) = patch(xData, yData, cCol{i});
    set(hP(i), 'CData', cCol{i});
    % scrivo annotazione
    hT(i) = text(X(i), 0, cAnnotations{i});
end

% settaggio Ylim se specificato
if not(isempty(yLimits))
    set(hAx, 'yLim', yLimits)
end
yLimits = get(hAx, 'yLim');

% fomattazione etichette testo
yPosLabelNorm = 0.04;
YposLabel = interp1([0 1], yLimits, -yPosLabelNorm, 'linear', 'extrap');
for i = 1:length(Y)
    % formattazione etichette dei dati
    set(hT(i), 'Position', [X(i), YposLabel, 0]);
    set(hT(i), 'Rotation',90, 'HorizontalAlignment', 'right');
end

% tolgo numerazione sotto asse X
set(hAx, 'YGrid','on')
set(hAx, 'xTick',[])
% predispongo spazio corretto sotto asse X (le etichette ci devono stare)
yAnnotMaxHeight = 0;
for i = 1:length(Y)
    ext =  get(hT(i), 'Extent');
    yAnnotMaxHeight = max(yAnnotMaxHeight, ext(4));
end
yAnnotMaxHeightNorm = interp1([0 yLimits(2) - yLimits(1)], [0 1], yAnnotMaxHeight, 'linear', 'extrap');
yAxBott = (yAnnotMaxHeightNorm + yPosLabelNorm)*0.9;
xAxLeft = 0.15;
set(hAx, 'position', [xAxLeft yAxBott (1-xAxLeft-0.05) (1-yAxBott-0.05)]);

return


function [xData, yData] = rectangle(x, y ,w)
% rettangolo chiuso per uso con fill
xData = [x-w, x+w, x+w, x-w, x-w]';
yData = [0,  0,   y,    y,   0]';
return