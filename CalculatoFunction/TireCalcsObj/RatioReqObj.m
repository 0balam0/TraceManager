function varargout = RatioReqObj(varargin)
% RATIOREQOBJ MATLAB code for RatioReqObj.fig
%      RATIOREQOBJ, by itself, creates a new RATIOREQOBJ or raises the existing
%      singleton*.
%
%      H = RATIOREQOBJ returns the handle to a new RATIOREQOBJ or the handle to
%      the existing singleton*.
%
%      RATIOREQOBJ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RATIOREQOBJ.M with the given input arguments.
%
%      RATIOREQOBJ('Property','Value',...) creates a new RATIOREQOBJ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RatioReqObj_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RatioReqObj_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RatioReqObj

% Last Modified by GUIDE v2.5 03-Nov-2022 16:37:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RatioReqObj_OpeningFcn, ...
                   'gui_OutputFcn',  @RatioReqObj_OutputFcn, ...
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


% --- Executes just before RatioReqObj is made visible.
function RatioReqObj_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

    if not(isempty(varargin))
        if any(strcmp(varargin, 'String'))
            names = varargin{find(strcmp(varargin, 'String'))+1};
            set(handles.vhcSignal, 'String', ['vhc speed ', names{1}]);
            set(handles.engSpeedSignal, 'String', ['Eng speed ', names{2}]);
        end
        if any(strcmp(varargin, 'tTH'))
            UD = varargin{find(strcmp(varargin, 'tTH'))+1};
            set(hObject, 'UserData', UD);
        end
    end
guidata(hObject, handles);


% UIWAIT makes RatioReqObj wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function reactivation(ratio, handles, varargin)
    if nargin == 2 % non sono stati passati gli handles
        handles = struct();
        for i=1:length(ratio.Children)
            handles.(ratio.Children(i).Tag) = ratio.Children(i);
        end
        set(ratio, 'Visible', 'on'); 
    end
    
    return
    

% --- Outputs from this function are returned to the command line.
function varargout = RatioReqObj_OutputFcn(hObject, eventdata, handles, varargin) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --- Executes during object creation, after setting all properties.
function edit_num_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% callBack
function edit1_Callback(hObject, eventdata, handles)
    str = get(hObject, 'String');
    val = str2num(str);
    if isempty(val)
        val = 0;
    end
    set(hObject, 'String', num2str(val));
    
function Savebtt_Callback(hObject, eventdata, handles)
    try
        strV = get(handles.edit1, 'String');
        val = str2num(strV); % rapporti
        gearName = get(handles.edit11, 'String'); % nome del segnale delle marce
        UserData = get(gcbf,'UserData');
        ratio = [];
        if strcmpi(gearName, 'none') % non è stato inserito il nome delle marce
                ratio = ones(size(UserData.time.v)).*val(1);
        else % è stato inserito il nome del canale 
            UserData = get(gcbf,'UserData'); 
            v = ceil(UserData.(gearName).v); 
            if length(val) < max(v) % piu marce dei rapporti
                s = sprintf('%s %d %s %d %s %.2f', 'you entered ', length(val), ' ratios but I found a maximum of', ...
                    max(v),' gears. Do I use the first value', val(1), ' as a fixed ratio? click yes to continue.');
                    answer = questdlg(s, '?','Yes','No', 'Cancel', 'Cancel');
                    if strcmp(answer, 'Yes') % uso il rapporto fisso
                        ratio = ones(size(UserData.time.v)).*val(1);
                    else
                        ratio = [];
                    end
            else % provo a tirar fuori un vettore dei rapporti
                ratio = val(v);
            end
            
        end
        if ~isempty(ratio)
            UserData.CalcAutogenRatios = struct('v', ratio, 'u', '-', 'd', 'Autogenerate ratios channels');
            set(gcbf,'UserData', UserData);
            figure1_CloseRequestFcn(gcbf);
        end
        
    catch Me
        dispError(Me)
        hObject = gcbf;
        errorTracking(Me);
    end


function edit11_Callback(hObject, eventdata, handles)
    strV = get(hObject,'String');
    UserData = get(gcbf,'UserData');
    if ~isfield(UserData, strV)
        strV = 'none';
    end
    set(hObject, 'String', strV);
return 


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    UserData = get(hObject,'UserData');
    if ~isfield(UserData,'CalcAutogenRatios') % ho premuto x prima di qualsiasi operazione
        UserData.errore = [];
        set(hObject, 'UserData', UserData);
    end
        
    set(hObject, 'Visible', 'off');
%     delete(hObject);
