function NumberOfCursor=CreateCursor(scr, fhandle, NumberOfCursor, AxesList, UserFunction)
% scCreateCursor creates or replaces a vertical cursor
%
% Examples
% n=CreateCursor()
% n=CreateCursor(fighandle)
% n=CreateCursor(fighandle, CursorNumber)
% n=CreateCursor(fighandle, CursorNumber, AxesList)
% n=CreateCursor(fighandle, CursorNumber, AxesList, UserFunction)
%
% Cursors are specific to a figure. If the figure handle is not specified
% in fhandle, the current figure (returned by gcf) will be used.
% CursorNumber is any positive number. If not specified the lowest numbered
% free cursor number will be used. 
%
% AxesList, if supplied and not empty, is vector of axes handles and 
% will restrict the drawing of cursors to the specified axes. Note that
% cursor numbers must be unique to any MATLAB figure but using this feature,
% cursors 1 and 2, for example,  could be applied to one set of axes 
% while 3 and 4 are applied to a second set.
%
% UserFunction, if specified is a function handle or a cell array
% containing a function handle in the first element. The function will be
% called when there is a ButtonUpEvent following movement of the cursor.
% if UserFunction is a cell array, the 2nd and subsequent elements will be
% passed to the function as arguments.
%
% Returns n, the number of the cursor created in the relevant figure.
%
% A record is kept of the cursors in the figure's application data
% area. Cursor n occupies the nth element of a cell array. Each element is
% a structure containing the following fields:
%           Handles:    a list of objects associated with this cursor -
%                       one line for each axes and one or more text objects
%           IsActive:   true if this cursor is currently being moved. False
%                       otherwise. For manual cursors, IsActive is set by a
%                       button down on the cursor and cleared by a button
%                       up. 
% Functions that affect the position of a cursor must explicitly update all
% the objects listed in Handles. A cursor is not presently an object itself.
%
% Revisions: 27.02.07 add restoration of gca
%            30.01.08 add uicontextmenu. Speed up UpdateCursorPosition.
%            14.11.09 add UserFunction argument
%            15.11.09 update text label only on button up - improves speed
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright � The Author & King's College London 2007-
% -------------------------------------------------------------------------
%
% Note: These functions presently work with 2D views only
% Keep gca to restore current axes at end
fhandle = scr.Parent.Parent;
assignin('base', 'fhandle', fhandle);
current=gca;
% Figure details
if nargin<1
    fhandle=gcf;
end
if nargin<3
    if isappdata(fhandle, 'AxesList')
        % Within sigTOOL figure
        AxesList=getappdata(fhandle, 'AxesList');
        AxesList=AxesList(AxesList>0);
    else
        % Otherwise
        AxesList=sort(findobj(fhandle, 'type', 'axes'));
    end
else
    if isempty(AxesList)
        AxesList=sort(findobj(fhandle, 'type', 'axes'));
    end
end
if nargin<4
    UserFunction=[];
end
% Get cursor info
newhandles=zeros(1, length(AxesList));
Cursors=getappdata(fhandle, 'VerticalCursors');
% Deal with this cursor number
if isempty(Cursors)
    NumberOfCursor=1;
else
    if nargin<2
        FirstEmpty=0;
        if ~isempty(Cursors)
            for i=1:length(Cursors)
                if isempty(Cursors{i})
                    FirstEmpty=i;
                    break
                end
            end
        end
        if FirstEmpty==0
            NumberOfCursor=length(Cursors)+1;
            Cursors{NumberOfCursor}=[];
        else
            NumberOfCursor=FirstEmpty;
        end
    end
end
% Add numel 19.01.08
if ~isempty(Cursors) && numel(Cursors)>NumberOfCursor && ~isempty(Cursors{NumberOfCursor}) &&...
        isfield(Cursors{NumberOfCursor},'CursorIsActive')
    if Cursors{NumberOfCursor}.CursorIsActive==true
        disp('CreateCursor: Ignored attempt to delete the currently active cursor');
        return
    else
        delete(Cursors{NumberOfCursor}.Handles);
    end
end
Cursors{NumberOfCursor}.IsActive=false;
Cursors{NumberOfCursor}.Handles=[];
Cursors{NumberOfCursor}.Type='';
XLim=get(AxesList(end),'XLim');
xhalf=XLim(1)+(0.5*(XLim(2)-XLim(1)));

