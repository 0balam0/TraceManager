function showHide_signalLabel(app, v_lab1, t_lb1, v_lb2, t_lb2, t_des)
    % mostra nascodi label 1
    set([app.dbSignal1, app.LabelDropDown2, app.lbuS1], 'Visible', v_lab1);
    set(app.LabelDropDown2, 'Text', t_lb1);
    
    % mostra nascondi label 2
    set([app.Label2, app.dbSignal2, app.lbuS2], 'Visible', v_lb2);
    set(app.Label2, 'Text', t_lb2);
    
    % descrizione
    set(app.lbDes, 'Value', t_des);
end