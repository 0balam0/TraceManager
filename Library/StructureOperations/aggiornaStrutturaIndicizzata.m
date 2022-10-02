function tOut = aggiornaStrutturaIndicizzata(tOut, tAdd)

% aggiorna la struttura indicizzata tOut(n) aggiungendo tAdd in tOut(n+1).
% tutti le varie tOut(i) vengono aggiornati metendoci dentro i campi comuni
% a tutti tOut(n+1)



% nomi dei campi della struttura da aggiungere
cF = fieldnames(tAdd);
%
for i = 1:length(tOut)
   cF = union(cF, fieldnames(tOut(i)));
end
% ordinamento alfabetico
cF = sort(cF);

% aggiornamento dei campi della struttura
for i = 1:length(tOut)
   for j = 1:length(cF)
      if not(isfield(tOut(i), cF{j}))
         tOut(i).(cF{j}) = struct();
      end
   end
end
% indice nuovo (tOut(n+1))
tOut(length(tOut)+1) = aggiungiCampi(tOut(i), tAdd);

return