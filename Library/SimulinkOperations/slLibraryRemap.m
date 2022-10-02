function [] = slLibraryRemap(cConv)

% [] = slLibraryRemap(cConv)
%
% changes Simulink library names and links
%
% cConv: [cSource, cDestination]
% cSource: {'libOld1/block1'; 'libOld2/block3'}
% cDestination: {'libNewA/block5'; 'libNewB/block6'}
% libOld1/block1 --> libNewA/block5
% libOld2/block3 --> libNewB/block6

% get source library list
[cLibsSrc, bSrcMapping] = getLibraryList(cConv(:,1));
% open source library
openModel(cLibsSrc);
% check for block existance into source
checkBlocksExistance(cConv(:,1));

% get destination library list
[cLibsNew, bDstMapping] = getLibraryList(cConv(:,2));
% create new libraries and set to be modified
createDstLibrary(cLibsNew);
     
% copy objects from source libray to destination libraries
copyBlocks(cConv)

% Not used because the remapping procedure makes this automatically
% and avoids unwanted changes to the library
% % set the forwarding table to source libraries
% setForwardingTable(cConv, cLibsSrc, bSrcMapping)
% saveModel(cLibsSrc)

% save and close destination libraries
saveModel(cLibsNew)
closeModel(cLibsNew)

% remaps all links into new libraries
slModelRemap(cConv, cLibsNew)

% % remaps all link into user models (user-selected)
% slModelRemap(cConv)

% close source libraries
closeModel(cLibsSrc)

return

function setForwardingTable(cConv, cLibsSrc, bSrcMapping)

for i = 1:length(cLibsSrc)  
    [dum, sLib] = fileparts(cLibsSrc{i});
    % extact sub-set of convertion table
    cConv0 = cConv(bSrcMapping(:,i),:);
    cFwd = cell(1, size(cConv0,1));
    for j=1:length(cFwd)
        cFwd{j} = {cConv0{j,1}, cConv0{j,2}};
    end
    % set forwd table
    set_param(sLib, 'ForwardingTable', cFwd);
end

return

function saveModel(cLibs)

for i = 1:length(cLibs)
    sLib = cLibs{i};
    [dum, sLibNoExt] = fileparts(sLib);
    save_system(sLibNoExt)
end

return

function createDstLibrary(cLibsNew)
     
% open libraries and set to be modified
for i = 1:length(cLibsNew)
    sLibNew = cLibsNew{i};
    [dum, sLibNewNoExt] = fileparts(sLibNew);
    if not(exist(sLibNew, 'file'))
        % creates and saves
        new_system(sLibNewNoExt, 'Library')
        open_system(sLibNewNoExt)
        save_system(sLibNewNoExt)
    else
        % opens
        open_system(sLibNewNoExt);
    end
    % unlocks for next editing
    set_param(sLibNewNoExt, 'Lock', 'off');
    set_param(sLibNewNoExt, 'LibraryLinkDisplay', 'User')
end

return

function openModel(c)

for i=1:length(c)
    % open and unlocks the source library
    [dum, s] = fileparts(c{i});
    open_system(s);
    set_param(s, 'Lock', 'off');
end

return

function closeModel(c)

for i=1:length(c)
    % open the source library
    close_system(c{i});
end

return

function checkBlocksExistance(cConv)

% check for existance
for i = length(cConv)
    sBlockSrc = cConv{i};
    if not(isempty(sBlockSrc)) && not(exist_block(sBlockSrc))
        disp(['Error: block ', sBlockSrc, ' does not exist.'])
    end
end

return

function [cLibsNewExt, bMapping] = getLibraryList(cConv)

% cLibsNewExt: libraries list
% bMapping: tells where cLibsNewExt is found into cConv

cLibsNew = cell(size(cConv));
bEmpty = false(size(cLibsNew));
for i = 1:length(cLibsNew)
    cTmp = stringDivide(cConv{i}, '/', 'lastDelRem',true);
    cLibsNew{i} = cTmp{1};
    if isempty(cLibsNew{i})
        bEmpty(i) = true;
    end
