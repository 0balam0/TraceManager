function varargout = graficoTH(varargin)
% GRAFICOTH M-file for graficoTH.fig
%      GRAFICOTH, by itself, creates a new GRAFICOTH or raises the existing
%      singleton*.
%
%      H = GRAFICOTH returns the handle to a new GRAFICOTH or the handle to
%      the existing singleton*.
%
%      GRAFICOTH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRAFICOTH.M with the given input arguments.
%
%      GRAFICOTH('Property','Value',...) creates a new GRAFICOTH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before graficoTH_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to graficoTH_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help graficoTH

% Last Modified by GUIDE v2.5 09-Oct-2022 01:29:09

% Begin initialization code - DO NOT EDIT
try
   gui_Singleton = 1;
   gui_State = struct('gui_Name',       mfilename, ...
      'gui_Singleton',  gui_Singleton, ...
      'gui_OpeningFcn', @graficoTH_OpeningFcn, ...
      'gui_OutputFcn',  @graficoTH_OutputFcn, ...
      'gui_LayoutFcn',  [] , ...
      'gui_Callback',   []);
   if nargin && ischar(varargin{1})
      gui_State.gui_Callback = str2func(varargin{1});
   end

   if nargout
      [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
   else
      gui_mainfcn(gui_State, varargin{:});
   end
   
catch
end
return

function graficoTH_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to graficoTH (see VARARGIN)
try

   % Update handles structure
   guidata(hObject, handles);

   % UIWAIT makes graficoTH wait for user response (see UIRESUME)
   % uiwait(handles.figGraficoTH);
   %
   handles = disegna(handles, varargin{:});

   % Update handles structure
   guidata(hObject, handles);
   
   %create DataCursor button
   tbar = handles.tbar;
   handles.ptDataCursor = uipushtool(tbar);
   load('.\ico\DataCursorICO.mat')
   handles.ptDataCursor.CData = DataCursorICO;
   handles.ptDataCursor.ClickedCallback  = @(src,event)CreateCursor(src);
   
catch
end
return

function varargout = graficoTH_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pb_export_ClickedCallback(hObject, eventdata, handles)
try
   % esporta la figura della time history
   % Guenna, 29/06/2015: suggerisce la directory della prima time history
   cExt = {'*.jpg'; '*.png'; '*.tiff'; '*.emf'; '*.fig'};   % Guenna, 209/06/2015: aggiunto png
   tUD = get(handles.figGraficoTH,'UserData');
   sDir = '';
   if isfield(tUD,'tFiles') && not(isempty(tUD.('tFiles')))
       if isfield(tUD.('tFiles'),'sFile_1') && not(isempty(tUD.('tFiles').('sFile_1')))
          sDir = [fileparts(tUD.tFiles.sFile_1) '\'];  
       end
   end
   [sFile, sPath, sFiltIdx] = uiputfile(cExt, 'esporta su file grafico...', ...
       [sDir 'timeHistory1']);

   if not(isequal(sFile,0)) && not(isequal(sPath,0)) && (sFiltIdx>=1 && sFiltIdx<=length(cExt))
      switch cExt{sFiltIdx}
         case '*.jpg'
            sExt = '-djpeg95';
         case '*.tiff'
            sExt = '-dtiff';
         case '*.emf'
            sExt = '-dmeta';
         case '*.fig'
            sExt = 'fig';
         case '*.png'
            sExt = '-dpng';
      end
      % esportazione
      esportaFigura(handles.figGraficoTH, [sPath,sFile], sExt);
   end

catch
end

return

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

function tb_zoomAll_ClickedCallback(hObject, eventdata, handles)

try
   switch get(hObject,'state')
       
      case 'on'
         zoom on;
         % ripristino i tick automatici per assi X e Y
         cAx = listaTagAssi(handles);
         for i = 1:length(cAx)
             sAx = cAx{i};
             set(handles.(sAx), 'XtickMode', 'auto', 'YtickMode', 'auto')
         end
         
      case 'off'
         zoom off;
   end
   set([handles.tb_zoomX handles.tb_zoomY], 'state','off')

catch
end
return

function tb_zoomX_ClickedCallback(hObject, eventdata, handles)


h = zoom;
set(h, 'Motion','horizontal', 'Enable',get(hObject,'state'));
set([handles.tb_zoomY handles.tb_zoomAll], 'state','off')

switch get(hObject,'state')

    case 'on'
        % ripristino i tick automatici per assi X
        cAx = listaTagAssi(handles);
        for i = 1:length(cAx)
            sAx = cAx{i};
            set(handles.(sAx), 'XtickMode', 'auto')
        end
    case 'off'
end

return

function tb_zoomY_ClickedCallback(hObject, eventdata, handles)


h = zoom;
set(h, 'Motion','vertical', 'Enable',get(hObject,'state'));
set([handles.tb_zoomX handles.tb_zoomAll], 'state','off')

switch get(hObject,'state')

    case 'on'
        % ripristino i tick automatici per tutti assi Y
        cAx = listaTagAssi(handles);
        for i = 1:length(cAx)
            sAx = cAx{i};
            set(handles.(sAx), 'YtickMode', 'auto')
        end
    case 'off'
end

return

function pb_zoomAuto_ClickedCallback(hObject, eventdata, handles)

   
zoom out

% ripristino i tick automatici per assi X e Y
cAx = listaTagAssi(handles);
for i = 1:length(cAx)
    sAx = cAx{i};
    set(handles.(sAx), 'XtickMode', 'auto', 'YtickMode', 'auto', 'XlimMode', 'auto', 'YlimMode', 'auto')
end

return

function tb_points_ClickedCallback(hObject, eventdata, handles)
%
try
   switch get(hObject,'state')
      case 'on'
         sMarker = 'square';
      case 'off'
         sMarker = 'none';
   end
   %
   cAx = listaTagAssi(handles);
   for i=1:length(cAx)
      cL = listaTagLinee(handles,cAx{i});
      for j=1:length(cL)
         set(handles.(cL{j}), 'Marker',sMarker)
      end
   end
catch
end
return

function tb_legend_ClickedCallback(hObject, eventdata, handles)

try
   % ricerco handles degli assi
   cAx = listaTagAssi(handles);
   switch get(hObject,'state')
      case 'on'
         s = 'show';
      case 'off'
         s = 'hide';
   end
   for i=1:length(cAx)
      legend(handles.(cAx{i}), s)
   end

catch
end
return

function handles = disegna(handles,varargin)
%

try
   % ricerco struttura degli assi per il plottaggio
   bForceZero = false;
   if not(isempty(varargin))
      %
      a = find(strcmp(varargin, 'tAx'));
      if not(isempty(a))
         UserData.tAx = varargin{a+1};
      end
      %
      a = find(strcmp(varargin, 'bForceZero'));
      if not(isempty(a))
          bForceZero = logical(varargin{a+1});
      end
      %
      a = find(strcmp(varargin, 'tFiles'));  % Guenna 29/06/2015
      if not(isempty(a))
          UserData.tFiles = varargin{a+1};
      end
   end
   set(handles.figGraficoTH, 'UserData',UserData) % serve??
   % UserData.tAx.assi(i).signals(j)
   %
   % cancello assi di precedente esecuzione
   hAx = findobj(handles.figGraficoTH,'type','axes');
   if not(isempty(hAx))
      delete(hAx);
   end
   handles = guihandles(handles.figGraficoTH);
   %
   % disegno gli assi e il loro contenuto
   [handles, flag_yDoubled] = creaOggetti(handles, bForceZero);
   set(handles.tb_legend, 'state','off');
   set(handles.flag_yDoubled, 'Value', flag_yDoubled);
   %
   % impagino gli assi nella figura
   setPosizioniAssi(handles.figGraficoTH,[],handles);
   %
   % esporto l'handle della funzione di disegno assi x richiamare il
   % ridisegno dall'esterno
   handles.fDisegna = @disegna; %str2func('disegna')
   guidata(handles.figGraficoTH,handles);
   %
catch
end
return

function [handles, flag_yDoubled] = creaOggetti(handles, bForceZero)
% recupero info dalla figura
%


   UserData = get(handles.figGraficoTH, 'UserData');
   tAx = UserData.tAx;
   flag_yDoubled = 0;
   %
   % richiamo figura corrente
   figure(handles.figGraficoTH)
   %---creazione oggetti---
   cColor = listaColori;
   cLineStyle = {'-','--',':','-.'};
   %
   % ciclo sugli assi
   L = length(tAx(1).assi);
   hAssi = zeros(L,1);

   % controllo se ho selezionato il confronto di più manovre o la singola
   % manovra
   bOneMan = length(tAx)==1;

   % ordine di plottaggio
   vOrd = fillAxisOrder(tAx(1));

   %
   % ciclo sugli assi
   for i = 1:L
      iAx = vOrd(i); % ordine dell'asse
      hA = axes;
      sTagAx =  num2str(iAx);
      if i <= 9
          sTagAx = ['0', sTagAx];
      else
          sTagAx = sTagAx;
      end
      [sFontName, dFontSize, sFontWeight] = setFont(get(hA,'type'));
      set(hA, 'FontName',sFontName, 'FontSize',dFontSize, 'FontUnits','points','FontWeight',sFontWeight,...
         'xGrid','on', 'yGrid','on', 'zGrid','on', 'GridAlpha', 0.3, ...
         'Units','pixel', 'ButtonDownFcn','', 'Parent', handles.figGraficoTH, 'Tag',['ax_',sTagAx]);
     if i<L
         set(hA, 'XTickLabel', {})
     end
     hAssi(iAx) = hA;
      %
      %%% label asse X
      if iAx == L
          if isfield(tAx(1).assi(1), 'Xlabel') && not(isempty(tAx(1).assi(1).Xlabel))
              sLabX = tAx(1).assi(1).Xlabel;
          else
              sLabX = 'time [s]';
          end
          hLab = xlabel(hA, sLabX);
          set(hLab, 'Interpreter', 'none' , 'FontSize',10)
      end
      %
      %%% label asse Y
      for p = 1:length(tAx)
          if strcmp(tAx(p).assi(i).signals(1).u,'')
              p = p + 1;
          else
              break
          end
      end
      if isfield(tAx(p).assi(i), 'Ylabel') && not(isempty(tAx(p).assi(i).Ylabel))
          sLabY = tAx(p).assi(i).Ylabel;
      else
          sLabY = ['[', tAx(p).assi(i).signals(1).u, ']'];
      end
      hLab = ylabel(sLabY);
      set(hLab, 'Interpreter','none', 'FontSize',10)
      %
      %%% ciclo sulle grandezze
      L1 = length(tAx(1).assi(i).signals);
      hLine = [];
      cLeg = {''};
      for j = 1:L1
         % ciclo sulle manovre da confrontare
         for k = 1:length(tAx)
            [val_x, val_y] = lengthCorrection(tAx(k).assi(i).signals(j).t, tAx(k).assi(i).signals(j).v, 2);
            if bForceZero
                val_y = forceToZero(val_y);
            end
            
            if tAx(k).assi(i).yDoubled
                if tAx(k).assi(i).signals(j).secAx
                    yyaxis 'right';
                    assignin('base', 'ax', hA);
                    ylabel (['[', tAx(k).assi(i).signals(j).u, ']']);
                else
                    yyaxis 'left'
                end
            end
       
            hL = line(val_x, val_y);
                       
            if isempty(hL)
               continue
            end
            %
            % linee
            sLineStyle = cLineStyle{min(1,length(cLineStyle))}; % ad ogni grandezza in uno stesso asse è associato un solo stile di linea
            if isfield(tAx(k).assi(i).signals(j), 'color') && not(isempty(tAx(k).assi(i).signals(j).color))
                vColore = tAx(k).assi(i).signals(j).color;
            else
                if bOneMan
                    % una sola manovra
                    vColore = sceltaColore(cColor,j); % in uno stesso asse il colore cambia con la grandezza
                else
                    % confronto di più manovre
                    vColore = sceltaColore(cColor,k); % ad ogni manovra è associato lo stesso colore
                end
            end
            
            vStyle = char(tAx(k).assi(i).signals(j).Lstyle);
            vWidth = char(tAx(k).assi(i).signals(j).Width);            
            Mstyle = char(tAx(k).assi(i).signals(j).Mstyle);
            Msize  = str2double(char(tAx(k).assi(i).signals(j).Msize));
            switch vStyle
                case 'Solid'
                    vStyle = '-';
                case 'Dashed'              
                    vStyle = '--';
                case 'Dotted'                   
                    vStyle = ':';
                case 'Dash-dot'
                    vStyle = '-.';
            end
            
            vWidth = str2num(vWidth);

            set(hL, 'Color', vColore, 'LineWidth',vWidth, 'LineStyle',vStyle,...
                    'MarkerEdgeColor', vColore, 'MarkerFaceColor', vColore, 'MarkerSize', Msize, 'Marker', Mstyle,...
                    'ButtonDownFcn','', 'Parent',hA, 'Tag',['line_',num2str(i),'_',num2str(j),''], 'UserData', tAx(k).assi(i).signals(j).name);
%             assignin('base','hl', hL)
            % legenda
            hLine(length(hLine)+1) = hL;
            if isfield(tAx(k).assi(i).signals(j), 'label') && not(isempty(tAx(k).assi(i).signals(j).label))
                sLeg = tAx(k).assi(i).signals(j).label;
            else
                sLeg = tAx(k).assi(i).signals(j).name;
            end
            cLeg{length(cLeg)+1} = sLeg;
            % ripristino i colori degli assi
            if tAx(k).assi(i).yDoubled
                flag_yDoubled = 1;
                if tAx(k).assi(i).signals(j).secAx
                    set(hA.YAxis(2), 'Color', vColore);
                end
            end
            set(hA.YAxis(1), 'Color', [0.15, 0.15, 0.15]) 

            %%% setto limiti assi X e Y
            impostaLimitiAsse(hA, 'X', tAx(1).assi(1).Xlimit);
            impostaLimitiAsse(hA, 'Y', tAx(1).assi(i).Ylimit);
         end
      end
      cLeg = cLeg(2:end);
      %
      % creo legenda predefinita
      legend(hA, hLine, cLeg, 'interpreter','none');
      legend(hA,'hide');
   end
   %
   % lego limiti degli assi in direzione x per zoom
   if length(hAssi)>1
      linkaxes(hAssi,'x')
   end
   %
   % Update handles structure
   handles = guihandles(handles.figGraficoTH);
   guidata(handles.figGraficoTH, handles);

return

function [sFontName,dFontSize,sFontWeight] = setFont(cType)
%
try
   switch cType
      case 'axes'
         sFontName = 'Helvetica';
         dFontSize = 10;
         sFontWeight = 'bold';
      case ''
   end
catch
end
return

% function cColor = listaColori
% % lista colori nel plottaggio delle linee
% cColor{1} = [0,0,255]/255;
% cColor{2} = [255,0,0]/255;
% cColor{3} = [0,0,0]/255;
% cColor{4} = [255,204,0]/255;
% cColor{5} = [0,200,0]/255;
% cColor{6} = [204,153,255]/255;
% cColor{7} = [0,255,255]/255;
% cColor{8} = [153,51,0]/255;
% cColor{9} = [255,153,204]/255;
% cColor{10} = [255,255,0]/255;
% cColor{11} = [51,153,102]/255;
% cColor{12} = [153,204,0]/255;
% cColor{13} = [255,204,153]/255;
% cColor{14} = [0,255,0]/255;
% cColor{15} = [255,153,0]/255;
% cColor{16} = [102,102,153]/255;
% cColor{17} = [153,153,153]/255;
% cColor{18} = [51,51,0]/255;
% cColor{19} = [0,51,0]/255;
% cColor{20} = [0,0,128]/255;
% return

function vColore = sceltaColore(cColor,i)
try
   L = length(cColor);
   if i> L
      i = i-floor((i-1)/L)*L;
   end
   vColore = cColor{i};
catch
end
return

function setPosizioniAssi(hObject, eventdata, handles, flag_yDoubled)
% suddivide lo spazio tra gli assi nella figura in parti uguali
% sovrascrivo handles xè forse vuota

flag_yDoubled = get(handles.flag_yDoubled, 'Value');
%Teoresi (rendo invisibili inizialmente gli edit text con le dimensioni dei subplot)
for i = 1:12
    pippo = ['edit_width' num2str(i)];
    pippo1 = ['edit_height' num2str(i)];
    set(handles.(pippo),'Visible','off')
    set(handles.(pippo1),'Visible','off')
end

try
   % varie
   bordoDx = 25 + (80-25)*flag_yDoubled;  %se esiste un grafico con due assi allora aumenta lo spazio a destra
   bordoSx = 80;
   bordoInf = 50;
   bordoSup = 20; %20
   interlinea = 15; % 35
   set(handles.figGraficoTH, 'units','pixel');
   posFig = get(handles.figGraficoTH,'position');
   %
   % Teoresi(variabili per posizioni edit text dei subplot)
   pos_edit_width(3)=50;
   pos_edit_width(4)=20;
   pos_edit_height(3)=50;
   pos_edit_height(4)=20;
   %
      % ricerco handles degli assi
   cAx = listaTagAssi(handles);
   %
   % setto posizioni degli assi
   L = length(cAx); % numero di assi
   pos(4) = (posFig(4) - bordoInf - bordoSup -(L-1)*interlinea)/L; % altezza dell'asse
   for i = L:-1:1 % parto dal primo asse in basso
      pos(1) = bordoSx;
      pos(3) = posFig(3)-bordoSx-bordoDx;
      if i==L
         pos(2) = bordoInf;
      else
         posPrec = get(handles.(cAx{i+1}),'position');
         pos(2) = posPrec(2) + posPrec(4) + interlinea;
      end
      set(handles.(cAx{i}), 'position',pos);
      
     
      %Teoresi (posizioni edit text per ogni subplot)
      pos_edit_height(1)=pos(1)+pos(3)-60;
      pos_edit_width(1)=pos(1)+pos(3)-120;
      pos_edit_width(2)=pos(2)+pos(4)-25;
      pos_edit_height(2)=pos_edit_width(2);
     
      pippo=['edit_width' num2str(i)];
      pippo1=['edit_height' num2str(i)];
      set(handles.(pippo), 'position',pos_edit_width);
      set(handles.(pippo1), 'position',pos_edit_height);
      set(handles.(pippo),'string',num2str(pos(3)))
      set(handles.(pippo1),'string',num2str(pos(4)))  
      set(handles.(cAx{i}), 'position',pos);
      
      set(handles.uitoggletool9,'state','off')
   end
catch
end

return

function cAx = listaTagAssi(handles)
try
   %  lista i tag degli assi ,ex: {'ax_1', 'ax_2', 'ax_3'}, dall'alto al basso
   cNames = fieldnames(handles);
   if ischar(cNames)
      cNames1{1} = cNames;
   else
      cNames1 = cNames;
   end
   cAx = sort(cNames1(strfindB(cNames1,'ax_')));
catch
end
return

function cL = listaTagLinee(handles,tagAsse)
try
   %  lista i delle linee nell'asse specificato
   cNames = get(findobj(handles.(tagAsse), 'type','line'),'tag');
   if ischar(cNames)
      cNames1{1} = cNames;
   else
      cNames1 = cNames;
   end
   cL = sort(cNames1(strfindB(cNames1,'line_')));
catch
end
return

function impostaLimitiAsse(hA, sAsse, vLim)


if not(isnan(vLim(1))) && not(isnan(vLim(2)))
    if vLim(2) > vLim(1)
        set(hA, [sAsse,'lim'], vLim(1:2))
    else
        set(hA, [sAsse, 'LimMode'], 'auto')
    end
    if not(isnan(vLim(3)))
        set(hA, [sAsse, 'tick'], vLim(1):vLim(3):vLim(2))
    else
        set(hA, [sAsse, 'TickMode'], 'auto')
    end
else
    set(hA, [sAsse, 'LimMode'], 'auto')
    set(hA, [sAsse, 'TickMode'], 'auto')
end

return

function val_y = forceToZero(val_y)

% suppose to have mainly positive values
minY = min(val_y);
maxY = max(val_y);

bReverse = false;
if abs(minY) > abs(maxY)
    % reverse case (mainly negative values)
    bReverse = true;
    val_y = -val_y;
    minY = min(val_y);
    maxY = max(val_y);
end

if abs(minY) < 0.001 * maxY
    % minimum value is sliglty negative: can be rounded to zero
    val_y = max(val_y, 0);
end

if bReverse
    % reset original sign
   val_y = -val_y; 
end

return

%Teoresi (toggle per attivare gli edit text)
function uitoggletool9_ClickedCallback(hObject, eventdata, handles)

cAx = listaTagAssi(handles);
for i=1:length(cAx)
pippo=['edit_width' num2str(i)];
pippo1=['edit_height' num2str(i)];
switch get(hObject,'state')
    case 'on'
       set(handles.(pippo),'Visible','on')
       set(handles.(pippo1),'Visible','on')
    case 'off'
       set(handles.(pippo),'Visible','off')
       set(handles.(pippo1),'Visible','off')
end
end

% Teoresi (edit text per dimensioni dei subplot)
function edit_width1_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_01, 'position',[handles.ax_01.Position(1),handles.ax_01.Position(2),new_width_subplot,handles.ax_01.Position(4)]);

function edit_height1_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
set(handles.ax_01, 'position',[handles.ax_01.Position(1),handles.ax_01.Position(2)+(handles.ax_01.Position(4)-new_height_subplot),handles.ax_01.Position(3),new_height_subplot]);

function edit_width2_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_02, 'position',[handles.ax_02.Position(1),handles.ax_02.Position(2),new_width_subplot,handles.ax_02.Position(4)]);

