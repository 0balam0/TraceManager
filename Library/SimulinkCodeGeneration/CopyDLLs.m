function CopyDLLs()
% A function to copy GOFAST DLL files to the main directory
%
% 1/6/2021  t2631vs

% Delete garbage left behind from deploySmkModel_dll
rec = recycle('off');
delete('Models\*.exp');
delete('Models\*.lib');
delete('Models\*.obj');
delete('Models\*.exp');
delete('Models\*.lib');
delete('Models\*.sdl_sfun.mexw64');
recycle(rec);

% Move compiled files into main dir and zip
movefile('.\Models\*.dll');
movefile('.\Models\pF_*');
ZipDLLs();

return