function c = stringDivide(s, sDelim, varargin)

% split string s into a cell array looking for sDelimiter sDelim

bLastDelimRemove = false;
if not(isempty(varargin))
    % consider or not last delimiter
    a = find(strcmpi(varargin,'lastDelRem'));
    if not(isempty(a))
        bLastDelimRemove = varargin{a+1};
    end
end


posFound = find(s == sDelim);
nFound = length(posFound);
if nFound>=1 && isequal(posFound(end), length(s))
    % removes last delimiter
    if bLastDelimRemove
        s = s(1:end-1);
        nWords = nFound;
    else
        nWords = nFound+1;
    end
else
    nWords = nFound+1;
end


if nWords == 1
    % one word
    c = {s};
else
    % more than one word
    c = cell(1, nWords);
    for i = 1:nWords
        if i == 1
            % first word
            posIniz = 1;
            posEnd = posFound(1)-1;
        elseif i == nFound+1
            % last word
            posIniz = posFound(i-1)+1;
            posEnd = length(s);
        else
            % intermediate word
            posIniz = posFound(i-1)+1;
            posEnd = posFound(i)-1;
        end
        c{i} = s(posIniz:posEnd);
    end
end
    

return