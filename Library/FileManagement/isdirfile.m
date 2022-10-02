function [MyDir,MyFile]=isdirfile(sPathFile)
MyDir=0;
MyFile=0;
xDir=dir(sPathFile);
[r,c]=size(xDir);

if r==1 
% se è 1 file  > xDir è una struttura : size = 1    
    MyDir=1;
    MyFile=1; 
elseif r>=2
% Se è una dir vuota > xDir è una struttura : size = 2
% Se è una dir non vuota > xDir è una struttura : size > 2
    MyDir=1;
    MyFile=0; 
else
% se non è niente > xDir è una struttura : size = 0    
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