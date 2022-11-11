function varargout = loadInterpData_1D(varargin)
% LOADINTERPDATA_1D MATLAB code for loadInterpData_1D.fig
%      LOADINTERPDATA_1D, by itself, creates a new LOADINTERPDATA_1D or raises the existing
%      singleton*.
%
%      H = LOADINTERPDATA_1D returns the handle to a new LOADINTERPDATA_1D or the handle to
%      the existing singleton*.
%
%      LOADINTERPDATA_1D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADINTERPDATA_1D.M with the given input arguments.
%
%      LOADINTERPDATA_1D('Property','Value',...) creates a new LOADINTERPDATA_1D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loadInterpData_1D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loadInterpData_1D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loadInterpData_1D

% Last Modified by GUIDE v2.5 10-Nov-2022 16:47:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loadInterpData_1D_OpeningFcn, ...
                   'gui_OutputFcn',  @loadInterpData_1D_OutputFcn, ...
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


% --- Executes just before loadInterpData_1D is made visible.
function loadInterpData_1D_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
UserData = struct('file', '',...% Percorso completo del file
                  'sName', '',...% nome del foglio selezionato
                  'num', [],... % matrice dei valori all'interno del foglio
                  'txt', [],... % celle dell'intestazione
                  'X', [],... % valori della X Da elaborare
                  'Y', [],... % valori della Y da elaborare
                  'Xsel', [],... % x selezionata
                  'Ysel', [],... % y selezionata
                  'Extrp', '',... % extrapolation method linear default
                  'out', []); % struttura di output semplificata
set(hObject, 'UserData', UserData);


guidata(hObject, handles);
pop_plotType_Callback(handles.pop_plotType, [], handles);

