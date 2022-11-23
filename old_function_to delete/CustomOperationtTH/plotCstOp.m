function plotCstOp(x, y, ris, plotSwitch, xName, yName, risName, xInterp)
    figure();
    
    switch plotSwitch
        case 4 % plotto un integrale, derivata
            nPlot = 2;
        case 5 % plotto in interpolazione 1D
            nPlot = 1;
        otherwise
            nPlot = plotSwitch;
    end
    
    sp=zeros(nPlot,1);
    for i=1:nPlot
        sp(i) = subplot(nPlot,1,i);
        grid(sp(i), 'minor');
    end
    switch plotSwitch
        case 3 % *,/,+,- etc
            plot(sp(1), x, 'LineWidth', 2);   ylabel(sp(1), xName); 
            plot(sp(2), y, 'LineWidth', 2);   ylabel(sp(2), yName); 
            plot(sp(3), ris, 'LineWidth', 2); ylabel(sp(3), risName);
        case 2 
            plot(sp(1), x, 'LineWidth', 2);   ylabel(sp(1), xName); 
            plot(sp(2), ris, 'LineWidth', 2); ylabel(sp(2), risName);
        case 4
            plot(sp(1), x, y, 'LineWidth', 2);   ylabel(sp(1), yName); 
            plot(sp(2), x, ris, 'LineWidth', 2);   ylabel(sp(2), risName); 
        case 5
            plot(sp(1), x, y, 'LineWidth', 2, 'DisplayName', yName);   ylabel(sp(1), yName); 
            plot(sp(1), xInterp, ris, 'LineWidth', 2, 'DisplayName', risName);   ylabel(sp(1), risName); 
    end
    for i=1:nPlot
        grid(sp(i), 'minor');
    end
    
    linkaxes(sp, 'x');
    
end