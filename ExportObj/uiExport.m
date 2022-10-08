function varargout = uiExport(varargin)
% UIEXPORT MATLAB code for uiExport.fig
%      UIEXPORT, by itself, creates a new UIEXPORT or raises the existing
%      singleton*.
%
%      H = UIEXPORT returns the handle to a new UIEXPORT or the handle to
%      the existing singleton*.
%
%      UIEXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UIEXPORT.M with the given input arguments.
%
%      UIEXPORT('Property','Value',...) creates a new UIEXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uiExport_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uiExport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uiExport

% Last Modified by GUIDE v2.5 07-Oct-2022 11:55:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiExport_OpeningFcn, ...
                   'gui_OutputFcn',  @uiExport_OutputFcn, ...
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


% --- Executes just before uiExport is made visible.
function uiExport_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);

    set(handles.axesLst,'Max', 99);
    set(handles.tTHtrgLbl,'Max', 99);
    % popolo sita degli assi
    hObject.UserData = struct();
    set(hObject, 'UserData', varargin{1});
    UD = varargin{1};
    if isfield(UD, 'tAx')
        if isfield(UD.tAx(1), 'assi')
            set(handles.axesLst, 'String', mat2cell(1:length(UD.tAx(1).assi), 1,length(UD.tAx(1).assi)));
        end
    end
    handles.axesLst.Value = 1:length(UD.tAx(1).assi);

    % popolo lista tTH
    if isfield(UD, 'tFiles')
        tFiles = fieldnames(UD.tFiles);
        names = mat2cell(1:length(tFiles), 1,length(tFiles));
        for i = 1:length(tFiles)
            [~,name,~] = fileparts(UD.tFiles.(tFiles{i}));
            names{i} = name;
        end
        set(handles.tTHtrgLbl, 'String', names);
    end
    handles.tTHtrgLbl.Value = 1:length(UD.tAx);

    set(hObject, 'Name', 'Export Data');
    %popolo la lista dei canali
    set(handles.chnLst, 'enable' , 'off')
    selectionMod(handles, hObject.UserData);
    % controllo i filtri
    filterCheck_Callback(handles)
    ResCheck_Callback(handles)
    assignin('base', 'UserData', hObject.UserData);


% UIWAIT makes uiExport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = uiExport_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function tTHtrgLbl_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function chnLst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function axesLst_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rateLbl_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sngFlt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minFilt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxFilt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in chnLst.
function tTHtrgLbl_Callback(hObject, eventdata, handles)
    selectionMod(handles);
    
function axesLst_Callback(hObject, eventdata, handles)
    selectionMod(handles);

function saveBtt_Callback(hObject, eventdata, handles)
    save_to_file(handles)
    
function selectionMod(handles, UD)
    if nargin ==1
            UD = get(gcbf,'UserData');
    end
    axesList = get(handles.axesLst, 'Value');
    tTHlist  = get(handles.tTHtrgLbl, 'Value');
    chList = {};
    chList{end+1} = 'time';
    try
        for cc=1:length(tTHlist)
            tTHn = tTHlist(cc);
            tTHcfg = UD.tAx(tTHn).assi;
            for j=1:length(axesList)
                ax = axesList(j);
                if ~isempty(tTHcfg(ax).signals)
%                     tTHcfg(ax).signals.name
                    for s=1:length(tTHcfg(ax).signals)
                        if ~any(strcmp(chList, tTHcfg(ax).signals(s).name))
                            if ~isempty(tTHcfg(ax).signals(s).name)
                                chList{end+1} = tTHcfg(ax).signals(s).name;
                            end
                        end
                    end
                end
            end
        end
    catch Me
                    mex = getReport(Me, 'extended','hyperlinks','off');
        uiwait(msgbox({['ID: ' Me.identifier]; ['Message: ' Me.message]; mex}, 'Error','Error','modal'))
        mex = getReport(Me)
    end
    set(handles.chnLst, 'String', chList);
    
