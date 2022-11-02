function fun_pb_loadCfg_Callback(hObject, eventdata, handles)
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
    
    % aggiornamento lista unità di misura disponibili
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
        % nMan: numero della manovra, se >=2 è da intendersi per il confronto
        sMan = num2str(i);
        sFig = ['fig_selectSim',sMan];
        sF = cFiles{i};
        % chiamo la scelta manovra e uso come argomento di ingresso il file
        % della configurazione
        handles.(sFig) = selectSim_v2('callerHandle',gcbf, 'selDepth','inf', 'sFileDef', UserData.tFiles.(sF));
        %
        set(handles.(sFig), 'visible','off')
    end
    % memorizzo handles figure chiamate
    guidata(hObject, handles);
    
    %% carico le informazioni su xCustom axes
    try
        
        tTHnames = fieldnames(UserData.tTH);
        if ~isfield(tFile, 'UDpm') % carico una configurazione tracemanage_v1
            tFile.UDpm = struct();
            for i=1:length(tTHnames) % per tutte le tTH caricati creo una configurazione tTH
                tTHname = tTHnames{i};
                tFile.UDpm.(tTHname).xSngName = 'time';   % x axes name
                tFile.UDpm.(tTHname).fltSngName = 'time'; % filter name
                tFile.UDpm.(tTHname).enable = 0;          % disabilito xCustom
                tFile.UDpm.(tTHname).filter = 0;          % disabilito filtro
                tFile.UDpm.(tTHname).from = min(UserData.tTH.(tTHname).time.v);   % tempo di inizio filtro
                tFile.UDpm.(tTHname).to   =   max(UserData.tTH.(tTHname).time.v); % tempo di fine filtro
                names = fieldnames(UserData.tTH.(tTHname));
                tTH = UserData.tTH.(tTHname);
                for j=1:length(names)
                    name = names{j};
                    if isempty(tTH.(name).t0)
                        tTH.(name).t0 = 0;
                    end
                    if isempty(tTH.(name).g0)
                        tTH.(name).g0 = 1;
                    end
                end
                UserData.tTH.(tTHname) = tTH;
            end
        end
    catch Me
        dispError(Me);
        funWriteToInfobox( handles.lbl_infoBox, {'Error! Impossible to load x custom axes'}, 'n');
    end
    
    %% salvo dati utente correnti
    set(gcbf, 'UserData', UserData);
    set(handles.pm_CstXtTH_selection, 'UserData', tFile.UDpm);
    
    % ripristino l'interazione utente con l'interfaccia
    while etime(clock, t0) < 0.5
    end
    delete(hD)
    
    if isfield(tFile, 'xSpaces')
        handles.xSignalTab.Data = tFile.xSpaces;
    end
    
catch Me
    dispError(Me, handles.lbl_infoBox);
    if isvalid(hD)
        delete(hD)
    end
    funWriteToInfobox( handles.lbl_infoBox, {'Error! impossible to retrieve all data needed for loading configuration'}, 'n');
end

return
