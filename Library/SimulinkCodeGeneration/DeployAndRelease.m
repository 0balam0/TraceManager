function DeployAndRelease(deleteSlprj)
% Function to glue together DeployAndCompile and UpdateRelease
%
% 1/5/2021  t2631vs

if nargin == 0
    deleteSlprj = 0;
end

DeployAndCompile(deleteSlprj);
UpdateRelease();
return