function edit_height2_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_01.Position(2)-(handles.ax_02.Position(2)+handles.ax_02.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_03')
    set(handles.ax_02, 'position',[handles.ax_02.Position(1),handles.ax_02.Position(2),handles.ax_02.Position(3),new_height_subplot]);
else
    set(handles.ax_02, 'position',[handles.ax_02.Position(1),handles.ax_02.Position(2)+(handles.ax_02.Position(4)-new_height_subplot),handles.ax_02.Position(3),new_height_subplot]);
end

function edit_width3_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_03, 'position',[handles.ax_03.Position(1),handles.ax_03.Position(2),new_width_subplot,handles.ax_03.Position(4)]);

function edit_height3_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_02.Position(2)-(handles.ax_03.Position(2)+handles.ax_03.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_04')
    set(handles.ax_03, 'position',[handles.ax_03.Position(1),handles.ax_03.Position(2),handles.ax_03.Position(3),new_height_subplot]);
else
     set(handles.ax_03, 'position',[handles.ax_03.Position(1),handles.ax_03.Position(2)+(handles.ax_03.Position(4)-new_height_subplot),handles.ax_03.Position(3),new_height_subplot]);
end

function edit_width4_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_04, 'position',[handles.ax_04.Position(1),handles.ax_04.Position(2),new_width_subplot,handles.ax_04.Position(4)]);

