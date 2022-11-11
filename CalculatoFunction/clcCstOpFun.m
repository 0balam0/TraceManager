function [risp, app]= clcCstOpFun(app, tTHstore)
risp = [];
OpUserData = get(app.pop_selOperation, 'UserData'); % se ho richiamato la steta funzione la riapro semplicemente;
% get operator
lista = get(app.pop_selOperation, 'String');
val =   get(app.pop_selOperation, 'Value');
opVal = lista{val};
% prendo il nome delle tTH
lista = get(app.pop_file1Sel, 'String');
val   = get(app.pop_file1Sel, 'Value');
tTHname1 = lista{val};
lista = get(app.pop_file2Sel, 'String');
val   = get(app.pop_file2Sel, 'Value');
tTHname2 = lista{val};
%prendo il nome dei segnali
nameS1 = get(app.lb_clcSng1, 'String');
nameS2 = get(app.lb_clcSng2, 'String'); %non lo uso per tutte le operazioni

% tTH da elaborare
tTH1 = tTHstore.(tTHname1);
tTH2 = tTHstore.(tTHname2);

% primo segnale esiste per tutte le operazioni
X = tTH1.(nameS1).v;

% controllo se il flag del plot è attivo
plotFlag = get(app.ckb_createPlot, 'Value');

try
    switch opVal
        case 'Integrate' % selezionato integrale
            Y = tTH2.(nameS2).v;
            op = 'cumtrapz(X,Y)';
            risp = eval(op);
            op = strrep(op,'X',nameS1); op = strrep(op,'Y',nameS2);
            
        case 'Derivate' % selezionata la somma
            Y = tTH2.(nameS2).v;
            op = '[0,diff(Y)]./[0,diff(X)]';
            risp = eval(op);
            op = strrep(op,'X',nameS1); op = strrep(op,'Y',nameS2);
            
        case 'Calc Tire Radius'
            Y = tTH2.(nameS2).v;
            %                 f = questdlg('prova')
            if isempty(OpUserData.tireCalc)% creo da 0 l'obj
                ratio = RatioReqObj('String', {[tTHname1, ':', nameS1], [tTHname1, ':', nameS2]},...
                    'tTH', tTH1);
                set(ratio, 'Visible', 'on')
            else
                ratio = OpUserData.tireCalc;
                assignin('base', 'ratio', ratio);
                handles = struct();
                for i=1:length(ratio.Children)
                    handles.(ratio.Children(i).Tag) = ratio.Children(i);
                end
                set(handles.vhcSignal, 'String', ['vhc speed ', tTHname1, ':', nameS1]);
                set(handles.engSpeedSignal, 'String', ['Eng speed ', tTHname1, ':', nameS2]);
                
                set(ratio, 'UserData', tTH1);
                set(ratio, 'Visible', 'on');
            end
            assignin('base', 'ratio', ratio)
            waitfor(ratio, 'Visible');
            RatioData = get(ratio, 'UserData');
            if isfield(RatioData, 'CalcAutogenRatios') %
                size(X)
                size(RatioData.CalcAutogenRatios.v)
                risp = (X/3.6)./(Y*2*pi/60./RatioData.CalcAutogenRatios.v);
                Y = RatioData.CalcAutogenRatios.v;
                op = 'radius Tire';
            else
                plotFlag = false; % non creo il plot
            end
            OpUserData.tireCalc = ratio;
            
        case '1D Interpolation'
            if isempty(OpUserData.interp1D) || ~isvalid(OpUserData.interp1D)% lo chiamo per la prima volta
                InterpData = loadInterpData_1D;
            else
                InterpData = OpUserData.interp1D; % esistente lo riapro
                set(InterpData, 'Visible', 'on');
            end
            waitfor(InterpData, 'Visible');
            UD = get(InterpData, 'UserData'); out = UD.out;
            if ~isempty(out) % se è andata a buon fine la scelta del file
                nameS2 = cell(2,1);  Y = cell(2,1);
                if out.extrap
                    risp = interp2(out.x, out.y, X, out.method, 'extrap');
                else
                    risp = interp1(out.x, out.y, X, out.method);
                end
                Y{1} = out.x; Y{2}=out.y;
                op = 'Interpolation';
                nameS2{1} = out.x_name; nameS2{2} = out.y_name;
            else
                plotFlag = false;
            end
            OpUserData.interp1D = InterpData;
        case '2D Interpolation'
            Y = tTH2.(nameS2).v;
            if isempty(OpUserData.interp2D) || ~isvalid(OpUserData.interp2D)% lo chiamo per la prima volta
                InterpData = loadInterpData_2D;
            else
                InterpData = OpUserData.interp2D; % esistente lo riapro
                set(InterpData, 'Visible', 'on');
            end
            waitfor(InterpData, 'Visible');
            UD = get(InterpData, 'UserData'); out = UD.out;
            if ~isempty(out)
