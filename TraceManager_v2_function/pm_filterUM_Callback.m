function pm_filterUM_Callback(hObject, eventdata, handles)

% visualizza nella lista delle grandezze disponibili solo quelle
% corrispondenti all'unità di misura selezionata da questo menu.

% dati utente
UserData = get(gcbf,'UserData');

% filtro le grandezze disponibili in base alle unità di misura
cSel = getListBoxSelection(hObject);
if isfield(UserData, 'tTH')
    cChan = listaCanali(UserData.tTH, cSel{1});
    % scrivo l'elenco filtrato delle grandezze
    set(handles.lb_avail, 'value',1);
    set(handles.lb_avail, 'string', cChan);
     
    
end

return

function cSel = listaCanali(tTH, varargin)
% filtra i canali disponibili dalle varie time-histories in base a quelli
% che soddisfano il filtraggio sulle unità di misura

sUnit = '(no filter)';
if not(isempty(varargin))
    % filtro sulle unità di misura
    a = strcmpi(varargin, 'units');
    if not(isempty(a))
        sUnit = varargin{a+1};
    end
    %
end

% unità di misura vuote
if strcmpi(sUnit, '(empty)')
   sUnit = '';
end

% procedura di filtraggio
cSel = {''};
cF = fieldnames(tTH);
for i = 1:length(cF)
   % i-esima time history: elimino i campi
   tTHi = tTH.(cF{i}); 
   %
   % solo grandezze (no tempo)
   % TODO: può causare problemi? Ex: per concatenazione??
   [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTHi);
   cCurr = union(cQint, cQorg);
   %
   if strcmpi(sUnit, '(no filter)')
       cCurrFilt = cCurr;
   else
       % filtraggio
       cFU = unitsList(tTHi, cCurr);
       bFilt = strcmp(cFU, sUnit);
       cCurrFilt = cCurr(bFilt);
   end
   % unione alle altre TH
   cSel = union(cSel, cCurrFilt);
end

cSel = setdiff(cSel,' ');
if strcmpi(cSel{1}, '')
    cSel = cSel(2:end);
end


return

function c = upgradeUnitsList(tTH) 

% fornisce tutte le unità di misura disponibili fra i vari files letti

% elenco unità disponibili
c = {''};
cF = fieldnames(tTH);
for i = 1:length(cF)
    %
    [cTorgSet, cQorg, cTorg, cQint] = rfSdsMain('historyTimeFields', tTH.(cF{i}));
    cQ = union(cQint, cQorg);
    %
    cFU = unitsList(tTH.(cF{i}), cQ);
    c = union(c, cFU);
end
%
% aggiorno la lista
c = c(not(strcmpi(c, '')));
c = c(not(strcmpi(c, ' ')));
cDef = {'(no filter)'; '(empty)'};
c = [cDef; c];

return

function c = unitsList(tTH, cQ)
% lista delle unità di misura associate ad una certa TH in corrispondenza
% delle grandezze cQ

c = cell(size(cQ));
for i = 1:length(cQ)
    c{i} = tTH.(cQ{i}).u; 
end

return

function [cSel, val] = getListBoxSelection(hLB)


cList = get(hLB, 'string');
val = get(hLB, 'value');
cSel = cList(val);
if ischar(cSel)
    cSel{1} = cSel;
end

return

% aggiornamento lista unità di misura disponibili
      cListUM = upgradeUnitsList(UserData.tTH);
      set(handles.pm_filterUM, 'value', 1);
      set(handles.pm_filterUM, 'string', cListUM);
      %
   % aggiornamento della lista grandezze disponibili
   pm_filterUM_Callback(handles.pm_filterUM, [], handles);
