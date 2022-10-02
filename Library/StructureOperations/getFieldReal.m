% % -------------IMPLEMENTAZIONE FUNCTION--------------------------
% 15-02-2005: implementazione dell'errore
% % -------------CALL FUNCTION--------------------------
% 	[sFieldName,fFieldVal]=getFieldReal(Struttura,fld,DispON);
% % -------------FUNCTION--------------------------
function [sFieldName,fFieldVal]=getFieldReal(varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
% controlla sia un oggetto esistente
    Struttura = varargin{1};
    fld = varargin{2};
    if nargin >2
        DispON=varargin{3};
    else
%         dpe 8-7
        DispON='ON';
    end
   fld=strtrim(fld);
   sFieldName=[];
   fFieldVal=[];
   if isa(Struttura,'struct')
      vFields=strvcat(fieldnames(Struttura));
      [r] = strCmpInMatrix(vFields,fld);
      if isempty(r)
         if  strcmpi(DispON, 'ON')
             disp([mfilename,': ' ,fld,' è un oggetto/field inesistente']);
         end
         return; % non esiste il campo
      end
      ind=find(r > 0);
      sFieldName=strtrim(vFields(ind,1:end));
      fFieldVal =getfield(Struttura,sFieldName);
   else
        if  strcmpi(DispON, 'ON')
            disp([mfilename,' ' ,Struttura,' non è una struttura valida']);
        end
      return;
   end

% % GESTIONE ERRORI
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end

return;

