function visualizzaListaAssi(hlb_Ax, nAssi, vOrd)
%
% aggiorno lista assi
cAx = cell(nAssi,1);

% ordine esterno opzionale
% if isempty(cOrd)
%     cOrd = cell(nAssi,1);
%     for i = 1:nAssi
%         cOrd{i} = i;
%     end
% end
% assegno label ad assi
for i = 1:nAssi
%     if not(isempty(cOrd{i}))
%         v = cOrd{i};
%     else
%         % i valori di cOrd vuoti li metto come default all'asse corrente
%         v = i;
%     end
    cAx{i} = stringaAsse(vOrd(i));
end
set(hlb_Ax, 'string', cAx)
set(hlb_Ax, 'value', nAssi)
return
