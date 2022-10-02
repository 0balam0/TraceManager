function FullGOFASTCompile()

try
    cd('C:\PWT-Tools\PS_Models\GOFAST_Scripts');
    DeployAndCopy(1);
    compileMe;
catch
end
exit;
end