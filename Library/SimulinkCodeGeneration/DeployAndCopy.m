function DeployAndCopy(deleteSlprj)
% Combination of deploy SMK Model Dll and compileMe
try cd('..\GOFAST_TopLevel'); catch; end
rec = recycle();

% Delete slprj if desired
if nargin == 1 && deleteSlprj == 1
    recycle('off');
    try
        rmdir('.\slprj', 's');
    catch
    end
end

deploySmkModel_dll();

% Trash the unused files
recycle('off');
delete('*.exp');
delete('*.lib');
delete('*.obj');
delete('*.exp');
delete('*.lib');
delete('*.sdl_sfun.mexw64');
recycle(rec);
cd('..\GOFAST_Scripts');

% Move compiled files into main dir and zip
try
    movefile('..\GOFAST_TopLevel\*.dll');
    movefile('..\GOFAST_TopLevel\pF_*');
    ZipDLLs();
catch
    disp('No dlls found.');
end

end

