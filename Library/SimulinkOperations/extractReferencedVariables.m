function [cVars, cVarsXLS] = extractReferencedVariables(sModel)

% get variables 
tVars = get_param(sModel, 'ReferencedWSVars');

% cell array for Matlab use
cVars = cell(length(tVars),2);
for i = 1:length(tVars)
    % variable name
    cVars{i,1} = tVars(i).Name;
    % names of blocks that reference this
    h = tVars(i).ReferencedBy;
    cTmp = cell(length(h),1);
    for j = 1:length(h)
        cTmp{j} = [get(h(j),'Path'), '/', get(h(j),'Name')];
    end
    cVars{i,2} = cTmp;
    clear cTmp
end

% cell array to be filterd with excel
a = 0;
cVarsXLS = cell(30000,2);
for i = 1:size(cVars,1)
    sVarName = cVars{i,1};
    cBlocks = cVars{i,2};
    for j = 1:length(cBlocks)
        a = a+1;
        cVarsXLS{a,1} = sVarName;
        sBlock = cBlocks{j};
        % replace C format characts
        sBlock = strrep(sBlock, char(9), '_');
        sBlock = strrep(sBlock, char(10), '_');
        sBlock = strrep(sBlock, char(13), '_');
        cVarsXLS{a,2} = sBlock;
    end
end
cVarsXLS = cVarsXLS(1:a,:);

% print to text file
cHead = {'Vars', 'Blocks'};
sFileOut = [sModel, '.txt'];
fid = fopen(sFileOut,'w');
writeCellAscii(fid, [cHead; cVarsXLS], '\t', '')
fclose(fid);

return