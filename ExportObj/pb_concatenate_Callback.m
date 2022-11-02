function pb_concatenate_Callback(hObject, eventdata, handles)

try
   UD = get(gcbf,'UserData');
   % selezione file di out
   [name, path] =  uiputfile('*.mat', 'select ouput file...', cd);
   if isequal(name,0) || isequal(path,0)
      return
   else
      sFile = [path, '\', name];
   end

   % blocco l'interazione dell'utente con l'interfaccia
   t0 = clock;
   hD = msgbox('exporting file...please wait', '', 'modal');


   % recupero dati utente
   tTH = UD.tTH;
   cAll = listaCanali(tTH); % get(handles.lb_avail, 'string');
   cF = fieldnames(tTH);

   %
   %%% tempo comune alle manovra da concatenare
   t_s = zeros(length(cF),1);
   tMin = zeros(length(cF),1);
   tMax = zeros(length(cF),1);
   for k = 1:length(cF)
      tTH_k = tTH.(['tTH_',num2str(k)]);
      t_s(k) = tTH_k.time.v(2) - tTH_k.time.v(1);
      [time] = applicaOffset(tTH_k.time, tTH_k.('time'));
      tMin(k) = time(1);
      tMax(k) = time(end);
   end
   t_s1 = min(t_s);
   time_i = (min(tMin):t_s1:max(tMax))';
   % time history concatenata
   tTHc.time.v = time_i;
   tTHc.time.u = 's';
   tTHc.time.d = '';

   %%% indici del tempo complessivo coperti dalle varie time-historiies
   idxOk = false(length(tTHc.time.v), length(cF));
   for k = 1:length(cF)
      tTH_k = tTH.(['tTH_',num2str(k)]);
      [time] = applicaOffset(tTH_k.time, tTH_k.('time'));
      % indici compresi
      idxOk(:,k) = tTHc.time.v>=time(1) & tTHc.time.v<=time(end);
   end

   %%% interpolazione delle grandezze sulle varie misure
   % ciclo sulle grandezze
   tTH_1 = tTH.(['tTH_',num2str(1)]);
   for i = 1:length(cAll)
       sField = cAll{i};
       if strcmpi(sField,'time')
           % non interpolo il tempo
           continue
       end
      % NaN di preallocazione
      tTHc.(sField).v = NaN * zeros(size(tTHc.time.v));
      %
      % solo se le trovo nella prima time-history
      if any(strcmpi(fieldnames(tTH_1), sField))
         try
            % riconoscimento grandezze cumulate dalle unità di misura
            bCum = any(strcmpi(tTH_1.(sField).u, {'MJ','kJ','J','mJ', 'kg','g','mg',...
               'MWh','kWh','Wh','mWh', 'Km','m','mi', 'l','ml'}));
            lastVal = 0;
            % ciclo sulle misure
            for k = 1:length(cF)
               tTH_k = tTH.(['tTH_',num2str(k)]);
               %
               [time, value] = applicaOffset(tTH_k.time, tTH_k.(sField), false);
               idx = idxOk(:,k);
               %
               tTHc.(sField).v(idx) = interp1q(time, value, tTHc.time.v(idx));
               % concatenazione cumulata dei cumulati
               if bCum
                  tTHc.(sField).v(idx) = tTHc.(sField).v(idx) + lastVal;
                  lastVal = tTHc.(sField).v(find(idx,1,'last'));
               end
               tTHc.(sField).d = tTH_k.(sField).d;
               tTHc.(sField).u = tTH_k.(sField).u;
            end
         catch Me
             dispError(Me)
            disp(['Warning: problemi nel concatenare la grandezza "', sField, '"; passo alla successiva.']);
            if isfield(tTHc, sField)
               tTHc = rmfield(tTHc, sField);
            end
         end
      end
   end
   tTH = tTHc;


   %%% salvataggio su file mat dei risultati
   save(sFile, 'tTH');

   % ripristino l'interazione utente con l'interfaccia
   while etime(clock, t0) < 0.5
   end
   delete(hD)

catch Me
    dispError(Me)
end

return