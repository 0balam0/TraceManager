function varargout = selectSim_v2(varargin)
% SELECTSIM_V2 M-file for selectSim_v2.fig
%      SELECTSIM_V2, by itself, creates a new SELECTSIM_V2 or raises the existing
%      singleton*.
%
%      H = SELECTSIM_V2 returns the handle to a new SELECTSIM_V2 or the handle to
%      the existing singleton*.
%
%      SELECTSIM_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTSIM_V2.M with the given input arguments.
%
%      SELECTSIM_V2('Property','Value',...) creates a new SELECTSIM_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectSim_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectSim_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectSim_v2

% Last Modified by GUIDE v2.5 31-Oct-2022 15:38:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
   'gui_Singleton',  gui_Singleton, ...
   'gui_OpeningFcn', @selectSim_v2_OpeningFcn, ...
   'gui_OutputFcn',  @selectSim_v2_OutputFcn, ...
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

function selectSim_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for selectSim_v2
handles.output = hObject;

%%% seleziono la profondità della scelta che l'utente deve compiere
% selDepth: 'dir', 'lnc', 'appl', 'man', 'opt', 'par1', 'par2', 'par3',..., 'inf'
selDepth = 'inf';
sFileIn = '';
sDirIn = '';
bDefFile = false;
if not(isempty(varargin))
   a = strcmp(varargin, 'selDepth');
   if any(a)
      selDepth = varargin{find(strcmp(varargin, 'selDepth'))+1};
   end
   % se specifico dall'esterno una directory di default a cui accedere
   % (Guenna, 29/06/2015)
   a = strcmp(varargin, 'sDefDir');
   if any(a)
      bDefFile = false;
      sDirIn = varargin{find(strcmp(varargin, 'sDefDir'))+1};
      if strcmpi(sDirIn(end),'\')
          sDirIn = sDirIn(1:end-1);
      end
   end
   % fine dell'aggiunta di Guenna
   % se specifico dall'esterno un file di default a cui accedere
   a = strcmp(varargin, 'sFileDef');
   if any(a)
      bDefFile = true;
      sFullFileIn = varargin{find(strcmp(varargin, 'sFileDef'))+1};
      [sDirIn, sFileIn, sExt] = fileparts(sFullFileIn);
      sFileIn = [sFileIn sExt];
   end
end
UD.bDefFile = bDefFile;
UD.selDepth = selDepth;
UD.sFileIn = sFileIn;
UD.sDirIn = sDirIn;
set(handles.fig_selectSim, 'UserData',UD);

% riempio la casella di scelta dir
if not(isempty(sDirIn))
% if not(isempty(sDirIn)) && not(isempty(sFileIn))
    pb_foldIn_Callback([], [], handles)
    % dati utente
    UD.THtype = 2;
end
% riempio la casella di scelta file
if not(isempty(sFileIn))
    pm_fileIn_Callback(handles.pm_fileIn, [], handles)
%     % dati utente
%     UD = get(gcbf,'UserData');
end


%%% memorizzo l'handle dell'applicazione chiamante
hCaller = [];
if not(isempty(varargin))
   a = strcmp(varargin, 'callerHandle');
   if any(a)
      hCaller = varargin{find(strcmp(varargin, 'callerHandle'))+1};
   end
end
handles.hCaller = hCaller;
% flag di annullamento interfaccia
handles.bCancel = false;
% flag di chiusura interfaccia
handles.bClose = false;
% struttura di dati in uscita
handles.tData = [];

% Update handles structure
guidata(hObject, handles);

if not(bDefFile)
    % nascondo gli oggetti che non verranno richiesti dalla selezione
    settaVisible(handles,selDepth);

    % setto la grafica dell'interfaccia
    settaInterfaccia(handles,'');
else
    set(handles.pb_avantiSim, 'enable', 'off')
end
set(handles.copyPrp, 'Enable', 'on');
return

function varargout = selectSim_v2_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
%
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% if handles.bCancel % se premo annulla
%    varargout{2} = [];
% else % se ho premuto "avanti..."
%    varargout{2} = get(handles.pb_avantiSim, 'UserData');
% end
%
% if handles.bClose
%     delete(handles.fig_selectSim)
% end
return

%%%%%%%% pannello di selezione simulazione %%%%%%%%

function et_foldIn_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to et_foldIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% set(hObject, 'enable','inactive');
set(hObject, 'string',cd);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end
return

function et_foldIn_Callback(hObject, eventdata, handles)
%
sDirIn = get(hObject,'string');
if isdir(sDirIn)
   %
   caricaDirDati(handles,sDirIn);
   % dovrei uscire dalla casella x far comprendere che ha funzionato; come
   % faccio??
else
   hMsg = msgbox({'Warning:',' not existing directory'},'','error','modal');
   uiwait(hMsg);
end
return

function pb_foldIn_Callback(hObject, eventdata, handles)
% finestra di scelta directory
UserData = get(handles.fig_selectSim,'UserData');
if isfield(UserData,'sDirIn') && isdir(UserData.sDirIn)
   sStartDir = UserData.sDirIn;
else
   sStartDir = cd;
end
if not(UserData.bDefFile)
    sDirIn = uigetdir(sStartDir, 'select dir...');
else
    % ho specificato dalla chiamata di questa GUI un file da caricare
    sDirIn = sStartDir;
end
%
if ischar(sDirIn) && isdir(sDirIn)
   %
   caricaDirDati(handles,sDirIn)
end
return

function pm_fileIn_Callback(hObject, eventdata, handles)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'iAppl', 'tResults', 'sMan', 'iMan', 'sOpt', 'iOpt', 'sPar1', 'iPar1', 'sPar2', 'iPar2', 'sPar3' ,'iPar3'}));


