function [xArr, ID, xSet, IDSet, lSet] = trovaGruppi(x, tollAbs, varargin)
%trova i raggruppamenti di pari valori in un vettore x data una certa
%tolleranza assoluta di arrotondamento
%
% ESEMPIO:
% trovaGruppi(x[1490 1492 1515 1505 1509, 2009 2000 1998 2005, 3000 3002 2990], 50);
% restituisce:
% vettore x arrotondato per gruppi:
% xArr = [1500 1500 1500 1500 1500, 2000 2000 2000 2000, 3000 3000 3000];
% indici di xArr associati ai gruppi
% ID = {[1 2 3 4 5], [6 7 8 9], [10 11 12]};
% elementi dei gruppi
% xSet = [1500 2000 3000];
% indici su xArr di inizio gruppo
% IDSet = [1 6 10];
% numerosità dei gruppi
% lSet = [5 4 3]
%

sSort = 'ascend';
if not(isempty(varargin))
   sSort = varargin{1};
end

x = x(:);
tollAbs = abs(tollAbs);
if tollAbs>0
    xArr = arrotonda(x,tollAbs); %arrotondo le x alla tolleranza assoluta specificata
else
    xArr = x;
end
%
%ordino vettore se richiesto
switch sSort
   case {'ascend','descend'} 
      xArr = sort(xArr, 1, sSort); 
   case 'no'
end
%
IDSet = [1; find(diff(xArr))+1; length(xArr)+1]; %identificativo della lunghezza dei set di dati a x = cost
lSet = diff(IDSet); %numerosità dei vari ragguppamenti
ID = cell(length(lSet)-1,1);
for i=1:length(IDSet)-1
    ID{i} = IDSet(i):IDSet(i+1)-1; %indici di xArr a cui c'è un set di dati a x = cost
end
IDSet = IDSet(1:end-1);
xSet = xArr(IDSet); %primi elementi di ogni gruppo
return


