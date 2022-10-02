function cRefVarsTun = refreshTunVars(sModel)
% aggiorna la lista di variabili tunable
% sModel deve essere aperto e con il suo WSP già caricato


% Get from model the referenced workspace variables
tRefVars = get_param(sModel, 'ReferencedWSVars');

% exclude structures for now
cRefVarsTun = cell(length(tRefVars),1);
a = 0;
for j = 1:length(cRefVarsTun)
    sVarName = tRefVars(j).Name;
    val = evalin('base', sVarName);
    if isstruct(val);
        disp(['Warning: referenced variable "', sVarName, '" is a structure and will not be tuned'])
        continue
    end
    %
    % update tunable list
    a = a+1;
    cRefVarsTun{a} = sVarName;
end
% cut list
cRefVarsTun = cRefVarsTun(1:a);

% Build lists
sVars = '';
sStorageClass = '';
sTypeQualifier = '';
for j = 1:length(cRefVarsTun)
   sVars = [sVars, cRefVarsTun{j}, ',']; % TunableVars
   sStorageClass = [sStorageClass, 'Auto', ',']; % TunableVarsStorageClass
   sTypeQualifier = [sTypeQualifier, ' ,']; % TunableVarsTypeQualifier
end
sVars = sVars(1:end-1); % tolgo virgola finale
sStorageClass = sStorageClass(1:end-1);
sTypeQualifier = sTypeQualifier(1:end-1);
%
% variabili tunable
set_param(sModel, 'TunableVars',sVars, 'TunableVarsStorageClass',sStorageClass, 'TunableVarsTypeQualifier',sTypeQualifier);
% settaggi di rtw
set_param(sModel, 'InlineParams','on', 'InlineParameters','on', 'rtwInlineParameters','on')
% altri settaggi di rtw
set_param(sModel, 'rtwGenerateCodeOnly','off', 'GenCodeOnly','off')


return