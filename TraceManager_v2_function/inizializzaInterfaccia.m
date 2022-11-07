function inizializzaInterfaccia(handles)
cTag = sort(fieldnames(handles));

%%% gestisco interfaccia di diverse versioni

idx = find(strfindB(lower(cTag), lower('pb_indietroQuan')));
for i = 1:length(idx)
   set(handles.(cTag{idx(i)}), 'visible','off')
end

cC = listaColori;

for i = 1:length(idx) % abilito i pulsanti
     set(handles.(cTag{idx(i)}), 'visible','on') % scurisco i colori
%    set(handles.(cTag{idx(i)}), 'visible','on', 'ForegroundColor',max((cC{i}-[0.1 0.1 0.1]),0)) % scurisco i colori
end

%%% coloro i pulsanti di selezione colore
hTb = get(handles.pan_colButt, 'children');
for i = 1:length(hTb)
    set(handles.(['tb_c',num2str(i)]) , 'BackGroundColor', cC{i})
end
return
