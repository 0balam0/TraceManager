function out_rtp = modifyRTP(in_rtp, varargin)

% versione di matlab R2008b,
% l'ultima compatibile che funziona con i nostri modelli.
%
% rtp = MODIFYRTP(rtp, idx)
% Expands rtp to have idx sets of parameters
%
% rtp = MODIFYRTP(rtp, parameterName, val, ...)
% Takes an rtp structure with tunable parameter information and sets the
% values associated with 'ParameterName' to be val if possible.  There can
% be more than one name value pair.
%
% rtp = MODIFYRTP(rtp, idx, parameterName, val, ...)
% Takes an rtp structure with tunable parameter information and sets the
% values associated with 'ParameterName' to be val in the idx'th parameter
% set.  There can be more than one name value pair.  If the rtp structure
% does not idx parameter sets, the first set is copied and appended until
% there are idx parameter sets then the idx'th set is changed
%
% If the mapping information is not there for 'ParameterName' or val has
% the wrong number of elements, rtp is returned unchanged and an error is
% issued.
%
% see also: RSIMGETRTP

% Copyright 2005-2008 The MathWorks, Inc.

% syntax A
% rtp = modifyRTP(rtp, param, val, ....) with param val pairs
%
% syntax B
% rtp = modifyRTP(rtp, idx, param, val, ....) with param val pairs
%
% note it is possible to call with no param value pairs but with an idx to
% expand an rtp structure from one set to multiple sets


if nargin < 2
    % should error here instead
    out_rtp = in_rtp;
    return;
end
%check the possible idx parameter
% sets idx, expandFlag, and argidx


if isnumeric(varargin{1})
    idx = varargin{1};
    if ( length(idx) > 1) || (idx < 1) || ~isreal(idx)
        DAStudio.error('RTW:rsim:SetRTPParamBadIdx');
    end
    argidx = 2;
    expandFlag = true;
else
    idx = 1;
    argidx = 1;
    expandFlag = false;
end


%check the rtp structure to make sure it is ok
% check for proper structure of the rtp parameter
if ~isstruct(in_rtp) || ~isfield(in_rtp,'parameters')
    DAStudio.error('RTW:rsim:SetRTPParamBadRTP');
end

if ~iscell(in_rtp.parameters)
    p = in_rtp.parameters;
else
    if idx > length(in_rtp.parameters);
          p = in_rtp.parameters{1};
     else
          p = in_rtp.parameters{idx};
     end        
end
    
if ~isstruct(p) || ~isfield(p,'map')
    DAStudio.error('RTW:rsim:SetRTPParamBadMap');
end

nvarargin = length(varargin);
% make sure there are an even number of arguments for
% the name value pairs.
if ~mod(nvarargin - argidx, 2)
    DAStudio.error('RTW:rsim:SetRTPParamBadParamCount');
end

while argidx < nvarargin
    paramname = varargin{argidx};
    val       = varargin{argidx+1};
    argidx = argidx +2;
    
    % do one parameters
    p = setOneRTPParam(p, paramname, val);
end

% now put p in out_rtp
out_rtp = in_rtp;

if ~iscell(out_rtp.parameters)
    if expandFlag
        p1 = out_rtp.parameters;
        out_rtp.parameters = [];
        out_rtp.parameters{1} = p1;
    else
        out_rtp.parameters = p;
        return;
    end
end

% out_rtp.parameters must be a cell array to get here
numsets = length(out_rtp.parameters);
if idx > numsets
    for i = (numsets + 1):idx
        out_rtp.parameters{i} = out_rtp.parameters{1};
    end                
end

out_rtp.parameters{idx} = p;
end %function rsimsetsrtpparam

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper function to set one parameter in p
function p = setOneRTPParam(p, parameterName, val)

%%%% find the maping of the specified parameter
numtypes = length(p);
mapIdx  = [];
typeIdx = [];
for i = 1:numtypes
    prmNames = {p(i).map.Identifier};
    mapIdx = strmatch(parameterName, prmNames, 'exact');
    if ~isempty(mapIdx)
        typeIdx = i;
        break;
    end
end

if isempty(mapIdx)
    DAStudio.error('RTW:rsim:SetRTPParamBadIdentifier', parameterName);
end
map = p(typeIdx).map(mapIdx);

%%%% check the attributes (dimensions, datatype and complexity) 
%%%% of the parameter found against the size of val specified
numind = map.ValueIndices(2) - map.ValueIndices(1) + 1;
if numel(val) ~= ( numind )
    DAStudio.error('RTW:rsim:SetRTPParamBadValueSize', inputname(3), parameterName);
end

if ~isequal(size(val), map.Dimensions)
    DAStudio.error('RTW:rsim:SetRTPParamBadValueDimensions', inputname(3), size(val,1), size(val,2));
end

if ~(p(typeIdx).complex == ~isreal(val))
    DAStudio.error('RTW:rsim:SetRTPParamBadValueComplexity', inputname(3), parameterName);
end


%%%% set the specified parameter values in p
fullInd = linspace(map.ValueIndices(1), map.ValueIndices(2), numind);
p(typeIdx).values(fullInd) = val(:);

end % function setonertpparam
