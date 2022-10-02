function UpdateRelease(pathToRelease)
% Function to copy all nessisary files to update a GOFAST release.
%
% 1/5/2021  t2631vs

if nargin == 0
    pathToRelease = uigetdir('C:\PWT-Tools\GOFAST', 'Select the target GOFAST Directory');
    if length(pathToRelease) == 1
        return;
    end
end

% Delete the existing dll files and DBs to clean up
rec = recycle('off');
delete([pathToRelease '\exe*.dll']);
rmdir([pathToRelease '\DB-INTERFACE'], 's');
rmdir([pathToRelease '\DB-EXE'], 's');
rmdir([pathToRelease '\UTILITIES'], 's');

% Copy GOFAST.exe, the zipped dlls and the DBs
copyfile('C:\PWT-Tools\PS_Models\GOFAST_Scripts\GOFAST.exe', pathToRelease);
copyfile('C:\PWT-Tools\PS_Models\GOFAST_Scripts\*.zip', pathToRelease);
copyfile('C:\PWT-Tools\PS_Models\GOFAST_Scripts\DB-INTERFACE', [pathToRelease '\DB-INTERFACE']);
copyfile('C:\PWT-Tools\PS_Models\GOFAST_Scripts\DB-EXE', [pathToRelease '\DB-EXE']);
copyfile('C:\PWT-Tools\Utilities_Release\*', [pathToRelease '\UTILITIES']);

% Print that it is completed
fprintf('%s updated with the latest models, DB-INTERFACE, and DB-EXE\r\nRemember to update Utilities as nessisary\r\n',...
    pathToRelease);
recycle(rec);
return