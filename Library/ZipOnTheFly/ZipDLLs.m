function ZipDLLs()
% Zip the dll files to reduce storage space for the open models. Ignores the
% thunks becase they are small and needed to compile GOFAST.exe
% 
% 1/5/2021  t2631vs

toZip = cellLs('*_win64.dll');
rec = recycle('off');

for i = 1:length(toZip)
    dllName = toZip{i};
    zipName = dllName;
    zipName(end-2:end) = 'zip';
    
    fprintf('Zipping and deleting %s \n', dllName);
    
    % If the zip exists delete it because we are replacing it
    if exist(zipName, 'file')
        delete(zipName);
    end
    zip(zipName, dllName);
    delete(dllName);
end

% Cleanup by resetting recycle state
recycle(rec);
return