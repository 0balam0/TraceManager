
function visualizzaAsse(handles,v)
try
    % visualizza le grandezze associare all'asse v-esimo dentro alla lb_exp
    %
    tAssi = get(handles.pb_draw, 'UserData');
    L = length(tAssi(v).sigName);
    %
    c = {''};
    for i=1:L
        c(i) = tAssi(v).sigName(i);
    end
    for i=1:L
        if iscell(c{i})
            c(i) = c{i};            
        end
    end
    %
    % asse vuoto (senza grandezze)
    if L==1 && isempty(c{1})
        c{1} = ' ';% le listbox non vogliono stringa nulla
    end
    %
    set(handles.lb_exp ,'value',1)
    set(handles.lb_exp, 'string',c)
catch Me
    dispError(Me, handles.lbl_infoBox)
end
return