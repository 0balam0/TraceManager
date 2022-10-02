% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 15-02-2005: creazione
% % -------------CALL FUNCTION--------------------------
%     % % PARAMETRI INPUT
function vListFiles=getNomiFilesByEst(DataDir,Est)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try 
   sFilterFile=fullfile(DataDir,Est);
   tFilesDati=dir(sFilterFile);
   [row,col]=size(tFilesDati);
   % % % %     vListFiles=strvcat(tFilesDati.name);
   % % % %     [fRow,col]=size(tFilesDati);
   mFolder=[];
   iFolder=0;
   mFile=[];
   iFile=0;
   for i=1:row
      if tFilesDati(i).isdir == 1
         if strcmpi(tFilesDati(i).name,'.') || strcmpi(tFilesDati(i).name,'..') 
            % non è una dir: no action
         else
            iFolder=iFolder+1;
            mFolder=matrixAddRow(mFolder,iFolder,tFilesDati(i).name);
         end
      else
         iFile=iFile+1;
         mFile=matrixAddRow(mFile,iFile,tFilesDati(i).name);
      end
   end
    
   vListFiles=strvcat(mFolder,mFile);
    
    
% % GESTIONE ERRORI
catch
    [vListFiles]=gestErr2(THIS_FUNCTION);
end

return;