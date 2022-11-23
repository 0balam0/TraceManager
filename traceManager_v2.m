function varargout = traceManager_v2(varargin)
% TRACEMANAGER_V2 M-file for traceManager_v2.fig
%      TRACEMANAGER_V2, by itself, creates a new TRACEMANAGER_V2 or raises the existing
%      singleton*.
%
%      H = TRACEMANAGER_V2 returns the handle to a new TRACEMANAGER_V2 or the handle to
%      the existing singleton*.
%

%      TRACEMANAGER_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACEMANAGER_V2.M with the given input arguments.
%
%      TRACEMANAGER_V2('Property','Value',...) creates a new TRACEMANAGER_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before traceManager_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to traceManager_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help traceManager_v2

% Last Modified by GUIDE v2.5 03-Nov-2022 08:17:36
   
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
   'gui_Singleton',  gui_Singleton, ...
   'gui_OpeningFcn', @traceManager_v2_OpeningFcn, ...
   'gui_OutputFcn',  @traceManager_v2_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

return

function traceManager_v2_OpeningFcn(hObject, ~, handles, varargin)

try
    % Choose default command line output for traceManager_v2
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % memorizzo l'handle dell'applicazione chiamante
    hCaller = [];
    if not(isempty(varargin))
        a = strcmp(varargin, 'callerHandle');
        if any(a)
            hCaller = varargin{find(strcmp(varargin, 'callerHandle'))+1};
        end
    end
    handles.hCaller = hCaller;
    %
    
    guidata(hObject, handles);
    
    % version string
    set(handles.figSalvaTH,'name','Trace Manager v2.03');
    
    % setto la grafica dell'interfaccia
    inizializzaInterfaccia(handles)
    
    % aggiungo nuovo asse (il primo) alla selezione assi
    cContAx{1} = stringaAsse(1);
    set(handles.lb_Ax,'string',cContAx)
    set(handles.lb_Ax,'value',length(cContAx))
    % creo e memorizzo struttura di assi vuota
    tAssi(1).sigName{1} = ' ';
    
    set(handles.pb_draw, 'UserData',tAssi)

    % evita errori, ci metto cell array
    set(handles.lb_man, 'string', {1});

    % obbligo quest'applicazione (se aperta) ad essere sempre in primo piano
    set(hObject, 'WindowStyle', 'normal'); %Teoresi (modal-->normal)
    
    % inizializzo gli UserData
    UserData = struct();
    set(hObject, 'UserData',UserData);
            
catch Me
    dispError(Me, handles.lbl_infoBox);
end

return

function varargout = traceManager_v2_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
return

%%%%%%%%% pannello di selezione grandezze %%%%%%%%%%
function lb_avail_Callback(hObject, eventdata, handles)

try
   % recupero le infos dalla di Dati dalla figura
   UserData = get(gcbf,'UserData');
   try
      % visualizzo nell'et_descr la descrizione della grandezza
      cCont = get(hObject, 'string');
      if ~isempty(cCont) 
          sQuant = cCont{get(hObject, 'value')};

          %%% scrivo la descrizione nell'edit text
          cF = fieldnames(UserData.tTH);
          % ricerca della variabile fra le manovre
          % ciclo sulle manovre
          bOk = false(size(cF));
          for i = 1:length(cF)
             if isfield(UserData.tTH.(cF{i}), sQuant)
                bOk(i) = true;
             end
          end
          idx = find(bOk);
          % scrivo la descrizione della prima
          set(handles.et_descr, 'string', {['Description: ', UserData.tTH.(cF{idx(1)}).(sQuant).d];...
             ' ';...
             ['Unit: ', UserData.tTH.(cF{idx(1)}).(sQuant).u]});         
      end
   catch Me
      dispError(Me, handles.lbl_infoBox)
      s = sprintf('Could not perform required operation!', get(hObject,'String'));
      funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
%       uiwait(msgbox('Could not perform required operation.','','warn','modal'))
   end
catch 
    dispError(Me, handles.lbl_infoBox)
end

return

function lb_exp_Callback(hObject, eventdata, handles)
   % recupero le infos dalla di Dati dalla figura
    UserData = get(gcbf,'UserData');
    try
        if EnbDisSelez(handles) % solo se sono presenti dei segnali all'interno della lista    
            cCont = get(hObject, 'string'); % prendo la lista dei nomi presenti           
            sQuant = cCont{get(hObject, 'value')}; % prendo il nome selezionato
            cF = fieldnames(UserData.tTH); % trovo i tutti i nomi delle tTH es tTH_1 tTH_2 ecc
            bOk = {}; % vettore in cui salvo i nomi delle tTH
        for i = 1:length(cF) % per ogni tTH_x in tTH
            if isfield(UserData.tTH.(cF{i}), sQuant)
                bOk{end+1} = cF{i}; % segnale presente
            end
        end
          % scrivo l'elenco manovre per cui esiste questa grandezza
          if isempty(bOk)
            s = sprintf('Warning! Signal %s not found in any TH, please remove the signal!', sQuant);
            a = msgbox(s,'','warn','modal'); pause(0.5); delete(a); %stun
            funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
            set(handles.lb_man, 'string', {''});  
          else
            set(handles.lb_man, 'string', bOk);  
            set(handles.lb_man, 'value', 1);
            [tTH, sQuant, sF, ~] = get_selected_Channel(handles);
            if ~isempty(tTH)
                refreshLinestyle(handles, tTH, sQuant, sF); % aggiorno stile linea
            end
          end     
        end
    catch Me
       dispError(Me, handles.lbl_infoBox)
    end

return

function pb_add_Callback(hObject, eventdata, handles)
try
   %%% aggiungo la grandezza selezionata tra quelle disponibili a quelle da esportare
   % grandezze scelte
   cQuantCh = getListBoxSelection(handles.lb_avail);
   
   % grandezze selezionate precedentemente per l'asse corrente
   cQuantExp = deblank(get(handles.lb_exp, 'string'));
   if ischar(cQuantExp)
      cQuantExp = {cQuantExp};
   end
   % aggiungo la scelta
   if isempty(cQuantExp{1})
      cQuantExp = {};
   end
   % unione contenuti (esistente più nuovo)
   cQuantExp = union(cQuantExp, cQuantCh);
   set(handles.lb_exp, 'string',cQuantExp)
   set(handles.lb_exp, 'value',length(cQuantExp))
   % attivo la modifica delle grandezze selezionate
   EnbDisSelez(handles);
   lb_exp_Callback(handles.lb_exp, [], handles);
catch Me
    dispError(Me, handles.lbl_infoBox)
end
return

function pb_rem_Callback(hObject, eventdata, handles)

try
    [bEmpty] = remOneLB(handles.lb_exp);
    if bEmpty
        % disattivo edit delle grandezze selezionate
        EnbDisSelez(handles);
        %       disattivaEditSelez(handles)
    else
        lb_exp_Callback(handles.lb_exp, [], handles);
    end
catch Me
    dispError(Me, handles.lbl_infoBox)
end
return

function remAll(handles)

try
   % rimuove tutte le grandezze da esportare
   set(handles.lb_exp, 'value', 1)
   set(handles.lb_exp, 'string', {' '})
   % disattivo edit delle grandezze selezionate
   EnbDisSelez(handles);
%    disattivaEditSelez(handles)
catch Me
    dispError(Me, handles.lbl_infoBox)
end
return

function read_tTH(hObject, eventdata, handles)
% legge le time-history da file mat
    sObj = get(hObject, 'tag');
    num = str2num(sObj(end)); % ex: 1
    selManovra(hObject, handles, num);
    %% update custom x axes choice 
    % non vengono cancellati i dati di una tTH che viene elimitata per non
    % rifare la configurazione ogni volta che si cambia tTH.
    UD = get(gcbf, 'UserData');
    pm_CstXtTH = handles.pm_CstXtTH_selection;
    UDpm = get(pm_CstXtTH, 'UserData');
    tTHname = ['tTH_',sObj(end)];
    if isfield(UD, 'tTH') % non sono mai state caticarte tTH ed è stato premuto back durante la selezione
        if ~isfield(UDpm, tTHname) && isfield(UD.tTH, tTHname)
            UDpm.(tTHname) = struct('xSngName', 'time',...
                                    'fltSngName', 'time',...
                                    'from', min(UD.tTH.(tTHname).time.v),...
                                    'to',   max(UD.tTH.(tTHname).time.v),...
                                    'enable', false, 'filter', false);      
        end
        %% carico la lista delle tTH nelle diverse dropdox
        set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
        names = fieldnames(UD.tTH);
        if isempty(names) % sono state cancellate tutte le tTH
            names = {'load a file before'};
        end
        set(handles.pm_CstXtTH_selection, 'String', names);
        set(handles.pop_file1Sel, 'String', names);
        set(handles.pop_file2Sel, 'String', names);
        set(handles.bp_outFileTarget, 'String', names);
        if isfield(UD.tTH, tTHname) % se la tTH caricata o cancellata è presente UserData
            id = find(strcmp(get(handles.pm_CstXtTH_selection,'String'), tTHname)); % apro l'ultima tTH per controllare che i segnali memorizzati esistono.
        else
            id =1;
        end
        set(handles.pm_CstXtTH_selection, 'Value', id);
        set(handles.pop_file1Sel, 'Value', 1);
        set(handles.pop_file2Sel, 'Value', 1);
        set(handles.bp_outFileTarget, 'Value', 1);
        pm_CstXtTH_selection_Callback(handles.pm_CstXtTH_selection, [], handles);
    end
return

function selManovra(hObject, handles, nMan)

