function UnzipAllDlls(pathToDlls)
%Unzip all dll files in a given director
if nargin == 0
    pathToDlls = uigetdir('C:\PWT-Tools\GOFAST', 'Select dir');
end

files = cellLs([pathToDlls '\*.zip']);
for i = 1:length(files)
    disp(['Unzipping ' files{i}]);
    unzip([pathToDlls '\' files{i}], pathToDlls);
end

end