function app = clcOpSelectedUpWin(app)
 % signal1 state, %signal 2 state, %message % external data
    viewOpt = {'on', 'on', 'none'};
    lbl = app.text_Help_calculator;
    lista = get(app.pop_selOperation, 'String');
    val =   get(app.pop_selOperation, 'Value');
    
    opVal = lista{val};
    help='';
%     help = 'No help implemented';
    switch opVal
        case 'Integrate' 
          viewOpt = {'on', 'on', 'output signal := cumtrapz(X,Y)'};
          help = sprintf('%s\n%s',...
              'Computes the approximate cumulative integral of Y via the trapezoidal method',...
              'Integrates Y with respect to the coordinates or scalar spacing specified by X');
        case 'Derivate' 
           viewOpt = {'on', 'on', 'output signal := [0;diff(Y)]./[0;diff(X)]'};           
        case '1D Interpolation' 
           viewOpt = {'on', 'off', 'output signal := interp1(x_note, y_note, X)'};   
           help = sprintf('%s\n%s\n%s\n%s',...
              'Calculate the tire radius for each point in the history.',...
              'Select for X the vehicle speed signal in km/h',...
              'Select for Y the engine speed in rpm',...
              'When you click on Calulate a windows appear and you have to define the ratio beetween the wheel and the engine.');
        case '2D Interpolation'
           viewOpt = {'on', 'on', 'output signal := interp2(x_note, y_note, val, X, Y)'};   
        case 'Calc Tire Radius'
           viewOpt = {'on', 'on', 'output signal := f(X,Y); X=Vehicle speed; Y=EngineSpeed'}; 
           help = sprintf('%s\n%s\n%s\n%s',...
              'Compute the tire radius for every points of the time history.',...
              'Select for X the vehicle speed signal in km/h',...
              'Select for Y the engine speed in rpm',...
              'When you click on Calulate a windows appear and you have to define the ratio beetween the wheel and the engine.');
        otherwise 
            if any(strcmp(opVal, {'abs', 'sin', 'cos', 'asin', 'acos', 'tan', 'atan'}))
                viewOpt = {'on', 'off', ['output signal := ', opVal, '(X)']}; 
            else
                viewOpt = {'on', 'on', ['output signal := X ', opVal, ' Y']};  
            end
    end
    
    set([app.clc_lblX, app.pop_file1Sel, app.lb_clcSng1, app.lb_opChan1Unit], 'Visible', viewOpt{1});
    set([app.clc_lblY, app.pop_file2Sel, app.lb_clcSng2, app.lb_opChan2Unit], 'Visible', viewOpt{2});
    set(app.lb_example, 'String', viewOpt{3});
    help = sprintf('%s\n%s', help, viewOpt{3});
    set(lbl, 'TooltipString', help);
%     set([app.pop_extData, app.pb_loadExtData],  'Visible',  viewOpt{4});
end