function [c, hc, hl] = isolivelloFormattate(ax_1, x_i, y_i, z_d, v)

[c, hc] = contour(ax_1, x_i, y_i, z_d, v,'k');
set(hc,'fill','on', 'LabelSpacing',200);

if true
   hl = clabel(c,hc, 'BackgroundColor','none', 'EdgeColor', 'none', ...
      'FontName','Arial', 'Rotation', 0, 'Fontsize', 8, ...
      'Fontweight', 'demi', 'LabelSpacing',200);

   delBoundLabel(x_i(:)', y_i(:), z_d, hl);
else
   hl = [];
end

hP = findobj(gca,'type','patch');
set(hP, 'FaceAlpha',0.05, 'EdgeAlpha',1, 'Edgecolor',[0.4 0.4 0.4])
set(gca, 'Clim',interp1([0 1],[min(v) max(v)],[-.5 .75], 'linear','extrap'));

grid on
return