function save_to_file(handles, UD)
    try
        if nargin ==1
            UD = get(gcbf,'UserData');
        end
        tTHlist  = get(handles.tTHtrgLbl, 'Value'); %numero delle tTH selezionate
        tFiles = fieldnames(UD.tFiles); % nome dei campi in tFiles contenti path tTH
        [dir, name,~] = fileparts(UD.tFiles.(tFiles{tTHlist(1)})); 
        if length(tTHlist) ~=1 % se � stata selezionata solo una tTH suggerisce il nome 
            name = '*';
        end

        [name, dir] = uiputfile({'*.xlsx'; '*.txt'; '*.hst'},'Select output file', strcat(dir, '\', name, '.xlsx')); 
%         uiwait(gcbf)
        if ~isnumeric(name) % se � stato scelto un percorso 
            filename = strcat(dir,name);
            [~, ~, ext] = fileparts(name); % estensione del file scelta
            if length(tTHlist)>1 && ~strcmp(ext, '.xlsx')
                warndlg({'Cannot create ascii files with multiple tTHs.';...
                         'Select one tTH or choose xlsx extension'},'Warning');
            else
                wb = waitbar(0,'Please wait...');
                tTH_names = fieldnames(UD.tTH); % nome dei campi tTH presenti nella configurazione UD
                chnlst = get(handles.chnLst, 'String'); % nome dei segnali all'interno di chn litbox
                for i = 1: length(tTHlist) % per ogni tTH selezionta
                    waitbar(i/length(tTHlist), wb, 'Please wait...');
                    n = tTHlist(i);
                    tTH = UD.tTH.(tTH_names{n});
                    [~, sheet,~] = fileparts(UD.tFiles.(tFiles{n})); 
                    Names = {}; Units  = {}; vals = [];
                    
                    [resample_flag, newTime] = funResample(handles, tTH);
                    % controllo se � necessario filtrare
                    sngFlt = get(handles.sngFlt, 'String');
                    v = tTH.(sngFlt).v;
                    if resample_flag % se l'output � ricampionato
                        v = interp1(tTH.time.v, v, newTime);
                    end
                    [~, flt] = funFilter(handles, v);
                         
                    % controllo se � necessario filtrare
                    
                    for j=1:length(chnlst) % per ogni nome della lista
                        if isfield(tTH, chnlst{j})
                            Names{end+1} = chnlst{j};
                            if isfield(tTH.(chnlst{j}), 'u')
                                Units{end+1} = tTH.(chnlst{j}).u;
                            else
                                Units{end+1} = 'None';
                            end
                            v = tTH.(chnlst{j}).v;
                            if resample_flag % ricampiono se necessario
                                v = interp1(tTH.time.v, v, newTime);
                            end
                            v = v(flt);
                            vals(:,end+1) = v;
                        end
                    end
                    if strcmp(ext, '.xlsx')
                        xlswrite(filename, Names, sheet, 'A1');
                        xlswrite(filename, Units, sheet, 'A2');
                        xlswrite(filename, vals, sheet, 'A3');
                    else
                        fileID = fopen(filename,'w');
                        for ccF=1:length(Names)
                            fprintf(fileID, '%s\t', Names{ccF});
                        end
                        fprintf(fileID, '\n');
                        for ccF=1:length(Units)
                            fprintf(fileID, '%s\t', Units{ccF});
                        end
                        fprintf(fileID, '\n');
                        s = size(vals);
                        for ccF=1:s(1)
                            fprintf(fileID, '%.4f\t', vals(ccF,:));
                            fprintf(fileID, '\n');
                        end
                        fclose(fileID);
                    end
                end
            end
            delete(wb)
        end
    catch Me
            mex = getReport(Me, 'extended','hyperlinks','off');
        uiwait(msgbox({['ID: ' Me.identifier]; ['Message: ' Me.message]; mex}, 'Error','Error','modal'))
        mex = getReport(Me)
        fprintf('Qualcosa � andato storto durante il salvataggio!\n')
        try
            delete(wb)
        end
    end
    
%     uiputfile('c:\*.xlsx','Select output file');
%     uiputfile('*.xlsx','Select output file');

function [resample_flag, newTime]=funResample(handles, tTH)
    resample_flag = false;
    newTime = [];
    if get(handles.ResCheck, 'Value') 
        if isfield(tTH, 'time')
            try
                time = tTH.time.v;
                rate = get(handles.rateLbl, 'String');
                rate = str2double(rate);
                resample_flag = true;
                newTime = min(tTH.time.v):rate:max(tTH.time.v);
            catch
                resample_flag = false;
            end
        end
    end
return

function [filter_flag, flt] = funFilter(handles, signal)
    filter_flag = false;
    flt = ones(size(signal));
    if get(handles.filterCheck, 'Value')
        try
            fMin = str2double(get(handles.minFilt, 'String'));
            fMax = str2double(get(handles.maxFilt, 'String'));
            flt = signal>fMin & signal<fMax; 
            filter_flag = true;
        catch
            filter_flag = false;
        end

    end
return 

% --- Executes on button press in ResCheck.
function ResCheck_Callback(hObject, eventdata, handles)
    if nargin==1 
        handles = hObject;
    end
    val = get(handles.ResCheck, 'Value');
    if val
        vis = 'on';
    else
        vis = 'off';
    end
    set([handles.text2, handles.rateLbl], 'Visible', vis);
        
function filterCheck_Callback(hObject, eventdata, handles)
    if nargin==1 
        handles = hObject;
    end
    val = get(handles.filterCheck, 'Value');
    if val
        vis = 'on';
    else
        vis = 'off';
    end
    set([handles.minFilt, handles.maxFilt, handles.sngFlt, handles.text6, handles.text5], 'Visible', vis)

function sngFlt_Callback(hObject, eventdata, handles)

function minFilt_Callback(hObject, eventdata, handles)

function maxFilt_Callback(hObject, eventdata, handles)