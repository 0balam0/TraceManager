% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 28-02-2005: implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     fileKill(sPathFile);
% % -------------FUNCTION--------------------------
function fileKill(sPathFile)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
    [sPath,sFile,ext,versn] = fileparts(sPathFile);
    vListFiles=getNomiFilesByEst(fullfile(sPath,'\'),strcat(sFile,'.*'));
    [row,col]=size(vListFiles);
    
    
    tF=exist(sPathFile);
    switch tF
        case 2
            if row == 1
                %           delete un solo file
                sSwitch= questdlg(['Vuoi davvero eliminare il file : ',strcat(sFile,ext),' ?'],'Kill','Si','No','No');
                switch lower(sSwitch)
                case 'si'
                    delete(sPathFile)
                otherwise  
                    return;
                end;
            else
                form_fileKill(sPathFile,vListFiles);
            end;
        case 7
%             è una dir
                sSwitch= questdlg(['Vuoi davvero eliminare la directory ',strcat(sFile,ext),' e tutti i file contenuti?'],'Kill','Si','No','No');
                switch lower(sSwitch)
                case 'si'
                    rmdir(sPathFile,'s')
                    otherwise  
                    
                    return;
                end;
        otherwise
            msgbox([sPathFile,' oggetto non riconsciuto'],'Kill','warn')
            return;
    end
    

% % GESTIONE ERRORI
catch
    [sOutput]=gestErr(THIS_FUNCTION);
end

return;




