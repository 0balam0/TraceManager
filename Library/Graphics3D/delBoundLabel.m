function delBoundLabel(xi, yi, zi, ht)
% cancella le etichette ht (spec di isolivello) create ai bordi della matrice
%  plottata zi(xi,yi), che solitamente sono addensate ai bordi da clabel in
%  abbinamento alle isolivello colorate

% solo matrice numerica
ziNum = zeros(size(zi));
bNum = not(isnan(zi) | zi == Inf | zi == -Inf);
ziNum(bNum) = zi(bNum);
% valore z ai bordi
zBound = 2*max(max(ziNum));
% matrice z riempita oltre i bordi con zBound
zMod = zi;
zMod(not(bNum)) = zBound;
zMod(1,:) = zBound;
zMod(end,:) = zBound;
zMod(:,1) = zBound;
zMod(:,end) = zBound;

% calcolo contorno [xB yB] numerico di z
% c = contourc(xi, yi, zMod, [zBound zBound]);
c = contourc(xi(1,:), yi(:,1), zMod, [zBound zBound]);
c = c(:,2:end)';
c = sortrows(c,1);
c = unique(c,'rows');

%%% eliminazione delle etichette troppo vicine al contorno
toll = 0.02;
Dx = toll*(xi(end)-xi(1));
Dy = toll*(yi(end)-yi(1));
% ciclo sulle etichette
for k = 1:length(ht)
    pos = get(ht(k),'position'); % [x y z] dell'oggetto testo, relative agli assi
    % contorno nell'intorno x dell'etichetta considerata
    xInf = max(pos(1)-Dx, xi(1));
    xSup = min(pos(1)+Dx, xi(end));
    cClose = c(c(:,1)>=xInf & c(:,1)<=xSup,:);
    % matrice nell'intorno vuota; prendo l'intorno più vicino al punto
    if isempty(cClose)
       [xmini, a] = min(abs(c(:,1)-pos(1)));
       xMin = c(a,1);
       b = find(xi == xMin);
       b1 = [max(b-1,1), b, min(b+1,length(xi))]';
       
       cClose = [c(c(1,:)==b1(1),:);...
                 c(c(1,:)==b1(2),:);...
                 c(c(1,:)==b1(3),:)];
    end
    % cancello l'etichetta troppo vicina al contorno
    if not(isempty(cClose))
        for j = 1:length(cClose(1,:))
            if any(cClose(:,2)+Dy > pos(2) & cClose(:,2)-Dy < pos(2))
                delete(ht(k))
                break
            end
        end
    end
 end

return