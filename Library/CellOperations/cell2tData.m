function [tData] = cell2tData(variable, value, varargin)
% varargin{1}, se specificato, è la struttura di dati "tData" prima della nuova
% assegnazione di variable e value

% assegnazione tData precedente
if nargin>2
    tData = varargin{1};
else
   tData = struct();
end
% controllo coerenza lunghezza di value e variable   
if length(variable) ~= length(value)
  disp('la lunghezza di variable deve essere pari a quella di value!')
  return
end
% ciclo di assegnazione di tData  
for i = 1:length(variable)
   % tolgo spazi e parentesi dal nome campo: rimpiazzo con "_"
   sField = variable{i};
   idx1 = strfind(sField, ' ');
   idx2 = strfind(sField, '(');
   idx3 = strfind(sField, ')');
   idx = union([idx1 idx2 idx3], [idx1 idx2 idx3]);
   sField(idx) = '_';
   if not(isempty(sField)) % il nome campo non può essere vuoto  
      if  isnan(str2double(sField(1))) % il nome campo non può iniziare con un numero 
         tData.(sField) = value{i};
      end
   end
end
return