function edit_height4_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_03.Position(2)-(handles.ax_04.Position(2)+handles.ax_04.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_05')
    set(handles.ax_04, 'position',[handles.ax_04.Position(1),handles.ax_04.Position(2),handles.ax_04.Position(3),new_height_subplot]);
else
    set(handles.ax_04, 'position',[handles.ax_04.Position(1),handles.ax_04.Position(2)+(handles.ax_04.Position(4)-new_height_subplot),handles.ax_04.Position(3),new_height_subplot]);
end

function edit_width5_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_05, 'position',[handles.ax_05.Position(1),handles.ax_05.Position(2),new_width_subplot,handles.ax_05.Position(4)]);

function edit_height5_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_04.Position(2)-(handles.ax_05.Position(2)+handles.ax_05.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_06')
    set(handles.ax_05, 'position',[handles.ax_05.Position(1),handles.ax_05.Position(2),handles.ax_05.Position(3),new_height_subplot]);
else
    set(handles.ax_05, 'position',[handles.ax_05.Position(1),handles.ax_05.Position(2)+(handles.ax_05.Position(4)-new_height_subplot),handles.ax_05.Position(3),new_height_subplot]);
end

function edit_width6_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_06, 'position',[handles.ax_06.Position(1),handles.ax_06.Position(2),new_width_subplot,handles.ax_06.Position(4)]);

