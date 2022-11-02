function setPanelEnable(hPan, sAct)

hC = get(hPan, 'children');
for i = 1:length(hC)
    sProp = 'Type';
    sPropEn = 'Enable';
    if isprop(hC(i), sProp) && strcmpi(get(hC(i), sProp), 'uipanel')
        % panel: call itself
        setPanelEnable(hC(i), sAct);
    elseif isprop(hC(i), sPropEn)
        % sets enable
        set(hC(i), 'Enable', sAct);
    else
        % next object
        continue
    end
end

return