for i=1:length(AxesList)
    % For each cursor there is a line object in each axes
    subplot(AxesList(i));
    YLim=get(AxesList(i),'YLim');
    newhandles(i)=line([xhalf xhalf], [YLim(1) YLim(2)]);
    Cursors{NumberOfCursor}.Type='2D';
    
end
axs = findobj(fhandle, 'type', 'axes'); %trovo tutti gli obj assi
for i=1:length(axs)
    t = text(axs(i), 0, 0, '', 'interpreter', 'tex', 'Tag', strcat('CursorInfo_',num2str(NumberOfCursor)),'Interruptible','off');
    parents = findobj(axs(i), '-regexp','Tag', 'line_[^]');
    set(t, 'UserData', parents);
    Cursors{NumberOfCursor}.TextInfo{i} = t;
end
% Put a label at the top and make it behave as part of the cursor
axes(AxesList(1));
YLim=get(AxesList(1),'YLim');
th=text(xhalf, YLim(2), ['C' num2str(NumberOfCursor)],...
    'Tag','Cursor',...
    'UserData', NumberOfCursor,...
    'FontSize', 7,...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom',...
    'Color', 'k',...
    'EdgeColor',[26/255 133/255 5/255],...
    'Clipping','off');%,...
    %'ButtonDownFcn',{@CursorButtonDownFcn});
% Set line properties en bloc
% Note UserData has the cursor number
if ispc==1
    % Windows
    EraseMode='xor';
else
    % Mac etc: 'xor' may cause problems
    EraseMode='normal';
end
set(newhandles, 'Tag', 'Cursor',...
    'Color', [26/255 133/255 5/255],...
    'UserData', NumberOfCursor,...
    'Linewidth',1,...%    'Erasemode', EraseMode,...
    'ButtonDownFcn',{@CursorButtonDownFcn, UserFunction});
Cursors{NumberOfCursor}.IsActive=false;
Cursors{NumberOfCursor}.Handles=[newhandles th];
cmenu=uicontextmenu();
m = uimenu(cmenu, 'Label', 'Delete', 'Callback', @Delete,...
    'UserData', NumberOfCursor);
m2 = uimenu(cmenu,'Label', 'Get Data', 'Callback', @GetData, 'UserData', NumberOfCursor);
m2 = uimenu(cmenu,'Label', 'Go to', 'Callback', @GoTo, 'UserData', NumberOfCursor);
m2 = uimenu(cmenu,'Label', 'Change background', 'Callback', @changeBackground, 'UserData', NumberOfCursor);
set(Cursors{NumberOfCursor}.Handles, 'UIContextMenu', cmenu);
setappdata(fhandle, 'VerticalCursors', Cursors);
set(gcf, 'WindowButtonMotionFcn',{@CursorWindowButtonMotionFcn});

% Restore the axes on entry as the current axes
axes(current);
x=GetCursorLocation(fhandle, NumberOfCursor);
dispDataCursor(Cursors{NumberOfCursor}, x);

% add Cursor information 
% axs = findobj(fhandle, 'type', 'axes');
% for i=1:length(axs) 
%     t= text(axs(i), 0, 0, '', 'interpreter', 'tex', 'Tag', strcat('CursorInfo_',num2str(NumberOfCursor)));
% end
% Cursors{NumberOfCursor}.textInfo = t;
return
end

%--------------------------------------------------------------------------
function CursorButtonDownFcn(hObject, EventData, UserFunction) %#ok<INUSD>
%--------------------------------------------------------------------------
% Make sure we have a left button click
type=get(ancestor(hObject,'figure'), 'SelectionType');
flag=strcmp(type, 'normal');
if flag==0
    % Not so, return and let matlab call the required callback, 
    % e.g. the uicontextmenu, which will be in the queue
    return
end;
% Flag the active cursor
Cursors=getappdata(gcf, 'VerticalCursors');
for i=1:length(Cursors)
    if isempty(Cursors{i})
        continue
    end
    if any(Cursors{i}.Handles==hObject)
            % Set flag
            Cursors{i}.IsActive=true;
            break
    end