function edit_height6_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_05.Position(2)-(handles.ax_06.Position(2)+handles.ax_06.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_07')
    set(handles.ax_06, 'position',[handles.ax_06.Position(1),handles.ax_06.Position(2),handles.ax_06.Position(3),new_height_subplot]);
else
    set(handles.ax_06, 'position',[handles.ax_06.Position(1),handles.ax_06.Position(2)+(handles.ax_06.Position(4)-new_height_subplot),handles.ax_06.Position(3),new_height_subplot]);
end
function edit_width7_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_07, 'position',[handles.ax_07.Position(1),handles.ax_07.Position(2),new_width_subplot,handles.ax_07.Position(4)]);

function edit_height7_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_06.Position(2)-(handles.ax_07.Position(2)+handles.ax_07.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_08')
    set(handles.ax_07, 'position',[handles.ax_07.Position(1),handles.ax_07.Position(2),handles.ax_07.Position(3),new_height_subplot]);
else
    set(handles.ax_07, 'position',[handles.ax_07.Position(1),handles.ax_07.Position(2)+(handles.ax_07.Position(4)-new_height_subplot),handles.ax_07.Position(3),new_height_subplot]);
end

function edit_width8_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_08, 'position',[handles.ax_08.Position(1),handles.ax_08.Position(2),new_width_subplot,handles.ax_08.Position(4)]);