%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
% carico il lancio scelto dall'utente
cCont = get(hObject, 'string');
if not(UserData.bDefFile)
    %lancio scelto dall'utente
    val = get(hObject, 'value');
else
    % ho specificato dalla chiamata di questa GUI un file da caricare
    val = find(strcmpi(cCont, UserData.sFileIn));
    if isempty(val)
        % il file richiesto non esiste (più)
        return
    end
    set(hObject, 'value',val)
end
sFileIn = cCont{val};
tLoad = load([UserData.sDirIn,'\',sFileIn]);

%
% memorizzo il lancio scelto nella figura
UserData.sFileIn = sFileIn;

if isfield(tLoad, 'tResults')
   % simulazione Perfects
   THtype = 1;
   %
   % scrivo indici applicazioni nulle in lb_appl
   L = length(tLoad.tResults.Applicazioni);
   set(handles.lb_appl, 'value',1);
   set(handles.lb_appl, 'string',{1:L});
   %
   UserData.tResults = tLoad.tResults;
   UserData.selDepth = 'inf';
   
elseif isfield(tLoad, 'tTH')
   % time-history singola, come da conversione acquisizione
   THtype = 2;
   %
   UserData.tTH = tLoad.tTH;
   UserData.selDepth = 'lnc';
   
else
   % caso non gestito
   THtype = 0;
   hMsg = msgbox({'Warning:','selected MAT file has unsupported format',''},'','error','modal');
   uiwait(hMsg);
   return
end
% salvo qua perchè mi serve per l'interfaccia
UserData.THtype = THtype;
set(handles.fig_selectSim, 'UserData',UserData);

% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));

% salvataggio

UserData.THtype = THtype;
set(handles.fig_selectSim, 'UserData',UserData);
return

function lb_appl_Callback(hObject, eventdata, handles)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'iAppl', 'sMan', 'iMan', 'sOpt', 'iOpt', 'sPar1', 'iPar1', 'sPar2', 'iPar2', 'sPar3' ,'iPar3'}));


