function funWriteToInfobox(lbl, msg, method)
% funWriteToInfobox( handles.lbl_infoBox, {}, 'clc');

lista = get(lbl, 'String');
if ~iscell(lista)
    tmp = lista; lista = {};
    lista{1} = tmp;
end
    switch method
        case 'a' % append alla linea corrente
            lista{end} = strcmp(lista{end}, msg{1});
        case 'n' %write on new line
            lista{end+1} = msg{1};
        case 'cell' % new line
            for i=1:length(msg)
                lista{end+1} = msg{i};
            end
        case 'clc' % clear message
            lista = {};
    end
    % non è presente una scrollbar elimino le linee prima
    if length(lista)>4
        lista = lista(end-3: end);
    end
    set(lbl, 'String', lista)
end