function v = string2vect(sIn)
% potrebbe essere un vettore numerico, ex: [12 25, 3|4]

v = [];
sIn = togliQuadre(sIn);
if isempty(sIn)
    return
end
%
% ricerca di separatori tra scalari: spazi e virgole e pipe
idx1a = [strfind(sIn,' ') length(sIn)+1];
idx2a = [strfind(sIn,',') length(sIn)+1];
idx3a = [strfind(sIn,'|') length(sIn)+1];
% parti di separatori
idx1 = union([idx1a idx2a idx3a],[idx1a idx2a idx3a]);
iE = idx1(diff([0 idx1])>=2)-1; % indici di fine parti numeriche
% parti non di separatori (suppongo numeriche)
idx2 = setdiff(1:length(sIn),idx1);
iS = idx2(diff([-1 idx2])>=2); % indici di inizio parti numeriche
% non trovo separatori, potrebbe essere uno scalare
if length(idx1)<2 || length(idx2)<2
    v = str2double(sIn);
   return
end

% assegnazione parti numeriche in un vettore
v = zeros(1,length(iE));
for k = 1:length(iE)
    v(k) = str2double(sIn(iS(k):iE(k)));
end

% controllo sul risultato ottenuto
if any(isnan(v))
    v = NaN;
    return
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