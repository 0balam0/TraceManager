function vOrd = fillAxisOrder(tAx)
   
L = length(tAx.assi);
vOrd = zeros(L,1);
cOrd = orderAxisList(tAx(1));

% default: numerazione crescente
for i = 1:L
    if not(isempty(cOrd{i}))
        valNew = cOrd{i};
        if not(any(vOrd == valNew))
            % solo se non è ancora presente prendo la nuova imposizione
            % utente
            vOrd(i) = cOrd{i};
        end
    end
end


posNotSel = find(vOrd==0);
vOrd1 = vOrd(vOrd>0); % posizioni scelte da utente
vOrd2 = setdiff(1:1:L, vOrd1); % posizioni non scelte, libere
% riempio le pozioni non scelte da utente
if isempty(posNotSel)
    % ho riempito tutte le posizioni possibili
    return
end
%
for i = 1:length(vOrd2)
    vOrd(posNotSel(i)) = vOrd2(i);
end


return