function cOrd = orderAxisList(tAx)
% a partire dalla struttura degli assi, costruisco un vettore 
% di ordinanmento degli assi per subplot

L = length(tAx.assi);
cOrd = cell(L,1);
for i = 1:L
    % ciclo sugli assi
    if isfield(tAx.assi, 'order')
        % opzionale: ordine da utente
        v = tAx.assi(i).order;
    else
        % default: vuoto
        v = [];
    end
    cOrd{i} = v;
end
return