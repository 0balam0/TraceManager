function app = clcPlotCstOp(plotStr, app)
%    plotStr = struct('sng',  struct('X', X, 'Y', X, 'Z', risp),...
%                  'name', struct('nameS1', nameS1, 'nameS2', nameS2),...
%                  'opVal', opVal,...
%                  'op', op,...
%                  'type', 0);
    % apro la figura della calcolatrice se non esiste la creo
    f = get(app.ckb_createPlot, 'UserData');
    if ~isgraphics(f)
        f = figure('name', 'Calculator figure');
        set(f, 'Visible', 'off');
        set(app.ckb_createPlot, 'UserData', f);
    end
    sp = [];
    set(f, 'Visible', 'off'); clf(f);
    set(0,'CurrentFigure',f)
     if any(strcmp(plotStr.opVal, {'abs', 'sin', 'cos', 'asin', 'acos', 'tan', 'atan'}))
        sp(1) = subplot(2,1,1);
        plot(sp(1), plotStr.sng.X, 'LineWidth', 2); ylabel(sp(1), plotStr.name.nameX); 
        plot(sp(2), plotStr.sng.Z, 'LineWidth', 2); ylabel(sp(2), plotStr.op);
     elseif any(strcmp(plotStr.opVal, {'Integrate', 'Derivate'}))
        sp(1) = subplot(2,1,1);
        plot(sp(1), plotStr.sng.X, plotStr.sng.Y, 'LineWidth', 2);   ylabel(sp(1), plotStr.name.nameY); 
        sp(2) = subplot(2,1,2);
        length(plotStr.sng.Z)
        length(plotStr.sng.X)
        plot(sp(2), plotStr.sng.X, plotStr.sng.Z, 'LineWidth', 2);   ylabel(sp(2), plotStr.op);  
     elseif strcmp(plotStr.opVal, 'Calc Tire Radius')
         sp(1) = subplot(2,1,1);
         plot(sp(1), plotStr.sng.X, plotStr.sng.Z, 'LineWidth', 2);   ylabel(sp(1), plotStr.op);
         sp(2) = subplot(2,1,2);
         plotStr.sng.Y
         plot(sp(2), plotStr.sng.X, plotStr.sng.Y, 'LineWidth', 2);   ylabel(sp(2), 'Ratio');
         xlabel(plotStr.name.nameX);
         
     else
        sp(1) = subplot(3,1,1);
        plot(sp(1), plotStr.sng.X, 'LineWidth', 2);   ylabel(sp(1), plotStr.name.nameX); 
        sp(2) = subplot(3,1,2);
        if length(plotStr.sng.Y)==1
            Y = ones(size(plotStr.sng.X)) * plotStr.sng.Y;
        else
            Y = plotStr.sng.Y;
        end
        xY = 1:length(plotStr.sng.X);
        plot(sp(2),xY,Y, 'LineWidth', 2);   ylabel(sp(2), plotStr.name.nameY); 
        sp(3) = subplot(3,1,3);
        plot(sp(3), plotStr.sng.Z, 'LineWidth', 2); ylabel(sp(3), plotStr.op);
     end
    for i=1:length(sp)
        grid(sp(i), 'minor');
    end
    set(f, 'Visible', 'on');
    linkaxes(sp, 'x');
    
end



% 
% switch plotSwitch
%         case 3 % *,/,+,- etc
%             plot(sp(1), x, 'LineWidth', 2);   ylabel(sp(1), xName); 
%             plot(sp(2), y, 'LineWidth', 2);   ylabel(sp(2), yName); 
%             plot(sp(3), ris, 'LineWidth', 2); ylabel(sp(3), risName);
%         case 2 
%             plot(sp(1), x, 'LineWidth', 2);   ylabel(sp(1), xName); 
%             plot(sp(2), ris, 'LineWidth', 2); ylabel(sp(2), risName);
%         case 4
%             plot(sp(1), x, y, 'LineWidth', 2);   ylabel(sp(1), yName); 
%             plot(sp(2), x, ris, 'LineWidth', 2);   ylabel(sp(2), risName); 
%         case 5
%             plot(sp(1), x, y, 'LineWidth', 2, 'DisplayName', yName);   ylabel(sp(1), yName); 
%             plot(sp(1), xInterp, ris, 'LineWidth', 2, 'DisplayName', risName);   ylabel(sp(1), risName); 
%     end
%     for i=1:nPlot
%         grid(sp(i), 'minor');
%     end
    