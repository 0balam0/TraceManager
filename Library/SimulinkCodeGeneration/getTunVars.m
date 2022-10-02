function cRefVars = getTunVars(sModel)
% aggiorna la lista di variabili tunable
% sModel deve essere aperto e con il suo WSP già caricato


% Get from model the referenced workspace variables
tRefVars = get_param(sModel, 'ReferencedWSVars');
cRefVars = cell(length(tRefVars),1) ;
% Build lists
sVars = '';
sStorageClass = '';
sTypeQualifier = '';
for j = 1:length(cRefVars)
   cRefVars{j} = tRefVars(j).Name;
   sVars = [sVars, cRefVars{j}, ',']; % TunableVars
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