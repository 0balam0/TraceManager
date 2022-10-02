function [] = slModelRemap(cConvMap, cModels)
% slModelRemap(cConvMap, cModels)
%
% updates the models when changing libraries
% (call of this script should follow the slLibrayRemap script)
% should be performed on the changed library also, not only on the models,
% after the slLibrayRemap
%
% cConv: [cSource, cDestination]
% cSource: {'libOld1/block1'; 'libOld2/block3'}
% cDestination: {'libNewA/block5'; 'libNewB/block6'}
% libOld1/block1 --> libNewA/block5
% libOld2/block3 --> libNewB/block6

% define models list
if nargin == 1
    cModels = '';
end
if ischar(cModels)
    cModels = {cModels};
end
if isempty(cModels{1})
    [cModels] = uigetfile({'*.mdl'; '*.slx'}, 'select models whose library links were remapped', 'MultiSelect', 'on');
    if isequal(cModels, 0)
        return
    end
    if ischar(cModels)
        cModels = {cModels};
    end
end

% loop on the models
for i = 1:length(cModels)
    % init
    cInfo = {'model block', 'source', 'destination', 'warning';...
             '[-]','[-]','[-]','[-]'};
    %
    % open model / library
    [dum, sModel] = fileparts(cModels{i});
    open_system(sModel);
    set_param(sModel, 'Lock', 'off');
    %
    % update all the links
    cInfo = updateLink(sModel, cConvMap, cInfo);
    
    % writes one log per model
    sFile = [sModel,'_reMap.log'];
    fid = fopen(sFile, 'w');
    writeCellAscii(fid, cInfo, '\t', '')
    fclose(fid);
    %
    % save and close model
    save_system(sModel)
    close_system(sModel);
end



return

function cInfo = updateLink(sModel, cConvMap, cInfo)


tP = get_param(sModel, 'ObjectParameters');
% list of blocks contained
if not(isfield(tP, 'Blocks'))
    return
end
cBlocks = get_param(sModel, 'Blocks');

if strcmpi(sModel, 'lib_DriverCtrl/components/driver preset')
    disp('')
end

for i = 1:length(cBlocks)
    % full path of 
    sBlock = modelPathCorrection(cBlocks{i});
    sSub = [sModel, '/', sBlock];
    %
    tP = get_param(sSub, 'ObjectParameters');
    % below procedure makes sense only for SubSystems and 
    if ~isfield(tP, 'BlockType') ||...
            ~(strcmpi(get_param(sSub, 'BlockType'), 'SubSystem') ||...
              strcmpi(get_param(sSub, 'BlockType'), 'Reference'))
        continue
    end
    % 
    sLinkStatus = get_param(sSub, 'LinkStatus');
    if strcmpi(get_param(sSub, 'BlockType'), 'SubSystem')
        switch sLinkStatus
            case 'none'
                % if subsystem is not linked, go down one level to look into current subystem
                cInfo = updateLink(sSub, cConvMap, cInfo);
            case 'resolved'
                % link to simulink base blocks
            otherwise
                % not correct link: gives warning
                cInfo = [cInfo; {removeChar(sSub), '', '', ['link: ', removeChar(sLinkStatus)]}];
        end
    end
    % reads link
    if ~strcmpi(get_param(sSub, 'BlockType'), 'Reference')
        continue
    end
    sSrc = get_param(sSub, 'SourceBlock');
    if isempty(sSrc)
        continue
    end
    %  in case is link is found into source mapping, is remapped to new
    %  destiantion
    bIdx = strcmpi(cConvMap(:,1), sSrc);
    if any(bIdx)
        sDest = cConvMap{bIdx,2};
        set_param(sSub, 'SourceBlock', sDest);
        cInfo = [cInfo; {removeChar(sSub), removeChar(sSrc), removeChar(sDest), ''}]; 
    end
    % if no link exist, goes in and checks if has blocks
end


return

function sValA = removeChar(sValA)

sValA = strrep(sValA, char(9), '_');
sValA = strrep(sValA, char(10), '_');
sValA = strrep(sValA, char(13), '_');

return