function [MyDir,MyFile]=isdirfile(sPathFile)
MyDir=0;
MyFile=0;
xDir=dir(sPathFile);
[r,c]=size(xDir);

if r==1 
% se � 1 file  > xDir � una struttura : size = 1    
    MyDir=1;
    MyFile=1; 
elseif r>=2
% Se � una dir vuota > xDir � una struttura : size = 2
% Se � una dir non vuota > xDir � una struttura : size > 2
    MyDir=1;
    MyFile=0; 
else
% se non � niente > xDir � una struttura : size = 0    
    [sPath] = fileparts(sPathFile);
    if isdir(sPath) ==1
        MyDir=1;
        MyFile=0; 
    else
        MyDir=0;
        MyFile=0; 
    end
end

return