% UIWAIT makes loadInterpData_1D wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function varargout = loadInterpData_1D_OutputFcn(hObject, eventdata, handles) 
varargout{1} = hObject;

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function selectX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function selectY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function sheetNames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveBtt.
function showData(handles)
%     assignin('base', ' hl', handles);

    UserData = get(handles.figure1,'UserData');
	if ~isempty(UserData) % prima esecuzione
        X = UserData.X; Y = UserData.Y; txt = UserData.txt; Xsel = UserData.Xsel; Ysel = UserData.Ysel;
        [~, fileName,~] = fileparts(UserData.file);
        if (~isempty(X) && ~isempty(Y)) && (length(X) == length(Y)) %% posso fare la rappresentazione
            switch get(handles.pop_plotType, 'UserData')
                case 'Plot'
                    plotData(UserData, handles)
                case 'Table'
                    compileTable(UserData, handles);
            end
            s = sprintf('%s\\%s\\(x: %s, y:%s)', fileName, UserData.sName, txt{1, Xsel}, txt{1, Ysel});
            set(handles.data_lbl, 'String', s);
        else
            cla(handles.axes2);
            set(handles.data_lbl, 'String', [fileName,'\', UserData.sName, '-> Data selected are not compatible']);
        end
    end
    return

function plotData(UserData, handles)
    X = UserData.X; Y = UserData.Y;
    Xsel = UserData.Xsel; Ysel = UserData.Ysel;
    txt = UserData.txt;
    cla(handles.axes2);
    plot(handles.axes2, X,Y);
    set(handles.axes2,'XMinorGrid','on');
    set(handles.axes2,'YMinorGrid','on');
    xlabel(handles.axes2,sprintf('%s [%s]', txt{1, Xsel}, txt{2, Xsel}));
    ylabel(handles.axes2,sprintf('%s [%s]', txt{1, Ysel}, txt{2, Ysel})); 
return

function compileTable(UserData, handles)
    set(handles.DataTable,'data', UserData.num);
    set(handles.DataTable,'ColumnName', UserData.txt(1,:))
return


function selectY_Callback(hObject, eventdata, handles)
%     assignin('base', 'hl', handles);
    val = get(hObject, 'Value');
    UserData = get(handles.figure1,'UserData');
    num = UserData.num;
    txt = UserData.txt;
    UserData.Y = num(:,val);
    UserData.Ysel = val;
    u = txt{2, val};
    set(handles.unitY, 'String', u);
    set(handles.figure1,'UserData', UserData);
    showData(handles)
    
function selectX_Callback(hObject, eventdata, handles)
    val = get(hObject, 'Value');
    UserData = get(handles.figure1,'UserData');
    num = UserData.num;
    txt = UserData.txt;
    UserData.X = num(:,val);
    UserData.Xsel = val;
    u = txt{2, val};
    set(handles.unitX, 'String', u);
    set(handles.figure1,'UserData', UserData);
    showData(handles)
    
    
function edit1_Callback(hObject, eventdata, handles)
function sheetNames_Callback(hObject, eventdata, handles)
    UserData = get(handles.figure1,'UserData');
    file = UserData.file;
    [~, fileName,~] = fileparts(UserData.file);
    % Foglio selezionato
    val = get(hObject, 'Value');
    lista = get(hObject, 'String');
    name = lista{val};
    UserData.sName = name;
    hideSelection(handles, 'xy', 'off');
    try
        [num, txt, ~] = xlsread(file, name);
        if ~isempty(num)
            stxt = size(txt);
            s = size(num);
            if stxt(1) == 0 % non ci sono nomi nelle colonne
                txt = cell(2,s(2));
                for i=1:s(2)
                    txt{1, i} = sprintf('column %d',i);
                end               
            end
            stxt = size(txt);
            if stxt(1) == 1
                for i=1:s(2)
                    txt{2, i} = sprintf('?');
                end 
            end
            set(handles.selectX, 'String', txt(1,:));
            set(handles.selectY, 'String', txt(1,:));
            set(handles.selectX, 'Visible', 'on');
            set(handles.selectY, 'Visible', 'on');
            UserData.num = num;
            UserData.txt = txt;
            set(handles.figure1,'UserData', UserData);
            selectY_Callback(handles.selectY, [], handles);
            selectX_Callback(handles.selectX, [], handles);
            set(handles.data_lbl, 'String', [fileName,'\', name]);
            hideSelection(handles, 'xy', 'on');
        else
            UserData.num = [];
            UserData.txt = [];
            UserData.X = [];
            UserData.Y = [];
            set(handles.selectX, 'Visible', 'off');
            set(handles.selectY, 'Visible', 'off');
            set(handles.figure1,'UserData', UserData);
            set(handles.data_lbl, 'String', [fileName,'\', name, '-> the sheet appears empty']);
            hideSelection(handles, 'xy', 'off');
        end
    catch Me
        dispError(Me);
        hideSelection(handles, 'xy', 'off');
        set(handles.data_lbl, 'String', [fileName,'\', name, '-> Something gone wrong! Please choose an file!']);
    end
    return

function hideSelection(handles, type, flag)
switch type
    case 'all'
        set(handles.sheetNames, 'Visible', flag);
        set(handles.selectX, 'Visible', flag);
        set(handles.selectY, 'Visible', flag);
    case 'xy'
        set(handles.selectX, 'Visible', flag);
        set(handles.selectY, 'Visible', flag);
    case 'sheet'
        set(handles.sheetNames, 'Visible', flag);
end

        
function btt_loadData_Callback(hObject, eventdata, handles)
    file = '';
    try
        hideSelection(handles, 'all', 'off');
        cla(handles.axes2);
        [name, dir] = uigetfile('.\*xlsx');
        set(handles.data_lbl, 'String', 'In reading, please wait'); pause(0.1);
        if ~isnumeric(name)
            prt = strsplit(name, '.');
            if strcmp(prt{2}, 'xlsx')
                file = strcat(dir, name);
                sheets = {};
                e = actxserver('Excel.Application');
                ewb = e.Workbooks.Open(file);
                for i=1: ewb.Sheets.Count
                    sheets{i} = ewb.Worksheets.Item(i).Name;
                end
                set(handles.sheetNames, 'String', sheets);       
                ewb.Close(false)
                e.Quit
                set(handles.data_lbl, 'String', ['Excel: ', name]);
                hideSelection(handles, 'sheet', 'on');
            else
                set(handles.data_lbl, 'String', 'File not supported');
            end
            UserData = get(handles.figure1,'UserData');
            UserData.file = file;
            set(handles.figure1, 'UserData', UserData);
        else
            hideSelection(handles, 'all', 'off');
            set(handles.data_lbl, 'String', 'Please choose an file!')
        end
    catch Me
        dispError(Me);
        hideSelection(handles, 'all', 'off');
        set(handles.data_lbl, 'String', 'Something gone wrong! Please choose an file!')
    end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles, varargin)
    % delete(hObject);
    UD  = get(hObject, 'UserData');
    if nargin>0
        if ~isempty(varargin)
            lista = get(handles.pop_mth, 'String');
            val   = get(handles.pop_mth, 'Value');
            out = struct('x', UD.X, 'y', UD.Y,...
                 'x_name', UD.txt{1, UD.Xsel},...
                 'y_name', UD.txt{1, UD.Ysel},...
                 'extrap', get(handles.extrapolation, 'Value'),...
                 'method', lista{val});
        else
            out = [];
        end
    end
    UD.out = out;
    set(hObject, 'UserData', UD);
    set(hObject, 'Visible', 'off');

function saveBtt_Callback(hObject, eventdata, handles)
    figure1_CloseRequestFcn(handles.figure1,[], handles, 1);
function bp_cancel_Callback(hObject, eventdata, handles)
    figure1_CloseRequestFcn(handles.figure1,[], handles);
% --- Executes during object creation, after setting all properties.
function pop_mth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pop_plotType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_plotType.
function pop_plotType_Callback(hObject, eventdata, handles)
    lista = get(hObject, 'String');
    val   = get(hObject, 'Value');
    set(hObject, 'UserData', lista{val});
    if strcmp(lista{val}, 'Plot')
        set(handles.DataTable, 'Visible', 'off');
        set(handles.axes2, 'Visible', 'on');
        showData(handles);
    elseif strcmp(lista{val}, 'Table')
        set(handles.DataTable, 'Visible', 'on');
        set(handles.axes2, 'Visible', 'off');
        showData(handles);
    end


% --- Executes on button press in hardClose.
function hardClose_Callback(hObject, eventdata, handles)
    fig = handles.figure1;
    figure1_CloseRequestFcn(fig, eventdata, handles)
    delete(fig);   
