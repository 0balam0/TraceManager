% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 25-10-2004: sistemazione secondo gli ultimi standard
% 17/05/2006: aggiunto il caso di arresto del programma
% 28/11/2006: tolto il caso di uscita da Matlab
% % -------------CALL FUNCTION-------------------------------------  
% Non c'è la struttura dei dati ed è sempre nello stesso modo
% FUNCTION è il nome della funzione in cui si è generato l'errore
%     [sErrOut]=gestErr(FUNCTION);
% % -------------FUNCTION------------------------------------------

function sErrOut=gestErr2(varargin)

% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
    
% controlla ci sia input
   if nargin==0
      sErrOut='Errore generico';
   end
    
   if nargin==1
      sErr=lasterror;
      sErrOut=['Errore in ',varargin{1},'  ',[sErr.message,' ', ...
               sErr.identifier]];
   end
   
   if nargin==2
      sErrOut=['Errore in ',varargin{1},':  ',varargin{2}];
   end
    
   disp(sErrOut)
   % sSwitch= questdlg(sErrOut,'GESTIONE ERRORI','Esco da Matlab',...
   %                   'Esco dal programma','Continuo','Esco dal programma');
   [sSwitch, tFig]= questdlg3(sErrOut,'GESTIONE ERRORI',...
                              'Esco dal programma','Continuo',...
                              'Esco dal programma');
   imwrite(tFig.cdata,'errore.tif');
   switch sSwitch
      % case 'Esco da Matlab'
      %    quit;
      case 'Esco dal programma'
         if isdeployed
            quit
         else
            msgbox('Premi Ctrl+C','Esci dal programma','Error')
            disp('Premi Ctrl+C')
            pause
         end
      case 'Continuo'    
         return
   end

% % GESTIONE ERRORI
catch
   sErr=lasterror;
   sErrOut=['Errore in ',THIS_FUNCTION,' ',[sErr.message,' ',...
            sErr.identifier]];
   disp(sErrOut )
   % sSwitch= questdlg(sErrOut,'GESTIONE ERRORI','Esco da Matlab',...
   %                   'Continuo','Esco da Matlab');
   [sSwitch, tFig]= questdlg3(sErrOut,'GESTIONE ERRORI',...
                              'Esco dal programma','Continuo',...
                              'Esco dal programma');
   imwrite(tFig.cdata,'errore2.tif');
   switch sSwitch
      % case 'Esco da Matlab'
      %    quit;
      case 'Esco dal programma'
         msgbox('Premi Ctrl+C','Esci dal programma','Error')
         disp('Premi Ctrl+C')
         pause
      case 'Continuo'    
         return
   end
end

return;
