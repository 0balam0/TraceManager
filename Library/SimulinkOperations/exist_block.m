function bExist = exist_block(sPath)

bExist = true;
try
    % command will be successful
    get_param(sPath, 'ObjectParameters');
catch
    % command will be unsuccessful if block doesn't exist
    bExist = false;
end

end