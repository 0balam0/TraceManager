function [] = slSetMask(h, cVars, cVals)

%%% slSetMask(h, cVars, cVals)
%
% sets mask to subsystem h
% cVars is the list of variables as they appear in the subsystem
% cVals are the values to be given to the variables (vuales come externally
% to subsystem); numbers must be set as strings, not as numbers

% activate mask
set(h, 'Mask', 'on')
% 
% check length
N = length(cVars);
N1 = length(cVals);
if N ~= N1
    disp('Error: length of parameters do not match lenght of values')
    return
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set properties
%
% MaskIconFrame 'on'
% MaskIconOpaque 'on'
% MaskIconRotate 'off'
% MaskIconUnits 'autoscale'
% MaskPortRotate 'default'
% MaskRunInitForIconRedraw 'off'
% MaskSelfModifiable 'off'
% MaskType ''
%
% MaskEnable {'on','on'}
% MaskEnableString 'on,on'
cOn = repeatString('on', N);
sOn = cell2string(cOn, ',');
% set(h, 'MaskEnable', cOn)
% set(h, 'MaskEnableString', sOn)
%
% MaskCallbacks {'',''}
% MaskCallbackString '|'
cEmpty = repeatString('', N);
% set(h, 'MaskCallbacks', cEmpty)
% set(h, 'MaskCallbackString', '|')
%
% MaskNames {'var1', 'var2'}
% set(h, 'MaskNames', cVars)
%
% MaskPrompts {'parametro1','parametro1'}
% MaskPromptString 'parametro1|parametro2'
% MaskPropertyNameString 'var1|var2'
set(h, 'MaskPrompts', cVars)
% set(h, 'MaskPromptString', cell2string(cVars, '|'))
% set(h, 'MaskPropertyNameString', cell2string(cVars, '|'))
%
% MaskStyles {'edit','edit'}
% MaskStyleString 'edit,edit'
cEdit = repeatString('edit', N);
set(h, 'MaskStyles', cEdit)
% set(h, 'MaskStyleString', cell2string(cEdit, ','))
% MaskTabNames {'',''}
% MaskTabNameString ''
set(h, 'MaskTabNames', cEmpty)
% set(h, 'MaskTabNameString', '')
% MaskToolTipsDisplay {'on','on'}
% MaskToolTipString 'on,on'
set(h, 'MaskToolTipsDisplay', cOn)
% set(h, 'MaskToolTipString', sOn)
%
% MaskTunableValues {'on','on'}
% MaskTunableValueString 'on,on'
set(h, 'MaskTunableValues', cOn)
% set(h, 'MaskTunableValueString', sOn)
%
% MaskValues {'VarFromBase1','5'}
% MaskValuestring 'VarFromBase1|5'
set(h, 'MaskValues', cVals)
% set(h, 'MaskValuestring', cell2string(cVals,'|'))
%
% MaskVarAliases {'',''}
% MaskVarAliasString ''
set(h, 'MaskVarAliases', cEmpty)
% set(h, 'MaskVarAliasString', '');
%
% MaskVisibilities {'on','on'}
% MaskVisibilityString 'on,on'
%%%%set(h, 'MaskVarAliases', cOn)%selenia
%%%%set(h, 'MaskVarAliasString', sOn);%selenia
set(h, 'MaskVarAliasString', '');%selenia
%
% MaskVariables 'var1=@1;var2=@2;'
% MaskWSVariables struct 1x2 --> t
%   t(1).Name = var1
%   t(1).Value = 1
cMaskVariables = cell(size(cVars));
for i = 1:N
    cMaskVariables{i} = [cVars{i}, '=@', num2str(i)];
end
sMaskVariables = cell2string(cMaskVariables,';');
sMaskVariables(end+1) = ';';
set(h, 'MaskVariables', sMaskVariables);


return

function cOut = repeatString(sIn, N)

cOut = cell(N,1);
for i = 1:N
    cOut{i} = sIn;
end

return