function edit_height8_Callback(hObject, ~, handles)
A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_07.Position(2)-(handles.ax_08.Position(2)+handles.ax_08.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_09') 
    set(handles.ax_08, 'position',[handles.ax_08.Position(1),handles.ax_08.Position(2),handles.ax_08.Position(3),new_height_subplot]);
else
    set(handles.ax_08, 'position',[handles.ax_08.Position(1),handles.ax_08.Position(2)+(handles.ax_08.Position(4)-new_height_subplot),handles.ax_08.Position(3),new_height_subplot]);
end

function edit_width9_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_09, 'position',[handles.ax_09.Position(1),handles.ax_09.Position(2),new_width_subplot,handles.ax_09.Position(4)]);

function edit_height9_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_08.Position(2)-(handles.ax_09.Position(2)+handles.ax_09.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_09')
    set(handles.ax_09, 'position',[handles.ax_09.Position(1),handles.ax_09.Position(2),handles.ax_09.Position(3),new_height_subplot]);
else
    set(handles.ax_09, 'position',[handles.ax_09.Position(1),handles.ax_09.Position(2)+(handles.ax_09.Position(4)-new_height_subplot),handles.ax_09.Position(3),new_height_subplot]);
end

function edit_width10_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_10, 'position',[handles.ax_10.Position(1),handles.ax_10.Position(2),new_width_subplot,handles.ax_10.Position(4)]);

