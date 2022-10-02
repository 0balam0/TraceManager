function UnzipDLL(DLLName)
% On the fly unzipping of a DLL file at runtime
%
% 1/5/2021  t2631vs

% clean up the DLL name if there is an extension.
if DLLName(end-3) == '.'
    DLLName = DLLName(1:end-4);
end

% If it already exists do nothing and return
if exist([DLLName '.dll'], 'file')
    return;
end

zipName = [DLLName '.zip'];
unzip(zipName);
system(['compact /c .\'  DLLName '.dll']);

return