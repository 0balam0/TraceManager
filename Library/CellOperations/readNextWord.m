function [cNextWord] = readNextWord(cIn, sBegWord, sDel, bToEnd)

% finds in cell cIn the next "word" after the begenning "word" sBegWord
% delimiter identified by sDel

if not(isempty(sBegWord)) && sBegWord(end)~=sDel
    sBegWord(end+1) = sDel;
end

N = length(cIn);
cNextWord = cell(size(cIn));
for i = 1:N
    sIn = cIn{i};
    if isempty(sBegWord)
        % sBegWord is empty: read the first "word"
        pos = find(sIn == sDel);
        if isempty(pos)
            pos = length(sIn);
         else
            pos = pos(1)-1;
        end
        cNextWord{i} = sIn(1:pos);
    else
        % sBegWord is filled: read the next "word"
        if length(sIn) <= length(sBegWord)
            continue
        end
        if not(strcmpi(sIn(1:length(sBegWord)), sBegWord))
            continue
        end
        sIn1 = sIn(length(sBegWord)+1:end);
        pos = find(sIn1 == sDel);
        if isempty(pos) || bToEnd
            pos = length(sIn1);
        else
            pos = pos(1)-1;
        end
        cNextWord{i} = sIn1(1:pos);
    end
end

return