end
setappdata(gcf, 'VerticalCursors', Cursors);
% Set up
StoreWindowButtonDownFcn=get(gcf,'WindowButtonDownFcn');
StoreWindowButtonUpFcn=get(gcf,'WindowButtonUpFcn');
StoreWindowButtonMotionFcn=get(gcf,'WindowButtonMotionFcn');
% Store these values in the CursorButtonUpFcn persistent variables so they
% can be used/restored later
CursorButtonUpFcn({hObject,...
    StoreWindowButtonDownFcn,...
    StoreWindowButtonUpFcn,...
    StoreWindowButtonMotionFcn});
% Motion callback needs only the current cursor number
CursorButtonMotionFcn({hObject});
% Set up callbacks
% UserFunction
set(gcf, 'WindowButtonUpFcn',{@CursorButtonUpFcn, UserFunction});
set(gcf, 'WindowButtonMotionFcn',{@CursorButtonMotionFcn});
return
end
%--------------------------------------------------------------------------
function CursorButtonUpFcn(hObject, EventData, UserFunction) %#ok<INUSD>
%--------------------------------------------------------------------------
% These persistent values are set by a call from CursorButtonDownFcn
persistent ActiveHandle;
persistent StoreWindowButtonDownFcn;
persistent StoreWindowButtonUpFcn;
persistent StoreWindowButtonMotionFcn;
% Called from CursorButtonDownFcn - hObject is a cell with values to seed
% the persistent variables
if iscell(hObject)
    ActiveHandle=hObject{1};
    StoreWindowButtonDownFcn=hObject{2};
    StoreWindowButtonUpFcn=hObject{3};
    StoreWindowButtonMotionFcn=hObject{4};
    return
end
% Called by button up in a figure window - use the stored CurrentCursor
% value
[Handles cpos]=UpdateCursorPosition(ActiveHandle);
% 15.11.09 Update cursor text object(s)
% LabelHandle=findobj(Handles, 'Type', 'text');
% tpos=get(LabelHandle,'Position');
% tpos(1)=cpos(1);
% set(LabelHandle,'Position',tpos);
% set(LabelHandle, 'String', sprintf('%.3f',tpos(1)))
% set(LabelHandle, 'Visible', 'on');
    
% Restore the figure's original callbacks - make sure we do this in the
% same figure that we had when the mouse button-down was detected
h=ancestor(ActiveHandle,'figure');
set(h, 'WindowButtonDownFcn', StoreWindowButtonDownFcn);
set(h, 'WindowButtonUpFcn', StoreWindowButtonUpFcn);
set(h, 'WindowButtonMotionFcn',StoreWindowButtonMotionFcn);
% Remove the active cursor flag
Cursors=getappdata(gcf, 'VerticalCursors');
for i=1:length(Cursors)
    if isempty(Cursors{i})
        continue
    end
    if any(Cursors{i}.Handles==ActiveHandle)
        Cursors{i}.IsActive=false;
        break
    end
end
setappdata(gcf, 'VerticalCursors', Cursors);
% Added 14.11.09. Call user specified function on button up
if nargin==3 && ~isempty(UserFunction)
    if iscell(UserFunction)
        UserFunction{1}(UserFunction{2:end});
    else
        UserFunction();
    end
