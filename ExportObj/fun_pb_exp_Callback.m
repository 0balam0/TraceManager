function fun_pb_exp_Callback(hObject, eventdata, handles)

% esportazione su file di testo
try
    % esporta le grandezze scelta dall'utente dalla time history
    % della simulazione in un file esterno
    %
    % recupero la tTH dalla figura
    UserData = get(gcbf,'UserData');
    
    %%% scelta nome file per esportazione
    % recupero nome del primo file letto
    sFullFile = UserData.tFiles.sFile_1;
    [sPath, sFileName] = fileparts(sFullFile);
    sFullName = fullfile(sPath, [sFileName, '.hst']);
    [sFileName, sPathName, filterindex] = uiputfile({'*.hst', 'file ascii (*.hst)';...
        '*.dat', 'INCA binary file (*.dat)'}, 'file to export', sFullName);
    
    if length(sFileName)>2 && strcmp(sFileName(end-1:end),'.*')
        sFileName = sFileName(1:end-2);
    end
    %
    if not(ischar(sFileName)) || not(ischar(sPathName))
        return
    end
    
    % blocco l'interazione dell'utente con l'interfaccia
    t0 = clock;
    hD = msgbox('exporting file...please wait', '', 'modal');
   
    %%% scelta grandezze da esportare
    cQuant = get(handles.lb_exp, 'string');
    if ischar(cQuant)
        cQuant = {cQuant};
    end
    cQuant(2:end+1) = cQuant;
    cQuant{1} = 'time';

    %%% interpolazione time-histories
    tTH = UserData.tTH.tTH_1;
    answer = inputdlg('Select the rate sample');
    if isempty(answer)
        return
    else
        t_s = str2num(answer{1});
        if isempty(t_s) || length(t_s)>1
            return
        end
    end
    if not(isempty(t_s))
        names = fieldnames(tTH);
        t = tTH.time.v;
        tnew = min(t):t_s:max(t);
        
        for i=1:length(names)
            tTH.(names{i}).v
            tTH.(names{i}).v = interp1(t, tTH.(names{i}).v, tnew);
        end
%         tTH = rfSdsMain('interpolaTH', tTH, t_s); Rimpiazzato da quello
%         in alto perche non funzionava
    end
    switch filterindex
        case 1
            % esportazione della time-history della prima manovra(tTH_1)
            rfSdsMain('writeTHascii', [sPathName, sFileName], tTH, cQuant);
            
        case 2
            % DAT format
            for i = 1:length(cQuant)
                sField = cQuant{i};
                tTHdat.(sField) = double(tTH.(sField).v);
            end
            %
            mat2dat(tTHdat, [sPathName, sFileName])
    end
    
    % ripristino l'interazione utente con l'interfaccia
    while etime(clock, t0) < 0.5
    end
    delete(hD)
catch Me
    dispError(Me)
end

return