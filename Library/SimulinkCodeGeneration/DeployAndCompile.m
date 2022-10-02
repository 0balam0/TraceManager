function DeployAndCompile(deleteSlprj)
% Combination of deploy SMK Model Dll and compileMe
if nargin == 0
    deleteSlprj = 0;
end
DeployAndCopy(deleteSlprj);

% And compile
compileMe();
end

