function yi = interp1Fit(x, y, xi, sMethod, sExtr, varargin)

% interpola i dati y(x) alle xi in ingresso non in modo lineare ma usando
% un modello di fit a tratti: potenza, logaritmico, esponenziale
%
% sMethod: 'power', 'logar', 'expon', 'poly'
% sExtr: 'saturate', 'extrap'

% varargin
degPoly = 1;
if not(isempty(varargin))
    % polynomial degree
    a = find(strcmpi(varargin, 'degPoly'));
    if not(isempty(a))
        degPoly = varargin{a+1};
    end
end

% points needed for each method to fit data and thus interpolate
nPtsFit = 1;
if strcmpi(sMethod, 'poly')
    nPtsFit = degPoly;
end

% ordino per x crescenti
[dum, idxS] = sort(x);
x = x(idxS);
y = y(idxS);

% elimino dati a x ripetute
[dum, idxU] = unique(x);
x = x(idxU);
y = y(idxU);

yi = zeros(size(xi));

%%% punti xi compresi nelle x
% 
% ciclo sui tratti di x
L = length(x)-nPtsFit;
for i = 1:L
    
    % intervallo corrente di dati
    idx = i:i+nPtsFit;
    xPart = x(idx);
    yPart = y(idx);
    
    % identifico i punti compresi tra i limiti correnti di x
    if i < L
        idxi = xi>=xPart(1) & xi<xPart(end);
    else
        % ultimo punto
        idxi = xi>=xPart(1) & xi<=xPart(end);
    end
    
    % interpolo con un modello di fit sull'intervallo
    if any(idxi)
        yi(idxi) = intFit(xPart, yPart, xi(idxi), sMethod, degPoly);
    end
    
end

%%% punti xi a sx dell'intervallo x 
idxi = xi < x(1);
if any(idxi)
    switch sExtr
        case 'saturate'
            yi(idxi) = y(1);
        case 'extrap'
            yi(idxi) = intFit(x(1:1+nPtsFit), y(1:1+nPtsFit), xi(idxi), sMethod, degPoly);
    end
end

%%% punti xi a dx dell'intervallo x 
idxi = xi > x(end);
if any(idxi)
    switch sExtr
        case 'saturate'
            yi(idxi) = y(end);
        case 'extrap'
            yi(idxi) = intFit(x(end-nPtsFit:end), y(end-nPtsFit:end), xi(idxi), sMethod, degPoly);
    end
end



return

function val = intFit(x, y, xi, sMeth, degPoly)

switch sMeth
    case 'power'
        val = powerVal(powerFit(x, y), xi);
    case 'logar'
        val = logarVal(logarFit(x, y), xi);
    case 'expon'
        val = exponVal(exponFit(x, y), xi);
    case 'poly'
        val = polyval(polyfit(x, y, degPoly), xi);
end

return