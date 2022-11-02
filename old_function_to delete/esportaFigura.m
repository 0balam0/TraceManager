function esportaFigura(hFig, sFileFig, sFormat)
% esporta la figura "hFig" nel file "sFileFig" come nel formato indicato in sFormat,
% moltiplicando la risoluzione della figura mostrata a video per 2
% esempi opzioni sFormat: -djpegXX; -dmeta; -dtiff
% XX è un numero variabile tra 0 e 99 indicante la qualità del jpg
% (default:90; migliore: 95)

try

   if strcmp(sFormat,'fig')
      % creo figura di appoggio per il salvataggio
      hFigNew = figure;
      set(hFigNew, 'Position',get(hFig,'Position'));
      copyobj(findobj(hFig,'type','axes'),hFigNew) % copio gli assi sulla figura di appoggio
      hChil = get(hFigNew,'children');
      % causa errori di copiatura possono risultare ampiezze e altezze
      % negative
      for i = 1:length(hChil)
         set(hChil(i), 'Position', max(get(hChil(i), 'Position'), 1))
      end
      %
      saveas(hFigNew, sFileFig,'fig')
      close(hFigNew)
   else
      % imposto la risoluzione del file di out
      set(hFig,'PaperPositionMode','auto')
      SppI = get(0,'ScreenPixelsPerInch'); %screen pixels per inch della sessione corrente
      risoluzione = ['-r', num2str(round(SppI*2))];
      %
      % esportazione in formato grafico
      print(hFig, sFormat, risoluzione, sFileFig);
   end

catch
end

return
