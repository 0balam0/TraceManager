function cFiles = dirFilt(sDir, sExt)

% INPUT
% sDir: desired directory
% sExt: extension filter
%
% OTPUT
% cFile: list of desired files

% delete beginning point
if not(isempty(sExt)) && strcmpi(sExt(1), '.')
    sExt = sExt(2:end);
end

if isdir(sDir)
    t = dir(sDir);
    cFiles = cell(length(t),1);
    bOk = false(size(cFiles));
    % loop on result of dir
    for i = 1:length(cFiles)
        if not(t(i).isdir)
            [dum, sName, sExtCurr] = fileparts(t(i).name);
            if strcmpi(sExtCurr,['.',sExt])
                % look for current extension
                bOk(i) = true;
                cFiles{i} = [sName, sExtCurr];
            end
        end
    end
    cFiles = cFiles(bOk);
else
    % sDir is a file
    cFiles{1} = '';
end

return