%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
% memorizzo l'applicazione scelta nella figura
iAppl = get(handles.lb_appl, 'value');
UserData.iAppl = iAppl;
set(handles.fig_selectSim, 'UserData',UserData);
%
%---scrivo elenco manovre non nulle in pm_man---
cNamesSim = fieldnames(UserData.tResults.Simulazioni);
cNamesSim1 = {};
a = 0;
for i=1:length(cNamesSim)
   % prendo solo manovre con TimeHistory (anche se fallite)
   if  isfield(UserData.tResults.Simulazioni(iAppl).(cNamesSim{i})(1,1,1,1,1,1), 'History')...
         && not(isempty(UserData.tResults.Simulazioni(iAppl).(cNamesSim{i})(1,1,1,1,1,1).History))
      a = a+1;
      cNamesSim1{a} = cNamesSim{i};
   end
end
%
cNamesSim1 = cNamesSim1(:);
if isempty(cNamesSim1)
   cNamesSim1 = {' '};
end
set(handles.pm_man, 'value',1)
set(handles.pm_man, 'string',cNamesSim1)
%
%---scrivo descrizione applicazione corrente in et_descrSim---
cDescrSim{1} = '';
cDescrSim{2} = ['--- Vehicle n° ', num2str(iAppl),' ---'];
cDescrSim{3} = '';
l = length(cDescrSim);
a = 1;
% genero nomi di cDescrSim in auto da nomi files dell'applicazione
cFields = fieldnames(UserData.tResults.Applicazioni(iAppl).Files);
for i=1:length(cFields)
   [path,name] = fileparts(UserData.tResults.Applicazioni(iAppl).Files.(cFields{i}));
   cDescrSim{l+a} = [cFields{i}, ':    ',name];
   a = a+1;
   cDescrSim{l+a} = ' ';
   a = a+1;
end
cDescrSim{end+1} = ' ';
cDescrSim = cDescrSim(:);
set(handles.et_descrSim, 'string',cDescrSim);

return

function pm_man_Callback(hObject, eventdata, handles)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'sMan', 'iMan', 'sOpt', 'iOpt', 'sPar1', 'iPar1', 'sPar2', 'iPar2', 'sPar3' ,'iPar3'}));


%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
% prelevo la manovra scelta dall'utente
cCont = get(handles.pm_man, 'string');
iMan = get(handles.pm_man, 'value');
sMan = cCont{iMan};
%
% memorizzo la manovra scelta nella figura
UserData.sMan = sMan;
UserData.iMan = iMan;
set(handles.fig_selectSim, 'UserData',UserData);
%
%---scrivo elenco opzioni manovra in pm_opt---
L = length(UserData.tResults.Simulazioni(UserData.iAppl).(sMan));
for i=1:L
   cOpt{i} = [' ', num2str(i),' : ', UserData.tResults.Simulazioni(UserData.iAppl).(sMan)(i).Opzione];
end
set(handles.pm_opt, 'value',1)
set(handles.pm_opt, 'string',cOpt)
return

function pm_opt_Callback(hObject, eventdata, handles)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'sOpt', 'iOpt', 'sPar1', 'iPar1', 'sPar2', 'iPar2', 'sPar3' ,'iPar3'}));

