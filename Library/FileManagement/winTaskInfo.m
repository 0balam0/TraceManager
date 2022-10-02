function [tTask] = winTaskInfo(sWinName)

% access to OS
[runState, sMsg] = system(['tasklist /fo "csv" /v /fi "windowtitle eq ', sWinName, '"']);
pos = find(int8(sMsg)== 10);
pos1 = pos(1);

% divedes info in 2 cell arrays, label and values
cTaskLab = stringDivide(sMsg(1:pos1-1), ',');
cTaskVal = stringDivide(sMsg(pos1+1:end-1), ',');

if not(isequal(length(cTaskVal),9))
    % dummy cells for not found process
    cTaskLab = cell(9,1);
    cTaskVal = cell(9,1);
else
    % removes "" from data
    for i = 1:length(cTaskLab)
        cTaskLab{i} = cTaskLab{i}(2:end-1);
        cTaskVal{i} = cTaskVal{i}(2:end-1);
    end
end


% looks for items according to position
tTask.sImageName = cTaskVal{1};
tTask.PIDnum = str2double(cTaskVal{2});
tTask.sSessionName = cTaskVal{3};
tTask.sessionNum = str2double(cTaskVal{4});
tTask.sMemoryUsed = cTaskVal{5};
tTask.sStatus = cTaskVal{6};
tTask.sUserName = cTaskVal{7};
tTask.sCPUtime = cTaskVal{8};
tTask.sWinTitle = cTaskVal{9};

return
%
function value = lookItem(cTaskInfo, sPIDname)

value = [];
for i = 1:length(cTaskInfo)
    sF = cTaskInfo{i};
    if length(sF)>length(sPIDname)
        pos = find(strfind(sF, sPIDname));
        if not(isempty(pos))
            value = str2double(strtrim(sF(pos+length(sPIDname):end)));
            break
        end
    end
end

return