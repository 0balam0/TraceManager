function app = opSelectedUpWin(app)
    viewOpt = {'on', 'on', 'none', 'off' ,'off'};
    
    opVal = get(app.dbOperation, 'Value');
    
    switch opVal
        case 'Integrate' % selezionata la somma
          viewOpt = {'on', 'on', 'output signal = cumtrapz(X,Y)', 'off'};
        case 'Derivate' % selezionata la somma
           viewOpt = {'on', 'on', 'output signal = [0;diff(Y)]./[0;diff(X)]', 'off'};           
        case '1D Interpolation' % selezionata la somma
           viewOpt = {'on', 'off', 'output signal = interp1(x_note, y_note, X)', 'on'};   
        case '2D Interpolation'
           viewOpt = {'on', 'on', 'output signal = interp2(x_note, y_note, val, X, Y)', 'on'};   
           
        otherwise 
            if any(strcmp(opVal, {'abs', 'sin', 'cos', 'asin', 'acos', 'tan', 'atan'}))
                viewOpt = {'on', 'off', ['output signal = ', opVal, '(X)'], 'off'}; 
            else
                viewOpt = {'on', 'on', ['output signal = X ', opVal, ' Y'], 'off'};  
            end
    end
    
    set([app.dbSignal1, app.LabelDropDown2, app.Label6], 'Visible', viewOpt{1});
    set([app.Label2, app.dbSignal2, app.Label7], 'Visible', viewOpt{2});
    set(app.Label5, 'Text', viewOpt{3});
    set([app.Label3, app.extData, app.loadExtData],  'Visible',  viewOpt{4});
end