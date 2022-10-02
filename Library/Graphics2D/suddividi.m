
function tick = suddividi(xMin,xMax,nDiv,varargin)

% setto se tick deve includere i limiti [xMin xMax]
bLimIncl = true;
if not(isempty(varargin))
    bLimIncl = class2logical(varargin{1});
end

val = [xMin,xMax];
%---definisco delta arrotondato per le scale---
delta = (val(2)-val(1))/nDiv; %ricalcolo delta con la maggiorazione dei valori max/min
sDelta = sprintf('%0.1e', delta); %ex: 5.1e002
posE = strfind(sDelta,'e');
sNum = sDelta(1:posE-1); %ex: 5.1
sExp = sDelta(posE:end); %ex: e002
deltaNorm = str2double(sNum); %ex: 5.1
%prima cifra da impiegare come incremento per le scale (ex:5)
if (deltaNorm >= 1 ) && (deltaNorm <= 1.4)
    b = 1;
elseif (deltaNorm >= 1.5) && (deltaNorm <= 3.4)
    b = 2;
elseif (deltaNorm >= 3.5) && (deltaNorm <= 7.4)
    b = 5;
elseif (deltaNorm >= 7.5) && (deltaNorm < 10)
    b = 10;
end
deltaArr = str2double([num2str(b),sExp]); %delta arrotondato (ex:500) 
%---calcolo lim e tick---
if bLimIncl
    lim = [arrotonda(val(1),deltaArr,'floor'), arrotonda(val(2),deltaArr,'ceil')];
else
    lim = [arrotonda(val(1),deltaArr,'ceil'), arrotonda(val(2),deltaArr,'floor')];
end
    
tick = lim(1):deltaArr:lim(2); 

return