try
   % nMan: numero della manovra, se >=2 è da intendersi per il confronto
   sMan = num2str(nMan);
   sFig = ['fig_selectSim',sMan];
   if nMan > 1  % Guenna, 29/06/2015: serve per suggerire, nel caso che si voglia 
                % vedere una nuova manovra, la stessa directory della manovra precedente
       tAux = get(handles.(['fig_selectSim',num2str(nMan-1)]),'Userdata');
       sDirAux = tAux.sDirIn;
   end

   if not(isfield(handles, sFig))
      % prima esecuzione: chiamo la scelta manovra
      if nMan == 1  % Guenna, 29/06/2015
         handles.(sFig) = selectSim_v2('callerHandle',gcbf, 'selDepth','inf');   % questa è l'istruzione originale
      else  % Guenna, 29/06/2015
         handles.(sFig) = selectSim_v2('callerHandle',gcbf, 'selDepth','inf','sDefDir',sDirAux);
      end
      guidata(hObject, handles);
   else
      % esecuzioni successive: visualizzo la manovra scelta avendo cura di
      % evitare la modalità di caricamento file di default
      UserData = get(handles.(sFig),'UserData');
      UserData.bDefFile = 0;
      set(handles.(sFig), 'UserData',UserData);
      set(handles.(sFig), 'visible','on')
   end
   % blocco l'esecuzione della GUI corrente
    uiwait(gcbf)
   %
   set(handles.(sFig), 'visible','off')
   %
   %---creazione della struttura tTH dalle infos di tData---
   UserData = get(gcbf, 'UserData');
   %
   % recupero delle time-histories dalla selezione manovra
   handles_selectSim = guidata(handles.(sFig));
   tData = handles_selectSim.tData;
   %
   sTH = ['tTH_',sMan]; % ex: tTH_2
   sFile = ['sFile_',sMan]; % ex: sFile_2
   if isempty(tData)
      % se ho premuto "annulla" dalla selezione della manovra
      
      if isfield(UserData,'tTH') && nMan>1
         set(hObject, 'TooltipString', 'load time history');
         % elimino l'ultima manovra se non ho selezionato niente (vale solo
         % per le manovre dalla seconda in poi)
         if isfield(UserData.tTH, sTH)
            UserData.tTH = rmfield(UserData.tTH, sTH); % ex: tTH_2
         end
         if isfield(UserData.tFiles, sFile)
            UserData.tFiles = rmfield(UserData.tFiles, sFile); % ex: sFile_2
         end
         if isfield(UserData, 'tAx')
            La = length(UserData.tAx);
            UserData.tAx = UserData.tAx(1:max(min(La,nMan)-1,1)); % rimuovo la struttura assi
         end
         % salvo
         set(gcbf, 'UserData', UserData);
        % coloro il pulsante di grigio
        set(handles.(['pb_indietroQuan', num2str(nMan)]), 'ForegroundColor', [0.651, 0.651, 0.651], 'SelectionHighlight', 'off');
      
      
      elseif nMan==1
        funWriteToInfobox( handles.lbl_infoBox, {'Warning! it is impossible to delete the first tH, you could only replace it'}, 'n');
      end
      % coloro il pulsante di grigio
   else
      % se ho confermato la selezione manovra: devo prendere la time-histories
      % selezionata e memorizzarla in questo form
      % aggiungo campi per la gestione dell'offset verticale delle grandezze
      %% aggiorno proprietà le plot se è stata caricata una CFG
      tTH_old = [];
      
      if isfield(UserData, 'tTH') 
          if isfield(UserData.tTH, sTH) && get(handles_selectSim.copyPrp, 'Value') % se esiste il campo ed è stato selazionato il campo per importare i dati dalla vecchia tTH in selManovra
              tTH_old = UserData.tTH.(sTH);
          end
      end
      [tTH, warningOut] = completaHistory(tData.tTH, {}, tTH_old); % se var è vuoto applica lo standard a tutti i campi se è una struttura prende le info dalla struttura passata
      if ~isempty(warningOut)
          funWriteToInfobox(handles.lbl_infoBox, warningOut, 'n');
      end
      %%
      % copiatura del formato (ex: colore) dell'eventuale time-history già aperta in
      % corrispondenza del file corrente (nMan) sul file appena selezionato
      if isfield(UserData, 'tTH') && isfield(UserData.tTH, sTH)
         tTH = apply_tTHformat(UserData.tTH.(sTH), tTH);
      end
      
      % save di dati e percorso file
      UserData.tTH.(sTH) = tTH;
      UserData.tFiles.(sFile) = fullfile(tData.sDirDati, tData.sLncFile);
      set(hObject, 'TooltipString', UserData.tFiles.(sFile));
      set(gcbf, 'UserData', UserData);

      %---salvo asse corrente---
      v = get(handles.lb_Ax,'value');
      memorizzaAsse(handles,v);
      %
      tAssi = get(handles.pb_draw, 'UserData');
      %
      set(handles.pb_draw, 'UserData',tAssi)
      %
      set(gcbf, 'UserData', UserData);
      % coloro il pulsante 
      cC = listaColori;
      set(handles.(['pb_indietroQuan', num2str(nMan)]), 'ForegroundColor', cC{nMan}, 'SelectionHighlight', 'off'); % scurisco i colori
   end
   if isfield(UserData, 'tTH') % solo se esiste è stata caricata almeno una tTH
      % aggiornamento lista unità di misura disponibili
      cListUM = upgradeUnitsList(UserData.tTH);
      set(handles.pm_filterUM, 'value', 1);
      set(handles.pm_filterUM, 'string', cListUM);

      % aggiornamento della lista grandezze disponibili (per filtro)
      pm_filterUM_Callback(handles.pm_filterUM, [], handles);
   end
catch Me
    dispError(Me, handles.lbl_infoBox)
end
return
%
function tTHin = apply_tTHformat(tTHtemplate, tTHin)
cFnotCopy = {'v','d','u','v_org','xAxis_org'}'; % cell array dei sotto campi da non copiare (ex: valori)
cF = fieldnames(tTHtemplate);
cFtempl = fieldnames(tTHtemplate.(cF{1}));
cFCopy = setdiff(cFtempl, cFnotCopy); % cell array dei sotto campi da copiare (ex: colore)
% ciclo sui campi del template (modello da copiare)
for i = 1:length(cF)
    sF = cF{i};
    if isfield(tTHin, sF)
        % ciclo sui campi da copiare (quelli di formato) di ogni grandezza
        for j = 1:length(cFCopy)
            sFCopy = cFCopy{j};
            tTHin.(sF).(sFCopy) = tTHtemplate.(sF).(sFCopy);
        end
    end
end

return

function lb_man_Callback(hObject, eventdata, handles)
    try
        [tTHk, sQuant, sF, ~] = get_selected_Channel(handles);
        if ~isempty(tTHk)
            if isfield (tTHk, sQuant)
                refreshLinestyle(handles, tTHk, sQuant, sF);
            end  
        end
    catch Me
        dispError(Me, handles.lbl_infoBox)
        uiwait(msgbox('Could not perform required operation','','warn','modal'))
    end

return

function [bEmpty] = remOneLB(hLB)
% rimuove l'argomento selezionato dalla listbox
cQuant = get(hLB, 'string');
% Teoresi
if ischar(cQuant)
    cQuant = {get(hLB, 'string')};
end
%
L = length(cQuant);
idx = 1:L;
v = get(hLB, 'value');
idx = setdiff(idx, v);
selection=max(v-1,1);
set(hLB, 'value', selection(1))
if isempty(idx)
   set(hLB, 'string', {' '})
   bEmpty = true;
else
   bEmpty = false;
   set(hLB, 'string', cQuant(idx))
end
return

%%%%%%%%% pannello di selezione assi %%%%%%%%%%
function lb_Ax_Callback(hObject, eventdata, handles)
    % salvo il contenuto dell'asse da cui mi sono appena spostato
    % recupero le infos dalla di Dati dalla figura 
    UserData = get(gcbf,'UserData');

    vOld = get(handles.lb_Ax, 'UserData'); % valore precedente della lista
    if isempty(vOld)
        vOld = 1;
    end
    memorizzaAsse(handles,vOld)
    %
    % visualizzo le grandezze dell'asse su cui mi sono appena spostato
    vNew = get(handles.lb_Ax, 'value'); % valore attuale della lista
    visualizzaAsse(handles, vNew);
    %
    try
        EnbDisSelez(handles);
    catch Me
      dispError(Me, handles.lbl_infoBox)
    end
    set(handles.lb_Ax, 'UserData', vNew)
return

function pb_newAx_Callback(hObject, eventdata, handles)
%
% salvo il contenuto dell'asse corrente
% recupero le infos dalla di Dati dalla figura
UserData = get(gcbf,'UserData');

try
    % valore precedente della lista
   v = get(handles.lb_Ax, 'value'); 
   memorizzaAsse(handles,v)
   %
   % aggiungo nuovo asse in coda agli esistenti
   cContAx = getListBoxCell(handles.lb_Ax);
   %
   L = length(cContAx);
   if L==1 && isempty(deblank(cContAx{L}))
      L = 0;
   end
   cContAx{L+1} = stringaAsse(L+1);
   set(handles.lb_Ax, 'string',cContAx)
   vNew = length(cContAx); 
   set(handles.lb_Ax, 'value', vNew)
   set(handles.lb_Ax, 'UserData', get(handles.lb_Ax, 'value')) % aggiorno con il valore attuale della lista
   %
   % limite asse nuovo
   try
       % UserData.tAx potrebbe ancora non esieetre (nuovo...)
       visualizzaLimitiAsse(handles, UserData.tAx(1), L+1);
   catch Me
   end
   %
   % cancello la visualizzazione grandezze (asse nuovo è vuoto)
   remAll(handles);
%    set(handles.tb_graph ,'enable','on')
   %
   % salvo il contenuto (vuoto) dell'asse appena creato
   memorizzaAsse(handles,vNew)

catch Me
    dispError(Me, handles.lbl_infoBox)
end

% salvo le infos dalla di Dati dalla figura
set(gcbf, 'UserData', UserData);

return

