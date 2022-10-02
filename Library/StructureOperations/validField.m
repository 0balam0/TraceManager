function [sOut, bIdxWrong] =  validField(sIn, sRep, varargin)

% promemoria
% char(48) = 0
% char(57) = 9
% char(65) = A
% char(90) = Z
% char(95) = _
% char(97) = a
% char(122) = z

% gestione varargin
% stringa per rimpiazzo primo carattere
if not(isempty(varargin))
   sRep1 = varargin{1};
else
   sRep1 = sRep;
end
% eventuale default
if not(isAlphabeticString(sRep1(1)))
   sRep1(1) = 'a';
end


sOut = sIn;
%
% dentro al nome del campo (dal secondo carattere in poi), 
% i caratteri che vanno bene sono i numerici e gli alfabetici
bIdxWrong = not(isAlphabeticString(sIn) | isNumericString(sIn) | isUnderscoreString(sIn));
sOut(bIdxWrong) = sRep;
%
% il primo carattere deve essere alfabetico
bIdxWrong(1) = not(isAlphabeticString(sIn(1)));
sOut(bIdxWrong(1)) = sRep1;

return