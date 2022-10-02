function sFileOut = cutFileName(sFileIn)
% tronca il nome completo del file in ingresso alla massima lunghezza gestita da
% Windows (256 caratteri)

if length(sFileIn) >= 256 
   [sPath, sName, sExt] = fileparts1(sFileIn);
   sName1 = sName(1:256-(length(sPath)+1+length(sExt)));
   sFileOut = [sPath, '\', sName1, sExt];
%    disp(['Attenzione: il file "', sName,sExt, '"', char(13), ' verrà troncato in "', sName1,sExt, '"',char(13),...
%         ' causa limiti Windows nella gestione di file dal nome troppo lungo'])
else
   sFileOut = sFileIn;
end

return