%
% prelevo l'opzione dall'utente
iOpt = get(handles.pm_opt, 'value');
sOpt = UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(iOpt).Opzione; % esempio: " base"
%
% memorizzo la manovra scelta nella figura
UserData.sOpt = sOpt;
UserData.iOpt = iOpt;
set(handles.fig_selectSim, 'UserData',UserData);
%
%---scrivo il contenuto di pm_par1---
cPar1 = {};
tManovra = UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt);
intPar = dimEff(tManovra.History);
switch intPar
   % manovre a esecuzione singola
   case 0
      cPar1 = {' '};
      
      
   case 1
       %%% manovre a esecuzione multipla a 1 parametro
       L = length(tManovra.Points);
       cPar1 = cell(L,1);
       if any(strcmp(UserData.sMan, {'Elasticity'}))

           for i=1:L
               cPar1{i} = [num2str(tManovra.Points(i).GearIni), ' gear at ',...
                   num2str(arrotonda(tManovra.Points(i).SpeedI,1)), ' km/h'];
           end

       elseif any(strcmp(UserData.sMan,{'Overtaking','F2D'}))
           for i=1:L
               cPar1{i} = [num2str(tManovra.Points(i).GearIni), ' gear at ',...
                   num2str(arrotonda(tManovra.Points(i).VStart,1)), ' km/h'];
           end

       elseif strcmp(UserData.sMan,'Acceleration')
           for i=1:L
               cPar1{i} = [num2str(tManovra.Parametri.Pedal(i)), ' pedale ',...
                   num2str(arrotonda(tManovra.Parametri.RpmGearSh(i),1)), ' rpm'];
           end

       elseif strcmp(UserData.sMan,'FConsSteady')
           for i=1:L
               cPar1{i} = [num2str(tManovra.Parametri.Gear(i)), ' gear at ',...
                   num2str(arrotonda(tManovra.Parametri.Speed(i),1)), ' km/h'];
           end

       elseif strcmp(UserData.sMan,'LaunchQS')
           if strfind(lower(UserData.sOpt), '7t4097')
               for i=1:L
                   cPar1{i} = [num2str(tManovra.Points(i).Grade), ' % grade'];
               end
           end
       else
           for i=1:L
               cPar1{i} = [num2str(i)];
           end
       end
      
   case 2
      %%% manovre a esecuzione multipla a 2 parametri
      [r,c] = size(tManovra.Points);
      cPar1 = cell(r,1);
      for i = 1:r
          cPar1{i} = num2str(i);
      end

      % manovre a esecuzione multipla a 3 parametri --> TODO
   case 3
end
% nel caso la manovra non sia riconosciuta, scrivo il campo parametri in
% automatico
if isempty(cPar1)
   % cerco i campi di parametri candidati per la descrizione del parametro:
   % sono quelli che contengono uno scalare (0-D)
   cParField = fieldnames(tManovra.Parametri);
   b1 = false(size(cParField));
   sP = size(tManovra.Points);
   for i = 1:length(cParField)
      if dimEff(tManovra.Parametri(1).(cParField{i})) == 0
         b1(i) = true;
      end
   end
   % tra i diversi campi candidati per la descrizione del parametro, prendo
   % il primo; TODO: migliorare
   a = find(b1);
   if length(a)>1
      a = a(1);
   end
   % nome in auto
   if sP(1) > 1
      for i = 1:max(sP)
         cPar1{i} = [cParField{a}, ': ', num2str(tManovra.Parametri(i,1).(cParField{a}))];
      end
   elseif sP(2) > 1
      for i = 1:max(sP)
         cPar1{i} = [cParField{a}, ': ', num2str(tManovra.Parametri(1,i).(cParField{a}))];
      end
   end
   
end

set(handles.pm_par1, 'value',1);
set(handles.pm_par1, 'string',cPar1);
%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
%---scrivo descrizione opzione corrente in et_descrSim---
cDescrSim{1} = '';
cDescrSim{2} = ['--- Option n° ', num2str(iOpt),' ---'];
cDescrSim{3} = '';
l = length(cDescrSim);
a = 1;
% genero nomi di cDescrSim in auto da contenuto dei campi di "Parametri"
tPar = UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).Parametri;
if ischar(tPar)
   tPar.('NessunParametroEsterno') = 0;
end
cFields = fieldnames(tPar);
for i=1:length(cFields)
   sP = tPar.(cFields{i});
   if iscell(sP)
      sP = sP{1};
   end
   if isnumeric(sP) || islogical(sP)
      sP = num2str(sP(:)');
   end
   cDescrSim{l+a} = [cFields{i}, ':    ',sP];
   a = a+1;
   cDescrSim{l+a} = ' ';
   a = a+1;
end
cDescrSim{end+1} = ' ';
cDescrSim = cDescrSim(:);
set(handles.et_descrSim, 'string',cDescrSim);

return

function pm_par1_Callback(hObject, eventdata, handles)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'sPar1', 'iPar1', 'sPar2', 'iPar2', 'sPar3' ,'iPar3'}));

