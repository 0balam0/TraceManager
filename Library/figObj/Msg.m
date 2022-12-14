% [h] = Msg('string','MioMessaggio','title','Titolo')
function varargout = Msg(varargin)
% MSG MATLAB code for Msg.fig
%      MSG by itself, creates a new MSG or raises the
%      existing singleton*.
%
%      H = MSG returns the handle to a new MSG or the handle to
%      the existing singleton*.
%
%      MSG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MSG.M with the given input arguments.
%
%      MSG('Property','Value',...) creates a new MSG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Msg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Msg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Msg

% Last Modified by GUIDE v2.5 22-Apr-2015 16:56:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Msg_OpeningFcn, ...
                   'gui_OutputFcn',  @Msg_OutputFcn, ...
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

% --- Executes just before Msg is made visible.
function Msg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Msg (see VARARGIN)

% Choose default command line output for Msg
% varargin
varargout{1} = hObject;
% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
bWait=0;
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.lbl_Msg, 'String', varargin{index+1});
         case 'wait'
          if varargin{index+1}>0
              bWait=1;
%             uiwait(handles.fig_Msg)
          end
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
set(handles.fig_Msg,'WindowStyle','modal')

% UIWAIT makes Msg wait for user response (see UIRESUME)
if bWait>0
    uiwait(handles.fig_Msg);
end
return;

% --- Outputs from this function are returned to the command line.
function varargout = Msg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;

return;

% --- Executes when user attempts to close fig_Msg.
function fig_Msg_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fig_Msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

return;