end
cLibsNew = cLibsNew(not(bEmpty));
cLibsNew = unique(cLibsNew);
% add extension
cLibsNewExt = cLibsNew;
for i = 1:length(cLibsNewExt)
    cLibsNewExt{i} = [cLibsNewExt{i}, '.mdl'];
end

% mapping
bMapping = false(size(cConv,1),length(cLibsNew));
for i = 1:length(cConv)
    cTmp = stringDivide(cConv{i}, '/', 'lastDelRem',true);
    bMapping(i,:) = strcmpi(cLibsNew, cTmp{1});
end

return

function h = createPath(sPath)
% adds components path creating empty sub-systems

% split required path into multiple strings
cPath = stringDivide(sPath, '/', 'lastDelRem',true);
if not(isequal(sPath(end), '/'))
    % if last part of string is a path, not block, eliminates block from
    % list
    cPath = cPath(1:end-1);
end
h = zeros(length(cPath));

% string to be concatenated (tree building) 
sPathNew = '';
% loop growing from base
for i = 1:length(cPath)
    %
    s0 = cPath{i};
    if isequal(i,1)
        sPathNew = s0;
    else
        % goes down one more level
        sPathNew = [sPathNew, '/', s0];
    end
    % add new susystem in case not existing
    if not(exist_block(sPathNew))
        h(i) = add_block('built-in/SubSystem', sPathNew);
        % set position of current subsystem
        if i>1
            cBlocks = sort(get_param(get_param(sPathNew,'parent'), 'Blocks')); % "brother" sybsystems
            % idx = find(strcmpi(cBlocks, s0));
            setPositionFolder(sPathNew, length(cBlocks)); % ques last lock
        end
    else
        % 
        h(i) = get_param(sPathNew, 'handle');
    end
end

return

function setPositionFolder(sObj, n)
% set position vertically starting from top to down

w = 75;
h = 50;
x = 70;
y = 40 + (h+20)*(n-1);

pos = [x y w+x h+y];

set_param(sObj, 'Position', pos)

return

function setPositionObj(hObj)

% looks for "brother" objects
sPath = get_param(hObj,'parent');
cBlocks = sort(get_param(sPath, 'Blocks')); 
cName = {get_param(hObj, 'Name')};
cBlocks = setdiff(cBlocks, cName);
% full path
for i = 1:length(cBlocks)
    cBlocks{i} = [sPath, '/', cBlocks{i}];
end

% looks for last (bottom) object
posMax = 0;
for i = 1:length(cBlocks)
    pos = get_param(cBlocks{i}, 'position');
    posMax = max(posMax, pos(4));
end

space = 50;
if isempty(cBlocks)
    xnew = 80;
    ynew = space;
else
    xnew = pos(1); % horizontal alignnent
    ynew = posMax+space;
end
% new position for current object
posOld = get_param(hObj, 'Position');
w_old = posOld(3)-posOld(1);
h_old = posOld(4)-posOld(2);
posNew = [xnew, ynew, xnew+w_old, ynew+h_old];
set_param(hObj, 'Position', posNew)


return

function copyBlocks(cConv)
% copy objects from source libray to destination libraries

for i = 1:size(cConv,1)
    %
    try
        sBlockSrc = cConv{i,1};
        sBlockDst = cConv{i,2};
        %
        % prepares destination path
        createPath(sBlockDst);
        %
        % quits in case source is empty
        if isempty(sBlockSrc)
            continue
        end
        %
        % add object and break link
        if exist_block(sBlockDst)
            delete_block(sBlockDst)
        end
        hOld = get_param(sBlockSrc, 'handle');
        hNew = add_block(hOld, sBlockDst);
        set_param(hNew, 'LinkStatus', 'none');
        %
        % sets poistion
        setPositionObj(hNew)
        % copy content of block
        % Simulink.BlockDiagram.copyContentsToSubSystem(hOld, hNew);
        % doesn't break link (the forward table will think to it)
        % set_param(hNew, 'LibraryLink');
    catch ME
        disp(ME.message)
    end
end

return