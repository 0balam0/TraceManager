% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 04-07-2007 : implementazione 
% % -------------CALL FUNCTION--------------------------  
%     [sPathFileDefault]=SetPathDefault(Opt,sPathFile,sPathDefault);
% % -------------FUNCTION--------------------------
function [sPathFileDefault]=SetPathDefault(varargin)
% aggiunge un path di default se il file non ce l'ha!

% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
   if nargin==0
   % %     Gestione del caso con solo i default o exit
      sOutput=['Numero insufficiente di argomenti di input in ',THIS_FUNCTION];
      disp(sOutput);
      return;
   end
   
   sPathFileDefault='';
   if nargin>0
        Opt=varargin{1};
        sPathFile=varargin{2};
   end
   if isempty(sPathFile)
      return; 
   end
   
   if nargin>2
        sPathDefault=varargin{3};
   else
       sPathDefault=pwd;
   end  

%    controllo se c'è il path nel file, se non c'è metto ql del file lnc!
   [sPath, sFile, ext, versn] = fileparts(sPathFile);
   
    switch upper(Opt)

        case 'REPLACE'
            sPathFileDefault=fullfile(sPathDefault,[sFile ext]);
        
        case 'DEFAULT'
            if isempty(sPath)
                sPathFileDefault=fullfile(sPathDefault,[sFile ext]);
            else
                sPathFileDefault=sPathFile;
            end
        otherwise
            
    end
    
% % GESTIONE ERRORI 
catch
   [sOutput]=gestErr(THIS_FUNCTION);
end




