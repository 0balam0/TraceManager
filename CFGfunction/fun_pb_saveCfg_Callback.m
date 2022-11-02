function fun_pb_saveCfg_Callback(hObject, eventdata, handles)

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
    
%% informazioni su x custom axes
     UDpm = get(handles.pm_CstXtTH_selection, 'UserData');
     % cancello le informazioni di x custom per tutte le tTH che non salvo,
     % per mantenere ordine nella configurazione
     tTHnames = fieldnames(UDpm);
     for i=1:length(tTHnames)
         if ~isfield(UserData.tTH, tTHnames{i})
            UDpm = rmfield(UDpm, tTHnames{i});
         end
     end
%%     
%     xSpaces = handles.xSignalTab.Data; 
    %
    % decido se includere i dati delle time-history nel salvataggio della
    % configurazione
%     if get(handles.cb_inclTH, 'value') == 0
        % non includo: elimino i dati
%         tTH = deleteHistData(tTH);
%% elimino il campo v per tutti i segnali della tTH
        tTHnames = fieldnames(tTH);
        for i=1:length(tTHnames)
            tTHname = tTHnames{i};
            names = fieldnames(tTH.(tTHname));
            for j = 1:length(names)
                name = names{j};
                tTH.(tTHname).(name).v = [];
            end
        end
%%
%     end  
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
   save([sPathName, sFileName], 'tAx', 'tAssi', 'tTH', 'tFiles', 'UDpm', '-mat');

   % ripristino l'interazione utente con l'interfaccia
   while etime(clock, t0) < 0.5
   end
   delete(hD)

catch Me
    dispError(Me, handles.lbl_infoBox);
    if isvalid(hD)
        delete(hD);
    end
    funWriteToInfobox( handles.lbl_infoBox, {'Error! impossible to retrieve all data needed for saving configuration'}, 'n');
end

return