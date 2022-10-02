function updateMat()
% aggiunge a tutti i files mat selezionati il contenuto di un secondo file
% mat contente le aggiunte.
% Pensato per aggiornare i wsp di modelli simulink dopo l'introduzione di
% altri parametri


%
% selezione wsp da aggiornare
cWspFile = uigetfile({'*.mat','file mat (*.mat)'}, 'seleziona i files da aggiornare', 'MultiSelect','on');
if isnumeric(cWspFile) && cWspFile==0 % se premo "annulla"
   return
end
if ischar(cWspFile) % cell array dei modelli
   cWspFile = {cWspFile};
end
%
% selezione file costituente l'aggiornamento
sAddFile = uigetfile({'*.mat','file mat (*.mat)'}, 'seleziona il file di aggiornamento', 'MultiSelect','off');
tAddFile = load(sAddFile);

for i = 1:length(cWspFile)
   sWspFile = cWspFile{i};
   % aggiunta aggiornamento
   tWspFile = load(sWspFile);
   tWspFile = aggiungiCampi(tWspFile, tAddFile);
   % salvataggio
   eval(['save ', sWspFile,' -struct tWspFile'])
end


return