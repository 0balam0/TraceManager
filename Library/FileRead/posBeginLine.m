function posFile = posBeginLine(sF)

posFile = find(sF(:)==10)+1; % 10: \n
posFile(2:end+1) = posFile;
posFile(1) = 1;
%
if posFile(end)-1 > length(sF);
    posFile = posFile(1:end-1);
elseif posFile(end)-1 < length(sF)
    posFile(end+1) = length(sF)+1;
end

return
    