%
% prelevo il parametro scelto dall'utente
cPar1 = get(handles.pm_par1, 'string');
iPar1 = get(handles.pm_par1, 'value');
sPar1 = cPar1{iPar1};
%
% memorizzo la manovra scelta nella figura
UserData.sPar1 = sPar1;
UserData.iPar1 = iPar1;
set(handles.fig_selectSim, 'UserData',UserData);
%
%---scrivo il contenuto di pm_par2---
intPar = dimEff(UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).History);
switch intPar
    case {0,1}
        % manovre a esecuzione singola e a esecuzione multipla a 1 parametro
        cPar2 = {' '};

    case 2
        % manovre a esecuzione multipla a 2 parametri
        tManovra = UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt);
        [r,c] = size(tManovra.Points);
        cPar2 = cell(c,1);
        for i=1:c
            cPar2{i} =  [num2str(1)];
        end

    case 3
end
set(handles.pm_par2, 'value',1);
set(handles.pm_par2, 'string',cPar2);
%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%

return

function pm_par2_Callback(hObject, eventdata, handles)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'sPar2', 'iPar2', 'sPar3' ,'iPar3'}));

%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
% prelevo il parametro scelto dall'utente
cPar2 = get(handles.pm_par2, 'string');
iPar2 = get(handles.pm_par2, 'value');
sPar2 = cPar2{iPar2};
%
% memorizzo la manovra scelta nella figura
UserData.sPar2 = sPar2;
UserData.iPar2 = iPar2;
set(handles.fig_selectSim, 'UserData',UserData);
%
%---scrivo il contenuto di pm_par3---
intPar = dimEff(UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).History);
switch intPar
   % manovre a esecuzione singola e a esecuzione multipla a 1 e 2 parametri
   case {0,1,2}
      cPar3 = {' '};
      % manovre a esecuzione multipla a 3 parametri --> TODO
   case 3
end
set(handles.pm_par3, 'value',1);
set(handles.pm_par3, 'string',cPar3);
%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%

return

function pm_par3_Callback(hObject, eventdata, handles)
% funzione definita nella struttura ma non funzionante

% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');
% cancello campi di userData che in questa parte non possono ancora esistere
cF = fieldnames(UserData);
UserData = rmfield(UserData, intersect(cF, {'sPar3' ,'iPar3'}));


%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
% prelevo il parametro scelto dall'utente
cPar3 = get(handles.pm_par3, 'string');
iPar3 = get(handles.pm_par3, 'value');
sPar3 = cPar3{iPar3};
%
% memorizzo la manovra scelta nella figura
UserData.sPar3 = sPar3;
UserData.iPar3 = iPar3;
set(handles.fig_selectSim, 'UserData',UserData);
%
% %---scrivo il contenuto di pm_par4 (se esistesse)---
% intPar = dimEff(UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).Points);
% switch intPar
%    % manovre a esecuzione singola e a esecuzione multipla a 1, 2 e 3 parametri
%    case {0,1,2,3}
%       cPar3 = {' '};
%    % manovre a esecuzione multipla a 4 parametri
%    case 4
% end
% set(handles.pm_par4, 'value',1);
% set(handles.pm_par4, 'string',cPar4);
%
% imposto l'interfaccia (abilitazioni e cancellazioni controlli)
settaInterfaccia(handles,get(hObject,'tag'));
%
return

function pb_avantiSim_Callback(hObject, eventdata, handles)
%
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim, 'UserData');
%
% creo la struttura di dati di out
tData.('sDirDati') = UserData.sDirIn;
if isfield(UserData,'sFileIn')
   tData.('sLncFile') = UserData.sFileIn;
