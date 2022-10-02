function [path, fname, extension] = fileparts1(sFile, varargin)
% FILEPARTS1 Filename parts
% Come fileparts ma con possibilità di specificare un estensione attesa in
% varargin
%     [PATHSTR,NAME,EXT,VERSN] = FILEPARTS(FILE, sExtExpected) returns the path, 
%     filename, extension and version for the specified file. 
%     FILEPARTS is platform dependent.


if not(isempty(varargin))
   %
   sExtExp = varargin{1};
   if not(strcmpi(sExtExp(1),'.'))
      sExtExp(2:end+1) = sExtExp;
      sExtExp(1) = '.'; 
   end
else
   sExtExp = '';
end
   
[path, fname1, extension1] = fileparts(sFile);
%
if not(isempty(sExtExp))
   % cotrollo opzionale con estensione attesa
   switch isempty(extension1)
      case true
         % l'estensione vuota significa solo file e niente estensione
         fname = fname1;
         extension = '';
      case false
         % l'estensione piena può significare nome file con estensione
         % oppure nome file con dentro un punto (.) ma senza estensione
         switch strcmpi(extension1, sExtExp)
            case true
               % se l'estensione trovata è uguale a quella attesa
               fname = fname1;
               extension = extension1;
            case false
               % se l'estensione trovata NON è uguale a quella attesa
               fname =  [fname1, extension1];
               extension = '';
         end
   end
else
  % senza controllo opzionale
  fname = fname1;
  extension = extension1; 
end
   


return