end
return
end
%--------------------------------------------------------------------------
function CursorButtonMotionFcn(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% This replaces the CursorWindowButtonMotionFcn while a cursor is being
% moved
persistent ActiveHandle;
% Called from CursorButtonDownFcn
if iscell(hObject)
    ActiveHandle=hObject{1};
    return
end
%Called by button up
UpdateCursorPosition(ActiveHandle)
return
end
%--------------------------------------------------------------------------
function [a b]=UpdateCursorPosition(ActiveHandle)
%--------------------------------------------------------------------------
% Get the pointer position in the current axes
thisCursor= get(ActiveHandle,'UserData');
cpos=get(gca,'CurrentPoint');
% Get object handles
Cursors=getappdata(ancestor(ActiveHandle, 'figure'), 'VerticalCursors');
Handles=Cursors{thisCursor}.Handles;
% Update cursor line objects
CursorHandles=findobj(Handles, 'Type', 'line');
% ... and update them:
%if cpos(1,1)==cpos(2,1) && cpos(1,2)==cpos(2,2)
    % 2D Cursor
    % Limit to the x-axis limits
    XLim=get(gca,'XLim');
    if cpos(1)<XLim(1)
        cpos(1)=XLim(1);
    end
    if cpos(1)>XLim(2)
        cpos(1)=XLim(2);
    end
    % Update cursor line object(s)
    set(CursorHandles,'XData',[cpos(1) cpos(1)]);
    dispDataCursor(Cursors{thisCursor}, cpos(1));
    % 15.11.09
    % Turn cursor text object(s) off for now - updating them while moving
    % slows performance. Update only on button up
%     LabelHandle=findobj(Handles, 'Type', 'text');
%     set(LabelHandle, 'Visible', 'off');
% else
%     % TODO: Include support for 3D cursors
%     set(CursorHandles,'XData',[cpos(1) cpos(1)]);
%     return
% end
if nargout>0
    a=Handles;
    b=cpos;
end
return
end
%--------------------------------------------------------------------------
function Delete(hObject, EventData)
%--------------------------------------------------------------------------
fhandle=ancestor(hObject, 'figure');
n=get(hObject, 'UserData');
DeleteCursor(fhandle, n);
set(fhandle, 'Pointer', 'arrow');
return
end

%--------------------------------------------------------------------------
function GetData(hObject, EventData)
%--------------------------------------------------------------------------
    fhandle=ancestor(hObject, 'figure');
    n=get(hObject, 'UserData');
    Cursors=getappdata(fhandle, 'VerticalCursors');
    
    Ystore = {}; axis = {}; nameSignal = {}; Color ={}; lineStyleV = {}; unit = {};
    Cursor = Cursors{n};
    x = Cursor.Handles(1).XData(1);
    for i=1:length(Cursor.TextInfo)
        for j=1:length(Cursor.TextInfo{i}.UserData)
            l = Cursor.TextInfo{i}.UserData(j);
            [~, id] = min(abs(l.XData - x));
            color = l.Color;
            X = l.XData(id);
%             assignin('base','c', Cursor.TextInfo{i}.UserData(j));
            unit{end+1} = Cursor.TextInfo{i}.UserData(j).Parent.YLabel.String;
            Ystore{end+1} = l.YData(id);
            lineStyleV{end+1} = l.LineStyle;
            axis{end+1} = sprintf('axis_%i', i);
            nameSignal{end+1} = Cursor.TextInfo{i}.UserData(j).UserData;
            Color{end+1} = sprintf('[%.2f,%.2f,%.2f]', color(1), color(2), color(3));
        end
    end
    unit{end+1} = Cursor.TextInfo{i}.UserData(j).Parent.XLabel.String;
    Ystore{end+1} = X;
    lineStyleV{end+1} = 'none';
    axis{end+1} = 'all';
    nameSignal{end+1} = Cursor.TextInfo{i}.UserData(j).Parent.XLabel.String;
    Color{end+1} = '[1,1,1]';
            
    axis = axis'; nameSignal = nameSignal'; Color = Color'; 
    lineStyleV = lineStyleV'; Ystore=Ystore'; unit = unit';
%     fig = uifigure;
    t = table(axis, nameSignal, Color, lineStyleV, Ystore, unit);
    writetable(t, '.\myData.txt','Delimiter','\t');
    system('type .\myData.txt | clip');
%     s=get(t,'data');
%     clipboard('copy', s);
    return
end

function GoTo(hObject, EventData)
    fhandle=ancestor(hObject, 'figure');
    n=get(hObject, 'UserData');
    Cursors=getappdata(fhandle, 'VerticalCursors');
    Cursor = Cursors{n};
    answer = inputdlg('X location','xValue');
    if ~isempty(answer)
        try 
            xPos = str2double(answer{1});
            SetCursorLocation(fhandle, n, xPos);
            dispDataCursor(Cursors{n}, xPos);
        end
    end  
end

function changeBackground(hObject, EventData)
    fhandle=ancestor(hObject, 'figure');
    n=get(hObject, 'UserData');
    Cursors=getappdata(fhandle, 'VerticalCursors');
    Cursor = Cursors{n};
    assignin('base', 'C', Cursor);
    BGc = [1 1 1];
    if any(isnumeric(get(Cursor.TextInfo{1}, 'BackgroundColor')))
        BGc = 'none';
    end
    for i=1:length(Cursor.TextInfo)
        set(Cursor.TextInfo{i}, 'BackgroundColor', BGc);
    end
end