function app = clcOpSelectedUpWin(app)
 % signal1 state, %signal 2 state, %message % external data
    viewOpt = {'on', 'on', 'none', 'off' ,'off'};
    
    lista = get(app.pop_selOperation, 'String');
    val =   get(app.pop_selOperation, 'Value');
    
    opVal = lista{val};
    
    switch opVal
        case 'Integrate' 
          viewOpt = {'on', 'on', 'output signal = cumtrapz(X,Y)', 'off'};
        case 'Derivate' 
           viewOpt = {'on', 'on', 'output signal = [0;diff(Y)]./[0;diff(X)]', 'off'};           
        case '1D Interpolation' 
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
    
    set([app.clc_lblX, app.pop_file1Sel, app.lb_clcSng1, app.lb_opChan1Unit], 'Visible', viewOpt{1});
    set([app.clc_lblY, app.pop_file2Sel, app.lb_clcSng2, app.lb_opChan2Unit], 'Visible', viewOpt{2});
    set(app.lb_example, 'String', viewOpt{3});
    set([app.pop_extData, app.pb_loadExtData],  'Visible',  viewOpt{4});
end