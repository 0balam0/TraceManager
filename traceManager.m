function varargout = traceManager(varargin)
% TRACEMANAGER M-file for traceManager.fig
%      TRACEMANAGER, by itself, creates a new TRACEMANAGER or raises the existing
%      singleton*.
%
%      H = TRACEMANAGER returns the handle to a new TRACEMANAGER or the handle to
%      the existing singleton*.
%

%      TRACEMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACEMANAGER.M with the given input arguments.
%
%      TRACEMANAGER('Property','Value',...) creates a new TRACEMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before traceManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to traceManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help traceManager

% Last Modified by GUIDE v2.5 02-Oct-2022 17:08:51
   
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
   'gui_Singleton',  gui_Singleton, ...
   'gui_OpeningFcn', @traceManager_OpeningFcn, ...
   'gui_OutputFcn',  @traceManager_OutputFcn, ...
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

function traceManager_OpeningFcn(hObject, eventdata, handles, varargin)

try
    % Choose default command line output for traceManager
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
    set(handles.figSalvaTH,'name','Trace Manager R2020_04')
    
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
    
    %Teoresi (oscuro operation list all'avvio)
    set(handles.uipanel14, 'Visible','off');
    set(handles.listbox_operations,'Visible','off');
    
    % inizializzo gli UserData
    UserData = struct();
    set(hObject, 'UserData',UserData);
    
    handles.xSignalTab.Data = {'time', 'time', 'time', 'time', 'time', 'time', 'time', 'time'}'; 

catch Me
    dispError(Me)
    %
end

return

function varargout = traceManager_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
%
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Get default command line output from handles structure
varargout{1} = handles.output;


return

%%%%%%%%% pannello di selezione grandezze %%%%%%%%%%

function lb_avail_Callback(hObject, eventdata, handles)

try
hlu=get(hObject,'value');
   % recupero le infos dalla di Dati dalla figura
   UserData = get(gcbf,'UserData');
   
   try
       % disable panel of line data settings
      % setPanelEnable(handles.pan_color, 'off');
            
      % visualizzo nell'et_descr la descrizione della grandezza
      cCont = get(hObject, 'string');
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
            
   catch Me
      dispError(Me)
      uiwait(msgbox('Could not perform required operation.','','warn','modal'))
   end

catch 
    dispError(Me)
end

return

function lb_exp_Callback(hObject, eventdata, handles)

try

   % recupero le infos dalla di Dati dalla figura
   UserData = get(gcbf,'UserData');

   try
       if EnbDisSelez(handles) % solo se sono presenti dei segnali all'interno della lista
           
       cCont = get(hObject, 'string');            
       sQuant = cCont(get(hObject, 'value'));

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
      % scrivo l'elenco manovre per cui esiste questa grandezza
      idx = find(bOk);
      set(handles.lb_man, 'value', 1);
      set(handles.lb_man, 'string', num2cell(idx));

      % cancello contenuto campi per offset
      set(handles.et_timeManOffset, 'string', []);
      set(handles.et_vertOffset, 'string', []);
      set(handles.et_timeOffset, 'string', []);
      set(handles.et_vertGain, 'string', []);
      set(handles.et_LPF, 'string', []);
      
      % Teoresi 
      set(handles.teo_der, 'value', 0);
      set(handles.teo_int, 'value', 0);

      % controllo che sia un segnale amplificato per aggiornare il campo et_gain
      if contains(sQuant, 'Gain') || contains(sQuant, 'LPF')
          if iscell(sQuant)
              sQuant = sQuant{1};
          end
          et_gain = UserData.tTH.(cF{idx}).(sQuant).g0;
          et_lpf = UserData.tTH.(cF{idx}).(sQuant).lpf0;
          %
          set(handles.et_vertGain, 'String', et_gain);
          set(handles.et_LPF, 'String', et_lpf);
          set(handles.edit_new_channel, 'String', sQuant);
      end

      % Aggiornamento interfaccia propriet? Linee
      % STILE
       % se sono presenti segnali nella lista

            for cc = 1:idx
                refreshLinestyle(handles, UserData.tTH.(cF{cc}), sQuant{1})
            end
           popup_menu = get(handles.popupmenu_operazioni, 'value');
      
          if popup_menu > 1
              popupmenu_operazioni_Callback(handles.popupmenu_operazioni, eventdata, handles)
          else
              set(handles.edit_new_channel,'string','');
          end
      end
   catch Me
       dispError(Me)
      uiwait(msgbox('Could not perform required operation.','','warn','modal'))
   end
catch Me
    dispError(Me)
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
   % unione contenuti (esistente pi? nuovo)
   cQuantExp = union(cQuantExp, cQuantCh);
   set(handles.lb_exp, 'string',cQuantExp)
   set(handles.lb_exp, 'value',length(cQuantExp))
   %
   % attivo la modifica delle grandezze selezionate
   EnbDisSelez(handles);

catch Me
    dispError(Me)
end
return

function pb_rem_Callback(hObject, eventdata, handles)

try
   [bEmpty] = remOneLB(handles.lb_exp);
   if bEmpty
      % disattivo edit delle grandezze selezionate
      EnbDisSelez(handles);
%       disattivaEditSelez(handles)
   end
catch Me
    dispError(Me)
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
    dispError(Me)
end
return

function read_tTH(hObject, eventdata, handles)
% legge le time-history da file mat
sObj = get(hObject, 'tag');
num = str2num(sObj(end)); % ex: 1
%
selManovra(hObject, handles, num);
return

function selManovra(hObject, handles, nMan)

try
   % nMan: numero della manovra, se >=2 ? da intendersi per il confronto
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
         handles.(sFig) = selectSim('callerHandle',gcbf, 'selDepth','inf');   % questa ? l'istruzione originale
      else  % Guenna, 29/06/2015
         handles.(sFig) = selectSim('callerHandle',gcbf, 'selDepth','inf','sDefDir',sDirAux);
      end
      guidata(hObject, handles);
   else
      % esecuzioni successive: visualizzo la manovra scelta avendo cura di
      % evitare la modalit? di caricamento file di default
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
      end

   else
      % se ho confermato la selezione manovra: devo prendere la time-histories
      % selezionata e memorizzarla in questo form
      %
      % aggiungo campi per la gestione dell'offset verticale delle grandezze
      tTH = completaHistory(tData.tTH);
      %
      % copiatura del formato (ex: colore) dell'eventuale time-history gi? aperta in
      % corrispondenza del file corrente (nMan) sul file appena selezionato
      if isfield(UserData, 'tTH') && isfield(UserData.tTH, sTH)
         tTH = apply_tTHformat(UserData.tTH.(sTH), tTH);
      end
      %
      % save di dati e percorso file
      UserData.tTH.(sTH) = tTH;
      UserData.tFiles.(sFile) = fullfile(tData.sDirDati, tData.sLncFile);
      set(gcbf, 'UserData', UserData);
      %
      % aggiornamento lista unit? di misura disponibili
      cListUM = upgradeUnitsList(UserData.tTH);
      set(handles.pm_filterUM, 'value', 1);
      set(handles.pm_filterUM, 'string', cListUM);
      %
      % aggiornamento della lista grandezze disponibili (per filtro)
      pm_filterUM_Callback(handles.pm_filterUM, [], handles);

      %---salvo asse corrente---
      v = get(handles.lb_Ax,'value');
      memorizzaAsse(handles,v);
      %
      tAssi = get(handles.pb_draw, 'UserData');
      %
      set(handles.pb_draw, 'UserData',tAssi)
      %
      set(gcbf, 'UserData', UserData);
      % visualizzo la tTH e attivo controlli per la sua gestione
      
   end
catch Me
    dispError(Me)
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
%
function pb_concatenate_Callback(hObject, eventdata, handles)

try
   UD = get(gcbf,'UserData');


   % selezione file di out
   [name, path] =  uiputfile('*.mat', 'select ouput file...', cd);
   if isequal(name,0) || isequal(path,0)
      return
   else
      sFile = [path, '\', name];
   end

   % blocco l'interazione dell'utente con l'interfaccia
   t0 = clock;
   hD = msgbox('exporting file...please wait', '', 'modal');


   % recupero dati utente
   tTH = UD.tTH;
   cAll = listaCanali(tTH); % get(handles.lb_avail, 'string');
   cF = fieldnames(tTH);

   %
   %%% tempo comune alle manovra da concatenare
   t_s = zeros(length(cF),1);
   tMin = zeros(length(cF),1);
   tMax = zeros(length(cF),1);
   for k = 1:length(cF)
      tTH_k = tTH.(['tTH_',num2str(k)]);
      t_s(k) = tTH_k.time.v(2) - tTH_k.time.v(1);
      [time] = applicaOffset(tTH_k.time, tTH_k.('time'));
      tMin(k) = time(1);
      tMax(k) = time(end);
   end
   t_s1 = min(t_s);
   time_i = (min(tMin):t_s1:max(tMax))';
   % time history concatenata
   tTHc.time.v = time_i;
   tTHc.time.u = 's';
   tTHc.time.d = '';

   %%% indici del tempo complessivo coperti dalle varie time-historiies
   idxOk = false(length(tTHc.time.v), length(cF));
   for k = 1:length(cF)
      tTH_k = tTH.(['tTH_',num2str(k)]);
      [time] = applicaOffset(tTH_k.time, tTH_k.('time'));
      % indici compresi
      idxOk(:,k) = tTHc.time.v>=time(1) & tTHc.time.v<=time(end);
   end

   %%% interpolazione delle grandezze sulle varie misure
   % ciclo sulle grandezze
   tTH_1 = tTH.(['tTH_',num2str(1)]);
   for i = 1:length(cAll)
       sField = cAll{i};
       if strcmpi(sField,'time')
           % non interpolo il tempo
           continue
       end
      % NaN di preallocazione
      tTHc.(sField).v = NaN * zeros(size(tTHc.time.v));
      %
      % solo se le trovo nella prima time-history
      if any(strcmpi(fieldnames(tTH_1), sField))
         try
            % riconoscimento grandezze cumulate dalle unit? di misura
            bCum = any(strcmpi(tTH_1.(sField).u, {'MJ','kJ','J','mJ', 'kg','g','mg',...
               'MWh','kWh','Wh','mWh', 'Km','m','mi', 'l','ml'}));
            lastVal = 0;
            % ciclo sulle misure
            for k = 1:length(cF)
               tTH_k = tTH.(['tTH_',num2str(k)]);
               %
               [time, value] = applicaOffset(tTH_k.time, tTH_k.(sField), false);
               idx = idxOk(:,k);
               %
               tTHc.(sField).v(idx) = interp1q(time, value, tTHc.time.v(idx));
               % concatenazione cumulata dei cumulati
               if bCum
                  tTHc.(sField).v(idx) = tTHc.(sField).v(idx) + lastVal;
                  lastVal = tTHc.(sField).v(find(idx,1,'last'));
               end
               tTHc.(sField).d = tTH_k.(sField).d;
               tTHc.(sField).u = tTH_k.(sField).u;
            end
         catch Me
             dispError(Me)
            disp(['Warning: problemi nel concatenare la grandezza "', sField, '"; passo alla successiva.']);
            if isfield(tTHc, sField)
               tTHc = rmfield(tTHc, sField);
            end
         end
      end
   end
   tTH = tTHc;


   %%% salvataggio su file mat dei risultati
   save(sFile, 'tTH');

   % ripristino l'interazione utente con l'interfaccia
   while etime(clock, t0) < 0.5
   end
   delete(hD)

catch Me
    dispError(Me)
end

return
%
function pb_exp_Callback(hObject, eventdata, handles)

% esportazione su file di testo
try
    % esporta le grandezze scelta dall'utente dalla time history
    % della simulazione in un file esterno
    %
    % recupero la tTH dalla figura
    UserData = get(gcbf,'UserData');
    
    %%% scelta nome file per esportazione
    % recupero nome del primo file letto
    sFullFile = UserData.tFiles.sFile_1;
    [sPath, sFileName] = fileparts(sFullFile);
    sFullName = fullfile(sPath, [sFileName, '.hst']);
    [sFileName, sPathName, filterindex] = uiputfile({'*.hst', 'file ascii (*.hst)';...
        '*.dat', 'INCA binary file (*.dat)'}, 'file to export', sFullName);
    
    if length(sFileName)>2 && strcmp(sFileName(end-1:end),'.*')
        sFileName = sFileName(1:end-2);
    end
    %
    if not(ischar(sFileName)) || not(ischar(sPathName))
        return
    end
    
    % blocco l'interazione dell'utente con l'interfaccia
    t0 = clock;
    hD = msgbox('exporting file...please wait', '', 'modal');
    
    %%% scelta grandezze da esportare
    cQuant = get(handles.lb_exp, 'string');
    if ischar(cQuant)
        cQuant = {cQuant};
    end
    cQuant(2:end+1) = cQuant;
    cQuant{1} = 'time';

    %%% interpolazione time-histories
    tTH = UserData.tTH.tTH_1;
    t_s = str2num(get(handles.et_sample, 'string'));
    if not(isempty(t_s))
        tTH = rfSdsMain('interpolaTH', tTH, t_s);
    end
    
    switch filterindex
        case 1
            % esportazione della time-history della prima manovra(tTH_1)
            rfSdsMain('writeTHascii', [sPathName, sFileName], tTH, cQuant);
            
        case 2
            % DAT format
            for i = 1:length(cQuant)
                sField = cQuant{i};
                tTHdat.(sField) = double(tTH.(sField).v);
            end
            %
            mat2dat(tTHdat, [sPathName, sFileName])
    end
    
    % ripristino l'interazione utente con l'interfaccia
    while etime(clock, t0) < 0.5
    end
    delete(hD)
catch Me
    dispError(Me)
end

return

function tTH = interpolaTH(tTH,t_s)

% vecchia funzione, serve ancora???

cF = fieldnames(tTH);
time_i = (tTH.time.v(1):t_s:tTH.time.v(end))';
cF = cF(not(strcmpi(cF, 'time')));
for i = 1:length(cF)
   sF = cF{i};
   try
      tTH.(sF).v = interp1q(tTH.time.v , tTH.(sF).v, time_i);
   catch Me
       dispError(Me)
      continue
   end
end
tTH.time.v = time_i;

return

function pb_offsetOk_Callback(hObject, eventdata, handles)

% forzo aggiornamento visualizzaione campi dell'offset
% lb_exp_Callback(handles.lb_exp, eventdata, handles)
% lb_man_Callback(handles.lb_man, eventdata, handles)

try
    % get dati utente
    UD = get(gcbf, 'UserData');
    
    try        
        % lista manovre
        val = get(handles.lb_man, 'value');
        stringa = get(handles.lb_man, 'string');
        nMan = str2num(stringa{val});
        
        % lista grandezze
        val = get(handles.lb_exp, 'value');
        stringa = get(handles.lb_exp, 'string');
        
        %Teoresi
        check_der=get(handles.teo_der, 'value');
        check_int=get(handles.teo_int, 'value');
        popup_sel_index = get(handles.popupmenu_operazioni, 'Value');
        
        if ischar(stringa)
            sQuant = stringa;
        else
            sQuant = stringa{val};
        end

        % estrazione nomi delle time-history lette nei files
        cF = fieldnames(UD.tTH); % ex: {'tTH_1', 'tTH_2'}
        sF = cF{nMan}; % ex: 'tTH_2'
        %
        % tempi
        [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', UD.tTH.(sF));
        
        % prendo valori per l'offset e li salvo nelle time-histories
        
        % Teoresi (definizioni delle variabili per derivata/integrale)
        %      name_channel=get(handles.lb_exp, 'string');
        new_channel=get(handles.edit_new_channel,'string');
        
        %     if iscell(name_channel)
        %         name_channel=name_channel{val};
        %     end
        %
        %     if iscell(name_channel1)
        %         name_channel1=name_channel1{val};
        %     end
        %
        if iscell(new_channel)
            new_channel=new_channel{1};
        end
        %
        % elimino un eventuale "-" per evitare problemi quando creo il campo associato all'operazione
        if contains(new_channel,'-')
            new_channel1= erase(new_channel,'-');
            new_channel=[new_channel1 '_neg'];
        end
        %
        % elimino un eventuale "." per evitare problemi quando creo il campo associato all'operazione
        if contains(new_channel,'.')
            new_channel1= erase(new_channel,'.');
            new_channel=new_channel1;
        end
        %
        % Teoresi
        if popup_sel_index > 1 || check_der==1 || check_int==1
            if ischar(stringa)
                stringa={stringa};
            end
            A=stringa{val}; %name_channel %sQuant
            B=[A '_' num2str(nMan)];
            A = cellstr(A);
            B = cellstr(B);
            
            string_listbox=get(handles.listbox_operations,'string');
            % value_listbox=get(handles.listbox_operations,'value');
            empty_string=' ';
            if ischar (string_listbox)
                string_listbox={string_listbox};
            end
            if isequal(string_listbox{1},empty_string)
                set(handles.listbox_operations,'string',B);
            else
                %     B=union(string_listbox,B);
                L = length(string_listbox);
                string_listbox{L+1} = B{1};
                set(handles.listbox_operations,'string', string_listbox);
                set(handles.listbox_operations,'value',length(string_listbox));
            end
            if check_der~=1 && check_int~=1
                return
            end
        end
        
        edit_gain=get(handles.et_vertGain, 'string');
        edit_lpf=get(handles.et_LPF, 'string');
        
        if isfield(UD.tTH.(sF), sQuant)
            %||~isempty(strfind(sQuant,'derivate'))
            % non devo aggiungere campi nel caso di scelta da interfaccia a
            % cazzo (capita se non ho selezionato prima la grandezza fra
            % quelle disp0nibili)
            val = str2num(get(handles.et_timeManOffset, 'string'));
            if isempty(val)
                val = UD.tTH.(sF).time.v0;
            end
            %
            % grandezza scelta per plottaggio in x
            sXquant = grandezzaAsseX(handles.pm_Xaxis);
            %
            % tempo originario
            if strcmp(sXquant, 'time')
                if not(isempty(cQorg))
                    for i = 1:length(cTorgSet)
                        sF1 = cTorgSet{i};
                        UD.tTH.(sF).(sF1).v0 = val;  % per coerenza con graficazione dati
                        UD.tTH.(sF).(sF1).t0 = UD.tTH.(sF).(sF1).v_org(1);
                    end
                end
            else
                xSpace = handles.xSignalTab.Data; 
                sXquant = xSpace{nMan}; 
%                 bOrgData = [];
            end
            %
            % tempo interpolato o grandezza generica per asse X
%             sx
%             bOrgData
%             sXquant
% sF
            try
            UD.tTH.(sF).(sXquant).v0 = val;  % per coerenza con graficazione dati
            UD.tTH.(sF).(sXquant).t0 = UD.tTH.(sF).(sXquant).v(1);
            catch
            end
            %
            % grandezze
            UD.tTH.(sF).(sQuant).v0 = str2num(get(handles.et_vertOffset, 'string'));
            UD.tTH.(sF).(sQuant).t0 = str2num(get(handles.et_timeOffset, 'string'));
            UD.tTH.(sF).(sQuant).g0 = str2num(edit_gain);
            UD.tTH.(sF).(sQuant).lpf0 = str2num(edit_lpf);
            %
            % perform unit conversion
            v0 = get(handles.pm_convUM, 'value');
            if v0>1
                % infos about units
                sUnitOld = UD.tTH.(sF).(sQuant).u;
                cNewUnits = get(handles.pm_convUM, 'string');
                sUnitNew = cNewUnits{v0};
                % convert values
                UD.tTH.(sF).(sQuant).v = mainUnitConversion(UD.tTH.(sF).(sQuant).v, sUnitOld, sUnitNew);
                sOrg = 'v_org';
                if isfield(UD.tTH.(sF).(sQuant), sOrg) && not(isempty(UD.tTH.(sF).(sQuant).(sOrg)))
                    UD.tTH.(sF).(sQuant).(sOrg) = mainUnitConversion(UD.tTH.(sF).(sQuant).(sOrg), sUnitOld, sUnitNew);
                end
                % update units
                UD.tTH.(sF).(sQuant).u = sUnitNew;
                %
                % update displayed units and convertion factor
                set(handles.et_vertUnit, 'string', sUnitNew);
                pm_convUM_Callback(handles.pm_convUM, eventdata, handles);
            end
            %
            % formato
            % UD.tTH.(sF).(sQuant).color = leggiColoreLinea(handles);
            % UD.tTH.(sF).(sQuant).label = get(handles.et_labLine, 'string');
        else
            uiwait(msgbox('Could not perform required operation','','warn','modal'))
        end
        
        % Teoresi
        if ~contains(sQuant, 'Gain') && ~contains(sQuant, 'LPF') % Per generare nuovo canale in lb_avail
            if ~isempty(edit_gain) || ~isempty(edit_lpf)
                if check_der==1 || check_int==1 || popup_sel_index > 1
                    if not(isempty(edit_gain)) && not(isempty(edit_lpf))
                        sQuant1 = ['Gain_' 'LPF_' sQuant '_' edit_gain '_' edit_lpf];
                    elseif not(isempty(edit_gain))
                        sQuant1 = ['Gain_' sQuant '_' edit_gain];
                    else
                        sQuant1 = ['LPF_' sQuant '_' edit_lpf];
                    end
                else
                    sQuant1 = new_channel;
                end
                UD.tTH.(sF).(sQuant1) = UD.tTH.(sF).(sQuant);
                UD.tTH.(sF).(sQuant1).label = sQuant1;
                %
                if strcmp(sXquant,'time')
                    bOrgData = [];
                else
                    bOrgData = false;
                end
                [~, value] = applicaOffset(UD.tTH.(sF).(sXquant), UD.tTH.(sF).(sQuant1), bOrgData);
                UD.tTH.(sF).(sQuant1).v = value;
                %
                list_channels=get(handles.lb_avail,'string');
                UD_lb_avail=get(handles.lb_avail,'UserData');
                if ~contains(list_channels, sQuant1)
                    list_channels{end+1}=sQuant1;
                    UD_lb_avail{end+1}=sQuant1;
                else
                    uiwait(msgbox('This Channel already exists, It will be owritten','','warn','modal'))
                end
                %
                UD.tTH.(sF).(sQuant1).color = leggiColoreLinea(handles);
                UD.tTH.(sF).(sQuant1).label = get(handles.et_labLine, 'string');
                
                % creazione campo Stile linea
%                 styles=get(handles.DashType, 'String');
%                 styleSelected=styles(get(handles.DashType, 'Value'));
                
%                 Mstyles=get(handles.MarkerType, 'String');
                
                set(handles.lb_avail,'string',list_channels);
                set(handles.lb_avail,'UserData',UD_lb_avail);
            end
        end

        % Teoresi (utilizzo dell'editor per cambiare nome di derivate e integrali)
        if check_der==1 || check_int==1
            if not(isfield(handles, 'edit_name'))
                handles.edit_name = {};
            end
            if isempty(handles.edit_name)
                a = get(handles.listbox_operations, 'String'); % NB: sicuramente ? una cella con almeno un elemento
                b = length(a);
                if b>1
                    v = (1:1:b-1);
                    set(handles.listbox_operations, 'Value', v);
                    a = a(1:end-1);
                    set(handles.listbox_operations, 'String', a);
                    uiwait(msgbox('Delete the selected channels from the Operation List','','warn','modal'))
                    return
                end
            end
            l = length(handles.edit_name);
            name = get(handles.edit_new_channel, 'String'); %new_channel
            handles.edit_name{l+1}= name{1};
            guidata(hObject,handles);
        end

        % Teoresi (utilizzo dell'editor per cambiare nome del vettore risultante da un'operazione tra canali)
        if popup_sel_index > 1
            if isfield(handles, 'edit_name')
                if not(isempty(handles.edit_name))
                    l = length(handles.edit_name);
                    v = 1:1:l;
                    set(handles.listbox_operations, 'Value', v);
                    a = get(handles.listbox_operations, 'String'); % NB: sicuramente ? una cella con pi? di un elemento
                    a = a(1:end-1);
                    set(handles.listbox_operations, 'String', a);
                    uiwait(msgbox('Delete the selected channels from the Operation List','','warn','modal'))
                    return
                end
            end
            handles.edit_name1 = new_channel;
            guidata(hObject,handles);
        end

        % Fix cambiocolore
        NuovoNome = get(handles.edit_new_channel, 'String');
        if strcmp(NuovoNome,stringa(1,1)) || isempty(NuovoNome)
            % creazione campo Stile linea
            defineLineStyle(handles, UD, sF, sQuant);
            return
        else
            UD.tTH.(sF).(sQuant).g0 = [];
            UD.tTH.(sF).(sQuant).lpf0 = [];
        end
        
        % save dati utente
        set(gcbf, 'UserData', UD);
        
        % disable panel of line data settings
        % setPanelEnable(handles.pan_color, 'off');
    catch Me
        dispError(Me)
        uiwait(msgbox('Could not perform required operation','','warn','modal'))
    end
catch Me
    dispError(Me)
end

return

function setPanelEnable(hPan, sAct)

hC = get(hPan, 'children');
for i = 1:length(hC)
    sProp = 'Type';
    sPropEn = 'Enable';
    if isprop(hC(i), sProp) && strcmpi(get(hC(i), sProp), 'uipanel')
        % panel: call itself
        setPanelEnable(hC(i), sAct);
    elseif isprop(hC(i), sPropEn)
        % sets enable
        set(hC(i), 'Enable', sAct);
    else
        % next object
        continue
    end
end

return

function lb_man_Callback(hObject, eventdata, handles)

try
   % recupero le infos dalla di Dati dalla figura
   UserData = get(gcbf,'UserData');

   try
      % lista manovre
      val = get(hObject, 'value');
      stringa = get(hObject, 'string');
      nMan = str2num(stringa{val});

      % lista grandezze
      val = get(handles.lb_exp, 'value');
      stringa = get(handles.lb_exp, 'string');
      
      %Teoresi
      if iscell(stringa)
        sQuant = stringa{val};
      else
        sQuant = stringa;
      end
     
      %
      cF = fieldnames(UserData.tTH);
      %
      % aggiorno campi per l'offset
      tTHk = UserData.tTH.(cF{nMan});
      
      %Teoresi
      if ~isfield (tTHk,sQuant)
        tTHk = UserData.tTH.tTH_1;  
      end
      %
      set(handles.et_timeManOffset, 'string', tTHk.time.v0);
      set(handles.et_vertOffset, 'string', tTHk.(sQuant).v0);
      set(handles.et_timeOffset, 'string', tTHk.(sQuant).t0);
      set(handles.et_LPF, 'string', tTHk.(sQuant).lpf0);
      set(handles.et_vertGain, 'string', tTHk.(sQuant).g0);
      set(handles.teo_der,'value',0);
      set(handles.teo_int,'value',0);
      sCurrUnit = tTHk.(sQuant).u;
      
      % Refresh linestyle e linewidth interfaccia
      refreshLinestyle(handles, tTHk, sQuant);
      
      % update display of current unit
      set(handles.et_vertUnit, 'string', sCurrUnit);
      
      % update list of possible conversions for selected unit
      cPossUnits = getListUnitConv(sCurrUnit);
      set(handles.pm_convUM, 'string', cPossUnits, 'value',1);
      
   catch Me
       dispError(Me)
      uiwait(msgbox('Could not perform required operation','','warn','modal'))
   end
catch Me
    dispError(Me)
end

return

function pm_convUM_Callback(hObject, eventdata, handles)

val = get(hObject, 'value');
if val>1
    % if some unit for convertion is selected
    %
    % get old unit
    sUnitOld = get(handles.et_vertUnit, 'string');
    %
    % get desired (new) unit
    cUnitsNew = get(hObject, 'string');
    sUnitNew = cUnitsNew{get(hObject, 'value')};
    %
    % writes conversion factor to text object
    gain = mainUnitConversion(1, sUnitOld, sUnitNew);
    set(handles.et_convFact, 'string', gain);
end

return

function c = getListUnitConv(sCurrUnit)

% searches for possible conversion
bSupp = false;
cPossUnits = {''};
if not(isempty(sCurrUnit))
    [dum, bSupp, cPossUnits] = mainUnitConversion(1, sCurrUnit, sCurrUnit);
end
% first is no conversion option
c = {'(no conv.)'};
% adds possible units
if bSupp
    c(2:length(cPossUnits)+1,1) = cPossUnits(:);
end
return

function inizializzaInterfaccia(handles)

cTag = sort(fieldnames(handles));

%%% gestisco interfaccia di diverse versioni
%
idx = find(strfindB(lower(cTag), lower('pb_indietroQuan')));
for i = 1:length(idx)
   set(handles.(cTag{idx(i)}), 'visible','off')
end

cC = listaColori;

for i = 1:length(idx)
   set(handles.(cTag{idx(i)}), 'visible','on', 'ForegroundColor',max((cC{i}-[0.1 0.1 0.1]),0)) % scurisco i colori
end


%%% coloro i pulsanti di selezione colore
hTb = get(handles.pan_colButt, 'children');
for i = 1:length(hTb)
    set(handles.(['tb_c',num2str(i)]) , 'BackGroundColor', cC{i})
end


return

function s = eliminaCaratteri(s)
% tolgo caratteri strani dal nome
sChar = '\/.,;:';
for i=1:length(sChar)
   L = length(s);
   a = strfind(s,sChar(i));
   if not(isempty(a))
      idx = setdiff(1:L,a);
      s = s(idx);
   end
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

function tTH = completaHistory(tTH)

% aggiunta campi v0 e t0 per l'offset verticale della grandezza
% in pi? aggiungo il campo d (descrizione), non sempre presente
% e i campi colore e label per legenda

cF = fieldnames(tTH);
for i = 1:length(cF)
   sF = cF{i};
   if not(isfield(tTH.(sF), 'u'))
      tTH.(sF).('u') = '';
   end
   if not(isfield(tTH.(sF), 'd'))
      tTH.(sF).('d') = '';
   end
   if not(isfield(tTH.(sF), 'v0'))
      tTH.(sF).('v0') = [];
   end
   if not(isfield(tTH.(sF), 't0'))
      tTH.(sF).('t0') = [];
   end
   if not(isfield(tTH.(sF), 'g0'))
      tTH.(sF).('g0') = [];
   end
   if not(isfield(tTH.(sF), 'lpf0'))
      tTH.(sF).('lpf0') = [];
   end
   if not(isfield(tTH.(sF), 'color'))
      tTH.(sF).('color') = [];
   end
   if not(isfield(tTH.(sF), 'label'))
      tTH.(sF).('label') = sF;
   end
   % 
   % nuovo formato a pi? sample times
   if not(isfield(tTH.(sF), 'v_org'))
      tTH.(sF).('v_org') = [];
   end
   if not(isfield(tTH.(sF), 'xAxis'))
      tTH.(sF).('xAxis') = 'time';
   end
   if not(isfield(tTH.(sF), 'xAxis_org'))
      tTH.(sF).('xAxis_org') = 'time';
   end
end

return

function pb_saveCfg_Callback(hObject, eventdata, handles)

% dati utente
UserData = get(gcbf,'UserData');

try
    %%% prendo strutture dati per il salvataggio
    if isfield(UserData, 'tAx')
        tAx = UserData.tAx;
    else
        tAx = struct();
    end
    tAssi = get(handles.pb_draw, 'UserData');
    tTH = UserData.tTH;
    tFiles = UserData.tFiles;
    xSpaces = handles.xSignalTab.Data; 
    %
    % decido se includere i dati delle time-history nel salvataggio della
    % configurazione
    if get(handles.cb_inclTH, 'value') == 0
        % non includo: elimino i dati
        tTH = deleteHistData(tTH);
    end  
   % nome file per salvataggio configurazione
   sFullFile = UserData.tFiles.sFile_1;
   [sPath, sFileName] = fileparts(sFullFile);
   sFullName = fullfile(sPath, [sFileName, '.etc']);
   [sFileName, sPathName] = uiputfile({'*.etc'; 'file matlab (*.etc)'}, 'file matlab di configurazione', sFullName);
   %
   if not(ischar(sFileName)) || not(ischar(sPathName))
      return
   end
   %

   % blocco l'interazione dell'utente con l'interfaccia
   t0 = clock;
   hD = msgbox('exporting file...please wait', '', 'modal');

   %
   % salvataggio file su disco
   save([sPathName, sFileName], 'tAx', 'tAssi', 'tTH', 'tFiles', 'xSpaces', '-mat')

   % ripristino l'interazione utente con l'interfaccia
   while etime(clock, t0) < 0.5
   end
   delete(hD)
    

catch Me
    dispError(Me)
    disp('impossible to retrieve all data needed for saving configuration')
end

return

function tTH = deleteHistData(tTH)
% crea una struttura history con dentro dati "finti", in modo da
% risparmiare spazio

cFth = fieldnames(tTH);
v1 = [0 1]';
for j = 1:length(cFth)
    sFth = cFth{j}; % ex: tTH_1, tTH_2
    cF = fieldnames(tTH.(sFth));
    for i = 1:length(cF)
        sF = cF{i}; % ex: VELVEIC
        tTH.(sFth).(sF).v = v1;
        tTH.(sFth).(sF).v_org = v1;
    end
end

return

function pb_loadCfg_Callback(hObject, eventdata, handles)

% dati utente
UserData = get(gcbf,'UserData');

try
   %
   % caricamento file di configurazione
   [sFileName, sPathName] = uigetfile({'*.etc'; 'file matlab (*.etc)'}, 'file matlab di configurazione');
   if not(ischar(sFileName)) || not(ischar(sPathName))
      return
   else
       sFullFile = fullfile(sPathName, sFileName);
   end
   
   % blocco l'interazione dell'utente con l'interfaccia
   t0 = clock;
   hD = msgbox('loading file...please wait', '', 'modal');
   
   % caricamento
   tFile = load(sFullFile, '-mat');
   %
   % impongo la configurazione ai dati utente correnti
   if isfield(tFile, 'tAx')
       tAx = tFile.tAx;
   else
       tAx = struct();
   end
   cFA = fieldnames(tAx);
   if not(isempty(cFA))
       UserData.tAx  = tAx;
   end
   UserData.tTH = tFile.tTH;
   UserData.tFiles = tFile.tFiles;
   set(handles.pb_draw, 'UserData', tFile.tAssi);
   %
   set(gcbf, 'UserData', UserData);
   %
   % aggiornamento lista unit? di misura disponibili
   cListUM = upgradeUnitsList(UserData.tTH);
   set(handles.pm_filterUM, 'value', 1);
   set(handles.pm_filterUM, 'string', cListUM);
   %
   % aggiornamento della lista grandezze disponibili
   pm_filterUM_Callback(handles.pm_filterUM, [], handles);
   
   %
   % visualizzo lista assi
   nAx = length(tFile.tAssi);
   vOrd = fillAxisOrder(tAx(1));
   visualizzaListaAssi(handles.lb_Ax, nAx, vOrd);
   set(handles.lb_Ax, 'UserData', nAx) 
   %
   % visualizzo le grandezze dell'ultimo asse (convenzionale)
   visualizzaAsse(handles,nAx)
   %
   % riempio le finestre di selezione manovra con i files contenuti nella
   % configurazione caricata
   cFiles = fieldnames(UserData.tFiles);
   for i = 1:length(cFiles)
       % nMan: numero della manovra, se >=2 ? da intendersi per il confronto
       sMan = num2str(i);
       sFig = ['fig_selectSim',sMan];
       sF = cFiles{i};
       % 
       % chiamo la scelta manovra e uso come argomento di ingresso il file
       % della configurazione
       handles.(sFig) = selectSim('callerHandle',gcbf, 'selDepth','inf', 'sFileDef', UserData.tFiles.(sF));
       %
       set(handles.(sFig), 'visible','off')
   end
   % memorizzo handles figure chiamate
   guidata(hObject, handles);
   
   % salvo dati utente correnti
   set(gcbf, 'UserData', UserData);
   
   % ripristino l'interazione utente con l'interfaccia 
   while etime(clock, t0) < 0.5
   end
   delete(hD)
   
   if isfield(tFile, 'xSpaces')
       handles.xSignalTab.Data = tFile.xSpaces; 
   end
   
catch Me
    dispError(Me);
    disp('impossible to retrieve all data needed for loading configuration')
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
    % disable panel of line data settings
    % setPanelEnable(handles.pan_color, 'off');
    % UserData.tAx potrebbe ancora non esistere (ex: non acnora fatto un
    % plot)
    % UserData.tAx.assi(1).Ylimit = [0 25 400]; % [yMin Step yMax]
    if isfield(UserData, 'tAx') % disable panel of line data settings
        visualizzaLimitiAsse(handles, UserData.tAx(1), vNew);
        visualizzaLabelAsse(handles, UserData.tAx(1), vNew);
        visualizzaOrdineAsse(handles, UserData.tAx(1), vNew);
    end
    EnbDisSelez(handles);
catch Me
  dispError(Me)
end
     % abilita/ disabilita obj operazioni se ci sono/non ci sono segnali nell'Asse selezionato MDM
%
% salvo l'indice dell'asse su cui mi sono appena spostato
set(handles.lb_Ax, 'UserData', vNew)
%
% % attivo controlli di scelta grandezze
% attivaEditSelez(handles);

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
   % cancello la visualizzazione grandezze (asse nuovo ? vuoto)
   remAll(handles);
   set(handles.tb_graph ,'enable','on')
   %
   % salvo il contenuto (vuoto) dell'asse appena creato
   memorizzaAsse(handles,vNew)

catch Me
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
%Teoresi (soluzione quando non c'? il campo tAx)
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
   % scalo indicizzazione di ordine assi per compatibilit? con eliminazione
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
   
   %---salvo asse corrente---
   % Teoresi (evito l'utilizzo di (lb_Ax_Callback([], [], handles)) quando viene utilizzato il plot order)
%    str_Ax=getListBoxCell(handles.lb_Ax);
%    L=num2str(length(str_Ax));
%    v=get(handles.lb_Ax, 'value');
%    final_str=str_Ax{v};
%    num=final_str(end);
%    if L==num 
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
      sXquant = grandezzaAsseX(handles.pm_Xaxis);
      UserData.tAx = crea_tAx(handles,tAxOld, tAssi, UserData.tTH, sXquant); %%Teoresi (handles)
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
      sXquant = grandezzaAsseX(handles.pm_Xaxis);
      UserData.tAx = crea_tAx(handles,tAxOld, tAssi, UserData.tTH, sXquant); %%Teoresi (handles)

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
    dispError(Me)
end
return

function sXquant = grandezzaAsseX(h_pm_Xaxis)

% nome grandezza fra quelle comprese in tTH da plottare in X
cX = get(h_pm_Xaxis, 'string');
sX = cX{get(h_pm_Xaxis, 'value')};
switch sX
    case 'time'
        sXquant = 'time';
    case 'custom'
        sXquant = 'custom';
end

return

function sAsse = stringaAsse(i)
%
sAsse = [labelAsse, num2str(i)];
return

function vOrd = getOrderAsse(hLbAx, vSel)

% vSel: selezione dell'utente
% vOrd: ordine associato alla selezione
   
cCont = getListBoxCell(hLbAx);
sCont = cCont{vSel};
L = length(labelAsse);
sOrd = sCont(L+1:end);
vOrd = str2double(sOrd);
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

function tAx = crea_tAx(handles,tAx, tAssi, tTH, sXquant)

% UserData = get(gcbf,'UserData');

cF = fieldnames(tTH);
%
% ciclo su manovre selezionate
% (ex: k=1 acquisizione ECU; k=2 simulazione; k=3 acquisizione rullo)
% tAx(k).assi(i).signals(j)
for k = 1:length(cF)
   tTH_k = tTH.(['tTH_',num2str(k)]);
   [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTH_k);
   %
   % ciclo su assi
   % (ex: 1: asse in alto e 2: asse in basso)
   for i = 1:length(tAssi)
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
      % Teoresi          
        if ischar(sField)
            sField = sField;
        else
            sField = sField{1};
        end
        if any(strcmp(fieldnames(tTH_k), sField))
            % controllo esistenza nella manovra/acquizione del segnale
            % richiesto per quell'asse
            name = sField;
            unit = tTH_k.(sField).u;
            %
            % scelgo la grandezza X da usare nel plot
            if strcmp(sXquant,'time') 
                % plottaggio in base tempo 
                % 
                % recupero del sample time associato alla grandezza corrente 
                bOrgFind = strcmpi(cQorg, sField); % cerco nei sample time originari la grandezza corrente 
                if any(bOrgFind) 
                    % time associato alla grandezza corrente (originaria) 
                    sX = cTorg{bOrgFind}; 
                else 
                    % time associato alla grandezza corrente (interpolata) 
                    sX = 'time'; 
                end 
                bOrgData = []; 
            else
                % plottaggio in altra base  X (ex: spazio) 
                xSpace = handles.xSignalTab.Data; 
                sX = xSpace{k}; 
                bOrgData = []; 
            end 
            
            %Teoresi (cambio vettore time in base al tTH quando ho derivata/integrale)
            
%             str_comp1=strfind(tAssi(i).sigName(j),'derivative');
%             str_comp2=strfind(tAssi(i).sigName(j),'integral');
%             if ~isempty(str_comp1{1})||~isempty(str_comp2{1})
            if isfield(tTH_k.(sField), 'operation')
                sF1 = tTH_k.(sField).sF;
                tTH_k_new=tTH.(sF1);
                [x, value] = applicaOffset(tTH_k_new.(sX), tTH_k.(sField), bOrgData);
            %
            else
                [x, value] = applicaOffset(tTH_k.(sX), tTH_k.(sField), bOrgData);
            end
            color = tTH_k.(sField).color;
            label = tTH_k.(sField).label;
            
         else
            % valori nulli se non lo trovo, non lo graficher?
            name = '';
            value = [];
            unit = '';
            x = [];
            color = [];
            label = '';
         end
         %
         tAx(k).assi(i).signals(j).name = name;
         tAx(k).assi(i).signals(j).v = value;
         tAx(k).assi(i).signals(j).u = unit;
         tAx(k).assi(i).signals(j).t = x;
         tAx(k).assi(i).signals(j).color = color;
         tAx(k).assi(i).signals(j).label = label;
         %
         % import campi stile linea
         src = {'Lstyle', 'Width', 'Mstyle', 'Msize'};
         dft = {'Solid', '1.5', 'none', '15'};
         if isfield(tTH_k,(sField))
             for cc=1:length(src)
                 if isfield(tTH_k.(sField), src{cc})
                     tAx(k).assi(i).signals(j).(src{cc}) = tTH_k.(sField).(src{cc});
                 else
                     tAx(k).assi(i).signals(j).(src{cc}) = dft{cc};
                 end
             end
         end
      end
      
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

function [x, value] = applicaOffset(tTH_k_x, tTH_k_value, varargin) 

% campo per recepimento dati originari
sVorg = 'v_org';
bOrgData = isfield(tTH_k_value, sVorg) && not(isempty(tTH_k_value.(sVorg)));

% eventuale forzamento di utilizzo campi del tempo originari o interpolati
if(not(isempty(varargin)))
    if not(isempty(varargin{1}))
        bOrgData = varargin{1};
    end
end

% definizione campo per valori
if bOrgData
    sV = sVorg;
else
    sV = 'v';
end

value = tTH_k_value.(sV);
% applicazione offset orizzontale
v0x = tTH_k_x.v0;
if isempty(v0x)
   v0x = 0;
end
x = tTH_k_x.(sV) + v0x;

% dati per offset sulla grandezza
t0 = tTH_k_value.t0;
v0 = tTH_k_value.v0;
g0 = tTH_k_value.g0;
lpf0 = tTH_k_value.lpf0;
%
% applicazione guadagno verticale
% (prima scalo la grandezza, ex. rendo coerenti le unit? di misura, poi la
% centro in Y su cosa mi serve)
if isempty(g0)
    g0 = 1;
end
if ~isempty(tTH_k_value.label)
    value = g0 * value;
end
% applicazione dell'offset verticale
if not(isempty(t0)) && not(isempty(v0))
    v0_org = interp1qsat(x, value, t0);
    value = value + v0 - v0_org;
end

% LPF
if not(isempty(lpf0)) && (strcmpi(tTH_k_x.label, 'time') || strcmpi(tTH_k_x.u, 's')) && contains(tTH_k_value.label,'LPF')
    % TODO: could cause problem if filtered in distance
    value = LPfilter(x, value, lpf0, value(1));
end

return

function memorizzaAsse(handles,v)

try
% memorizzo nel pulsante pb_draw la struttura tAssi, che contiene il
% nome delle grandezze dei vari assi da plottare. v ? l'asse a cui ci si sta
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
    
end
return

function visualizzaListaAssi(hlb_Ax, nAssi, vOrd)

%
% aggiorno lista assi
cAx = cell(nAssi,1);

% ordine esterno opzionale
% if isempty(cOrd)
%     cOrd = cell(nAssi,1);
%     for i = 1:nAssi
%         cOrd{i} = i;
%     end
% end
% assegno label ad assi
for i = 1:nAssi
%     if not(isempty(cOrd{i}))
%         v = cOrd{i};
%     else
%         % i valori di cOrd vuoti li metto come default all'asse corrente
%         v = i;
%     end
    cAx{i} = stringaAsse(vOrd(i));
end
set(hlb_Ax, 'string', cAx)
set(hlb_Ax, 'value', nAssi)


return

function visualizzaAsse(handles,v)
try
    % visualizza le grandezze associare all'asse v-esimo dentro alla lb_exp
    %
    tAssi = get(handles.pb_draw, 'UserData');
    L = length(tAssi(v).sigName);
    %
    c = {''};
    for i=1:L
        c(i) = tAssi(v).sigName(i);
    end
    for i=1:L
        if iscell(c{i})
            c(i) = c{i};            
        end
    end
    %
    % asse vuoto (senza grandezze)
    if L==1 && isempty(c{1})
        c{1} = ' ';% le listbox non vogliono stringa nulla
    end
    %
    set(handles.lb_exp ,'value',1)
    set(handles.lb_exp, 'string',c)
catch Me
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
end

function visualizzaOrdineAsse(handles, tAx1, vAxY)

try
    % assi(vNew)potrebbe non esistere (ex: ho appena creato un asse nuovo)
    % visualizzo label di assi X e Y nelle apposite caselle
    set(handles.et_axisOrd, 'string', tAx1.assi(1).order);
    if vAxY<=length(tAx1.assi)
        sOrd = tAx1.assi(vAxY).order;
    else
        % ex: asse nuovo: limite nullo
        sOrd = '';
    end
    set(handles.et_axisOrd, 'string', sOrd);
catch Me
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
    UserData.tAx = crea_tAx(handles,struct(), tAssi, UserData.tTH, 'time'); %%Teoresi (handles)
end
 UserData.tAx(1).assi(1).Xlimit = vLimX; % il limite asse X ? comune per tutti gli assi (scelgo il primo) e per tutti le manovre (scelgo la prima)
 UserData.tAx(1).assi(nAx).Ylimit = vLimY; % il limite asse Y ? comune per tutti le manovre (scelgo la prima)

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
    % il delta non pu? essere nullo
    if vLim(3) == 0
        vLim(3) = NaN;
    end
end

return

function scriviLimitiAsse(handles, sAsse, vLim)

% scrive nei campi che da interfaccia specificano i limiti quanto ?
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% pannello di selezione colori
%

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

% accendo il pusante corrispondente al colore scelto (se c'?)

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
% corrispondenti all'unit? di misura selezionata da questo menu.

% dati utente
UserData = get(gcbf,'UserData');

% filtro le grandezze disponibili in base alle unit? di misura
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
% che soddisfano il filtraggio sulle unit? di misura

sUnit = '(no filter)';
if not(isempty(varargin))
    % filtro sulle unit? di misura
    a = strcmpi(varargin, 'units');
    if not(isempty(a))
        sUnit = varargin{a+1};
    end
    %
end

% unit? di misura vuote
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
   % TODO: pu? causare problemi? Ex: per concatenazione??
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

function c = upgradeUnitsList(tTH) 

% fornisce tutte le unit? di misura disponibili fra i vari files letti

% elenco unit? disponibili
c = {''};
cF = fieldnames(tTH);
for i = 1:length(cF)
    %
    [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTH.(cF{i}));
    cQ = union(cQint, cQorg);
    %
    cFU = unitsList(tTH.(cF{i}), cQ);
    c = union(c, cFU);
end
%
% aggiorno la lista
c = c(not(strcmpi(c, '')));
c = c(not(strcmpi(c, ' ')));
cDef = {'(no filter)'; '(empty)'};
c = [cDef; c];

return

function c = unitsList(tTH, cQ)
% lista delle unit? di misura associate ad una certa TH in corrispondenza
% delle grandezze cQ

c = cell(size(cQ));
for i = 1:length(cQ)
    c{i} = tTH.(cQ{i}).u; 
end

return

% Teoresi(popupmenu per le operazioni matematica tra pi? canali )
function popupmenu_operazioni_Callback(hObject, eventdata, handles)
     popup_sel_index = get(hObject, 'Value');
     if popup_sel_index > 1
        set(handles.uipanel14, 'Visible','on');
        set(handles.listbox_operations,'Visible','on');
        set(handles.teo_der,'value',0);
        set(handles.teo_int,'value',0);    
    %     set(handles.et_LPF, 'enable', 'off');
    %     set(handles.et_vertGain, 'enable', 'off');

        if isfield(handles, 'edit_name1')
            if not(isempty(handles.edit_name1'))
                set(handles.edit_new_channel, 'String', handles.edit_name1);
                return
            end
        end
        set(handles.edit_new_channel, 'String', '');
     else
        set(handles.et_LPF, 'enable', 'on');
        set(handles.et_vertGain, 'enable', 'on');
     end

 
 % Teoresi(checkbox per le effettuare la derivata di un canale )
function teo_der_Callback(hObject, eventdata, handles)
   
check_der=get(hObject,'value');
if check_der==1
    set(handles.uipanel14, 'Visible','on');
    set(handles.listbox_operations,'Visible','on');    
%     v = get(handles.lb_Ax, 'value'); 
%     memorizzaAsse(handles,v);
%     cContAx = getListBoxCell(handles.lb_Ax);
%     L = length(cContAx);
%     cContAx{L+1} = stringaAsse(L+1);
%     set(handles.lb_Ax, 'string',cContAx)
%     vNew = length(cContAx);
%     set(handles.lb_Ax, 'value', vNew)
%     set(handles.lb_Ax, 'UserData', get(handles.lb_Ax, 'value'))
     cCont = get(handles.lb_exp, 'string');
    sQuant = cCont{get(handles.lb_exp, 'value')};
    val = get(handles.lb_man, 'value');
    stringa = get(handles.lb_man, 'string');
    nMan = stringa{val};
    sQuant = {['derivative_' sQuant '_' nMan]};
%     set(handles.lb_exp,'value',1);
    set(handles.edit_new_channel,'string',sQuant);
    set(handles.popupmenu_operazioni,'value',1);  
    set(handles.teo_int,'value',0);
%     set(handles.et_LPF, 'enable', 'off');
%     set(handles.et_vertGain, 'enable', 'off');
else
%     set(handles.et_LPF, 'enable', 'on');
%     set(handles.et_vertGain, 'enable', 'on');
    set(handles.edit_new_channel,'string', '');
end

% Teoresi(checkbox per le effettuare la derivata di un canale )
function teo_int_Callback(hObject, eventdata, handles)

check_int=get(hObject, 'value');
if check_int==1    
    set(handles.uipanel14, 'Visible','on');
    set(handles.listbox_operations,'Visible','on');    
%     v = get(handles.lb_Ax, 'value'); 
%     memorizzaAsse(handles,v);
%     cContAx = getListBoxCell(handles.lb_Ax);
%     L = length(cContAx);
%     cContAx{L+1} = stringaAsse(L+1);
%     set(handles.lb_Ax, 'string',cContAx)
%     vNew = length(cContAx);
%     set(handles.lb_Ax, 'value', vNew)
%     set(handles.lb_Ax, 'UserData', get(handles.lb_Ax, 'value'))
    cCont = get(handles.lb_exp, 'string');
    sQuant = cCont{get(handles.lb_exp, 'value')};
    val = get(handles.lb_man, 'value');
    stringa = get(handles.lb_man, 'string');
    nMan = stringa{val};
    sQuant = {['Integral_' sQuant '_' nMan]};
%     set(handles.lb_exp,'value',1);
    set(handles.edit_new_channel,'string',sQuant)
    set(handles.popupmenu_operazioni,'value',1)
    set(handles.teo_der,'value',0);
%     set(handles.et_LPF, 'enable', 'off');
%     set(handles.et_vertGain, 'enable', 'off');
else
    set(handles.et_LPF, 'enable', 'on');
    set(handles.et_vertGain, 'enable', 'on');
    set(handles.edit_new_channel,'string', '');
end

%Teoresi (creo nell'edit text name_channel il nome del canale con il relativo guadagno) Es: Gain_v_veh_10
function et_vertGain_Callback(hObject, eventdata, handles)
set(handles.popupmenu_operazioni,'value',1);
set(handles.teo_der,'value',0);
set(handles.teo_int,'value',0);
teo_gain=get (hObject,'string');
cCont = get(handles.lb_exp, 'string');
sQuant = cCont{get(handles.lb_exp, 'value')};
edit_lpf = get(handles.et_LPF, 'String');
if isempty(edit_lpf)
    teo_gain1=['Gain_' sQuant '_' teo_gain];
else
    teo_gain1=['Gain_' 'LPF_' sQuant '_' teo_gain '_' edit_lpf];
end
set(handles.edit_new_channel,'string',teo_gain1);


%Teoresi (creo nell'edit text Edit Name Channel' il nome del canale con il relativo filtro) Es: LPF_v_veh_10
function et_LPF_Callback(hObject, eventdata, handles)
set(handles.popupmenu_operazioni,'value',1);
set(handles.teo_der,'value',0);
set(handles.teo_int,'value',0);
teo_LPF=get (hObject,'string');
cCont = get(handles.lb_exp, 'string');
sQuant = cCont{get(handles.lb_exp, 'value')};
edit_gain = get(handles.et_vertGain, 'String');
if isempty(edit_gain)
    teo_LPF1=['LPF_' sQuant '_' teo_LPF];
else
    teo_LPF1=['Gain_' 'LPF_' sQuant '_' edit_gain '_' teo_LPF];
end
set(handles.edit_new_channel,'string',teo_LPF1);

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
%   if bEmpty
%       % disattivo edit delle grandezze selezionate
%       disattivaEditSelez(handles)
%   end

  
  %Teoresi (effettuo l'operazioni fra canali, inserendola in Operation List e salvandola nella lista canali)
function save_operation_Callback(hObject, eventdata, handles)

% Creo nuovo asse
    v = get(handles.lb_Ax, 'value'); 
    memorizzaAsse(handles,v);
    cContAx = getListBoxCell(handles.lb_Ax);
    L = length(cContAx);
    cContAx{L+1} = stringaAsse(L+1);
    set(handles.lb_Ax, 'string',cContAx)
    vNew = length(cContAx);
    set(handles.lb_Ax, 'value', vNew)
    set(handles.lb_Ax, 'UserData', get(handles.lb_Ax, 'value'))   
%    
UD = get(gcbf, 'UserData');
string_listbox=get(handles.listbox_operations,'string');
popup_sel_index = get(handles.popupmenu_operazioni, 'Value');
check_der=get(handles.teo_der, 'value');
check_int=get(handles.teo_int, 'value');
% time=UD.tTH.(sF).time.v;
% step_size=UD.tTH.(sF).time.v(2);
if check_der==1
    for i=1:length(string_listbox)
    string_listbox1=string_listbox{i};
%     new_channel=['derivative_' string_listbox1];
    new_channel = handles.edit_name{i};
    name_channel1=string_listbox1(1:end-2);
    cF = fieldnames(UD.tTH); 
    sF = cF{str2num(string_listbox1(end))};
    step_size=UD.tTH.(sF).time.v(2);
        UD.tTH.tTH_1.(new_channel)=UD.tTH.(sF).(name_channel1); 
        UD.tTH.tTH_1.(new_channel).v=diff(UD.tTH.(sF).(name_channel1).v./step_size);
        m_unit=UD.tTH.(sF).(name_channel1).u;
        switch m_unit
            case 'km/h'
                UD.tTH.tTH_1.(new_channel).v=UD.tTH.tTH_1.(new_channel).v./3.6;
                UD.tTH.tTH_1.(new_channel).u='m/s^2';
            case 'kWh'
                UD.tTH.tTH_1.(new_channel).v=UD.tTH.tTH_1.(new_channel).v.*3600;
                UD.tTH.tTH_1.(new_channel).u='kW';   
            case 'J'
                UD.tTH.tTH_1.(new_channel).u='W';   
            case 'kJ'
                UD.tTH.tTH_1.(new_channel).u='kW';                    
            otherwise
                UD.tTH.tTH_1.(new_channel).u=[UD.tTH.(sF).(name_channel1).u '/s'];
        end
%         new_lb_exp{i}=new_channel;
%         set(handles.lb_exp,'value',1);
%         set(handles.lb_exp,'string',new_lb_exp);
        UD.tTH.tTH_1.(new_channel).label=new_channel;
        UD.tTH.tTH_1.(new_channel).operation = 'derivative';
        UD.tTH.tTH_1.(new_channel).sF = sF;
        list_channels=get(handles.lb_avail,'string');
        list_channels{end+1}=new_channel;
        set(handles.lb_avail,'string',list_channels);
        UD_lb_avail=get(handles.lb_avail,'UserData');
        UD_lb_avail{end+1}=new_channel;
        set(handles.lb_avail,'UserData',UD_lb_avail);       
    end  
    set(handles.lb_exp,'value',1);
    set(handles.lb_exp,'string', handles.edit_name);
    
elseif check_int==1
    for i=1:length(string_listbox)
    string_listbox1=string_listbox{i};
%     new_channel=['integral_'  string_listbox1];
    new_channel = handles.edit_name{i};
    name_channel1=string_listbox1(1:end-2);
    cF = fieldnames(UD.tTH); 
    sF = cF{str2num(string_listbox1(end))};  
    time=UD.tTH.(sF).time.v;
        UD.tTH.tTH_1.(new_channel)=UD.tTH.(sF).(name_channel1); 
        UD.tTH.tTH_1.(new_channel).v=cumtrapz(time,UD.tTH.(sF).(name_channel1).v);
        m_unit=UD.tTH.(sF).(name_channel1).u;
        switch m_unit
            case 'km/h'
                UD.tTH.tTH_1.(new_channel).v=UD.tTH.tTH_1.(new_channel).v./3.6;
                UD.tTH.tTH_1.(new_channel).u='m';
            case 'kg/h'
                UD.tTH.tTH_1.(new_channel).v=UD.tTH.tTH_1.(new_channel).v./3600;
                UD.tTH.tTH_1.(new_channel).u='kg';
            case 'm^3/h'
                UD.tTH.tTH_1.(new_channel).v=UD.tTH.tTH_1.(new_channel).v./3600;
                UD.tTH.tTH_1.(new_channel).u='m^3';
            case 'l/h'
                UD.tTH.tTH_1.(new_channel).v=UD.tTH.tTH_1.(new_channel).v./3600;
                UD.tTH.tTH_1.(new_channel).u='l';
            case 'l/s'
                UD.tTH.tTH_1.(new_channel).u='l';                
            case 'W'
                UD.tTH.tTH_1.(new_channel).u='J';
            case 'kW'
                UD.tTH.tTH_1.(new_channel).u='kJ';
            case 'Kg/s'
                UD.tTH.tTH_1.(new_channel).u='kg';
            case 'g/s'
                UD.tTH.tTH_1.(new_channel).u='g';                
            case 'm/s^2'
                UD.tTH.tTH_1.(new_channel).u='m/s';
            otherwise
                UD.tTH.tTH_1.(new_channel).u=[UD.tTH.(sF).(name_channel1).u '*s'];
        end
%         new_lb_exp{i}=new_channel;
%         set(handles.lb_exp,'value',1);
%         set(handles.lb_exp,'string',new_lb_exp);
        UD.tTH.tTH_1.(new_channel).label=new_channel;
        UD.tTH.tTH_1.(new_channel).operation = 'integral';
        UD.tTH.tTH_1.(new_channel).sF = sF;
        list_channels=get(handles.lb_avail,'string');
        list_channels{end+1}=new_channel;
        set(handles.lb_avail,'string',list_channels);
        UD_lb_avail=get(handles.lb_avail,'UserData');
        UD_lb_avail{end+1}=new_channel;
        set(handles.lb_avail,'UserData',UD_lb_avail);     
    end 
    set(handles.lb_exp,'value',1);
    set(handles.lb_exp,'string', handles.edit_name);
    
elseif popup_sel_index >1
 switch popup_sel_index 
    case 2
    new_string1='SUM_';
    case 3
    new_string1='DIFF_';
    case 4
    new_string1='MULT_';
    case 5
    new_string1='DIV_';
 end
 UM = {};
 for i=1:length(string_listbox)
     string_listbox1=string_listbox{i};
     channel=string_listbox1(end);
     channel1=['tTH_' channel];
     string_del=['_' channel];
     
     str_comp=strfind(string_listbox1,string_del);
     if length (str_comp)==1
     new_channel=erase(string_listbox1,string_del);
     else 
         new_channel=string_listbox1(1:end-2);
     end
     value=UD.tTH.(channel1).(new_channel).v;
     matrix_value(:,i) = value;     
     new_string=[new_string1 string_listbox{i} '_'];
     new_string1=new_string;
     UM{i} = UD.tTH.(channel1).(new_channel).u;
 end
new_string(end)=''; 

if not(isempty(handles.edit_new_channel.String))
    new_string = handles.edit_new_channel.String;
    handles.edit_new_channel.String = '';
    guidata(hObject, handles)
end

A=matrix_value';

 val = get(handles.lb_man, 'value');
 stringa = get(handles.lb_man, 'string');
 nMan = str2num(stringa{val});
 cF = fieldnames(UD.tTH); 
 sF = cF{nMan};      
UD.tTH.tTH_1.(new_string)=UD.tTH.(sF).(new_channel);
 switch popup_sel_index 
    case 2
    S=sum(A);
    S1=S';
    UD.tTH.tTH_1.(new_string).v=S1;
    case 3
    D=diff(A);
    D1=D';
    UD.tTH.tTH_1.(new_string).v=D1;
    case 4
    P=prod(A);
    P1=P';
    UD.tTH.tTH_1.(new_string).v=P1;
    u = ['(' UM{1} ')'];
    for i=2:length(UM)
        u1 = UM{i};
        u = [u '*' '(' u1 ')'];
    end
    UD.tTH.tTH_1.(new_string).u = u;
    case 5
    A1=A(1,:);
    A2=A(2,:);
    UD.tTH.tTH_1.(new_string).v=A1./A2;
    if length(UM)==2 && strcmp(UM{1}, UM{2})
        UD.tTH.tTH_1.(new_string).u = '-';
    else
        u = ['(' UM{1} ')'];
        for i=2:length(UM)
            u1 = UM{i};
            u = [u '/' '(' u1 ')'];
        end
        UD.tTH.tTH_1.(new_string).u = u;  
    end         
  end
UD.tTH.tTH_1.(new_string).label=new_string;
set(handles.lb_exp,'value',1);
set(handles.lb_exp,'string',new_string);
list_channels=get(handles.lb_avail,'string');
list_channels{end+1}=new_string;
set(handles.lb_avail,'string',list_channels);
UD_lb_avail=get(handles.lb_avail,'UserData');
UD_lb_avail{end+1}=new_string;
set(handles.lb_avail,'UserData',UD_lb_avail);
else
    msgbox('Select operation to be performed','Error','error'); 
end

set(gcbf, 'UserData', UD);  

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
        cQuant = handles.edit_name; % ? sempre una cella
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
%    if bEmpty
%       % disattivo edit delle grandezze selezionate
%       disattivaEditSelez(handles)
%    end


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


% --- Executes on selection change in listbox_operations.
function listbox_operations_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_operations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_operations contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_operations


% --- Executes during object creation, after setting all properties.
function pb_offsetOk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pb_offsetOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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
    % hObject    handle to xSignalTab (see GCBO) 
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE) 
    % Indices: row and column indices of the cell(s) currently selecteds 
    % handles    structure with handles and user data (see GUIDATA) 
    if ~(isempty(eventdata.Indices)) 
        handles.xSignalTab.UserData = eventdata.Indices(1); 
%         assignin('base', 'handles', handles); 
    end 

function dispError(Me)
    mex = getReport(Me, 'extended','hyperlinks','off');
    uiwait(msgbox({['ID: ' Me.identifier]; ['Message: ' Me.message]; mex}, 'Error','Error','modal'))
    mex = getReport(Me)
return 


% --- Executes on button press in DebugBtt.
function DebugBtt_Callback(hObject, eventdata, handles)
% hObject    handle to DebugBtt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('sono qua')
UD = get(gcbf, 'UserData');
assignin('base', 'UserData', UD);
assignin('base', 'handles', handles);
disp('ho finito')

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
        set([handles.lb_man, handles.pb_rem, handles.pb_exp,...
             handles.pb_exp, handles.lb_exp],...
            'enable', value)
         % setPanelEnable(handles.pan_color, value);
    catch Me
        dispError(Me)
    end
return 

function defineLineStyle(handles, UD, sF, sQuant)
    % set line style function
    try 
        % ricerco le informazioni
        color = leggiColoreLinea(handles);
        label = get(handles.et_labLine, 'string');
        styles = get(handles.DashType,  'String');
        marker = get(handles.MarkerType, 'String');

        styleSelected  = styles(get(handles.DashType, 'Value'));
        MstyleSelected = marker(get(handles.MarkerType, 'Value'));
        widths = get(handles.LineWidth, 'String');
        Msize  = get(handles.MarkerSize, 'String');

        % salvo le informazioni nel tTH
        UD.tTH.(sF).(sQuant).color  = color;
        UD.tTH.(sF).(sQuant).label  = label;
        UD.tTH.(sF).(sQuant).Lstyle = styleSelected;
        UD.tTH.(sF).(sQuant).Mstyle = MstyleSelected;
        UD.tTH.(sF).(sQuant).Width  = widths;
        UD.tTH.(sF).(sQuant).Msize  = Msize;
        
        set(gcbf, 'UserData', UD);
    catch Me
        dispError(Me)
    end
return

function refreshLinestyle(handles, tTHk, sQuant)
    try
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
              et_Msize = '15';
          end 
          set(handles.DashType,   'Value', et_Style);
          set(handles.MarkerType, 'Value', et_Mstyle);
          set(handles.LineWidth,  'String', et_Width);
          set(handles.MarkerSize, 'String', et_Msize);
          
          % aggiorno campi del colore
          if (isfield(tTHk.(sQuant),'color'))
            color = tTHk.(sQuant).color;
            scriviColoreLinea(handles, color) 
          end
    catch Me
        dispError(Me)
    end

% --- Executes during object creation, after setting all properties.
function MarkerType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function MarkerSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkerSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function LineWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
