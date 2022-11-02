function tTH = deleteHistData(tTH)
% crea una struttura history con dentro dati "finti", in modo da
% risparmiare spazio

cFth = fieldnames(tTH);
v1 = [0 1]';
for j = 1:length(cFth)
    sFth = cFth{j}; % ex: tTH_1, tTH_2
    cF = fieldnames(tTH.(sFth));
    for i = 1:length(cF)
        sF = cF{i}; % ex: VELVEIC
        tTH.(sFth).(sF).v = v1;
        tTH.(sFth).(sF).v_org = v1;
    end
end

return