function pb_remAx_Callback(hObject, eventdata, handles)
%%% questa funzione deve:
% leggere l'asse selezionato, vKill
% aggiornare tAssi (eliminare l'asse selezionato)
% aggiornare UserData.tAx (eliminare l'asse selezionato)
% mettere il focus di lb_Ax su campo valido

% recupero le infos dalla di Dati dalla figura
UserData = get(gcbf,'UserData');

%Teoresi 
    A=getListBoxCell(handles.lb_Ax);
    L=length(A);
    tAssiOld = get(handles.pb_draw, 'UserData');    
    L1=length(tAssiOld);
    vKill = get(handles.lb_Ax, 'value'); % indice asse cancellato
    % indice degli assi da conservare
 %    tAssiOld = getListBoxCell(handles.lb_Ax);
    nAxOld = length(tAssiOld);
    bIdxNew = true(nAxOld,1);
    bIdxNew(vKill) = false;
    %
    % aggiorno l'elenco degli assi da plottare
    tAssiNew = tAssiOld(bIdxNew);
    Lnew = length(tAssiNew);
    
    set(handles.pb_draw, 'UserData', tAssiNew);

%
%Teoresi (soluzione quando non c'è il campo tAx)
 if ~isfield(UserData,'tAx')||(L~=L1)  
   
   vOrd = zeros(Lnew,1);
   for i = 1:Lnew
       vOrd(i) = i;
   end  
   visualizzaListaAssi(handles.lb_Ax, Lnew, vOrd); % aggiorno string e value(=Lnew) di lb_Ax
   set(handles.lb_Ax, 'UserData', Lnew)
   %
   % aggiorno lista grandezze
   visualizzaAsse(handles, Lnew) % corrispondenza asse - segnali su lb_exp
      

else
%     
try
   % 
   tAxOld = UserData.tAx;
   tAxNew = tAxOld;
   for k = 1:length(tAxOld)
       tAxNew(k).assi = tAxOld(k).assi(bIdxNew);
   end
   % scalo indicizzazione di ordine assi per compatibilità con eliminazione
   Lnew = length(tAxNew(1).assi);
   MaxPos = Lnew;
   
   for i = 1:Lnew
       if tAxNew(1).assi(i).order > MaxPos
           tAxNew(1).assi(i).order = MaxPos;
           MaxPos = MaxPos-1; % abbasso il nuovo massimo
       end
   end
  
   UserData.tAx = tAxNew;
   %
   % aggiorno lista assi
   vOrd = fillAxisOrder(tAxNew(1));
   visualizzaListaAssi(handles.lb_Ax, Lnew, vOrd);
   set(handles.lb_Ax, 'UserData', Lnew)
   %
   % aggiorno lista grandezze e limiti
   visualizzaAsse(handles, Lnew)
   visualizzaLimitiAsse(handles, UserData.tAx(1), Lnew)
catch Me
end

% salvo le infos dalla di Dati dalla figura
set(gcbf, 'UserData', UserData);
end

return

function pb_draw_Callback(hObject, eventdata, handles)
%

try
   %---chiudo l'eventuale istanza di grafica---
   hFig_graficoTH = findobj('type','figure', 'tag','figGraficoTH');
   if not(isempty(hFig_graficoTH))
      bGiaEseguito = true;
   else
      bGiaEseguito = false;
   end
   
   lb_Ax_Callback([], [], handles)
%    end
   %
   
   %---riordino la struttura tAssi, salvo solo assi non vuoti---
   tAssi = get(handles.pb_draw, 'UserData');
   %
   %---chiamo l'interfaccia di plottaggio---
   if not(isempty(tAssi))
       
      % aggiorno i dati della struttura per gli assi (ex: cambio manovra)
      UserData = get(gcbf, 'UserData');
      tAxOld = struct();
      if isfield(UserData,'tAx')
          % esecuzioni successive
          tAxOld = UserData.tAx;
      end
      %     
      % creo la struttura assi
      
      UserData.tAx = crea_tAx(handles,tAxOld, UserData.tTH); %%Teoresi (handles)
      set(gcbf, 'UserData',UserData)    
        
      % disegno
      bForceZero = logical(get(handles.cb_roundZero, 'value'));
      if not(bGiaEseguito)
         % eseguo un'istanza della funzione e disegno la TH
         handles.figGraficoTH = graficoTH('tAx',UserData.tAx,...
                                          'bForceZero', bForceZero,...
                                          'tFiles', UserData.tFiles);   % Guenna 29/06/2015: aggiunto tFiles
      else
         % recupero gli handles del grafico (in particolare la funzione che
         % disegna gli oggetti) e disegno le nuove TH
         handlesGrafico = guidata(handles.figGraficoTH);
         handlesGrafico = handlesGrafico.fDisegna(handlesGrafico, 'tAx',UserData.tAx,...
                                                  'bForceZero', bForceZero, ...
                                                  'tFiles', UserData.tFiles);   % Guenna 29/06/2015: aggiunto tFiles
         % handlesGrafico = graficoTH('disegna',handlesGrafico,'tAx',UserData.tAx)
          
      
      end
      else
     
      UserData.tAx = crea_tAx(handles,tAxOld, UserData.tTH); %%Teoresi (handles)

      % disegno
      bForceZero = logical(get(handles.cb_roundZero, 'value'));
      if not(bGiaEseguito)
         % eseguo un'istanza della funzione e disegno la TH
         handles.figGraficoTH = graficoTH('tAx',UserData.tAx,...
                                          'bForceZero', bForceZero,...
                                          'tFiles', UserData.tFiles);   % Guenna 29/06/2015: aggiunto tFiles
      else
         % recupero gli handles del grafico (in particolare la funzione che
         % disegna gli oggetti) e disegno le nuove TH
         handlesGrafico = guidata(handles.figGraficoTH);
         handlesGrafico = handlesGrafico.fDisegna(handlesGrafico, 'tAx',UserData.tAx,...
                                                  'bForceZero', bForceZero, ...
                                                  'tFiles', UserData.tFiles);   % Guenna 29/06/2015: aggiunto tFiles
         % handlesGrafico = graficoTH('disegna',handlesGrafico,'tAx',UserData.tAx)       
      end        
   end
   
   % Teoresi (Inserisco dimensioni immagine totale nei corrispondenti edit text (Total Size)
        posFig = get(handles.figGraficoTH,'position');
        set(handles.total_width,'string',num2str(posFig(3)));
        set(handles.total_height,'string',num2str(posFig(4)));
   %    
   drawnow
   refresh(gcbf)
   %
   guidata(hObject,handles)

catch Me
    dispError(Me, handles.lbl_infoBox)
end
return

function cCont = getListBoxCell(hLb)
% ritorna il contenuto di una list box sempre in cell array

c = get(hLb, 'string');
if ischar(c)
    cCont{1} = c;
else
    cCont = c;
end

return

function tAx = crea_tAx(handles,tAx, tTH)

cF = fieldnames(tTH);
n_tTH =ones(length(cF),1);
for i = 1:length(cF)
    tmp = strsplit(cF{i}, '_');
    n_tTH(i) = str2num(tmp{2});
end
n_tTH = max(n_tTH);

tAssi = get(handles.pb_draw, 'UserData');
% sXquant = grandezzaAsseX(handles.pm_Xaxis);
%
for k = 1:n_tTH%length(cF)
%    if isfield(tTH, ['tTH_',str2num(k)])
   tTH_name = ['tTH_', num2str(k)];
   % ciclo su assi
   % (ex: 1: asse in alto e 2: asse in basso)
   for i = 1:length(tAssi)
      aXyDoubled = 0; % Asse y singolo
      % taglio al numero di segnali di struttura assi.
      if isfield(tAx, 'assi')
           Lax = length(tAssi(i).sigName);
          if k<= length(tAx) && i <= length(tAx(k).assi)
               Lold = length(tAx(k).assi(i).signals);
              Lnew = min(Lold, Lax);
              tAx(k).assi(i).signals = tAx(k).assi(i).signals(1:Lnew);
          end
      end
           
      %%% segnali
      % (ex: 1: VSSCD_v, 2: v_veh, 3: v_rullo)
      for j = 1:length(tAssi(i).sigName)              
        sField = tAssi(i).sigName{j};
        
        src = struct('name','', 'v',[], 'u', '', 't', [], 'color', [], 'label', '',...
                'Lstyle', 'Solid', 'Width', '1.5', 'Mstyle', 'none', 'Msize', '4', 'secAx', 0);
      % Teoresi 
         
        if ischar(sField)
            sField = sField;
        else
            sField = sField{1};
        end
        UDpm = get(handles.pm_CstXtTH_selection, 'UserData');
        if isfield(tTH, tTH_name)
            tTH_k = tTH.(tTH_name);
            [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTH_k);
            if any(strcmp(fieldnames(tTH_k), sField))
                % controllo esistenza nella manovra/acquizione del segnale
                % richiesto per quell'asse
                src.name = sField; 
                src.u = tTH_k.(sField).u;
                %
                % scelgo la grandezza X da usare nel plot
                %  UD_struct = struct('xSngName', 'time', 'fltSngName', 'time', 'form', min(UD.tTH.tTHname.time.v), 'to',   max(UD.tTH.tTHname.time.v), 'enable', false, 'filter', flase);      
                
                if  UDpm.(tTH_name).enable 
                    sX = UDpm.(tTH_name).xSngName;
                else
                    sX = 'time'; 
                end
%                 UDpm.(tTH_name).enable 
                sXflt = UDpm.(tTH_name).fltSngName;
                id_space = 1:length(tTH_k.(sXflt).v);
                if UDpm.(tTH_name).filter
                    id_space(tTH_k.(sXflt).v(id_space) < UDpm.(tTH_name).from) = [];
                    id_space(tTH_k.(sXflt).v(id_space) > UDpm.(tTH_name).to)   = [];
                end
%                 id_space
                src.t =  tTH_k.(sX).v(id_space) + tTH_k.time.t0;
                src.v =  tTH_k.(sField).v(id_space) * tTH_k.(sField).g0;
                % stile linea
                lineStyle = {'label', 'color', 'Lstyle', 'Width', 'Mstyle', 'Msize', 'secAx'};
                for cc=1:length(lineStyle)
                    if isfield(tTH_k.(sField), lineStyle{cc})
                        src.(lineStyle{cc}) = tTH_k.(sField).(lineStyle{cc});
                    end
                end
            end
        end 
        names = fieldnames(src);
        for cc=1:length(names)
            tAx(k).assi(i).signals(j).(names{cc}) = src.(names{cc});
        end
        if tAx(k).assi(i).signals(j).secAx  % Doppio asse Y
            aXyDoubled = 1; 
        end
      end
      
      %%% Aggiungo informazioni sul numero di assi Y grafico
      tAx(k).assi(i).yDoubled = aXyDoubled;
      
      %%% limite asse Y (non sovrascrivo)
      if not(isfield(tAx(1).assi(i), 'Ylimit')) || length(tAx(1).assi(i).Ylimit) ~=3 
          tAx(1).assi(i).Ylimit = NaN * zeros(3,1); % [Ymin Ymax DY]  
      end
      
      %%% label asse Y (non sovrascrivo)
      if not(isfield(tAx(1).assi(i), 'Ylabel'))
          % prendo il primo segnale
          tAx(1).assi(i).Ylabel = ''; %tAx(1).assi(i).signals(1).u;
      end

      %%% ordine dei subplot (non sovrascrivo)
      if not(isfield(tAx(1).assi(i), 'order'))
          % impongo pari all'ordine di creazione
          tAx(1).assi(i).order = [];
      end
      
   end
   % taglio struttura old troppo lunga
   tAx(k).assi = tAx(k).assi(1:length(tAssi));
end

%%% limite asse X (non sovrascrivo)
if not(isfield(tAx(1).assi(1), 'Xlimit')) || length(tAx(1).assi(1).Xlimit) ~=3
    tAx(1).assi(1).Xlimit = NaN * zeros(3,1); % [Xmin Xmax DX]
end
%
%%% label asse X (non sovrascrivo)
if not(isfield(tAx(1).assi(1), 'Xlabel'))
    % prendo il primo segnale
    tAx(1).assi(1).Xlabel = 'time [s]';
end

return

% function [x, value] = applicaOffset(tTH_k_x, tTH_k_value, varargin) 
% %% Da eliminare
% % campo per recepimento dati originari
% sVorg = 'v_org';
% bOrgData = isfield(tTH_k_value, sVorg) && not(isempty(tTH_k_value.(sVorg)));
% 
% % eventuale forzamento di utilizzo campi del tempo originari o interpolati
% if(not(isempty(varargin)))
%     if not(isempty(varargin{1}))
%         bOrgData = varargin{1};
%     end
% end
% 
% % definizione campo per valori
% if bOrgData
%     sV = sVorg;
% else
%     sV = 'v';
% end
% 
% value = tTH_k_value.(sV);
% % applicazione offset orizzontale
% v0x = tTH_k_x.v0;
% if isempty(v0x)
%    v0x = 0;
% end
% x = tTH_k_x.(sV) + v0x;
% 
% % dati per offset sulla grandezza
% t0 = tTH_k_value.t0;
% v0 = tTH_k_value.v0;
% g0 = tTH_k_value.g0;
% 
% %
% % applicazione guadagno verticale
% % (prima scalo la grandezza, ex. rendo coerenti le unità di misura, poi la
% % centro in Y su cosa mi serve)
% if isempty(g0)
%     g0 = 1;
% end
% if ~isempty(tTH_k_value.label)
%     value = g0 * value;
% end
% % applicazione dell'offset verticale
% if not(isempty(t0)) && not(isempty(v0))
%     v0_org = interp1qsat(x, value, t0);
%     value = value + v0 - v0_org;
% end
% 
% return

function memorizzaAsse(handles,v)

try
% memorizzo nel pulsante pb_draw la struttura tAssi, che contiene il
% nome delle grandezze dei vari assi da plottare. v è l'asse a cui ci si sta
% riferendo per associare le grandezze contenute in lb_exp
%
tAssi = get(handles.pb_draw, 'UserData');
%
c1 = get(handles.lb_exp,'string');
% trattamento elemento singolo (stringa, non cell)
if iscell(c1)
   if isempty(deblank(c1{1}))% le listbox non vogliono stringa nulla
      c{1} = '';
   else
      c = c1;
   end
else
   c{1} = c1;
end
%
% vOrd = getOrderAsse(handles.lb_Ax, v);
tAssi(v).sigName = c;
%
% salvataggio struttura
set(handles.pb_draw, 'UserData',tAssi)

catch Me
    dispError(Me, handles.lbl_infoBox)
end
return

function visualizzaLimitiAsse(handles, tAx1, vAxY)

try
    % assi(vNew)potrebbe non esistere (ex: ho appena creato un asse nuovo)
    % visualizzo limiti di assi X e Y nelle apposite caselle
    scriviLimitiAsse(handles, 'X', tAx1.assi(1).Xlimit)
    if vAxY<=length(tAx1.assi)
        vLimY = tAx1.assi(vAxY).Ylimit;
    else
        % ex: asse nuovo: limite nullo
        vLimY = [NaN NaN NaN];
    end
    scriviLimitiAsse(handles, 'Y', vLimY)
catch Me
    dispError(Me, handles.lbl_infoBox)
end

function visualizzaLabelAsse(handles, tAx1, vAxY)

try
    % assi(vNew)potrebbe non esistere (ex: ho appena creato un asse nuovo)
    % visualizzo label di assi X e Y nelle apposite caselle
    set(handles.et_labAxisY, 'string', tAx1.assi(1).Xlabel);
    if vAxY<=length(tAx1.assi)
        sLabY = tAx1.assi(vAxY).Ylabel;
    else
        % ex: asse nuovo: limite nullo
        sLabY = '';
    end
    set(handles.et_labAxisY, 'string', sLabY);
catch Me
    dispError(Me, handles.lbl_infoBox)
end

function visualizzaOrdineAsse(handles, tAx1, vAxY)

try
    % assi(vNew)potrebbe non esistere (ex: ho appena creato un asse nuovo)
    % visualizzo label di assi X e Y nelle apposite caselle
    if isfield(tAx1.assi(1),'order')
        set(handles.et_axisOrd, 'string', tAx1.assi(1).order);
        if vAxY<=length(tAx1.assi)
            sOrd = tAx1.assi(vAxY).order;
        else
            % ex: asse nuovo: limite nullo
            sOrd = '';
        end
        set(handles.et_axisOrd, 'string', sOrd);
    end
catch Me
    dispError(Me, handles.lbl_infoBox)
end

function pb_YlimitsOk_Callback(hObject, eventdata, handles)

% recupero le infos dalla di Dati dalla figura
UserData = get(gcbf,'UserData');

% UserData.tAx.assi(1).signals(1)
% UserData.tAx.assi(1).Ylimit = [0 25 400]; % [yMin Step yMax]
% UserData.tAx.assi(1).Ylimit = [0 NaN 400]; % limite non settato

vLimY = leggiLimitiAsse(handles, 'Y');
vLimX = leggiLimitiAsse(handles, 'X');

% indice asse corrente scelto da utente
nAx = get(handles.lb_Ax, 'value');
nAxMax = length(getListBoxCell(handles.lb_Ax));

% salvo limiti nella struttura dati
if not(isfield(UserData, 'tAx'))
    % creo la struttura degli assi
    memorizzaAsse(handles, get(handles.lb_Ax,'value'));
    tAssi = get(handles.pb_draw, 'UserData');
    UserData.tAx = crea_tAx(handles, struct(), tAssi, UserData.tTH); %%Teoresi (handles)
    
end
 UserData.tAx(1).assi(1).Xlimit = vLimX; % il limite asse X è comune per tutti gli assi (scelgo il primo) e per tutti le manovre (scelgo la prima)
 UserData.tAx(1).assi(nAx).Ylimit = vLimY; % il limite asse Y è comune per tutti le manovre (scelgo la prima)

% memorizzo label assi X e Y
UserData.tAx(1).assi(1).Xlabel = get(handles.et_labAxisX, 'string');
UserData.tAx(1).assi(nAx).Ylabel = get(handles.et_labAxisY, 'string');

% memorizzo ordine di subplot
nOrd = [];
% s = get(handles.et_axisOrd, 'string');
% if not(isempty(s))
%     % saturazione al numero di assi attuale
%     nOrd = round(str2double(s));
%     nOrd = min(max(nOrd, 1), nAxMax);
% end
UserData.tAx(1).assi(nAx).order = nOrd;

% visualizzo nuova lista assi
vOrd = fillAxisOrder(UserData.tAx(1));
L = length(getListBoxCell(handles.lb_Ax));
visualizzaListaAssi(handles.lb_Ax, L, vOrd);


% salvo
set(gcbf, 'UserData', UserData)

return

function vLim = leggiLimitiAsse(handles, sAsse)

% legge il contenuto dei campi che da interfaccia specificano i limiti e lo
% scrive nel vettore di out: vLim = [min max delta]

vLim = NaN * zeros(3,1);
% limite minimo
s1 = get(handles.(['et_',sAsse, 'min']), 'string');
if not(isempty(s1))
    vLim(1) = str2double(s1);
end
% limite massimo
s2 = get(handles.(['et_',sAsse, 'max']), 'string');
if not(isempty(s2))
    vLim(2) = str2double(s2);
end
% delta
s3 = get(handles.(['et_',sAsse, 'delta']), 'string');
if not(isempty(s3))
    vLim(3) = str2double(s3);
    % il delta non può essere nullo
    if vLim(3) == 0
        vLim(3) = NaN;
    end
end

return

function scriviLimitiAsse(handles, sAsse, vLim)

% scrive nei campi che da interfaccia specificano i limiti quanto è
% memorizzaro come limite corrente

% limite minimo
s1 = '';
if not(isnan(vLim(1)))
    s1 = num2str(vLim(1));
end
set(handles.(['et_',sAsse,'min']), 'string', s1);
% limite massimo
s2 = '';
if not(isnan(vLim(2)))
    s2 = num2str(vLim(2));
end
set(handles.(['et_',sAsse,'max']), 'string', s2);
% delta
s3 = '';
if not(isnan(vLim(3)))
    s3 = num2str(vLim(3));
end
set(handles.(['et_',sAsse,'delta']), 'string', s3);


return

%%% pannello di selezione colori
function tb_cX_Callback(hObject, eventdata, handles)

% setta a zero tutti i pulsanti non premuti

hPan = get(hObject, 'parent');
hTb = get(hPan, 'children');
hTbOff = hTb(hTb ~= hObject);
set(hTbOff, 'value', 0);

return

function [c] = leggiColoreLinea(handles)
% colore del pulsante selezionato
c = [];
hTb = get(handles.pan_colButt, 'children');
vVal = cell2mat(get(hTb, 'value')); % pulsante attivo
v = find(vVal);
if not(isempty(v))
    c = get(hTb(v), 'BackGroundColor');
end
return

function scriviColoreLinea(handles, color)

% accendo il pusante corrispondente al colore scelto (se c'è)

if isempty(color)
  color = [NaN NaN NaN];
end
hTb = get(handles.pan_colButt, 'children'); 
cCol = get(hTb, 'BackGroundColor');
bFound = false(size(cCol));
for i = 1:length(cCol)
  bFound(i) = all(color==cCol{i});
end
if any(bFound)
  % accendo pulsante corrispondente a colore scelto
  set(hTb(bFound), 'value',1)
  % spengo altri
  set(hTb(not(bFound)), 'value',0)
else
  % tutti pulsanti spenti
  set(hTb, 'value',0)
end

return

function [cSel, val] = getListBoxSelection(hLB)

cList = get(hLB, 'string');
val = get(hLB, 'value');
cSel = cList(val);
if ischar(cSel)
    cSel{1} = cSel;
end
return

function pm_filterUM_Callback(hObject, eventdata, handles)
% visualizza nella lista delle grandezze disponibili solo quelle
% corrispondenti all'unità di misura selezionata da questo menu.

% dati utente
UserData = get(gcbf,'UserData');

% filtro le grandezze disponibili in base alle unità di misura
cSel = getListBoxSelection(hObject);
if isfield(UserData, 'tTH')
    cChan = listaCanali(UserData.tTH, cSel{1});
    % scrivo l'elenco filtrato delle grandezze
    set(handles.lb_avail, 'value',1);
    set(handles.lb_avail, 'string', cChan);
    
     % Teoresi
    set(handles.lb_avail, 'UserData', cChan);
end

return

function cSel = listaCanali(tTH, varargin)
% filtra i canali disponibili dalle varie time-histories in base a quelli
% che soddisfano il filtraggio sulle unità di misura
sUnit = '(no filter)';
if not(isempty(varargin))
    % filtro sulle unità di misura
    a = strcmpi(varargin, 'units');
    if not(isempty(a))
        sUnit = varargin{a+1};
    end
    %
end

% unità di misura vuote
if strcmpi(sUnit, '(empty)')
   sUnit = '';
end

% procedura di filtraggio
cSel = {''};
cF = fieldnames(tTH);
for i = 1:length(cF)
   % i-esima time history: elimino i campi
   tTHi = tTH.(cF{i}); 
   %
   % solo grandezze (no tempo)
   % TODO: può causare problemi? Ex: per concatenazione??
   [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTHi);
   cCurr = union(cQint, cQorg);
   %
   if strcmpi(sUnit, '(no filter)')
       cCurrFilt = cCurr;
   else
       % filtraggio
       cFU = unitsList(tTHi, cCurr);
       bFilt = strcmp(cFU, sUnit);
       cCurrFilt = cCurr(bFilt);
   end
   % unione alle altre TH
   cSel = union(cSel, cCurrFilt);
end

cSel = setdiff(cSel,' ');
if strcmpi(cSel{1}, '')
    cSel = cSel(2:end);
end


return

%Teoresi (filtro di ricerca all'interno della lista canali)
function edit_filter_Callback(hObject, eventdata, handles)
UserData = get(gcbf,'UserData');
lettera=get(hObject,'string');
lista=get(handles.lb_avail,'UserData');
all_h=[];
if isempty(lettera)
    lettera=' ';
end
if lettera(1)=='*'
  lettera1=lettera(2:end);
  match=strfind(lower(lista),lower(lettera1));
  match1=~cellfun(@isempty,match);
  match2=find(match1==1);
  lista1=lista(match2);
  set(handles.lb_avail,'value',1);
  set(handles.lb_avail,'string',lista1);
else
    if lettera==' '
        lettera=get(hObject,'string');
    end
for h=1:length(lista)
    ele=lista{h};
    if (length(lettera)<=length(ele))
        ele1=ele(1:length(lettera));     
    else
    ele1='';
    end
    if strcmpi (ele1, lettera)
        all_h=[all_h h];
    end
end
lista1=lista(all_h);
set(handles.lb_avail,'value',1);
set(handles.lb_avail,'string',lista1);
end

% Teoresi (salvo il file .mat contenente la nuova lista canali)
function save_new_list_Callback(hObject, eventdata, handles)

% warndlg('New channels will be saved in tTH_1','!! Warning !!')

UserData = get(gcbf,'UserData');
   val = get(handles.lb_man, 'value');
   stringa = get(handles.lb_man, 'string');
   nMan = str2num(stringa{val});
   cF = fieldnames(UserData.tTH); 
   sF = cF{nMan}; 
   tTH=UserData.tTH.tTH_1;
   sFullFile = UserData.tFiles.sFile_1;
   [sPath, sFileName] = fileparts(sFullFile);
   sFullName = fullfile(sPath, [sFileName, '.mat']);
   [sFileName, sPathName] = uiputfile({'*.mat'; 'file matlab (*.mat)'}, 'file matlab di configurazione', sFullName);
   save([sPathName, sFileName],'tTH') 

   warndlg('New channels will be saved in tTH_1','!! Warning !!')
   
 %Teoresi (cancello canale nella lista canali e nell'UserData)
function delete_channel_Callback(hObject, eventdata, handles)
    % rimuove l'argomento selezionato dall'UserData
    UD = get(gcbf, 'UserData');
    L_file = length(fieldnames(UD.tTH));
    vKill = get(handles.lb_avail, 'Value');
    name_channel = get(handles.lb_avail, 'String');
    if ischar(name_channel)
        name_channel = {get(handles.lb_avail, 'String')};    
    end
        name_channel_kill = name_channel(vKill);
        nKill = length(name_channel_kill);    
    for k=1:L_file
    %     tTH_k = UD.tTH.(['tTH_',num2str(k)]);
        for i=1:nKill
            name_channel_kill_1 = name_channel_kill{i};        
            if isfield(UD.tTH.(['tTH_',num2str(k)]), name_channel_kill_1)
                UD.tTH.(['tTH_',num2str(k)]) = rmfield(UD.tTH.(['tTH_',num2str(k)]), name_channel_kill_1);
            end
        end
    end
    set(gcbf, 'UserData', UD);

    b = [];
    for i=1:nKill
        a = find(strcmp(name_channel, name_channel_kill(i)));
        b = [b; a];    
    end
    set(handles.lb_avail, 'Value', b);

    % rimuove l'argomento selezionato dalla lb_avail
    [bEmpty] = remOneLB(handles.lb_avail);
    EnbDisSelez(handles);


% Teoresi(plot order up) 
function pb_up_Callback(hObject, eventdata, handles)

UserData = get(gcbf,'UserData');

for i=1:length(length(UserData.tAx)) 
Ax_string=get(handles.lb_Ax,'string');
Ax_value=get(handles.lb_Ax,'value');
Ax_position=Ax_string{Ax_value};
signal_sel=UserData.tAx(i).assi(Ax_value).signals;
signal_sel_name=UserData.tAx(i).assi(Ax_value-1).signals.name;
Ylimit_sel=UserData.tAx(i).assi(Ax_value).Ylimit;
Ylimit_sel1=UserData.tAx(i).assi(Ax_value-1).Ylimit;
vOld=get(handles.lb_Ax, 'UserData');
v=vOld-1;
    if Ax_value > 1
        Ax_string{Ax_value}=Ax_string{Ax_value-1};
        Ax_string{Ax_value-1}=Ax_position;
        UserData.tAx(i).assi(Ax_value).signals=UserData.tAx(i).assi(Ax_value-1).signals;  
        UserData.tAx(i).assi(Ax_value-1).signals=signal_sel;
        UserData.tAx(i).assi(Ax_value-1).Ylimit=Ylimit_sel;
        UserData.tAx(i).assi(Ax_value).Ylimit=Ylimit_sel1;
        set(handles.lb_Ax, 'UserData',v);
        set(handles.lb_Ax,'value',Ax_value-1);
        field='sigName';
        tAssi_in={''};
        tAssi=struct(field,tAssi_in);
        for ii=1:length(UserData.tAx(i).assi)       
            if length(UserData.tAx(i).assi(ii).signals)>1
            for j=1:length(UserData.tAx(i).assi(ii).signals)
                tAssi2=UserData.tAx(i).assi(ii).signals(j).name;
                tAssi21{j,:}={tAssi2};                      
            end
                tAssi(ii).sigName=tAssi21;
            else
                tAssi1=UserData.tAx(i).assi(ii).signals.name;
                tAssi(ii).sigName={tAssi1};                
            end                   
         end    
    end 
end
set(handles.pb_draw, 'UserData',tAssi);    
set(gcbf, 'UserData', UserData);

 
% Teoresi(plot order down) 
function pb_down_Callback(hObject, eventdata, handles)
UserData = get(gcbf,'UserData');
down=get(hObject,'value');
for i=1:length(length(UserData.tAx)) 
    Ax_string=get(handles.lb_Ax,'string');
    Ax_value=get(handles.lb_Ax,'value');
    Ax_position=Ax_string{Ax_value};
    signal_sel=UserData.tAx(i).assi(Ax_value).signals;
    signal_sel_name=UserData.tAx(i).assi(Ax_value).signals.name;
    Ylimit_sel=UserData.tAx(i).assi(Ax_value).Ylimit;
    Ylimit_sel1=UserData.tAx(i).assi(Ax_value+1).Ylimit;
    vOld=get(handles.lb_Ax, 'UserData');
    v=vOld+1;    
        if Ax_value < length(UserData.tAx(i).assi)
            Ax_string{Ax_value}=Ax_string{Ax_value+1};
            UserData.tAx(i).assi(Ax_value).signals=UserData.tAx(i).assi(Ax_value+1).signals;  
            UserData.tAx(i).assi(Ax_value+1).signals=signal_sel;
            UserData.tAx(i).assi(Ax_value).Ylimit=Ylimit_sel1;
            UserData.tAx(i).assi(Ax_value+1).Ylimit=Ylimit_sel;
            Ax_string{Ax_value+1}=Ax_position;          
            set(handles.lb_Ax, 'UserData',v);
            set(handles.lb_Ax,'value',Ax_value+1);
            field='sigName';
            tAssi_in={''}; 
            tAssi=struct(field,tAssi_in);
            for ii=1:length(UserData.tAx(i).assi)       
            if length(UserData.tAx(i).assi(i).signals)>1
                for j=1:length(UserData.tAx(i).assi(ii).signals)
                    tAssi2=UserData.tAx(i).assi(ii).signals(j).name;
                    tAssi21{j,:}={tAssi2};                      
                end
                tAssi(ii).sigName=tAssi21;
            else
                tAssi1=UserData.tAx(i).assi(ii).signals.name;               
                tAssi(ii).sigName={tAssi1};     
            end                   
            end    
        end 
end
set(handles.pb_draw, 'UserData',tAssi);    
set(gcbf, 'UserData', UserData);

%Teoresi (cancello canale in operation list)
function pushbutton50_Callback(hObject, eventdata, handles)
    if isfield(handles, 'edit_name')
     if not(isempty(handles.edit_name))
        cQuant = handles.edit_name; % è sempre una cella
        % if ischar(cQuant)
        %     cQuant = {handles.edit_name};
        % end
        %
        L = length(cQuant);
        bIdxNew = true(L,1);
        vKill = get(handles.listbox_operations, 'value');
        bIdxNew(vKill) = false;
        cQuant = cQuant(bIdxNew);
        handles.edit_name = cQuant;
        guidata(hObject, handles)
     end
    end

    [bEmpty] = remOneLB(handles.listbox_operations);
    EnbDisSelez(handles);

% Teoresi (larghezza immagine totale plot)
function total_width_Callback(hObject, eventdata, handles)
new_width = get(hObject,'string');
posFig = get(handles.figGraficoTH,'position');
if ~isempty(new_width)
set(handles.figGraficoTH,'position',[posFig(1),posFig(2),str2num(new_width),posFig(4)]);
else
set(hObject,'string',posFig(3));
set(handles.figGraficoTH,'position',posFig);
end

% Teoresi (altezza immagine totale plot)
function total_height_Callback(hObject, eventdata, handles)
new_height = get(hObject,'string');
posFig = get(handles.figGraficoTH,'position');
if ~isempty(new_height)
set(handles.figGraficoTH,'position',[posFig(1),posFig(2),posFig(3),str2num(new_height)]);
else
set(hObject,'string',posFig(4));
set(handles.figGraficoTH,'position',posFig);
end

% --- Executes on button press in SelXSng.
function SelXSng_Callback(hObject, eventdata, handles)
    % hObject    handle to SelXSng (see GCBO) 
    % eventdata  reserved - to be defined in a future version of MATLAB 
    % handles    structure with handles and user data (see GUIDATA) 
    cQuantCh = getListBoxSelection(handles.lb_avail); 
    id = handles.xSignalTab.UserData; 
    if isempty(cQuantCh) && isempty(id) 
        uiwait(msgbox('Please select a tTH from the table above, then a channel from the list on the left and finally add it to the table from the button!','','warn','modal')) 
    else 
        UserData = get(gcbf,'UserData'); 
        tTHname = sprintf('tTH_%d', id); 
        if isfield(UserData.tTH, tTHname) 
            if isfield(UserData.tTH.(tTHname), cQuantCh{1}) 
                xSpace = handles.xSignalTab.Data; 
                xSpace{id} = cQuantCh{1}; 
                handles.xSignalTab.Data = xSpace; 
            else 
                uiwait(msgbox('Signal selected not included in this tTH','','warn','modal')); 
            end 
        else 
           uiwait(msgbox('tTH selected does not exist please load it before','','warn','modal')); 
        end 
    end 

% --- Executes when selected cell(s) is changed in xSignalTab.
function xSignalTab_CellSelectionCallback(hObject, eventdata, handles)
    if ~(isempty(eventdata.Indices)) 
        handles.xSignalTab.UserData = eventdata.Indices(1); 
    end 

% --- Executes on button press in DebugBtt.
function DebugBtt_Callback(hObject, eventdata, handles)
% hObject    handle to DebugBtt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('sono qua')
UD = get(gcbf, 'UserData');
UDpm = get(handles.pm_CstXtTH_selection, 'UserData');
assignin('base', 'UserData', UD);
assignin('base', 'handles', handles);
assignin('base', 'UDpm', UDpm);
disp('ho finito')

%% custom function
function risp = EnbDisSelez(handles)
    % se ci sono assi vuoti non abilito la gestione degli ordini degli assi
    % aggiorno la struttura pb_draw.UserData prima procedere
    pbDrawUD = handles.pb_draw.UserData;
    axesEmpty = 'on';
    for i=1:length(pbDrawUD) 
        if isempty(pbDrawUD(i).sigName{1})
            axesEmpty = 'off';
        end
    end
    set([handles.pb_up, handles.pb_down], 'enable', axesEmpty);
    
    % controlla se nell'asse selezionato ci sono segnali e abilita o disabilita alcuni obj
    try
        value = 'on'; risp = 1;
            if strcmp(handles.lb_exp.String{1}, ' ') % controllo se sono presnti dei segnali nell'asse selezionato
                value = 'off';  risp = 0;      
            end
        %   handles.pb_sort, handles.pb_sortInv, handles.tb_graph % rimosso questi obj non esitevano da set sotto
        set([handles.lb_man; handles.pb_rem; handles.lb_exp;...
            findobj(handles.pan_offset.Children,'type', 'UIControl');...   prp line, gain, offset, etc
            findobj(handles.pan_colButt.Children,'type', 'UIControl')],... paletta colori
            'enable', value)
    catch Me
        dispError(Me, handles.lbl_infoBox)
    end
return 

function UD = defineLineStyle(handles, UD, sF, sQuant)
    % set line style function
    try 
        % ricerco le informazioni
        label  = get(handles.et_labLine, 'string');
        unit  = get(handles.et_unit, 'string');
        
        g0 = str2double(get(handles.et_vertGain, 'string'));% get gain
        t0 = str2double(get(handles.et_timeManOffset, 'string'));% get offset
            
        color = leggiColoreLinea(handles);
        styles = get(handles.DashType,  'String');
        marker = get(handles.MarkerType, 'String');

        styleSelected  = styles(get(handles.DashType, 'Value'));
        MstyleSelected = marker(get(handles.MarkerType, 'Value'));
        widths = get(handles.LineWidth, 'String');
        Msize  = get(handles.MarkerSize, 'String');
        
        % asse Secondario selezionato?
        UD.tTH.(sF).(sQuant).secAx = get(handles.secAx, 'Value');
        
        % salvo le informazioni nel tTH
        UD.tTH.(sF).(sQuant).color  = color;
        UD.tTH.(sF).(sQuant).Lstyle = styleSelected{1};
        UD.tTH.(sF).(sQuant).Mstyle = MstyleSelected{1};
        UD.tTH.(sF).(sQuant).Width  = widths;
        UD.tTH.(sF).(sQuant).Msize  = Msize;
        UD.tTH.(sF).time.t0         = t0; % l'offset iniziale viene salvato e letto nel segnale time
        UD.tTH.(sF).(sQuant).g0     = g0;
        UD.tTH.(sF).(sQuant).label  = label;
        UD.tTH.(sF).(sQuant).u      = unit;
        
        names = fieldnames(UD.tTH.(sF));
        for i=1:length(names)
            UD.tTH.(sF).(names{i}).t0 = t0;
        end
    catch Me
        dispError(Me, handles.lbl_infoBox)
    end
return

function refreshLinestyle(handles, tTHk, sQuant, sF)
    try
        handles.pan_offset.Title = ['Selected: ', sQuant, '    from: ', sF];
          % Refresh plot option
          if (isfield(tTHk.time,'t0'))
              if ~isempty(tTHk.time.t0)
                t0 = tTHk.time.t0;     
              else
                  t0 = '0';
              end
          else
              t0 = '0';
          end
          if (isfield(tTHk.(sQuant),'g0'))
              if ~isempty(tTHk.(sQuant).g0)
                g0 = tTHk.(sQuant).g0;     
              else
                  g0 = '1';
              end
          else
              g0 = '1';
          end
          % Refresh linestyle
          if (isfield(tTHk.(sQuant),'Lstyle')) % Lstyle
              styles = get(handles.DashType,  'String');
              et_Style = find(strcmp(styles,tTHk.(sQuant).Lstyle)==1);
          else
              et_Style = 1;
          end
          if (isfield(tTHk.(sQuant),'Width')) % Lstyle
              et_Width = tTHk.(sQuant).Width;
          else
              et_Width = '1.5';
          end
          if (isfield(tTHk.(sQuant),'Mstyle')) % Lstyle
              styles = get(handles.MarkerType,  'String');
              et_Mstyle = find(strcmp(styles,tTHk.(sQuant).Mstyle)==1);
          else
              et_Mstyle = 1;
          end
          if (isfield(tTHk.(sQuant),'Msize')) % Lstyle
              et_Msize = tTHk.(sQuant).Msize;
          else
              et_Msize = '4';
          end 
          if (isfield(tTHk.(sQuant),'secAx')) 
              secAx = tTHk.(sQuant).secAx;
          else
              secAx = 0;
          end
          if (isfield(tTHk.(sQuant),'label')) 
              label = tTHk.(sQuant).label;
          else
              label = sQuant;
          end
          if (isfield(tTHk.(sQuant),'u')) 
              unit = tTHk.(sQuant).u;
          else
              unit = '-';
          end
              
          set(handles.DashType,   'Value',  et_Style);
          set(handles.MarkerType, 'Value',  et_Mstyle);
          set(handles.LineWidth,  'String', et_Width);
          set(handles.MarkerSize, 'String', et_Msize);
          set(handles.secAx,      'Value',  secAx);

          set(handles.et_timeManOffset, 'String',  t0);
          set(handles.et_vertGain,      'String',  g0);
          
          set(handles.et_labLine, 'String', label);
          set(handles.et_unit, 'String', unit);
          % aggiorno campi del colore
          if (isfield(tTHk.(sQuant),'color'))
            color = tTHk.(sQuant).color;
            scriviColoreLinea(handles, color) 
          end
    catch Me
        dispError(Me, handles.lbl_infoBox)
    end

    
    
%% callBack
function pb_saveStyle_Callback(hObject, eventdata, handles)
try
    % save line style function
    % get dati utente
    UD = get(gcbf, 'UserData');      
    % manovra selezionata
    [~, sQuant, sF] = get_selected_Channel(handles);
    if ~isempty(sQuant)
        if isfield(UD.tTH.(sF), sQuant)
            try
                UD = defineLineStyle(handles, UD, sF, sQuant);
                set(gcbf, 'UserData', UD);
            catch Me
                dispError(Me, handles.lbl_infoBox)
            end
        else
            uiwait(msgbox('Could not perform required operation','','warn','modal'))
        end
    end
    
catch Me
    dispError(Me, handles.lbl_infoBox)
end
return

%% ----------------------------Menu function-------------------------------
function Export_xlsx_txt(hObject, eventdata, handles)
    UserData = get(gcbf,'UserData');
    uiExport(UserData, handles.pb_draw.UserData);
function pb_exp_Callback(hObject, eventdata, handles)
% spostata in una funzione esterna per alleggerire il codice
    try
        fun_pb_exp_Callback(hObject, eventdata, handles)
    catch Me
        dispError(Me, handles.lbl_infoBox)
    end
    
function pb_saveCfg_Callback(hObject, eventdata, handles)
    fun_pb_saveCfg_Callback(hObject, eventdata, handles)
function pb_loadCfg_Callback(hObject, eventdata, handles)
    fun_pb_loadCfg_Callback(hObject, eventdata, handles)
    
%% --- Executes during object creation, after setting all properties.
function pb_saveStyle_CreateFcn(hObject, eventdata, handles)

function MarkerType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MarkerSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LineWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function et_unit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function et_labLine_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pm_multiWnds_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function et_timeManOffset_Callback(hObject, eventdata, handles)
    val = get(hObject,'String');
    try 
        risp = str2num(val);
    catch
        risp = 0;
    end
    if isempty(risp) || length(risp)>1
        risp = 0;
    end
    set(hObject, 'String', num2str(risp));

function et_vertGain_Callback(hObject, eventdata, handles)
    val = get(hObject,'String');
    try 
        risp = str2num(val);
    catch
        risp = 1;
    end
    if isempty(risp) || length(risp)>1
        risp = 1;
    end
    if risp == 1 % se il gain = 1 setto unit a old unit
        [tTH, sQuant] = get_selected_Channel(handles);
        set(handles.et_unit, 'String', tTH.(sQuant).old_u)
    end
    set(hObject, 'String', num2str(risp));

function et_labLine_Callback(hObject, eventdata, handles)
   str = get(hObject,'String');
   if isempty(str)
       [~, sQuant] = get_selected_Channel(handles);       
       set(handles.et_labLine, 'String', sQuant)
   end

function et_unit_Callback(hObject, eventdata, handles)
   str = get(hObject,'String');
   if isempty(str)
        [tTH, sQuant] = get_selected_Channel(handles);
        set(handles.et_labLine, 'String', tTH.(sQuant).old_u)
   end
   
function [tTH, sQuant, sF, nMan] = get_selected_Channel(handles)
    try
        tTH = struct(); sQuant = ''; nMan = [];
        UD = get(gcbf, 'UserData'); 
        % trovo tTH selezionata
        val = get(handles.lb_man, 'value');      % numero selezionato
        lista = get(handles.lb_man, 'string');   % lista dei nomi
        sF =  lista{val}; 
        if ~isempty(sF)
            tmp = strsplit(sF,'_');
            nMan = str2num(tmp{2});

            % grandezza selezionata
            listChn = get(handles.lb_exp, 'string');  % lista dei nomi dei canali
            val = get(handles.lb_exp, 'value');       % numero del canale selezioanto
            sQuant = listChn{val};                    % canale selezionato
            tTH = UD.tTH.(sF);
        end
    catch Me
       dispError(Me, handles.lbl_infoBox)
    end

    
function pm_multiWnds_Callback(hObject, eventdata, handles)
    % abilita/ disabilità la visualizzazione dei pannelli, l'ordine deve
    % essere mantenuto.
    val = get(hObject, 'Value');
    obj = [handles.customXpanel, handles.claclPanel];
    set(obj, 'Visible', 'off')
    set(obj(val), 'Visible', 'on');

%% calculator
function handles = clear_calc_data(handles) %handles = clear_calc_data;
    % cancella operazione precendete e disabilita il pulsante salva;
    set(handles.pb_Calculate, 'UserData', []); % cancello i dati del calcolo;
    set(handles.pb_saveOperation, 'Visible', 'off');
return

function pop_file1Sel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pop_selOperation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    opList = {'+', '-', '.*', './', '.^',...
              '==', '~=', '>', '>=', '<', '<=', '&', '|', '~',...
              'Integrate', 'Derivate', 'abs', 'sin', 'cos', 'asin', 'acos', 'tan', 'atan',...
              '1D Interpolation', '2D Interpolation', 'Calc Tire Radius'};
    set(hObject, 'String', opList);
    set(hObject, 'Value', 1);
    % dopo la prima esecuzione dei diversi ogetti li memonizzo in UserData 
    OpUserData = struct('interp1D', [],... 
                        'interp2D', [],... 
                        'tireCalc', []);
    set(hObject, 'UserData', OpUserData);
    
function pb_Calculate_CreateFcn(hObject, eventdata, handles)
    set(hObject, 'UserData', []);
    
function ckb_createPlot_CreateFcn(hObject, eventdata, handles)
    f = figure('name', 'Calculator figure');
    set(f, 'Visible', 'off');
    set(hObject, 'UserData', f);
    
function pop_file2Sel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lb_outSingalName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lb_outSignalUnit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lb_clcSng1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lb_clcSng2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pop_selOperation_Callback(hObject, eventdata, handles)
    set(handles.pb_Calculate, 'UserData', []);
    clcOpSelectedUpWin(handles);
    clear_calc_data(handles); % cancella operazione precedente

function [tTH, tTHname] = get_tTH_clcSelected(hObject, handles)
    lista = get(hObject, 'String');
    val   = get(hObject, 'Value');
    tTHname = lista{val};
    UD = get(gcbf, 'UserData'); 
    tTH = UD.tTH.(tTHname);
    clear_calc_data(handles);
return

function lb_clcSng2_Callback(hObject, eventdata, handles)
    % se il nome del segnale 1 è una costante o non esiste il campo viene
    % reimpostato il valore di default.
    set(handles.pb_Calculate, 'UserData', []);
    val = get(hObject, 'String'); 
    numVal = str2num(val);
    u = '-';
    [tTH, tTHname] = get_tTH_clcSelected(handles.pop_file2Sel, handles);
    handles = clear_calc_data(handles); %cancello i risultati precedenti se esistono
    if isempty(numVal) % allora ho inserito un nome di un segnale, controllo che esiste
        if ~isfield(tTH, val)
            s = sprintf('Warning! Signal (%s) not found in %s, please enter a valid signal. Restored default value: time', val, tTHname);
            funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
            val = 'time';
        end
        u = tTH.(val).u;
    elseif length(numVal)>1 % ho inserito un vettore, non supportato per ora
        val = 'time';
        u = tTH.(val).u;
        s = sprintf('Warning! Unsupported value. Restored default value: time', tTHname);
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
    end
    set(hObject, 'String', val);
    set(handles.lb_opChan2Unit, 'String', u);
    
function lb_clcSng1_Callback(hObject, eventdata, handles)
    % se il nome del segnale 1 è una costante o non esiste il campo viene
    % reimpostato il valore di default.
    set(handles.pb_Calculate, 'UserData', []);
    val = get(hObject, 'String'); 
    [tTH, tTHname] = get_tTH_clcSelected(handles.pop_file1Sel, handles);
    handles = clear_calc_data(handles); %cancello i risultati precedenti se esistono
    if ~isfield(tTH, val) || isempty(val)
        s = sprintf('Warning! Signal (%s) not found in %s, please enter a valid signal. restored default value: time', val, tTHname);
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
        val = 'time';
    end
    set(hObject, 'String', val);
    set(handles.lb_opChan1Unit, 'String', tTH.(val).u);
    
function lb_outSingalName_Callback(hObject, eventdata, handles)
    val = get(hObject, 'String'); 
    if ~(isvarname(val)) % se non può essere creata una variabile con questo nome allora viene settato valore di default output_signal
        s = sprintf('Warning! The output signal name (%s) is not correct , please enter a valid signal. restored default value: output_signal', val);
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
        val = 'output_signal';
    end
    set(hObject, 'String', val);
    set(handles.lbl_outInfo, 'String', ['Save ', val, ' on:']);
    
function lbl_clcDesOutChn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lbl_clcDesOutChn_Callback(hObject, eventdata, handles)
    val = get(hObject, 'String'); 
    if isempty(val)
        s = sprintf('Description in not correct, please enter a valid description. restored default value: Calc');
        val = 'output_signal';
    end
    
function pb_Calculate_Callback(hObject, eventdata, handles)
    set(handles.pb_Calculate, 'UserData', []);
    try
        UD = get(gcbf, 'UserData');
        [risp, handles] = clcCstOpFun(handles, UD.tTH);
        set(handles.pb_Calculate, 'UserData', risp);
        if ~isempty(risp) % se il calcolo è andato a buon fine
            set(handles.pb_saveOperation, 'Visible', 'on');
        else
            set(handles.pb_saveOperation, 'Visible', 'off'); 
        end
    catch Me
        dispError(Me, handles.lbl_infoBox);
        s = sprintf('Ops! qualcosa è andato storto');
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
    end

function pop_file1Sel_Callback(hObject, eventdata, handles)
    val = get(hObject, 'Value');
    set(handles.pop_file2Sel, 'Value', val);
    set(handles.bp_outFileTarget, 'Value', val);
    handles = clear_calc_data(handles); % cancella operazione precedente

function pop_file2Sel_Callback(hObject, eventdata, handles)
    handles = clear_calc_data(handles); % cancella operazione precedente
    
function pb_saveOperation_Callback(hObject, eventdata, handles)
    risp = get(handles.pb_Calculate, 'UserData');
    if ~isempty(risp)
        % ricerco il tTH su cui salvare
        lista = get(handles.bp_outFileTarget, 'String');
        val   = get(handles.bp_outFileTarget, 'Value');
        tTHname = lista{val};
        UD = get(gcbf, 'UserData'); 
        tTH = UD.tTH.(tTHname);
        % ricerco il nome l'unita di misura e la descrizione
        name = get(handles.lb_outSingalName, 'String');
        u = get(handles.lb_outSignalUnit, 'String');
        d = get(handles.lbl_clcDesOutChn, 'String');
        check = {};
        if isfield(tTH, name)
            check{end+1} = sprintf('%d) The Signal with the name %s already exists in %s', length(check)+1, name, tTHname);
        end
        if length(tTH.time.v)~=length(risp)
            check{end+1} = sprintf('%d) The length of the calculated signal (%s) is different from the length of the time base of %s', length(check)+1, name, tTHname);
        end
        if isempty(check)
             UD.tTH.(tTHname).(name) = struct('v', risp, 'u', u, 'd', d);
             UD.tTH.(tTHname) = completaHistory( UD.tTH.(tTHname), {name});
             UD = set(gcbf, 'UserData',UD); 
             pm_filterUM_Callback(handles.pm_filterUM, [], handles);
        else
            check{end+1} = 'push Yes to continue!';
             cnt = questdlg(check, 'Warning!');
             if strcmp(cnt, 'Yes')
                UD.tTH.(tTHname).(name) = struct('v', risp, 'u', u, 'd', d);
                UD.tTH.(tTHname) = completaHistory( UD.tTH.(tTHname), {name});
                UD = set(gcbf, 'UserData',UD); 
                pm_filterUM_Callback(handles.pm_filterUM, [], handles);
             end
        end
        set(handles.pb_Calculate, 'UserData', []); % cancello i dati del calcolo;
        set(handles.pb_saveOperation, 'Visible', 'off'); % Nascondo il pulsante;
        lst = get(handles.bp_outFileTarget, 'String'); % list output tTH
        val = get(handles.bp_outFileTarget, 'Value');  % tTH di output selezionata
        s = sprintf('Signal %s saved on %s', get(handles.lb_outSingalName,'String'), lst{val});
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
    else
        s = sprintf('Warning! Perform a calculation before saving');
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
    end

function bp_outFileTarget_CreateFcn(hObject, eventdata, handles)


%% custom x axes selection
function lb_xAxesSngName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lb_fromFlt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lb_toFlt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lb_xFltSngName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pm_CstXtTH_selection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%  UD_struct = struct('xSngName', 'time', 'fltSngName', 'time', 'form', min(UD.tTH.tTHname.time.v), 'to',   max(UD.tTH.tTHname.time.v));      
set(hObject, 'UserData', struct());

function pm_CstXtTH_selection_Callback(hObject, eventdata, handles)
try
    [~, tTHname, UDpm] = get_ftltTHSelection(handles);
    set(handles.lb_xAxesSngName, 'String', UDpm.(tTHname).xSngName);      lb_xAxesSngName_Callback(handles.lb_xAxesSngName, [], handles);
    set(handles.lb_xFltSngName,  'String', UDpm.(tTHname).fltSngName);    lb_xFltSngName_Callback(handles.lb_xFltSngName, [], handles);
    set(handles.lb_fromFlt,      'String', num2str(UDpm.(tTHname).from)); lb_fromFlt_Callback(handles.lb_fromFlt, [], handles);
    set(handles.lb_toFlt,        'String', num2str(UDpm.(tTHname).to));   lb_toFlt_Callback(handles.lb_toFlt, [], handles);
    set(handles.cb_enbCstAxes,   'Value',  UDpm.(tTHname).enable);       
    set(handles.cb_enbFlt,       'Value',  UDpm.(tTHname).filter);       
catch Me
    dispError(Me, handles.lbl_infoBox);
end

function lb_toFlt_Callback(hObject, eventdata, handles)
    try
        val = str2num(get(hObject,'String'));
        [tTH, tTHname, UDpm] = get_ftltTHSelection(handles);
        if isempty(val) || length(val)>1
            fltName = UDpm.(tTHname).fltSngName;
            s = sprintf('Warning! Value (%s) not supported! Restored default value: max(%s)', get(hObject,'String'), fltName);
            funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
            val = max(tTH.(fltName).v);
            set(handles.lb_toFlt, 'String', num2str(val));
        end
        UDpm.(tTHname).to = val;
        set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
    catch Me
        dispError(Me, handles.lbl_infoBox);
    end
function lb_fromFlt_Callback(hObject, eventdata, handles)
    try
        val = str2num(get(hObject,'String'));
        [tTH, tTHname, UDpm] = get_ftltTHSelection(handles);
        if isempty(val) || length(val)>1
            fltName = UDpm.(tTHname).fltSngName;
            s = sprintf('Warning! Value (%s) not supported! Restored default value: min(%s)', get(hObject,'String'), fltName);
            funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
            val = min(tTH.(fltName).v);
            set(handles.lb_fromFlt, 'String', num2str(val));
        end
        UDpm.(tTHname).from = val;
        set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
    catch Me
        dispError(Me, handles.lbl_infoBox);
    end

function lb_xAxesSngName_Callback(hObject, eventdata, handles)
try
    [tTH, tTHname, UDpm] = get_ftltTHSelection(handles);
    lbl = get(hObject, 'String');
    if ~isfield(tTH, lbl) || isempty(lbl)
        s = sprintf('Warning! Signal (%s) not found in %s, please enter a valid signal. restored default value: time', lbl, tTHname);
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
        UDpm.(tTHname).xSngName = 'time';
    else
        UDpm.(tTHname).xSngName = lbl; 
    end
    set(handles.lb_xAxesSngName, 'String', UDpm.(tTHname).xSngName);
    set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
catch Me
    dispError(Me, handles.lbl_infoBox);
end

function lb_xFltSngName_Callback(hObject, eventdata, handles)
try
    [tTH, tTHname, UDpm] = get_ftltTHSelection(handles);
    lbl = get(hObject, 'String');
    if ~isfield(tTH, lbl) || isempty(lbl)
        s = sprintf('Warning! Signal (%s) not found in %s, please enter a valid signal. restored default value: time', lbl, tTHname);
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
        UDpm.(tTHname).fltSngName = 'time';
        UDpm.(tTHname).to = max(tTH.time.v);
        UDpm.(tTHname).form = min(tTH.time.v);
    else
        UDpm.(tTHname).fltSngName = lbl; 
    end
    set(handles.lb_xFltSngName, 'String', UDpm.(tTHname).fltSngName);
    set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
catch Me
    dispError(Me, handles.lbl_infoBox);
end    
function [tTH, tTHname, UDpm] = get_ftltTHSelection(handles)
    pm_CstXtTH = handles.pm_CstXtTH_selection;
try
    lista = get(pm_CstXtTH, 'String');
    val = get(pm_CstXtTH, 'Value');
    tTHname = lista{val};
    UD = get(gcbf, 'UserData');
    tTH = UD.tTH.(tTHname);
    UDpm = get(pm_CstXtTH, 'UserData');
catch Me
	dispError(Me, handles.lbl_infoBox);
end
return

function cb_enbCstAxes_Callback(hObject, eventdata, handles)
try
    val = get(hObject, 'Value');
    [tTH, tTHname, UDpm] = get_ftltTHSelection(handles);
    UDpm.(tTHname).enable = val;
    set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
catch Me
    dispError(Me, handles.lbl_infoBox);
end
     
function cb_enbFlt_Callback(hObject, eventdata, handles)
try
    val = get(hObject, 'Value');
    [tTH, tTHname, UDpm] = get_ftltTHSelection(handles);
    UDpm.(tTHname).filter = val;
    set(handles.pm_CstXtTH_selection, 'UserData', UDpm);
catch Me
    dispError(Me, handles.lbl_infoBox);
end   

function LineWidth_Callback(hObject, eventdata, handles)
    val = str2num(get(hObject, 'String'));
    if isempty(val) || length(val)>1 || val == 0
        s = sprintf('Warning! Value (%s) not supported! Restored default value: 1.5', get(hObject,'String'));
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
        val = '1.5';
    end
    set(hObject, 'String', val);

function MarkerSize_Callback(hObject, eventdata, handles)
    val = str2num(get(hObject, 'String'));
    if isempty(val) || length(val)>1 || val == 0
        s = sprintf('Warning! Value (%s) not supported! Restored default value: 1.5', get(hObject,'String'));
        funWriteToInfobox(handles.lbl_infoBox, {s}, 'n');
        val = '1.5';
    end
    set(hObject, 'String', val);


function funPPT_Guide_Callback(hObject, eventdata, handles)
    open('.\Help\Help_traceManager_v2.pptx');

function funPDF_Guide_Callback(hObject, eventdata, handles)
    open('.\Help\Help_traceManager_v2.pdf');


