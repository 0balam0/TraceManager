function cRefVars = getReferencedWSVars(sModel)
% aggiorna la lista di variabili tunable
% sModel deve essere aperto e con il suo WSP già caricato


% Get from model the referenced workspace variables
tRefVars = get_param(sModel, 'ReferencedWSVars');
cRefVars = cell(length(tRefVars),1) ;
%
for j = 1:length(cRefVars)
   cRefVars{j} = tRefVars(j).Name;
end


return