end
if isfield(UserData,'tResults') && isfield(UserData.tResults,'Simulazioni')
   tData.('Simulazioni') = UserData.tResults.Simulazioni;
end

% aggiunta campi in automatico
c = fieldnames(UserData);
c = setdiff(c, {'selDepth','tResults','sFileIn','sDirIn','tData'});
for i=1:length(c)
   tData.(c{i}) = UserData.(c{i});
end
%

switch UserData.THtype
   
   case 1
      % estrazione della time history della manovra scelta
      tOpt = tData.Simulazioni(tData.iAppl).(tData.sMan)(tData.iOpt);
      % campi opzionali
      cNames = fieldnames(tData);
      bPar1 = any(strcmp(cNames, 'iPar1'));
      bPar2 = any(strcmp(cNames, 'iPar2'));
      bPar3 = any(strcmp(cNames, 'iPar3'));
      %
      if bPar3 % manovra triparametriche
         val = tOpt.History(tData.iPar1,tData.iPar2,tData.iPar3);
      elseif bPar2 % manovra biparametriche
         val = tOpt.History(tData.iPar1,tData.iPar2);
      elseif bPar1 % manovra monoparametriche
         val = tOpt.History(tData.iPar1);
      else % manovre singole
         val = tOpt.History;
      end
      %
      %%% retrieve TH data
      if isstruct(val) && not(isempty(fieldnames(val)))
          % val is the TH data
          tTH = val;
      elseif iscell(val) && not(isempty(val)) && not(isempty(val{1}))
          % val is a link to the TH data file
          [sPath, sName, sExt] = fileparts(val{1});
          if isempty(sPath)
              sFileTH = fullfile(tData.sDirDati, [sName, sExt]);
          else
              sFileTH = fullfile(sPath, [sName, sExt]);
          end
          % load TH data
          tLoad = load(sFileTH);
          if isfield(tLoad, 'tTH')
              tTH = tLoad.tTH;
          else
              hMsg = msgbox({'Warning:','selected MAT file has unsupported format',''},'','error','modal');
              uiwait(hMsg);
          end
      end
      
   case 2
      % ricopio le time-histories
      tTH = UserData.tTH;
end
tData.tTH = tTH;

% memorizzo la scelta delle time-histories qua dentro
handles.tData = tData;
guidata(hObject, handles);

% aggiornamento
set(handles.fig_selectSim, 'UserData', UserData);

% sblocco la GUI chiamante
if ishandle(handles.hCaller)
   uiresume(handles.hCaller)
end
return

function pb_indietroSim_Callback(hObject, eventdata, handles)
%
% struttura vuota: indicazione che non voglio selezionare alcuna
% simulazione
handles.tData = struct([]);
guidata(hObject, handles);

% setto la grafica dell'interfaccia
settaInterfaccia(handles,'');

% sblocco la GUI chiamante
if ishandle(handles.hCaller)
   uiresume(handles.hCaller)
end
return

function pb_annulla_Callback(hObject, eventdata, handles)
%
% ritorno struttura vuota
handles.tData = [];
guidata(hObject, handles)
%
% flag di annullamento interfaccia
handles.bCancel = true;
guidata(hObject, handles)
%

% sblocco la GUI chiamante
if ishandle(handles.hCaller)
   uiresume(handles.hCaller)
end
return

function cLnc = listaLanci(sDirDati)
% elenca i nomi dei file mat che contengono le simulazioni in cLnc
%
% elenco di directory output di Simulazioni nella cartella dati

% raccolgo tutti i files mat
t = what(sDirDati);
cLnc= t.mat(:);
cLnc = cLnc(:);

% elimino wsp dei lanci
cExe = cLnc(strfindB(cLnc,'exe_') & strfindB(cLnc,'DOF_'));
cLnc = setdiff(cLnc, cExe);

if isempty(cLnc)
   cLnc = {};
   return
end


return

function caricaDirDati(handles,sDirIn)
% recupero le infos dalla di Dati dalla figura
UserData = get(handles.fig_selectSim,'UserData');

