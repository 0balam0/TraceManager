function s = setfield2(s,varargin)
%SETFIELD Set structure field contents.
%   S = SETFIELD(S,'field',V) sets the contents of the specified
%   field to the value V.  This is equivalent to the syntax S.field = V.
%   S must be a 1-by-1 structure.  The changed structure is returned.
%
%   S = SETFIELD(S,{i,j},'field',{k},V) is equivalent to the syntax
%       S(i,j).field(k) = V;
%
%   In other words, S = SETFIELD(S,sub1,sub2,...,V) sets the
%   contents of the structure S to V using the subscripts or field
%   references specified in sub1,sub2,etc.  Each set of subscripts in
%   parentheses must be enclosed in a cell array and passed to
%   SETFIELD as a separate input.  Field references are passed as
%   strings.  
%
%   For improved performance, when setting the value of a simple 
%   field, use <a href="matlab:helpview([docroot '/techdoc/matlab_prog/matlab_prog.map'], 'dynamic_field_names')">dynamic field names</a>.
%
%   See also GETFIELD, ISFIELD, FIELDNAMES, ORDERFIELDS, RMFIELD.
 
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.22.4.4 $  $Date: 2004/04/10 23:25:32 $

% Check for sufficient inputs
if (isempty(varargin) || length(varargin) < 2)
    error('MATLAB:setfield:InsufficientInputs',...
        'Not enough input arguments.');
end

arglen = length(varargin);
strField = varargin{1};
strField=deblank(strField);
if isempty(strField) 
    return 
end
if (arglen==2)
% The most common case, modified by Petrolo et al., 14/06/2006
    strField=deblank(strField);
    k = findstr(strField, '.');
    if isempty(k)
        s.(strField) = varargin{end};    
        return
    else
        strField=['.',strField,'.'];
        k = findstr(strField, '.');
        [c]=length(k);
        cFields='';
        for i=1 : c-1
            cFields{i}=strField(k(i)+1:k(i+1)-1);
        end
        [c]=length(cFields);
        switch c
            case 2
               s.(cFields{1}).(cFields{2})= varargin{end};
            case 3
               s.(cFields{1}).(cFields{2}).(cFields{3})= varargin{end};
            case 4
               s.(cFields{1}).(cFields{2}).(cFields{3}).(cFields{4})= varargin{end};
            case 5
               s.(cFields{1}).(cFields{2}).(cFields{3}).(cFields{4}).(cFields{5})= varargin{end};
            case 6
               s.(cFields{1}).(cFields{2}).(cFields{3}).(cFields{4}).(cFields{5}).(cFields{6})= varargin{end};
            otherwise
                error('MATLAB:setfield2:TooManyFieldLevels',...
                      'Invalid field name component.');
        end
        return;
    end
end
        
subs = varargin(1:end-1);
for i = 1:arglen-1
    index = varargin{i};
    if (isa(index, 'cell'))
        types{i} = '()';
    elseif ischar(index)        
        types{i} = '.';
        subs{i} = deblank(index); % deblank field name
    else
        error('MATLAB:setfield:InvalidType','Inputs must be either cell arrays or strings.');
    end
end

% Perform assignment
if arglen>2
    try
        s = builtin('subsasgn', s, struct('type',types,'subs',subs), varargin{end});   
    catch
        error('MATLAB:setfield2', lasterr)
    end
end

return