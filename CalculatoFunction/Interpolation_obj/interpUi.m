function varargout = interpUi(varargin)
% INTERPUI MATLAB code for interpUi.fig
%      INTERPUI, by itself, creates a new INTERPUI or raises the existing
%      singleton*.
%
%      H = INTERPUI returns the handle to a new INTERPUI or the handle to
%      the existing singleton*.
%
%      INTERPUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERPUI.M with the given input arguments.
%
%      INTERPUI('Property','Value',...) creates a new INTERPUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interpUi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interpUi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interpUi

% Last Modified by GUIDE v2.5 08-Nov-2022 17:22:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interpUi_OpeningFcn, ...
                   'gui_OutputFcn',  @interpUi_OutputFcn, ...
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


% --- Executes just before interpUi is made visible.
function interpUi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interpUi (see VARARGIN)

% Choose default command line output for interpUi
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes interpUi wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interpUi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btt_loadData.
function btt_loadData_Callback(hObject, eventdata, handles)
% hObject    handle to btt_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in selectX.
function selectX_Callback(hObject, eventdata, handles)
% hObject    handle to selectX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectX


% --- Executes during object creation, after setting all properties.
function selectX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in selectY.
function selectY_Callback(hObject, eventdata, handles)
% hObject    handle to selectY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectY


% --- Executes during object creation, after setting all properties.
function selectY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveBtt.
function saveBtt_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in sheetNanes.
function sheetNanes_Callback(hObject, eventdata, handles)
% hObject    handle to sheetNanes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sheetNanes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sheetNanes


% --- Executes during object creation, after setting all properties.