% memorizzo la directory di Dati nella figura
UserData.sDirIn = sDirIn;
set(handles.fig_selectSim, 'UserData',UserData);

% setto la stringa dell'edit text di importazione
set(handles.et_foldIn, 'string',sDirIn);

% scrivo il contenuto di pmFileIn
cLnc = listaLanci(sDirIn);
if isempty(cLnc)
   set(handles.pm_fileIn, 'value',1)
   set(handles.pm_fileIn, 'string',{''})
   hMsg = msgbox({'Attenzione:','la directory Dati specificata non contiene simulazioni',''},'','error','modal');
   uiwait(hMsg);
else
   % imposto l'interfaccia (abilitazioni e cancellazioni controlli)
   settaInterfaccia(handles,'pb_foldIn');
   %
      xValOld = get(handles.pm_fileIn, 'value');     % Guenna, 29/06/2015: 
      % evita il guaio che capita quando si cambia directory e nella directory
      % nuova ci sono meno file che in quella vecchia
      set(handles.pm_fileIn, 'value', min(xValOld, length(cLnc)));
   set(handles.pm_fileIn, 'string',cLnc)
end


return

function settaInterfaccia(handles, tagCallback)
% imposta l'interfaccia in base alla callback dell'oggetto chiamato

% recupero le infos dalla di Dati dalla figura 
UserData = get(handles.fig_selectSim,'UserData');
tagDepth = UserData.selDepth;
%
%---handles degli oggetti dal pannello simulazione da attivare---
tagPanSim = {'et_foldIn','pb_foldIn', 'pm_fileIn', 'lb_appl', 'pm_man', 'pm_opt', 'pm_par1', 'pm_par2', 'pm_par3', 'pb_indietroSim'};
% da abilitare sempre (ex: apertura figura)
hEn = [handles.text_foldIn; handles.et_foldIn; handles.pb_foldIn; handles.pb_annulla; handles.pb_indietroSim]; 
% callback della scelta directory
if any(strcmp(tagPanSim(1:end), tagCallback))
   if strcmp(tagDepth, 'dir')
      hEn = [hEn; handles.pb_avantiSim];
   else
      hEn = [hEn; handles.text_fileIn; handles.pm_fileIn]; % controlli primi livello della callback corrente
   end
end
% callback della scelta file di lancio
if any(strcmp(tagPanSim(3:end), tagCallback))
   if strcmp(tagDepth, 'lnc')
      hEn = [hEn; handles.pb_avantiSim];
   else
      hEn = [hEn; handles.text_appl; handles.lb_appl]; 
   end
end
% callback della scelta applicazione
if any(strcmp(tagPanSim(4:end), tagCallback))
   if strcmp(tagDepth, 'appl')
      hEn = [hEn; handles.pb_avantiSim];
   else
      hEn = [hEn; handles.text_man; handles.pm_man]; 
   end
end  
% callback della scelta manovra
if any(strcmp(tagPanSim(5:end), tagCallback))
   if strcmp(tagDepth, 'man')
      hEn = [hEn; handles.pb_avantiSim];
   else
      hEn = [hEn; handles.text_opt; handles.pm_opt]; 
   end
end  
% callback della scelta opzione manovra
if any(strcmp(tagPanSim(6:end), tagCallback))
   if isfield(UserData, 'sMan') && isfield(UserData, 'sOpt')
      if strcmp(tagDepth, 'opt')
         hEn = [hEn; handles.pb_avantiSim];
      else
         switch dimEff(UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).History)
            case {1,2,3}
               hEn = [hEn; handles.text_par1; handles.pm_par1];
            case 0
               hEn = [hEn; handles.pb_avantiSim];
         end
      end
   end