%                 assignin('base', 'out', out)
%                 assignin('base', 'X', X)
%                 assignin('base', 'Y', Y)
%                 interp2(out.x, out.y, out.v, X, Y, out.method)
                if out.extrap
                    risp = interp2(out.x, out.y, out.v, X, Y, out.method, 0);%, out.method, 'extrap'
                else
                    risp = interp2(out.x, out.y, out.v, X, Y, out.method);%, out.method
                end
                op = 'Interpolation';
            end
            plotFlag = false;
            OpUserData.interp2D = InterpData;
        otherwise
            if any(strcmp(opVal, {'abs', 'sin', 'cos', 'asin', 'acos', 'tan', 'atan'}))
                Y = [];
                op = [opVal, '(X)'];
                risp = eval(op);
                op = strrep(op,'X',nameS1);
            else
                val = str2num(nameS2);
                if isempty(val) % nome di un segnale
                    Y = tTH2.(nameS2).v;
                else % valore numerico
                    Y = val;
                end
                
                op =['X',opVal,'Y'];
                risp = double(eval(op));
                op = strrep(op,'X',nameS1); op = strrep(op,'Y',nameS2);
            end
    end
    
    if plotFlag
        try
            plotStr = struct('sng',  struct('X', X, 'Y', Y, 'Z', risp),...
                'name', struct('nameX', nameS1, 'nameY', nameS2),...
                'opVal', opVal,...
                'op', op,...
                'type', 0);
            assignin('base', 'plotStr', plotStr);
            app = clcPlotCstOp(plotStr, app);
        catch Me
            dispError(Me)
            funWriteToInfobox(app.lbl_infoBox, errorTracking(Me), 'cell');
        end
    end
    set(app.pop_selOperation, 'UserData', OpUserData);
catch Me
    dispError(Me);
    funWriteToInfobox(app.lbl_infoBox, errorTracking(Me), 'cell');
end
end




%% interp 1d
%         nameS2 = app.dbSignal2.Value;
%         nameS3 = app.dbSignal3.Value;
%         mapName = app.extData.Value;
%         tab = app.UD.extData.tab.(mapName);
%         X = tab.(nameS1); Xrpl = nameS1;
%         Y = tab.(nameS2); Yrpl = nameS2;
%         x = tab(nameS3);  xrpl = nameS3;
%         if isvector(X)
%             if ~isvector(Y)
%                 Y = Y(:, app.selCol2.ItemData);
%                 Yrpl = [nameS2, '(:,', app.selCol2.Value, ')'];
%             end
%         else
%             X = X(:, app.selCol1.ItemData);
%             if ~isvector(Y)
%                 Y = Y(:, app.selCol2.ItemData);
%                 Yrpl = [nameS2, '(:,', app.selCol2.Value, ')'];
%             end
%             Xrpl = [nameS1, '(:,', app.selCol1.Value, ')'];
%         end
%         op = 'interp1(X,Y,x)';
%         risp = eval(op);
%         op = strrep(op,'X', Xrpl);
%         op = strrep(op,'Y',Yrpl);
%         op = strrep(op,'Y',xrpl);