% MsgYesNo('string','MioMessaggio','title','Titolo')
function varargout = MsgYesNo(varargin)
% MSGYESNO MATLAB code for MsgYesNo.fig
%      MSGYESNO by itself, creates a new MSGYESNO or raises the
%      existing singleton*.
%
%      H = MSGYESNO returns the handle to a new MSGYESNO or the handle to
%      the existing singleton*.
%
%      MSGYESNO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MSGYESNO.M with the given input arguments.
%
%      MSGYESNO('Property','Value',...) creates a new MSGYESNO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MsgYesNo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MsgYesNo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MsgYesNo

% Last Modified by GUIDE v2.5 01-Apr-2015 10:52:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MsgYesNo_OpeningFcn, ...
                   'gui_OutputFcn',  @MsgYesNo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
% varargin
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
return;
% End initialization code - DO NOT EDIT

% --- Executes just before MsgYesNo is made visible.
function MsgYesNo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MsgYesNo (see VARARGIN)

% Choose default command line output for MsgYesNo
% varargin
handles.output.Text = 'Yes';
handles.output.Value = 1;

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.lbl_Msg, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Make the GUI modal
set(handles.fig_YesNo,'WindowStyle','modal')

% UIWAIT makes MsgYesNo wait for user response (see UIRESUME)
uiwait(handles.fig_YesNo);
return;

% --- Outputs from this function are returned to the command line.
function varargout = MsgYesNo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;
try
    varargout{2} = handles.output.Text ;
    varargout{3} = handles.output.Value ;
    % The figure can be deleted now
    delete(handles.fig_YesNo);
catch
    varargout{2} = 'CloseWindow' ;
    varargout{3} = -1 ; 
end

return;

% --- Executes on button press in cmd_Yes.
function cmd_Yes_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_Yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output.Text = get(hObject,'String');
handles.output.Value = 1;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.fig_YesNo);
return;

% --- Executes on button press in cmd_No.
function cmd_No_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_No (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output.Text = get(hObject,'String');
handles.output.Value = 0;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.fig_YesNo);
return;


% --- Executes on key press with focus on fig_YesNo and none of its controls.
function fig_YesNo_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to fig_YesNo (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
return;

% --- Executes when user attempts to close fig_YesNo.
function fig_YesNo_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fig_YesNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
return;

% --- Executes when fig_YesNo is resized.
function fig_YesNo_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to fig_YesNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
