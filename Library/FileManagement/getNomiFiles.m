% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 25-10-2004: standardizzazione
% 27-10-2004: gestione vargin
% 28-10-2004: implementazione di struttura e vargin
% 15-02-2005: revisione di showerr ed eliminazione dei case su action
% % -------------CALL FUNCTION--------------------------
%     % % PARAMETRI INPUT
%     tBrowserData.ExtFilter='*.*';
%     tBrowserData.Title='Leggo file ...';
%     tBrowserData.StartDir=pwd;
%     % % CALL
%     [tBrowser]=getNomiFiles(); % Usa i default
%     [tBrowser]=getNomiFiles('*.txt','Leggi file','c:\'); 
%     % Usa la chiamata diretta dei parametri 
%     [tBrowser]=getNomiFiles(tBrowserData); % Input con struttura
%     [tBrowser]=getNomiFiles('showerr'); % Prove di errore
%     % % GESTIONE OUTPUT
%     disp(['-------------------------------- OUTPUT BROWSER --------------------------------'])
%     switch lower(tBrowser.Errore)
%         case 'no error'
%             if tBrowser.NumFiles==0 
%                 disp(['Non ci sono file selezionati'])
%                 return;
%             else
%                 disp(['Hai selezionato ',num2str(tBrowser.NumFiles), ...
%                       'file in ',tBrowser.DirFiles]) 
%                 for n = 1:tBrowser.NumFiles
%                     disp(['file : ',tBrowser.Files(n).name,...
%                           '    PathFile : ',tBrowser.Files(n).pathname]);
%                 end
%             end
%         otherwise
%             disp(['Esco dal programma per: ',tOutput.Errore])
%             return;
%     end
% % -------------FUNCTION--------------------------
function tOutput=getNomiFiles(varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;
ERR_OUT='no error';

% % INIZIO FUNCTION
try 
   tOutput.Errore=ERR_OUT;

   % SETTAGGIO DEFAULT A SECONDA DEL MODELLO DI INGRESSO DEI DATI
   sAction='base';
   if nargin==0
   % %     Gestione del caso con solo i default o exit
   %     tOutput.Errore=['Numero insufficente di argomenti di input in ',...
   %                     THIS_FUNCTION]
   %     return
      t='';
      tInput='';
   else
      t=varargin{1}
   end

   if isstruct(t)==1
   % è una struttura e non si deve fare niente
      tInput=t;
   else
   % Se non è una struttura ci sono 2 possibilità:
   % 1) è showerr
   % 2) è un array con 1 o più un parametri
      if strfind(lower(t),'showerr')>=1
         sAction='showerr';
         % % PROVE ERRORE
         disp(['Esecuzione di ',THIS_FUNCTION, '  ACTION [ ',sAction,' ]']);
         e=mioErrore/'r'
      end
      % legge i nomi dei campi
      if nargin >= 1 
         tInput.ExtFilter=strvcat(varargin(1));  % OPZIONALE 
      end
      if nargin >= 2 
         tInput.Title=strvcat(varargin(2));  % OPZIONALE
      end
      if nargin >= 3 
         tInput.StartDir=strvcat(varargin(3));  % OPZIONALE
      end
   end

   % % SETTAGGIO PARAMETRI CHE SONO OPZIONALI / OPPURE NO
   [sStartDir]= gestField(tInput,'StartDir','c:\');
   [sExtFilter]=gestField(tInput,'ExtFilter','*.*');
   [sTitle]=    gestField(tInput,'Title','Load File');  

   disp(['Esecuzione di ',THIS_FUNCTION, '  ACTION [ ',sAction,' ]']);
   % %    controlla l'ultimo carattere che deve essere '\'  
   %         sStartDir=tInput.StartDir;
   [r,c]=size(sStartDir);        
   sLastCar=sStartDir(1,c:c);
   if strcmpi(sLastCar,'\')==1 | strcmpi(sLastCar,'/')==1
      %
   else
      sStartDir=[sStartDir,'\'];
   end

   [sFiles, sStartDirFiles]=uigetfile(sExtFilter,sTitle,sStartDir,...
                                      'MultiSelect', 'on');
   if isequal(sFiles,0)
      tOutput.NumFiles=0;
      return
   else
      v=strvcat(sFiles);
      [fRow,fCol]=size(v);
      for n = 1:fRow
         t.name=    v(n,:);
         t.pathname=fullfile(sStartDirFiles,t.name);
         tFile(n)=  t;
      end
      tFile=tFile';
      tOutput.DirFiles=   sStartDirFiles;
      tOutput.NumFiles=   fRow;
      tOutput.Files=      tFile;
      tOutput.FilesMatrix=v;
   end

% % GESTIONE ERRORI
catch
   [tOutput.Errore]=gestErr2(THIS_FUNCTION);
end

return;