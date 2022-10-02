function m = string2matrix(sIn)
% convert string to 2D matrix
%
m = [];
sIn = togliQuadre(sIn);
if isempty(sIn)
    return
end
%
% ricerca di separatori tra righe: punto e virgole
idx1 = [strfind(sIn,';') length(sIn)+1];
iE = idx1(diff([0 idx1])>=2)-1; % indici di fine riga
% parti non di separatori (suppongo numeriche)
idx2 = setdiff(1:length(sIn),idx1);
iS = idx2(diff([-1 idx2])>=2); % indici di inizio parti numeriche
%
% convert first row
v1 = string2vect(sIn(iS(1):iE(1)));
if any(isnan(v1))
    m = NaN;
    return
end
if isempty(v1)
    m = [];
    return
end
%
% allocate matrix to full dimension, using first row to get column numbers
Ncol = length(v1);
Nrow = length(idx1);
m = zeros(Nrow,Ncol);
% loop on rows
m(1,:) = v1;
for i = 2:Nrow
    v = string2vect(sIn(iS(i):iE(i)));
    if any(isnan(v))
        m = NaN;
        return
    end
    if isempty(v)
        m = [];
        return
    end
    if size(v,2)~=Ncol || size(v,1)~=1
        m = [];
        return
    end
    m(i,:) = v;
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