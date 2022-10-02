function provaColori()

c = listaColori;

% figure
for i = 1:length(c)
   plot(i, 1, 'marker','square', 'markersize',15, 'markerEdgeColor', c{i}, 'markerFaceColor', c{i});
   hold on
end
grid on
return