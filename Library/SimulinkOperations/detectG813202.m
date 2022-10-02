function detectG813202(modelName)
    % Check the version the customer is running    
    if verLessThan('simulink','6.0') || ~verLessThan('simulink','8.0')
        msg = ['You are running a version of MATLAB that is not affected ',...
            'by G813202.'];
        msgbox(msg);
        return;
    end
        
    load_system(modelName);
    
    args = get_param(modelName, 'ParameterArgumentNames');
    
    maskString = locCreateMaskString(args);

    if length(maskString) >= 2048
        msg = ['Your model ', modelName, ' is hitting G813202 ',...
            'which may result in a crash or other undefined behavior.',...
            ' Please reduce the number of model arguments and/or the ',...
            'length of the model workspace variable names and rerun ',...
            'this check.'];
        msgbox(msg, 'Error: Model is affected by G813202');
        return;
    else
        msg = ['Your model ', modelName, ' is not affected by G813202'];
        msgbox(msg, 'Model is not affected by G813202');
        return;
    end

end

function maskString = locCreateMaskString(paramArgs)
   args = strtrim(regexp(paramArgs, ',', 'split'));
      
   maskString = '';
   for i = 1:length(args)
       val = [args{i} '=@' num2str(i) ';'];
       maskString = [maskString val];
   end
end