end 
% callback della scelta parametro 1
if any(strcmp(tagPanSim(7:end), tagCallback))
   if isfield(UserData, 'sMan') && isfield(UserData, 'sOpt')
      if strcmp(tagDepth, 'par1')
         hEn = [hEn; handles.pb_avantiSim];
      else
         switch dimEff(UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).History)
            case {2,3}
               hEn = [hEn; handles.text_par2; handles.pm_par2];
            case 1
               hEn = [hEn; handles.pb_avantiSim];
         end
      end
   end
end 
% callback della scelta parametro 2
if any(strcmp(tagPanSim(8:end), tagCallback))
   if isfield(UserData, 'sMan') && isfield(UserData, 'sOpt')
      if strcmp(tagDepth, 'par2')
         hEn = [hEn; handles.pb_avantiSim];
      else
         switch dimEff(UserData.tResults.Simulazioni(UserData.iAppl).(UserData.sMan)(UserData.iOpt).History)
            case 3
               hEn = [hEn; handles.text_par3; handles.pm_par3];
            case 2
               hEn = [hEn; handles.pb_avantiSim];
            otherwise
         end
      end
   end
end
% callback della scelta parametro 3
if any(strcmp(tagPanSim(9:end), tagCallback))
end
%---operazioni su pannello Simulazione---
set(hEn, 'enable','on') % attivazione controlli precedenti (serve davvero?)
set(hEn, 'visible','on')
% disattivazione dei controlli successivi
hChildSim = get(handles.pan_selSim,'children');
hDis = setdiff(hChildSim, hEn);
set(hDis, 'enable','off') 
set(handles.copyPrp, 'Enable', 'on');
% set(hDis, 'visible','off')
% cancellazione contenuti controlli successivi
hDel = [findobj(hDis,'style','popupmenu'); findobj(hDis,'style','listbox')];
set(hDel, 'value',1, 'string',' ');
hDel = findobj(hDis,'style','edit');
set(hDel, 'string',' ');
% eccezioni
hDescr = [handles.et_descrSim; handles.text_descrSim];
if any(strcmp(tagCallback, {'lb_appl','pm_opt'}))
   set(hDescr(1), 'enable','inactive')
   set(hDescr(2), 'enable','on')
   set(handles.copyPrp, 'Enable', 'on');
end
set(handles.pb_annulla , 'visible','off')
return

function settaVisible(handles,selDepth)
hNotVis = [];
% oggetti non visibili
switch selDepth
   case 'dir'
      hNotVis = [handles.pm_par3; handles.text_par3; handles.pm_par2; handles.text_par2; handles.pm_par1; handles.text_par1;...
                 handles.pm_opt; handles.text_opt; handles.pm_man; handles.text_man; handles.lb_appl; handles.text_appl;...
                 handles.pm_fileIn; handles.text_fileIn];
   case 'lnc'
      hNotVis = [handles.pm_par3; handles.text_par3; handles.pm_par2; handles.text_par2; handles.pm_par1; handles.text_par1;...
                 handles.pm_opt; handles.text_opt; handles.pm_man; handles.text_man; handles.lb_appl; handles.text_appl];
   case 'appl'
      hNotVis = [handles.pm_par3; handles.text_par3; handles.pm_par2; handles.text_par2; handles.pm_par1; handles.text_par1;...
                 handles.pm_opt; handles.text_opt; handles.pm_man; handles.text_man];
   case 'man'
      hNotVis = [handles.pm_par3; handles.text_par3; handles.pm_par2; handles.text_par2; handles.pm_par1; handles.text_par1;...
                 handles.pm_opt; handles.text_opt];
   case 'opt'
      hNotVis = [handles.pm_par3; handles.text_par3; handles.pm_par2; handles.text_par2; handles.pm_par1; handles.text_par1];
   case 'par1'
      hNotVis = [handles.pm_par3; handles.text_par3; handles.pm_par2; handles.text_par2];
   case 'par2'
      hNotVis = [handles.pm_par3; handles.text_par3];
   case {'par3','inf'}
end
% settaggio
if not(isempty(hNotVis))
   set(hNotVis, 'visible','off')
end
return


function copyPrp_Callback(hObject, eventdata, handles)