function edit_height10_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_09.Position(2)-(handles.ax_10.Position(2)+handles.ax_10.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_10') 
    set(handles.ax_10, 'position',[handles.ax_10.Position(1),handles.ax_10.Position(2),handles.ax_10.Position(3),new_height_subplot]);
else
    set(handles.ax_10, 'position',[handles.ax_10.Position(1),handles.ax_10.Position(2)+(handles.ax_10.Position(4)-new_height_subplot),handles.ax_10.Position(3),new_height_subplot]);
end

function edit_width11_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_11, 'position',[handles.ax_11.Position(1),handles.ax_11.Position(2),new_width_subplot,handles.ax_11.Position(4)]);

function edit_height11_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_height_subplot=str2double(A);
interlinea=handles.ax_10.Position(2)-(handles.ax_11.Position(2)+handles.ax_11.Position(4));
if interlinea > 15 || ~isfield(handles,'ax_11') 
    set(handles.ax_11, 'position',[handles.ax_11.Position(1),handles.ax_11.Position(2),handles.ax_11.Position(3),new_height_subplot]);
else
    set(handles.ax_11, 'position',[handles.ax_11.Position(1),handles.ax_11.Position(2)+(handles.ax_11.Position(4)-new_height_subplot),handles.ax_11.Position(3),new_height_subplot]);
end

function edit_width12_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_width_subplot=str2double(A);
set(handles.ax_12, 'position',[handles.ax_12.Position(1),handles.ax_12.Position(2),new_width_subplot,handles.ax_12.Position(4)]);

function edit_height12_Callback(hObject, ~, handles)

A=get(hObject,'string');
new_height_subplot=str2double(A);
set(handles.ax_12, 'position',[handles.ax_12.Position(1),handles.ax_12.Position(2),handles.ax_12.Position(3),new_height_subplot]);
