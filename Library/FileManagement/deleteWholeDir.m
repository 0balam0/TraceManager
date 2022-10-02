function deleteWholeDir(sDir)

% delete whole content of a dir, including subdirs

tDir = dir(sDir);
for i = 1:length(tDir)
    % delete all files into curr dir
    delete(fullfile(sDir, '*.*'));
    if not(strcmpi(tDir(i).name, '.') || strcmpi(tDir(i).name, '..'))
        sSubDir = fullfile(sDir, tDir(i).name);
        if tDir(i).isdir
            % delete sub dirs
            deleteWholeDir(sSubDir);
        end
    end
end

% remove dir tree
try
    % only if all empty this command will be successful
    rmdir(sDir, 's')
catch
end
end

