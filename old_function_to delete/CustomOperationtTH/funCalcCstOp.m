function clcCstOpFun(app)
    opVal = get(app.dbOperation, 'Value');
    tTH = app.UD.tTH.(app.dB_tTH.Value);

    nameS1 = app.dbSignal1.Value;
    nameS2 = app.dbSignal2.Value;
    X = tTH.(nameS1).v;
    
    plotFlag = app.plotFlag.Value;
    
    try
        switch opVal
            case 'Integrate' % selezionata la somma
                nameS2 = app.dbSignal2.Value;
                Y = tTH.(nameS2).v;
                op = 'cumtrapz(X,Y)';
                risp = eval(op);
                op = strrep(op,'X',nameS1); op = strrep(op,'Y',nameS2);
                if app.plotFlag.Value
                    plotCstOp(X, Y, risp, 4, nameS1, nameS2, op);
                end
                
            case 'Derivate' % selezionata la somma
                nameS2 = app.dbSignal2.Value;
                Y = tTH.(nameS2).v;
                op = '[0,Y]./[0,X]';
                risp = eval(op);
                op = strrep(op,'X',nameS1); op = strrep(op,'Y',nameS2);
                if app.plotFlag.Value
                    plotCstOp(X, Y, risp, 4, nameS1, nameS2, op);
                end
                
            case '1D Interpolation' % selezionata la somma
                mapName = app.extData.Value;
                tab = app.UD.extData.tab.(mapName);
                x = tab.X; 
                v = tab.Y;
                xq = tTH.(nameS1).v;  xrpl = nameS1;
                op = 'interp1(x,v,xq)';
                risp = eval(op);
                op = strrep(op,'xq',xrpl);
                if app.plotFlag.Value
                    plotCstOp(x, v, risp, 5, 'xTab', 'yTab', 'interpolation', xq);
                end
                
            case '2D Interpolation'
                mapName = app.extData.Value;
                tab = app.UD.extData.tab.(mapName);
                X = tab.X; 
                Y = tab.Y;
                V = tab.V;
                Xq = tTH.(nameS1).v;  xrpl = nameS1;
                Yq = tTH.(nameS2).v;  xrp2 = nameS2;
                op = 'interp1(X,Y,V,Xq,Yq)';
                risp = eval(op);
                op = strrep(op,'Xq',xrpl); op = strrep(op,'Yq',xrp2);

            otherwise
                if any(strcmp(opVal, {'abs', 'sin', 'cos', 'asin', 'acos', 'tan', 'atan'}))
                    op = [opVal, '(X)'];
                    risp = eval(op);
                    op = strrep(op,'X',nameS1);
                    if app.plotFlag.Value
                        plotCstOp(X, 0, risp, 2, nameS1, ' ', op);
                    end
                else
                    
                    try
                        Y = eval(nameS2);
                    catch ME
                        Y = tTH.(nameS2).v;
                    end
                    op =['X',opVal,'Y'];
                    risp = double(eval(op));
                    op = strrep(op,'X',nameS1); op = strrep(op,'Y',nameS2);
                    if app.plotFlag.Value
                        plotCstOp(X, Y, risp, 3, nameS1, nameS2, op);
                    end
                end
        end
        app.addInfo(['=', op], 'add');
        
        u = app.lbUnit.Value; d = app.lbDes.Value;
        if isempty(u)
        end
        if isempty(d)
            d = '-';
        end
        app.UD.tTH.(app.dB_tTH.Value).(app.lbOutSignal.Value) = struct('v', risp, 'u', u, 'd', d);
        app.updateDataFun();
        app.addInfo('Done!', 'n');
        app.extFunction('CiaoMamma');
    catch Me
        app.addInfo('Calculation failed!!!','n');
        app.addInfo(Me.identifier, 'n');
        app.addInfo(Me.message,'n');
        dispError(Me)
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