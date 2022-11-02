function [risp, app]= clcCstOpFun(app, tTHstore)
    risp = [];
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
    
    % controllo se il flag del plot � attivo
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
                
%             case '1D Interpolation' % selezionata la somma
%                 mapName = app.extData.Value;
%                 tab = app.UD.extData.tab.(mapName);
%                 x = tab.X; 
%                 v = tab.Y;
%                 xq = tTH.(nameS1).v;  xrpl = nameS1;
%                 op = 'interp1(x,v,xq)';
%                 risp = eval(op);
%                 op = strrep(op,'xq',xrpl);
%                 if app.plotFlag.Value
%                     plotCstOp(x, v, risp, 5, 'xTab', 'yTab', 'interpolation', xq);
%                 end
%                 
%             case '2D Interpolation'
%                 mapName = app.extData.Value;
%                 tab = app.UD.extData.tab.(mapName);
%                 X = tab.X; 
%                 Y = tab.Y;
%                 V = tab.V;
%                 Xq = tTH.(nameS1).v;  xrpl = nameS1;
%                 Yq = tTH.(nameS2).v;  xrp2 = nameS2;
%                 op = 'interp1(X,Y,V,Xq,Yq)';
%                 risp = eval(op);
%                 op = strrep(op,'Xq',xrpl); op = strrep(op,'Yq',xrp2);

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
           plotStr = struct('sng',  struct('X', X, 'Y', Y, 'Z', risp),...
                         'name', struct('nameX', nameS1, 'nameY', nameS2),...
                         'opVal', opVal,...
                         'op', op,...
                         'type', 0);

            app = clcPlotCstOp(plotStr, app);
        end
        
%         app.addInfo(['=', op], 'add');   
%         app.addInfo('Done!', 'n');

    catch Me
%         app.addInfo('Calculation failed!!!','n');
%         app.addInfo(Me.identifier, 'n');
%         app.addInfo(Me.message,'n');
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