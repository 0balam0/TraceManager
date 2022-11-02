function [varargout] = rfSdsSim(sFunc, nOut, varargin)
% raccolta di funzioni chiamabili esternamente, qua connesse alla
% simulazione dei modelli SimuLink
%
% esempio: [a,b] = rfSdsOther('prova', 10,5);
%   è come [a,b] = prova(10,5)
hFun = str2func(sFunc); 
[varargout{1:nOut}] = hFun(varargin{:}); 
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% funzioni di simulazione
%
function tTH = calcolo(tTV, tPrj, tPrjWsp, tInt, sMod, sMan, sOpt)
% esegue la simulazione del modello sMod relativamente alla manovra sMan
% con opzione sOpt e ne restituisce la struttura di time history già
% "trattata" per l'esportazione

global nVer
%---simulazione manovra con modello SimuLink compilato---
tTH = rfSdsMain('simulazione', sMod, tTV, tPrjWsp.Dt_postCalc);

%---selezione delle time history a seconda della manovra---
switch sum(nVer)
   case 429
      cExcl = {''};
   otherwise
      cExcl = {'C_alt_PQM','ClutchSts_alt'};
end
tTH = rfSdsMain('selectTH', tTH,'excl', cExcl);

switch sMan

   case {'Acceleration', 'LaunchQS', 'Elasticity', 'Overtaking', 'F2D', 'TopSpeed', 'Creeping'}
      tTH = rfSdsMain('selectTH', tTH,'excl', {'Q_olio','Q_refr','Q_met','Q_risc','v_engSS','accensioneOn'});
      % 20/01/2011 A.Piu - R2.4
      % se cambio MT non faccio vedere le grandezze dell'eladriver
      if strcmp(tPrj.trs_Type,'MT')
         tTH = rfSdsMain('selectTH', tTH,'excl', {'pos_acc_eladriver','pos_friz_eladriver','pos_brk_eladriver','gear_eladriver','grade_eladriver'});
      end

   case {'FConsCycle', 'FConsUser', 'FConsSteady'}
      tTH = rfSdsMain('selectTH', tTH,'excl', {'F_tgRAnt','F_tgRPost','v_engSS'});
      % 20/01/2011 A.Piu - R2.4
      % se cambio MT non faccio vedere le grandezze dell'eladriver
      if strcmp(tPrj.trs_Type,'MT')
         tTH = rfSdsMain('selectTH', tTH,'excl', {'pos_acc_eladriver','pos_friz_eladriver','pos_brk_eladriver','gear_eladriver','grade_eladriver'});
      end
    
    case {'DriveAway', 'MFL','PTR','PTCP','TITO','FullCustom'}
        % 20/01/2011 A.Piu - R2.4
        % nelle manovre di driveability escludo le grandezze
        % 'pos_acc','pos_friz','pos_brk','gearDriver','grade'
        % rinomino le grandezze
        % 'pos_acc_eladriver','pos_friz_eladriver','pos_brk_eladriver','gear_eladriver','grade_eladriver'
        % come 'pos_acc','pos_friz','pos_brk','gearDriver','grade' per
        % coerenza di segnali con gli altri tipi di cambio       
        if strcmp(tPrj.trs_Type,'MT')
            tTH = rfSdsMain('selectTH', tTH,'excl', {'pos_acc','pos_friz','pos_brk','gearDriver','grade'});
            tTH.pos_acc = tTH.pos_acc_eladriver;
            tTH.pos_friz = tTH.pos_friz_eladriver;
            tTH.pos_brk = tTH.pos_brk_eladriver;
            tTH.gearDriver = tTH.gear_eladriver;
            tTH.grade = tTH.grade_eladriver;
            tTH = rfSdsMain('selectTH', tTH,'excl', {'pos_acc_eladriver','pos_friz_eladriver','pos_brk_eladriver','gear_eladriver','grade_eladriver'});
        end
end

%---taglio della time history su cosa mi serve---
idx = tTH.time.v >= tTV.t_stab;
switch sMan
   case {'LaunchQS'}
      
      idx1 = tTH.pos_acc.v > 0;
      idx2 = tTH.v_eng.v < (tTV.rpmlim-100);
      a = find(idx1);
      b = find(idx2);
      idx = false(size(tTH.time.v));
      idx(a(1):b(end)) = true;
      
   case {'Acceleration','TopSpeed'}
      idx = false(size(tTH.time.v));
      a = find(tTH.pos_brk.v == max(tTH.pos_brk.v)); % i primi possono essere bassi causa inizializzazione
      idx(max(a(end)-50,1):end) = true;
end
tTH = rfSdsMain('cutTH',tTH,idx);

%---aggiunta di nuovi campi a tTH---
%
% per metanizzazione e simili
tPrjWsp = rfSdsMain('substFuel',tPrjWsp);
%
%%% modifica di alcuni campi di tTH (ex: conversioni unità di misura senza
% ricompilare i modelli)
tTH = rfSdsMain('modFieldsTH', tTH, tTV, tPrj, tPrjWsp);

%%% comuni a tutte le manovre
%
% calcolo potenze motore dalle relative coppie
cFields = fieldnames(tTH);
for i = 1:length(cFields)
   % ricerca sole coppie motore
   sC = cFields{i};
   if any(strcmpi({'C_aux', 'C_brk', 'C_brkMax', 'C_fctEst', 'C_frict', 'C_frictHot',...
                   'C_ind', 'C_indCorr', 'C_indEst', 'C_indMax', 'C_indCorrMax', 'C_indReq', 'C_mot', ...
                   'C_pmp', 'C_pmpFre','C_propDriver', 'C_propEst', 'C_engOut',},...
                   sC))
      % potenze
      sP = ['P_', sC(3:end)];
      tTH.(sP).u = 'kW';
      tTH.(sP).v = rfSdsMain('torque2power', tTH.(sC).v, tTH.v_eng.v);
      tTH.(sP).d = '';
      % energie
      sE = ['E_', sC(3:end)];
      tTH.(sE).u = 'kJ';
      tTH.(sE).v = cumtrapz(tTH.time.v, max(tTH.(sP).v,0));
      tTH.(sE).d = '';
   end
end
%
% aggiunta coppia alternatore da piano quotato (condizione per calcolare la C_cons
tIntEng.v_engTdn_i = tInt.EngineMap.v_engTdn_i;
tIntEng.C_engTdn_i = tInt.EngineMap.C_engTdn_i;
tIntEng.C_altPQM_d = tInt.EngineMap.C_altPQM_d;
tTH.C_cons = tTH.C_mot; % fittizio, serve solo per l'intepolaPQM
tTHa = interpolaPQM(tTH, tIntEng, tInt.EngineFullLoad); % interpolazione
tTH  = rmfield(tTH, 'C_cons');
tTH.C_altPQM = tTHa.pqm_C_altPQM;
delete tTHa tIntEng

% altre grandezze
tTH = rfSdsMain('addFieldsTH', tTH,{'m_f','V_f','pme','C_frictHot', 'C_frictMotor','C_indMax', 'C_indCorrMax', 'C_brkMax','C_cons'...
                                    'p_ambT','p_ambVSat','UR_amb', 'P_gbxIn','P_gbxOut','P_fdOut', 'eff_mechTransm','eff_transm'}, tTV, tPrj, tPrjWsp);                        
% calcolo altre potenze motore dalle relative coppie ora appena calcolate
cFields = fieldnames(tTH);
for i = 1:length(cFields)
   % ricerca sole coppie motore
   sC = cFields{i};
   if any(strcmpi({'C_brkMax', 'C_frictHot', 'C_indMax', 'C_indCorrMax', 'C_indReq'},...
                   sC))
      % potenze
      sP = ['P_', sC(3:end)];
      tTH.(sP).u = 'kW';
      tTH.(sP).v = rfSdsMain('torque2power', tTH.(sC).v, tTH.v_eng.v);
      tTH.(sP).d = '';
      % energie
      sE = ['E_', sC(3:end)];
      tTH.(sE).u = 'kJ';
      tTH.(sE).v = cumtrapz(tTH.time.v, max(tTH.(sP).v,0));
      tTH.(sE).d = '';
   end
end
%
% 20/01/2011 A.Piu - R2.4
% Riporto la grandezza V_comb per tutte le manovre
% V_comb sarà usata solo per i consumi IVECO e a velocità costante 
% V_comb e m_CO2 sono calcolate in accordo EU4
tTH = rfSdsMain('addFieldsTH', tTH,{'V_comb','m_CO2'},  tTV, tPrj, tPrjWsp);

%%% differenziati per manovra
switch sMan
   case {'Acceleration','Elasticity','Creeping'}
      tTH = rfSdsMain('addFieldsTH', tTH,{'jerk_veh'},  tTV, tPrj, tPrjWsp);
   case {'FConsCycle', 'FConsUser'}
      tTH = rfSdsMain('addFieldsTH', tTH,{'E_veh','loadFactor_veh','load_ind'}, tTV, tPrj, tPrjWsp);
   case {'FConsSteady'}
   otherwise
end

%%% differenziati per modello
if strcmpi(tPrj.trs_Type, 'AT')
   tTH = rfSdsMain('addFieldsTH', tTH,{'capacityFactor_tqCnv_um2', 'slipRatio_tqCnv'}, tTV, tPrj, tPrjWsp);                        
end

%%% aggiunta delle time-Histories "statiche", cioè quelle rilevabili da
%%% piano quotato motore a pari giri e coppia della simulazione
tTHpqm = interpolaPQM(tTH, tInt.EngineMap, tInt.EngineFullLoad);
tTH = aggiungiCampi(tTH, tTHpqm);

%---reset di alcune grandezze integrali di tTH a zero a inizio simulazione---
tTH = resetTH(tTH, {'s_veh', 'E_dissFriz', 'E_dissFriz1', 'E_dissFriz2', 'E_veh', 'Q_met', 'Q_olio', 'Q_refr', 'Q_risc',...
                    'V_comb', 'loadFactor_veh', 'm_comb', 'm_CO2'});

%---filtraggio di alcuni campi di tTH---
tTH = rfSdsMain('filtTH', tTH,{'dvdt_veh','jerk_veh'}, [2,2]);

%---arrotondamento di alcuni campi di tTH---
% per ora lo escludo x evitare problemi di ascisse non distinte; servirebbe
% per esportazione time histories su XLS...
% tTH = rfSdsMain('roundTH', tTH);
return
%
function tTH = simulazione(sModel, tWsp, Dt_postCalc)

[sPath, sModelName, sModelExt] = fileparts(sModel);

switch sModelExt
   
   case {'.exe',''}
   
   % SIMULAZIONE dà le time history della simulazione di un modello
   % Simulink raccolte in una struttura. 
   % sModel è il nome del modello da simulare (ex: '2DOF_MT') e tWsp è una
   % struttura i cui nomi dei campi hanno i nomi delle variabili da tunare
   % (ex: tWsp.mpre = 1560)
   %
   % funzioni richiamate: scData2tTH; fillMissingUM
   %
   % nomi dei files che intervengono nella simulazione
   
   
   sModelName = sModelName(length('exe_')+1:end); 
   tmpFile = fullfile(sPath, ['tmp_',sModelName,'.mat']);
   parFile = fullfile(sPath, ['par_',sModelName,'.mat']);
   exeFile = fullfile(sPath, ['exe_',sModelName,'.exe']);
   exeFileMat = fullfile(sPath, ['exe_',sModelName,'.mat']);
   %
   % controllo esistenza modelli
   if not(exist(parFile,'file')) 
      disp(['Error: couldn''t find model file "',parFile,'"'])
   end
   if not(exist(exeFile,'file'))
      disp(['Error: couldn''t find model file "',exeFile,'"'])
   end
   %
   % tuning dei parametri per la simulazione corrente
   tPar = load(parFile);
   parameters_Simulation = tPar.parameters_Simulation;
   %ciclo sui DataType
   for i = 1:length(tPar.parameters_Simulation.parameters) 
      %ciclo sulle variabili di un DataType
       for j = 1:length(tPar.parameters_Simulation.parameters(i).map) 
          varName = tPar.parameters_Simulation.parameters(i).map(j).Identifier; %nome della variabile da tunare
          if isfield(tWsp,varName)
             var = tWsp.(varName);
             % controllo se il parametro è numerico o logico
             if isfloat(var) || isinteger(var) || islogical(var)
                % controllo nel parametro non ci sono NaN
                if not(any(isnan(var)))
                   % tuning: in caso di array posso avere errori se compilo con dimensioni trasposte
                   if not(isempty(var))
                      try
                         try
                            parameters_Simulation = rsimsetrtpparam(parameters_Simulation, varName, var); % modifica della struttura con il valori da tunare
                         catch
                            parameters_Simulation = rsimsetrtpparam(parameters_Simulation, varName, var'); % modifica della struttura con il valori da tunare
                         end
                      catch ME
                         disp(['Errore nel tunare il parametro ', varName,': ' ME.message]);
                      end
                   else
                      disp(['Errore: funzione "simulazione" nel file "', mfilename, '.m": il parametro numerico o logico "', varName,'" è vuoto'])
                   end
                else
                   disp(['Errore: funzione "simulazione" nel file "', mfilename, '.m": il parametro numerico o logico "', varName,'" contiene NaNs'])
                end
             else
                disp(['Errore: funzione "simulazione" nel file "', mfilename, '.m": il parametro "', varName,'" non è di tipo numerico o logico'])
             end
          else
             disp(['Warning: funzione "simulazione" nel file "', mfilename, '.m": non tunato il parametro "', varName,'" perchè non presente nel wsp'])
          end
       end
   end
   save(tmpFile,'parameters_Simulation');
   %
   % simulazione con l'eseguibile
   t0 = clock;
   fprintf('%s', ['Simulazione del modello "',exeFile,'" in corso... '])
   [nOutSim, sOutSim] = system([exeFile,' -p ',tmpFile,' -tf ',num2str(tWsp.t_tot + tWsp.t_stab)]);
   %
   tTH = struct();
   switch nOutSim
      
      case 0
         % eseguibile ha girato correttamente
         %
         t1 = clock;
         fprintf('%s\n', ['...simulazione completata in ',num2str(arrotonda(etime(t1,t0),0.01)),' s.'])
         % passaggio dalla struttura dei dati degli scope a quella delle time
         % history
         tRec = load(exeFileMat);
         tTH = scData2tTH(tRec, Dt_postCalc);
         tTH = fillMissingUM(tTH); % riempio campi senza unità di misura con '-'
      
      otherwise
         % eseguibile non ha girato correttamente
         fprintf('%s\n%s\n', '...simulazione fallita; descrizione errore: ', sOutSim)
         if not(isempty(strfind(sOutSim, 'Error: Memory allocation error')))
            fprintf('%s%s\n', 'La simulazione richiede una quantità di memoria fisica correntemente non disponibile sulla macchina: ',...
                              'provare a chiudere altri processi attivi, a diminuire il sample time di esportazione della manovra (se disponibile) o a ridurne la durata.')
         end
   end
   
   case '.mdl'
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Modifiche per simulazione Aperta

   % memorizzo e cancello il wsp base vecchio
   tWspBaseOld = wsp2struct('wsp','current');
   evalin('base', 'clear')
   %
   % carico le variabili necessarie ai modelli Simulink nel wsp base (solo lì va bene)
   assignin2('base', tWsp)
   % simulazione
   close_system('SimuDynSBlockset.mdl')
   close_system(sModel)
   sPathMdl = fileparts(sModel);
   sSearchPath = addpath(sPathMdl);
   sim(sModel)
   path(sSearchPath);
   % raccolta out da variabile
   % cercare tutte le variabili che iniziano con "sc" e sono strutture e
   % metterle come campi di tRec
   %
   % ripristino il wsp base originale
   tRec = wsp2struct('wsp','current', 'nameInclude', {'sc'}, 'classInclude','struct');
   tTH = scData2tTH(tRec, Dt_postCalc);
   tTH = fillMissingUM(tTH); % riempio campi senza unità di misura con '-'

   evalin('base', 'clear')
   assignin2('base', tWspBaseOld)

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% funzioni di trattamento time history
%
function tTH = scData2tTH(tRec, Dt_postCalc)
%
% SCDATA2TTH trasforma le registazioni sotto forma di struttura dei vari scope di un modello
% SimuLink, tutti contenuti nella struttura "tRec", in una struttura "tTH" di time histories
% con i nomi dei campi pari ai nomi dei segnali acquisiti
%
% sintassi:
% tTH = rtData2tTH(tRec); scrive tutti i segnali registrati
% tTH = rtData2tTH(tRec, cSigNames); scrive i soli segnali indicati nel
% cell array cSigNames; esempio: cSigNames = {'dvdt_veh','v_eng'}
%
% funzioni richiamate: separaNomeSegnale

%---controllo l'unicità del sample time dei vari scope di registrazione---
cScNames = fieldnames(tRec);
% escludo gli scope non attivati, che non contengono dati ma compaiono
% comunque come strutture
a = 0;
nSc = length(cScNames); % numero di scopes
cScNames0 = cScNames;
for i = 1:nSc
   % il prefisso rt_ è appiccicato al nome della variabile solo se la
   % simulazione deriva da un exe, altrimenti no (modello open)
    if ((length(cScNames{i})>=5 && strcmp(cScNames{i}(1:5),'rt_sc')) || (length(cScNames{i})>=2 && strcmp(cScNames{i}(1:2),'sc')))...
          && isfield(tRec.(cScNames{i}), 'time') && not(isempty(tRec.(cScNames{i}).time))
        a = a+1;
        cScNames0{a} = cScNames{i};
    end
end
cScNames = cScNames0(1:a);
nSc = length(cScNames);
%
% numero di segnali nei vari scopes
nSig = zeros(nSc,1);
for i = 1:nSc
    nSig(i) = length(tRec.(cScNames{i}).signals);
end
%
% raccolta tempi di campionamento
Dt = zeros(nSc,1);
timeSet = cell(Dt,1); 
for i = 1:nSc 
    time = tRec.(cScNames{i}).time;
    timeSet{i} = time;
    tT.(cScNames{i}).time = time;
    Dt(i) = chop(mean(diff(time)), 4);
end
%
% individuazione dei set di tempi di campionamento
DtSet = sort(unique(Dt));
%
% ciclo sui tempi di campionamento
for i = 1:length(DtSet) 
    idx = find(Dt == DtSet(i)); % individuo quali scopes hanno il sample time corrente
    %
    % tempo di riferimento
    sFT = ['time_', num2str(i)];
    % scrivo campo del tempo
    tTH.(sFT).('xAxis') = ''; % serve?
    tTH.(sFT).('label') = ['sampling time n° ', num2str(i)];
    tTH.(sFT).('v') = [];
    tTH.(sFT).('u') = 's';
    tTH.(sFT).('d') = 'Tempo di simulazione';
    tTH.(sFT).('Dt') = Dt(i);
    %
    tTH.(sFT).('xAxis_org') = '';
    tTH.(sFT).('v_org') = timeSet{idx(1)};
    %
    % ciclo sugli scopes con tempo di campionamento corrente
    for j = 1:length(idx)
        %
        idx1 = idx(j);
        sSc = cScNames{idx1};
        
        % ciclo sui segnali dello scope (al tempo di campionamento corrente)
        for k = 1:nSig(idx1)
            % nome e unità di misura
            [sN, sU] = separaNomeSegnale(tRec.(sSc).signals(k).label(2:end-1));
            % nome campo
            sF =  validField(sN, '_');
            % nome tempo di riferimento
            tTH.(sF).('xAxis') = 'time'; % serve?
            tTH.(sF).('label') = sN;
            tTH.(sF).('v') = [];
            tTH.(sF).('u') = sU;
            tTH.(sF).('d') = descrizTH(sN);
            tTH.(sF).('Dt') = [];
            %
            tTH.(sF).('xAxis_org') = sFT; % ex: 'time_2'
            tTH.(sF).('v_org') = tRec.(sSc).signals(k).values;
        end
    end
end

% interpolo le time-history al Dt_postCalc sample time (quello per fare in
% i calcoli, ex: estrazione dei points)
tTH = interpolaTH(tTH, Dt_postCalc);

return
%
function [sS, sU] = separaNomeSegnale(sSU)
% ex: sSU = 'v_eng [rpm]' --> sS = 'v_eng'; SU = 'rpm'
pos1 = strfind(sSU,'[');
pos2 = strfind(sSU,']');
if isempty(pos1) || isempty(pos2)
    sS = sSU;
    sU = '';
else
    sS = deblank(sSU(1:pos1-1));
    sU = sSU(pos1+1:pos2-1);
end
return
%
function tTH = fillMissingUM(tTH)
% riempie con '-' i campi delle unità di misura della time history lasciati
% vuoti (serve per fare i correttamente i grafici Excel da file ascii
% esportato .hst)

cFNames = fieldnames(tTH);
for i=1:length(cFNames)
   if isempty(tTH.(cFNames{i}).u)
      tTH.(cFNames{i}).u = '-';
   end
end
return
%
function tTH = cutTH(tTH,idx)
% taglia la struttura di time histories (tipicamente creata dalla
% simulazione), prendendone i soli indici idx
% ciclo sui campi di tTH (ex: time, speed...)

% tempi a cui corrisponde l'inzio taglio dei dati
if islogical(idx)
    idx = double(idx);
end
vIdx = find(idx);
tStart = tTH.('time').v(vIdx(1));
tEnd = tTH.('time').v(vIdx(end));

% racolta infos su grandezze
[cFTset, cFQ, cFQtime] = historyTimeFields(tTH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% grandezze su base TEMPO INTERPOLATO
%
% estrazione grandezze all'intervallo selezionato
for i = 1:length(cFQ)
    tTH.(cFQ{i}).v = tTH.(cFQ{i}).v(vIdx);
end
% reset del tempo
tTH.('time').v = tTH.('time').v(vIdx) - tStart;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% grandezze su base TEMPO ORIGINALE
%
% cicli sui vari sample time
for i = 1:length(cFTset)
    
    time_org = tTH.(cFTset{i}).v_org;
    
    % grandezze al sample time corrente
    bSt = strcmpi(cFQtime, cFTset{i});
    cFcurr = cFQ(bSt); 
    %
    % indivuazione indici corrispondenti al tempo di taglio
    vIdx = time_org>=tStart & time_org<=tEnd;
    %
    % taglio delle grandezze al sample time corrente
    for j = 1:length(cFcurr)
        tTH.(cFcurr{j}).v_org = tTH.(cFcurr{j}).v_org(vIdx);
    end
    %
    % reset del tempo
    tTH.(cFTset{i}).v_org = time_org(vIdx) - tStart;
end

return
%
function tOut = addTH(tIn, tAdd, idx, bFirst)

cF = fieldnames(tAdd);

for i = 1:length(cF)
   sF = cF{i};
   if strcmpi(sF, 'time')
      continue
   end
   % aggiunta di campo nuovo
   if bFirst && not(isfield(tIn, cF{i}))
      % preallocazione iniziale con NaN
      tIn.(sF).v = NaN * ones(size(tIn.time.v));
   end
   tIn.(sF).v(idx) = tAdd.(sF).v;
   tIn.(sF).u = tAdd.(sF).u;
   tIn.(sF).d = tAdd.(sF).d;
end
%
tOut = tIn;

return
%
function tIn = resetTH(tIn, cFields)
% resetta i campi indicati in ingresso cFields a zero al primo istante di
% simulazione, ad esempio lo spazio percorso dall'auto

% copio tutti i campi, resetto solo quelli specificati
%
fNames = fieldnames(tIn);
cFieldsCut = intersect(fNames,cFields);
if isempty(cFieldsCut)
   disp('funzione "resetTH" in rfSdsSim: nessun campo fra quelli indicati è presente nella struttura delle time history')
   return
end
% ciclo sui campi comuni (da resettare)
for i = 1:length(cFieldsCut)
    sF = cFieldsCut{i};
    tIn.(sF).v = tIn.(sF).v - tIn.(sF).v(1);
    if isfield(tIn.(sF), 'v_org')
        tIn.(sF).v_org = tIn.(sF).v_org - tIn.(sF).v_org(1);
    end
end

return
%
function tIn = selectTH(tIn, sOption, cFields)
% seleziona la struttura in ingresso tIn, scrivendo nella struttura in
% uscita tOut i campi risultanti dall'opzione sOption scelta.
% Se sOption vale 'excl', sono esclusi da tOut i campi contenuti in
% cFields; se sOption vale 'incl', sono inclusi in tOut i soli campi
% contenuti in cFields
%
% tOut = struct;
fNames = fieldnames(tIn);

% sOption per ora è solo excl
switch sOption
    case 'incl'
    case 'excl'
end

% rimuovo i campi
cFields = intersect(fNames, cFields); % soli campi disponibili possono essere rimossi
if not(isempty(cFields))
    tIn = rmfield(tIn, cFields);
end

return
%
function writeTHascii(fileName,tTH, varargin)
% scrive nel file ascii "fileName" la time history tTH derivante da una
% simulazione di un modello SimuDynS. Nomi grandezze e unità di misura
% devono già essere contenute in tTH.
% In varargin{1} posso indicare un sottinsieme di grandezze da salvare; 
% in questo caso si conserva l'ordine di esportazione grandezze coincide
% con quello indicato
%
% Esempio di tTH: 
% tTH.time.v = [0 0.2 0.4 0.6];
% tTH.time.u = 's';
% tTH.speed.v = [40 41 12 43];
% tTH.speed.u = 'km/h';

%---preparazione formato---
% gestione varargin per decidere se devo ordinare i nomi grandezze per
% esportazione su file
if not(isempty(varargin))
   % prendo grandezze specificate dall'esterno e ne conservo l'ordine
   cQ = varargin{1}; 
else
   % di default ordino i nomi
   cQ = sort(fieldnames(tTH));
   % metto il tempo nella prima colonna
   posT = find(strcmpi(cQ,{'time'})); 
   if not(isempty(posT))
       cQ = [cQ(posT); cQ(1:posT-1); cQ(posT+1:end)];
   end
end
%
%---preparazione dati---
mTH = zeros(length(tTH.(cQ{1}).v),length(cQ)); %dimensioni trasposte
cU = cell(1,length(cQ));
for i = 1:length(cQ)
    cU{i} = tTH.(cQ{i}).u; % cell array delle unità di misura
    mTH(:,i) = tTH.(cQ{i}).v; % matrice dei valori
end
cIntest = [cQ(:)'; cU(:)'];
%
%---scrittura su file---
fid = fopen(fileName, 'w');
% intestazione
writeCellAscii(fid, cIntest, '\t', '');
% dati
writeMatAscii(fid, mTH, '%f', '\t', '');
%
fclose(fid);
return
%
function writePerfFile(sFile, tInfo, cIntest, mDati, varargin)

% scrive il file "sFile" usando formato di Perfects (ex: .PQM, .PED,
% .CM...).
%
% argomenti opzionali
% newFormat: ['true','false']: se true (default) usa il formato a sezioni, se old
%         scrive i soli dati e intestazioni senza struttura di informazioni

% gestione varargin
bNewFormat = 'true';
if not(isempty(varargin))
   i = find(strcmpi(varargin(:),'newFormat'));
   if not(isempty(i))
      bNewFormat = varargin{i+1};
   end
end

%%% scrittura file
sFileCut = cutFileName(sFile); % eventuale troncatura file lunghi 
if not(strcmpi(sFileCut,sFile))
   [dum, s1, sExt1] = fileparts1(sFile);
   [dum, s2, sExt2] = fileparts1(sFileCut);
   disp(['Warning: original file name "', [s1 sExt1],'" will be cut to "', [s2 sExt2], '" because of Windows maximum path length limitation."'])
end
fid = fopen(sFileCut, 'w');
if fid == -1
   % impossibile aprire il file
   disp(['Warning: file "',sFileCut,'" will not be written because of problems in opening file. Make sure the file is not already opened by some other application.'])
   return
end

if bNewFormat
   %%% sezione informazioni
   % start
   fprintf(fid, '%s\r\n', '<Info>');
   % informazioni
   rfSdsMain('writeStructAscii', fid, tInfo, '%f', '\t', '');
   % end
   fprintf(fid, '%s\r\n', '</Info>');
   %
   %%% sezione dati
   % start
   fprintf(fid, '%s\r\n', '<Dati>');
   % intestazione
   rfSdsMain('writeCellAscii', fid, cIntest, '\t', '');
   % dati
   rfSdsMain('writeMatAscii', fid, mDati, '%f', '\t', '');
   % end
   fprintf(fid, '%s', '</Dati>');
else
   %%% sezione informazioni
   if isempty(cIntest{1}) && isempty(mDati)
      % informazioni
      rfSdsMain('writeStructAscii', fid, tInfo, '%f', '\t', '');
   elseif isempty(tInfo)
      %%% dati
      % intestazione
      rfSdsMain('writeCellAscii', fid, cIntest, '\t', '');
      % dati
      rfSdsMain('writeMatAscii', fid, mDati, '%f', '\t', '');
   end
end
%
fclose(fid);
return
%
function sFileOut = cutFileName(sFileIn)
% tronca il nome completo del file in ingresso alla massima lunghezza gestita da
% Windows (256 caratteri)

if length(sFileIn) >= 256 
   [sPath, sName, sExt] = fileparts1(sFileIn);
   sName1 = sName(1:256-(length(sPath)+1+length(sExt)));
   sFileOut = [sPath, '\', sName1, sExt];
%    disp(['Attenzione: il file "', sName,sExt, '"', char(13), ' verrà troncato in "', sName1,sExt, '"',char(13),...
%         ' causa limiti Windows nella gestione di file dal nome troppo lungo'])
else
   sFileOut = sFileIn;
end

return
%
function count = writeCellAscii(fid, cIn, sDel, sDelStart)

% scrive il cellArray cIn sul file di testo fid usando come separatore la
% stringa sDel (ex: '\t'), come inizio riga sDelStart (ex: '\t' o '') 

%
[r,c] = size(cIn);
sF1 = '%s'; % stringa
sEnd = '\r\n'; % terminatore di riga
%
%%% crezione della stringa per la formattazione del testo sul file
sFormat = formatoRiga(c, sF1, sDel, sDelStart, sEnd);
%
% scrittura su file
cIn_t = cIn'; % traspongo perchè fprintf prende la matrice per colonne
count = fprintf(fid, sFormat, cIn_t{:}); % verifica: s = sprintf(sFormat, cIn_t{:})
return
%
function count = writeMatAscii(fid, mIn, sNum, sDel, sDelStart)

% scrive la matrice numerica mIn sul file di testo fid usando come separatore la
% stringa sDel (ex: '\t'), come inizio riga sDelStart (ex: '\t' o '') 
% e come formato la stringa sNum (ex: '%6.3f')

%
[r,c] = size(mIn);
sEnd = '\r\n'; % terminatore di riga
%
%%% crezione della stringa per la formattazione del testo sul file
sFormat = formatoRiga(c, sNum, sDel, sDelStart, sEnd);
%
%%% scrittura su file
mIn_t = mIn'; % traspongo perchè fprintf prende la matrice per colonne
count = fprintf(fid, sFormat, mIn_t); % verifica: s = sprintf(sFormat, mIn_t)
return
%
function writeStructAscii(fid, tIn, sNum, sDel, sDelStart)

% scrive la matrice numerica mIn sul file di testo fid usando come separatore la
% stringa sDel (ex: '\t'), come inizio riga sDelStart (ex: '\t' o '')
% e come formato la stringa sNum (ex: '%6.3f')

%
cFields = fieldnames(tIn);
sEnd = '\r\n'; % terminatore di riga
%
%%% crezione della stringa per la formattazione del testo sul file
% sFormat = formatoRiga(nElem, sF, sDel, sDelStart, sEnd)
sFormatField = formatoRiga(1, '%s', sDel, sDelStart, '');
sFormatStr = formatoRiga(1, '%s', sDel, sDel, sEnd);
sFormatNum = formatoRiga(1, sNum, sDel, sDel, sEnd);
%
%%% scrittura su file
for i = 1:length(cFields)
   val = tIn.(cFields{i});
   if not(isnumeric(val))
      % valori stringhe
      fprintf(fid, [sFormatField sFormatStr], cFields{i},val); % sprintf([sFormatField sFormatStr], cFields{i},val)
   else
      % valori numerici
      [r,c] = size(val);
      if r==1 && c==1
         % scalari
         fprintf(fid, [sFormatField sFormatNum], cFields{i},val); % sprintf([sFormatField sFormatNum], cFields{i},val)
      elseif r>1 && c==1 || r==1 && c>1
         % vettori
         sFormatVect = formatoRiga(max(r,c), sNum, sDel, sDel, sEnd);
         fprintf(fid, [sFormatField sFormatVect], cFields{i},val); % sprintf([sFormatField sFormatVect], cFields{i},val)
      elseif r>1 && c>1
         % matrici: TODO: vedere cosa fa mat2str
         sFormat1 = [sDel, '[', formatoRiga(c, sNum, sDel, '', ''), ';']; % prima riga
         sFormatCentr = [sDel, formatoRiga(c, sNum, sDel, '',''), ';']; % righe centrali
         sFormatEnd = [sDel, formatoRiga(c, sNum, sDel, '', ''), ']', sEnd]; % ultima riga
         sFormatMatr = char(zeros([1,length(sFormat1) + length(sFormatCentr)*(r-2)+ length(sFormatEnd)],'int8')); 
          % metto tutta la matrice in una sola riga: preparo il formato
         sFormatMatr(1:length(sFormat1)) = sFormat1;
         idx = length(sFormat1) + (1:1:length(sFormatCentr));
         for j = 1:r-2
            sFormatMatr(idx) = sFormatCentr;
            idx = idx + length(sFormatCentr);
         end
         sFormatMatr(end-length(sFormatEnd)+1:end) = sFormatEnd;
         fprintf(fid, [sFormatField sFormatMatr], cFields{i},val'); % sprintf([sFormatField sFormatMatr], cFields{i},val')
      end
   end
   
end


return
%
function sFormat = formatoRiga(nElem, sF, sDel, sDelStart, sEnd)

% crea la stringa sFormat per la scrittura su file con fprintf (e sprintf)

sFormat = char(zeros([1,length(sF)*nElem + length(sDel)*nElem], 'int8')); 
i2 = 0;
for i = 1:nElem
   i1 = i2(end)+1:i2(end)+length(sF); % ex: [1 2]     [5 6]
   i2 = i1(end)+1:i1(end)+length(sDel); % ex:     [3 4]     [7 8]
   sFormat(i1) = sF;
   sFormat(i2) = sDel;
end
% inizio riga
if not(isempty(sDelStart))
   sFormat(1+length(sDelStart):end+length(sDelStart)) = sFormat;
   sFormat(1:length(sDelStart)) = sDelStart;
end
% tolgo ultimo delimitatore standard
sFormat = sFormat(1:end-length(i2)); 
% fine riga
sFormat(end+1:end+length(sEnd)) = sEnd; 

return
%
function tTH = modFieldsTH(tTH, tTV, tPrj, tPrjWsp)

global nVer

%%% conversione dei pedali in percentuale
% acceleratore
sField = 'pos_acc';
if isfield(tTH,sField) && strcmp(tTH.(sField).u, '-')
   tTH.(sField).v = tTH.(sField).v*100;
   tTH.(sField).u = '%';
end
% freno 
sField = 'pos_brk';
if isfield(tTH,sField) && strcmp(tTH.(sField).u, '-')
   tTH.(sField).v = tTH.(sField).v*100;
   tTH.(sField).u = '%';
end
% frizione
sField = 'pos_friz';
if isfield(tTH,sField) && strcmp(tTH.(sField).u, '-')
   tTH.(sField).v = tTH.(sField).v*100;
   tTH.(sField).u = '%';
end

%%% gestione della metanizzazione / gpllizzazione
if tPrjWsp.metanizz > 0
   % converto la TH di massa a benzina in TH di massa a metano G20
   % TODO: per gpl cambia la costante 0.78
    % conversione della CO2 a benzina in CO2 a metano, agisce su massa e
    % poi in seguito su CO2
   k =  tPrjWsp.k_CO2toCO2 * tPrjWsp.k_f2CO2_BZ/tPrjWsp.k_f2CO2;
   cFields = {'m_comb','dmdt_comb','m_f','m_fTot'};
   for i = 1:length(cFields)
      if isfield(tTH,cFields{i})
         tTH.(cFields{i}).v = k * tTH.(cFields{i}).v;
      end
   end
end

% %%% allineamento con CHR delle grandezze di coppia motore in attesa di
% %%% rifacimento modello alternatore NON differenziale
% % TODO: togliere appena ci sono i modelli nuovi di impianto elettrico NON differenziali
% c = {'C_brk', 'C_brkMaxEnv','C_ind','C_indCorr'};
% if isfield(tTH, 'C_alt_PQM')
%    for i = 1:length(c)
%       sF = c{i};
%       tTH.(sF).v = tTH.(sF).v + tTH.('C_alt_PQM').v;
%    end
% end


return
%
function tTH = steadyFieldsTH(v_eng, C_mot, tInt, tPrj, tPrjWsp, cExcl)

%%% interpolazione delle grandezze derivanti dalle interpolazioni delle mappe
% impiegate in Perfects sulla time-history di una simulazione, per ora
% limitata alle sole grandezze inserite da piano quotato

% estrazione delle sole grandezze dipendenti e con dimensione pari
% all'atteso
r =  length(tInt.EngineMap.C_engTdn_i.v);
c = length(tInt.EngineMap.v_engTdn_i.v);
cFields = fieldnames(tInt.EngineMap);
bD = false(size(cFields));
for i = 1:length(cFields)
   bD(i) = strcmp(cFields{i}(end-1:end), '_d') && ...
      r == size(tInt.EngineMap.(cFields{i}).v,1) && c == size(tInt.EngineMap.(cFields{i}).v,2);
end
cFieldsD = cFields(bD);
cFieldsD = setdiff(cFieldsD, cExcl);

% interpolazione delle mappe
v_eng = min(max(tInt.EngineMap.v_engTdn_i.v), max(v_eng, min(tInt.EngineMap.v_engTdn_i.v)));
C_mot = min(max(tInt.EngineMap.C_engTdn_i.v), max(C_mot, min(tInt.EngineMap.C_engTdn_i.v)));
for i = 1:length(cFieldsD)
   sName = [cFieldsD{i}(1:end-2), '_PQM'];
   tTH.(sName).v = interp2(tInt.EngineMap.v_engTdn_i.v, tInt.EngineMap.C_engTdn_i.v, tInt.EngineMap.(cFieldsD{i}).v, v_eng, C_mot);
   tTH.(sName).d = '';
   tTH.(sName).u = '';
end
return
%
function tTH = addFieldsTH(tTH, cFields, tTV, tPrj, tPrjWsp) 
% aggiunge alla struttura tTH i campi indicati in cFields calcolandoli a
% partire dalle grandezze già esistenti in tTH.
% se sono necessarie altre variabili per il cacolo delle grandezze
% richieste, queste sono passate nella struttura nel primo campo di
% varargin come struttura tVar

% calcolo
fNames = fieldnames(tTH);
for i = 1:length(cFields)
   try
        fNames{end+1} = cFields{i}; % aggiungo il campo appena creato all'elenco delle grandezze disponibili
        % calcolo delle grandezze richieste
        switch cFields{i}
            case 'pme'
                tTH.(cFields{i}).u = 'bar';
                tTH.(cFields{i}).v = tTH.('C_mot').v/(tPrjWsp.('cilind')*30/(1.2*pi));
            case 'm_CO2'
                tTH.(cFields{i}).u = 'g';
                tTH.(cFields{i}).v = tTH.('m_comb').v * tPrjWsp.k_f2CO2; %
            case 'C_frictHot'
                tTH.(cFields{i}).u = 'Nm';
                tTH.(cFields{i}).v = interp2(tTV.('T_oilFric_i'), tTV.('v_engPQM_i'), tTV.('C_fricENG_d'), tTV.('Tfin')+4, tTH.('v_eng').v);
                % saturazione (evito di vedere surriscaldamento olio
                % rispetto al PQM)
                tTH.(cFields{i}).v = min(tTH.(cFields{i}).v, tTH.('C_frict').v);
             case 'C_frictMotor'
                tTH.(cFields{i}).u = 'Nm';
                tTH.(cFields{i}).v = tTH.('C_frict').v + tTH.('C_pmp').v;
            case 'C_indMax'
                %
                % coppia nominale massima lungo la manovra in condizioni stazionarie, da C_brkFL_d(v_engFL_i)
                C_brkMaxNom = zeros(size(tTH.('time').v));
                a = tTH.('v_eng').v < tTV.v_engFL_i(1);
                b = tTH.('v_eng').v >= tTV.v_engFL_i(1) & tTH.('v_eng').v <= tTV.v_engFL_i(end);
                c = tTH.('v_eng').v > tTV.v_engFL_i(end);
                C_brkMaxNom(a) = tTV.C_engFL_d(1);
                C_brkMaxNom(b) = interp1(tTV.v_engFL_i, tTV.C_engFL_d, tTH.('v_eng').v(b));
                C_brkMaxNom(c) = tTV.C_engFL_d(end);
                C_brkMaxNom = min(C_brkMaxNom, interp1(tTV.gears_i, tTV.Tgbx, tTH.('gearCurr').v)); % limitazione cambio
                %
                % coppia indicata massima lungo il ciclo, somma di coppia
                % utile nominale massima e friction a caldo a motore
                % rodato (qua approssimate con C_frictHot, che in realtà
                % sono maggiori perchè al kilometraggio della manovra corrente)
                tTH.(cFields{i}).u = 'Nm';
                tTH.(cFields{i}).v = C_brkMaxNom + tTH.('C_frictHot').v;
            case 'C_indCorrMax'
                % coppia indicata corretta (con pompaggio) massima lungo il ciclo
                tTH.(cFields{i}).u = 'Nm';
                tTH.(cFields{i}).v = tTH.('C_indMax').v + tTH.('C_pmp').v;
            case 'C_brkMax'
                % coppia massima utile erogabile lungo la manovra in condizioni stazionarie, da C_indMax
                tTH.(cFields{i}).u = 'Nm';
                tTH.(cFields{i}).v = tTH.('C_indMax').v - tTH.('C_frict').v;
            case 'C_cons'
                % delta coppia rispetto al PQM (simulazione - PQM)
                DC = (tTH.C_frict.v - tTH.C_frictHot.v) + ... % warm-up motore
                     (tTH.C_engRsv.v) + ... % riserva di coppia
                     (tTH.C_pmpFre.v - 0) + ... % freno motore a valvola di scarico
                     (tTH.C_alt.v - tTH.C_altPQM.v) + ... % alternatore
                     (tTH.C_addAux.v - 0) + ... % altri ausiliari (ex: da missione)
                     (tTH.CoppiaMeccanicaCompressore.v - 0) + ... % compressore AC
                     (tTH.C_powerSteering.v - 0) + ...% servosterzo
                     (tTH.C_mechFan.v - 0); % ventola meccanica (IVECO)
                % coppia consumi
                tTH.(cFields{i}).u = 'Nm';
                tTH.(cFields{i}).v = tTH.('C_mot').v + DC;
            case 'P_fdOut'
                tTH.(cFields{i}).u = 'kW';
                tTH.(cFields{i}).v = rfSdsMain('torque2power', tTH.('C_fdOut').v, tTH.('v_fdOut').v);
            case 'P_gbxIn'
                tTH.(cFields{i}).u = 'kW';
                if isfield(tTH,'C_gbxIn1') && isfield(tTH,'C_gbxIn2') 
                   % trasmissioni DCT
                   tTH.(cFields{i}).v = rfSdsMain('torque2power', tTH.('C_gbxIn1').v, tTH.('v_gbxIn1').v) + ...
                                        rfSdsMain('torque2power', tTH.('C_gbxIn2').v, tTH.('v_gbxIn2').v);
                elseif isfield(tTH,'C_gbxIn') && isfield(tTH,'v_gbxIn')
                   % altre
                   tTH.(cFields{i}).v = rfSdsMain('torque2power', tTH.('C_gbxIn').v, tTH.('v_gbxIn').v);
                else
                   tTH.(cFields{i}).v = zeros(size(tTH.time.v));
                end
            case 'P_gbxOut'
                tTH.(cFields{i}).u = 'kW';
                tTH.(cFields{i}).v = rfSdsMain('torque2power', tTH.('C_gbxOut').v, tTH.('v_gbxOut').v);
            case 'UR_amb' 
                % umidità relativa
                tTH.(cFields{i}).u = '%';
                tTH.(cFields{i}).v = tTH.('p_ambV').v ./ tTH.('p_ambVSat').v *100; 
            case 'V_comb'
                tTH.(cFields{i}).u = 'l';
                tTH.(cFields{i}).v = tTH.('m_comb').v / (tPrjWsp.('eng_FuelRho')*1000);
            case 'V_f'
                tTH.(cFields{i}).u = 'mm^3/hub' ;
                tTH.(cFields{i}).v = tTH.('m_f').v / tPrjWsp.('eng_FuelRho');
            case 'eff_mechTransm'
                % efficienza della parte meccanica della trasmissione
                tTH.(cFields{i}).u = '%';
                tTH.(cFields{i}).v = rfSdsMain('effMech', tTH.('P_fdOut').v, tTH.('P_gbxIn').v, [0 1]);
            case 'eff_transm' 
                % efficienza complessiva della trasmissione, da motore alle
                % ruote
                tTH.(cFields{i}).u = '%';
                tTH.(cFields{i}).v = rfSdsMain('effMech', tTH.('P_fdOut').v, tTH.('P_engOut').v, [0 1]);
            case 'jerk_veh'
                tTH.(cFields{i}).u = 'm/s^3';
                tTH.(cFields{i}).v = gradient(tTH.dvdt_veh.v,tTH.time.v);
            case 'E_veh'
                % energia richiesta al veicolo per sostenere la manovra
                tTH.(cFields{i}).u = 'kWh';
                power = (2*pi/60*tTH.v_eng.v).*(tTH.C_cons.v)/1000; % [kW]
                power = max(power,0) .* tTH.eff_mechTransm.v; 
                tTH.(cFields{i}).v = cumtrapz(tTH.time.v, power)/3600 ; % [kWh]
            case 'loadFactor_veh'
                % fattore di carico del veicolo per sostenere la manovra
                tTH.(cFields{i}).u = 'kWh/l';
                tTH.(cFields{i}).v = tTH.E_veh.v/tPrjWsp.('cilind'); % [kWh/l]
           case 'load_ind'
                % fattore di carico indicato del motore:
                % coppiaIndicataErogata / coppiaIndicataMassima(v_end)
                tTH.(cFields{i}).u = '-';
                tTH.(cFields{i}).v = tTH.C_indCorr.v ./ tTH.C_indCorrMax.v ; 
           case 'm_f'
                % introduzione al ciclo per cilindro
                tTH.(cFields{i}).u = tTH.('m_fTot').u ;
                tTH.(cFields{i}).v = tTH.('m_fTot').v  / tPrjWsp.('n_cyl') ; 
           case 'p_ambT'
                % pressione atmosferica totale
                tTH.(cFields{i}).u = tTH.('p_ambS').u ;
                tTH.(cFields{i}).v = tTH.('p_ambS').v + tTH.('p_ambV').v ; 
            case 'p_ambVSat'
                % pressione di vapore in condizioni di saturazione (UR = 100%)
                tTH.(cFields{i}).u = tTH.('p_ambS').u ;
                tTH.(cFields{i}).v = interp1(tPrjWsp.h_road_i, tPrjWsp.p_ambVSat_d, tTH.('altitude').v) ; 
           case 'slipRatio_tqCnv'
                % slip del convertitore di coppia
                tTH.(cFields{i}).u = '';
                tTH.(cFields{i}).v = 1 - tTH.('speedRatio_tqCnv').v;
           case 'capacityFactor_tqCnv_um2'
                % capacity factor
                tTH.(cFields{i}).u = 'Nm/rpm^2';
                tTH.(cFields{i}).v = (tTH.('capacityFactor_tqCnv').v).^2;
            otherwise
                disp(['Warning: funzione "addFieldsTH" in "', mfilename, '.m": la grandezza richiesta ', cFields{i}, ' è sconosciuta'])
        end
        % aggiunta delle descrizioni dei campi solo se sono stati creati
        if isfield(tTH, cFields{i}) && isfield(tTH.(cFields{i}), 'v') && isfield(tTH.(cFields{i}), 'u') 
           tTH.(cFields{i}).('d') = descrizTH(cFields{i});
        else
           % non lo aggiungo
        end
   catch 
      disp(['Warning: funzione "addFieldsTH" in "', mfilename, '.m": la grandezza richiesta ', cFields{i}, ' ha generato un errore'])
   end
end
return
%
function tTH = filtTH(tTH,cFields,nPoints)
% filtra verso il basso le grandezze della time history nella struttura tTH indicate in
% cFields con il numero di punti indicati in nPoints

nPoints = round(nPoints);
fNames = fieldnames(tTH);
cFields = intersect(cFields,fNames);
for i=1:length(cFields)
   tTH.(cFields{i}).v = filtfilt(ones(nPoints(i),1)/nPoints(i), 1, tTH.(cFields{i}).v);
end
return
%
function tTH = roundTH(tTH,varargin)
% arrotonda la time history tTH secondo quanto specificato in
% ingresso; per i campi non specificati si applicano gli arrotondamenti di
% default previsti nella sezione apposita di questa function
% sintassi:
% tTH = roundTH(tTH); % applica solo arrotondamenti di default
% tTH = roundTH(tTH, {'P_meccMiss','T_H20'}, [0.1, 0.2]); % applica gli
% arrotondamenti specificati e i default per i rimanenti campi di tTH

% raccolta nomi dei campi e delle unità di misura 
fNames = fieldnames(tTH);
uNames = cell(size(fNames));
for i=1:length(fNames)
    uNames{i} = tTH.(fNames{i}).u;
end
%---arrotondamenti specificati dall'esterno---
if not(isempty(varargin))
    cFields = varargin{1}; % nomi dei campi da arrotondare secondo i valori assoluti in Round
    vRound = varargin{2};
    for i=1:length(cFields)
        tTH.(cFields{i}).v = arrotonda(tTH.(cFields{i}).v, vRound(i));
    end
else
    cFields = {};
end

%---arrotondamenti di default---
[fNamesDef,idx] = setdiff(fNames,cFields); % nomi dei campi da arrotondare in modo default
uNamesDef = uNames(idx);
% % accelerazioni in m/s^2
% a = intersect(find(strfindB(fNamesDef,'dvdt_')), find(strcmp(uNamesDef,'m/s^2')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% altrezza sede stradale in metri
% a = intersect(find(strfindB(fNamesDef,'Height')), find(strcmp(uNamesDef,'m')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % calori in kJ
% a = intersect(find(strfindB(fNamesDef,'Q_')), find(strcmp(uNamesDef,'kJ')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.1);
% end
% % consumo di combustibile in l/100km
% a = intersect(find(strfindB(fNamesDef,'fc')), find(strcmp(uNamesDef,'l/100km')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% coppie in Nm
% a = intersect(find(strfindB(fNamesDef,'C_')), find(strcmp(uNamesDef,'Nm')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % energie in kJ
% a = intersect(find(strfindB(fNamesDef,'E_')), find(strcmp(uNamesDef,'kJ')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % energia veicolo per manovra corrente
% a = intersect(find(strfindB(fNamesDef,'E_veh')), find(strcmp(uNamesDef,'kWh')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% % fattore di carico veicolo per manovra corrente
% a = intersect(find(strfindB(fNamesDef,'loadFactor_veh')), find(strcmp(uNamesDef,'kWh/l')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% % forze in N
% a = intersect(find(strfindB(fNamesDef,'F_')), find(strcmp(uNamesDef,'N')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.1);
% end
% % jerk in m/s^3
% a = intersect(find(strfindB(fNamesDef,'jerk_')), find(strcmp(uNamesDef,'m/s^3')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% % masse in grammi (ex: inquinanti cumulati)
% a = intersect(find(strfindB(fNamesDef,'m_')), find(strcmp(uNamesDef,'g')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.0001);
% end
% portata combustibile in g/s
% a = intersect(find(strfindB(fNamesDef,'dmdt_comb')), find(strcmp(uNamesDef,'g/s')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.0001);
% end
% % portate in g/h (ex: inquinanti)
% a = intersect(find(strfindB(fNamesDef,'dmdt_')), find(strcmp(uNamesDef,'g/h')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.0001);
% end
% % posizioni attuatori
% a = find(strfindB(fNamesDef,'pos_'));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% % potenze in kW
% a = intersect(find(strfindB(fNamesDef,'P_')), find(strcmp(uNamesDef,'kW')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % potenze in W
% a = intersect(find(strfindB(fNamesDef,'P_')), find(strcmp(uNamesDef,'W')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.1);
% end
% % pressioni medie (ex: pmi,pme...) in bar
% a = intersect(find(strfindB(fNamesDef,'pm')), find(strcmp(uNamesDef,'bar')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % rendimenti 
% a = find(strfindB(fNamesDef,'eta_'));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% % spazio in metri
% a = intersect(find(strfindB(fNamesDef,'s_')), find(strcmp(uNamesDef,'m')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % temperature in °C
% a = intersect(find(strfindB(fNamesDef,'T_')), find(strcmp(uNamesDef,'°C')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.01);
% end
% % velocità in km/h o m/s
% a = intersect(find(strfindB(fNamesDef,'v_')), find(strfindB(uNamesDef,{'km/h','m/s'})));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end
% % velocità angolari in rpm
% a = intersect(find(strfindB(fNamesDef,'v_')), find(strcmp(uNamesDef,'rpm')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.1);
% end
% % volumi in litri (ex:combustibile)
% a = intersect(find(strfindB(fNamesDef,'V_')), find(strcmp(uNamesDef,'l')));
% for i=1:length(a)
%     tTH.(fNamesDef{a(i)}).v = arrotonda(tTH.(fNamesDef{a(i)}).v, 0.001);
% end


return
%
function sDescr = descrizTH(sQuant)
% restituisce una stringa contenente la descrizione associata alla
% grandezza specificata in sQuant, che tipicamante è il nome del campo
% di una time history proveniente dalla simulazione di un modello SimuDynS
%
switch sQuant
   case 'C_aux'
      sDescr = ['Coppia (valutata a livello motore) assorbita dagli organi ausiliari, somma di contributi meccanici'...
                ' (ex: idroguida, compressore AC) ed elettrici (tramite alternatore)'];
   case 'C_brk'
      sDescr = ['Coppia utile erogata dal motore, considerata senza gli eventuali accessori meccanici ed elettrici,'...
                ' in modo che sia confrontabile con le condizioni di prova motore al banco'];
   case 'C_brkMax'
      sDescr = ['Coppia utile massima erogabile dal motore lungo la manovra in condizioni stazionarie (risente della limitazione di coppia del cambio)'];
   case 'C_cons'
      sDescr = ['Coppia usata per la stima dei consumi, somma di coppia utile erogata dal motore e della differenza fra'... 
                ' le friction di warm-up rispetto a quelle di motore regimato termicamente'];
   case 'C_engReq'
      sDescr = ['Coppia richiesta dalla GCU, modulo TMS, alla ECU'];
   case 'C_engOut'
      sDescr = ['Coppia erogata dal motore, considerata al''accoppiamento con il cambio; considera l''inerzia motore'];
   case 'C_fctEst'
      sDescr = ['Coppia di friction complessiva (meccanica, pompaggio e accessori interni) stimata dalla ECU motore'];
   case 'C_fdOut'
      sDescr = ['Coppia in uscita dalla riduzione finale del cambio (o ponte)'];
   case 'C_frict'
      sDescr = ['Coppia delle friction interne al motore (sono quindi esclusi gli accessori, meccanci ed elettrici, e il pompaggio). '...
                ' Variano in funzione del livello termico corrente del motore e della sua velocità angolare'];
   case 'C_frictHot'
      sDescr = ['Coppia delle friction interne al motore (sono quindi esclusi gli accessori, meccanci ed elettrici, e il pompaggio) '...
                'a motore termicamente regimato'];
   case 'C_friz'
      sDescr = ['Trasmissioni MT/AMT: coppia trasmessa dalla frizione tra uscita motore e ingresso cambio.'...
                ' Trasmissioni AT: coppia trasmessa dalla frizione di bloccaggio del convertitore di coppia ("lock-up").'];
   case 'C_friz1'
      sDescr = ['Trasmissione DCT: coppia trasmessa dalla frizione tra uscita motore e ingresso lato marce dispari (ex: 1-3-5) del cambio'];
   case 'C_friz2'
      sDescr = ['Trasmissione DCT: coppia trasmessa dalla frizione tra uscita motore e ingresso lato marce pari (ex: 2-4-6) del cambio'];
   case 'C_frizLU'
      sDescr = ['Trasmissione AT: coppia trasmessa dalla frizione di bloccaggio del convertitore di coppia ("lock-up").'];
   case 'C_gbxIn'
      sDescr = ['Coppia in ingresso alla parte meccanica del cambio'];
   case 'C_gbxIn1'
      sDescr = ['Trasmissione DCT: coppia in ingresso all''albero marce dispari del cambio'];
   case 'C_gbxIn2'
      sDescr = ['Trasmissione DCT: coppia in ingresso all''albero marce pari del cambio'];
   case 'C_gbxOut'
      sDescr = ['Coppia in uscita dal cambio, prima della riduzione finale'];
   case 'C_imp' 
      sDescr = ['Trasmissioni AT: coppia fluidodinamica (--> senza effetti inerziali) associata alla pompa (impeller) del convertitore di coppia '];
   case 'C_ind'
      sDescr = ['Coppia indicata (interna) erogata dal motore, calcolata sull''intero ciclo temodinamico: comprende quindi il pompaggio'];
   case 'C_indMax'
      sDescr = ['Coppia indicata (interna) massima erogabile dal motore lungo la manovra in condizioni stazionarie (risente della limitazione di coppia del cambio)'];
   case 'C_indCorr'
      sDescr = ['Coppia indicata (interna) erogata dal motore, calcolata sulle sole corse pistone di comprenssione ed espansione: non comprende quindi il pompaggio'];
   case 'C_indCorrMax'
      sDescr = ['Coppia indicata corretta con pompaggio massima erogabile dal motore lungo la manovra in condizioni stazionarie (risente della limitazione di coppia del cambio)'];
   case 'C_indEst'
      sDescr = ['Coppia indicata, correntemente prodotta, stimata dalla ECU motore'];
   case 'C_indReq'
      sDescr = ['Coppia indicata richiesta al modulo di centralina che si occupa di gestire gli azionamenti di potenza del motore'];
   case 'C_mot'
      sDescr = ['Coppia utile erogata dal motore, considerata all''uscita della frizione: è da considerarsi pertanto come già depurata'...
                ' dagli accessori meccanici ed elettrici; non considera l''inerzia motore'];
   case 'C_pmp'
      sDescr = ['Stima della coppia di pompaggio dovuta al lavoro di ricambio fluido in camera di combustione',...
                ' considerato sulle corse di aspirazione e scarico'];
   case 'C_propDrv'
      sDescr = ['Coppia richiesta dal driver tramite la mappa pedale, in termini di coppia utile; segnale derivante da GCU, modulo TMS'];
   case 'C_propDriver'
      sDescr = ['Coppia richiesta dal driver tramite la mappa pedale, in termini di coppia utile; segnale derivante da ECU'];
   case 'C_propEst'
      sDescr = ['Coppia utile, correntemente erogata, stimata dalla ECU motore'];
   case 'C_rAnt'
      sDescr = ['Coppia trasmessa alle ruote anteriori, considerata al mozzo ruota: comprende perciò l''azione frenante ma non l''inerzia ruota'];
   case 'C_rAntLim'
      sDescr = ['Coppia limite trasmessibile alle ruote anteriori in condizioni di incipiente slittamento'];
   case 'C_rPost'
      sDescr = ['Coppia trasmessa alle ruote posteriori, considerata al mozzo ruota: comprende perciò l''azione frenante ma non l''inerzia ruota'];
   case 'C_rPostLim'
      sDescr = ['Coppia limite trasmessibile alle ruote posteriori in condizioni di incipiente slittamento'];
   case 'C_starter'
      sDescr = ['Coppia del motorino d''avviamento riportata all''albero motore'];
   case 'C_turb'
      sDescr =  ['Trasmissioni AT: coppia fluidodinamica (--> senza effetti inerziali) associata alla turbina del convertitore di coppia '];
   case 'E_dissFriz'
      sDescr = ['Trasmissioni MT/AMT: energia dissipata nella frizione a causa del pattinamento dei dischi'];
   case 'E_dissFriz1'
      sDescr = ['Trasmissione DCT: energia dissipata nella frizione delle marce dispari (ex: 1-3-5) a causa del pattinamento dei dischi'];
   case 'E_dissFriz2'
      sDescr = ['Trasmissione DCT: energia dissipata nella frizione delle marce pari (ex: 2-4-6) a causa del pattinamento dei dischi'];
   case 'E_veh'
      sDescr = ['Energia richiesta al veicolo per compiere la manovra simulata; per dettagli sul significato chiedere a Pilo'];
   case 'F_coastDown'
      sDescr = ['Forza longitudinale dovuta alle resistenze all''avanzamento esclusa la pendenza stradale (coast down)'];
   case 'F_grade'
      sDescr = ['Forza longitudinale dovuta all''azione del campo gravitazionale terrestre (effetto pendenza strada)'];
   case 'F_tgRAnt' % verificare
      sDescr = ['Forza scambiata con il terrreno in direzione longitudinale dalla coppia di ruote anteriori'];
   case 'F_tgRPost'
      sDescr = ['Forza scambiata con il terrreno in direzione longitudinale dalla coppia di ruote posteriori'];
   case 'P_dissFriz'
      sDescr = ['Potenza dissipata dalla frizione a causa del pattinamento dei dischi'];
   case 'P_dissFrizLU'
      sDescr = ['Trasmissioni AT: potenza dissipata dalla frizione di bloccaggio del convertitore di coppia a causa del pattinamento dei dischi'];
   case 'P_dissFriz1'
      sDescr = ['Potenza dissipata dalla frizionedelle marce dispari (ex: 1-3-5) a causa del pattinamento dei dischi'];
   case 'P_dissFriz2'
      sDescr = ['Potenza dissipata dalla frizione delle marce pari (ex: 2-4-6) a causa del pattinamento dei dischi'];
   case 'P_elMiss'
      sDescr = ['Missione di potenza elettrica richiesta da alcuni ausiliari elettrici all''impianto della vettura, ipotizzandoli' ...
                ' funzione nota del tempo'];
   case 'P_meccMiss'
      sDescr = ['Missione di potenza meccanica richiesta da alcuni ausiliari meccanici al motore, ipotizzandoli'...
                ' funzione nota del tempo'];
   case 'P_propReq'
      sDescr = ['Potenza richiesta dalla mappa di guidabilità in termini utili; segnale derivante da GCU, modulo PDRM'];
   case 'P_propReqDisp'
      sDescr = ['Potenza richiesta dalla mappa di guidabilità in termini utili e limitata superiormente dalla curva di massime prestazioni'...
        'e inferiormente dalla curva di friction stimata; segnale derivante da GCU, modulo PDRM'];
   case {'P_fdOut','P_gbxIn','P_gbxOut'}
      sDescr = ['per la descrizione vedi corrispondente grandezza in termini di coppia'];
   case 'Q_met'
      sDescr = ['Frazione del calore rilasciato dal processo di combustione che modifica il livello termico della massa metallica del motore'];
   case 'Q_olio'
      sDescr = ['Frazione del calore rilasciato dal processo di combustione che modifica il livello termico della massa di lubrificante'...
                ' contenuta nel motore'];
   case 'Q_refr'
      sDescr = ['Frazione del calore rilasciato dal processo di combustione che modifica il livello termico della massa di refrigerante'...
                ' contenuta nel motore'];
   case 'Q_risc'
      sDescr = ['Calore differenza tra il calore associato alla massa di combustibile bruciato e la somma di lavoro utile motore più'...
                ' gli accessori e il calore ceduto ai gas combusti. In pratica rappresenta il calore suddiviso fra il riscaldamento'...
                ' del blocco motore e la dissipazione dello stesso mediante l''apposito scambiatore aria-acqua ("radiatore").'];
   case 'T_H2O'
      sDescr = ['Livello termico del liquido refrigerante del motore, modellizzato con un solo parametro concentrato'];
   case 'T_amb'
      sDescr = ['Temperatura dell''ambiente esterno al veicolo'];
   case 'T_olio'
      sDescr = ['Livello termico del liquido lubrificante del motore, modellizzato con un solo parametro concentrato'];
   case 'UR_amb'
      sDescr = ['Umidità relativa dell''ambiente esterno al veicolo'];
   case 'V_comb'
      sDescr = ['Volume di combustibile progressivamente bruciato (da inizio simulazione)'];
   case 'V_f'
      sDescr = ['Introduzione in volume di combustibile al ciclo e al cilindro'];
   case 'altitude'
      sDescr = ['Quota del fondo stradale'];
   case 'cutoffOn'
      sDescr = ['Segnale logico indicante le fasi di taglio alimentazione combustibile al motore (tipico in decelerazione)'];
   case 'dmdt_comb'
      sDescr = ['Portata di combustibile bruciata dal motore termico'];
   case 'dvdt_veh'
      sDescr = ['Accelerazione longitudinale del veicolo, con direzione contenuta in un piano localmente tangente al profilo stradale (ex: simulazioni con strada'...
                ' in pendenza)'];
   case 'eff_fd'
      sDescr = ['Rendimento della riduzione finale del cambio (o ponte)'];
   case 'eff_gbx'
      sDescr = ['Rendimento della parte meccanica del cambio, esclusa la riduzione finale'];
   case 'eff_mechTransm'
      sDescr = ['Rendimento della parte meccanica della trasmissione, considerata tra l''ingresso della parte meccanica del cambio e ',...
                'l''uscita dal rapporto finale: in caso di AT non comprende pertanto il rendimento del convertitore di coppia'];
   case 'eff_transm'
      sDescr = ['Rendimento complessivo della trasmissione, considerata fra l''uscita del motore e l''uscita della riduzione finale'];
   case 'eff_tqConv'
      sDescr = ['Rendimento del convertitore di coppia'];
   case 'fc'
      sDescr = ['Fuel Consumption cumulato (e non istantaneo), cioè volume di combustibile bruciato (da inizio simulazione)'...
                ' in relazione allo spazio percorso (da inizio simulazione)'];
   case 'gearCurr'
      sDescr = ['marcia correntemente innestata nel cambio'];
   case 'gearCurr1'
      sDescr = ['Trasmissione DCT: marcia correntemente innestata sull''albero relativo alle marce dispari (ex: 1-3-5)'];
   case 'gearCurr2'
      sDescr = ['Trasmissione DCT: marcia correntemente innestata sull''albero relativo alle marce pari (ex: 2-4-6)'];
   case 'gearDriver'
      sDescr = ['Marcia selezionata dal driver (ex: profilo di marce da file di missione per ciclo guida); quando il cambio è automatizzato'...
               ' questi valori hanno effetto solo se il cambio sta funzionando in modalità sequenziale'];
   case 'gearMiss'
      sDescr = ['Missione delle marce'];
   case 'gearReq'
      sDescr = ['Trasmissioni automatizzate: marcia in output dalla centralina di controllo cambio, ovvero richiesta agli attuatori'...
                ' cambio di inserimento di un determinato rapporto'];
   case 'grade'
      sDescr = ['Pendenza del profilo stadale (valutata come tangente fra orizzontale e verticale) incontrato dalla vettura'];
   case 'guidaOpenLoop'
      sDescr = ['Segnale logico indicante le fasi in cui il driver guida a comandi imposti, senza seguire la missione di velocità assegnata'];
   case 'iceAcceso'
      sDescr = ['Segnale logico indicante le fasi in cui il motore termico è acceso'];
   case 'idleOn'
      sDescr = ['Segnale logico di centralina controllo motore indicante quando la regolazione del propulsore è delegata esclusivamente'...
                ' alla ECU allo scopo di inseguire un regime motore ("di minimo") obiettivo, tipicamente durante le fasi di stazionamento'];
   case 'innestoFrizOn'
      sDescr = ['Trasmissioni MT/AMT: segnale logico indicante quando la frizione è innestata, cioè quando i dischi sono a contatto e' ...
                ' hanno la stessa velocità angolare. Trasmissioni AT: la frizione in oggetto è quella di bloccaggio del convertitore di coppia'];
   case 'innestoFrizLUOn'
      sDescr = ['Trasmissione AT: segnale logico indicante quando la frizione di bloccaggio del convertitore di coppia è innestata,'...
                ' cioè quando i dischi sono a contatto e hanno la stessa velocità angolare.'];
   case 'innestoFrizOn1'
      sDescr = ['Trasmissione DCT: segnale logico indicante quando la frizione delle marce dispari è innestata, cioè quando i dischi'...
                ' sono a contatto e hanno la stessa velocità angolare'];
   case 'innestoFrizOn2'
      sDescr = ['Trasmissione DCT: segnale logico indicante quando la frizione delle marce pari è innestata, cioè quando i dischi'...
                ' sono a contatto e hanno la stessa velocità angolare'];
   case 'jerk_veh'
      sDescr = ['Derivata rispetto al tempo dell''accelerazione longitudinale della vettura'];
   case 'limitOn'
      sDescr = ['Segnale logico di centralina controllo motore indicante quando la regolazione del propulsore è delegata esclusivamente'...
                ' alla ECU allo scopo di limitare il regime motore entro il limite massimo ammissibile ("limitatore")'];
   case 'loadFactor_veh'
      sDescr = ['Fattore di carico del motore durante una manovra: divisione fra l''energia del veicolo e la cilindrata del motore'];
   case 'load_ind'
      sDescr = ['Fattore di carico indicato del motore durante una manovra: rapporto fra la coppia indicata del motore e quella massima erogabile a quel regime'];
   case 'm_CO2'
      sDescr = ['massa di CO2 prodotta da inizio simulazione; rappresenta cioè la cumulata della portata di combustibile'];
   case 'm_comb'
      sDescr = ['massa di combustibile bruciato da inizio simulazione; rappresenta cioè la cumulata della portata di combustibile'];
   case 'm_f'
      sDescr = ['massa di combustibile intrappolato in camera di combustione per ogni ciclo termodinamico', ...
                ', chiamata anche "introduzione" nel caso di motori ad accensione per compressione'];
   case 'm_fAft'
      sDescr = ['Introduzione in massa di combustibile nella iniezione-after al ciclo e al cilindro'];
   case 'm_fTot'
      sDescr = ['massa di combustibile intrappolato in camera di combustione per ogni ciclo termodinamico', ...
                ', chiamata anche "introduzione" nel caso di motori ad accensione per compressione, moltiplicata per il numero dei cilindri'];
   case 'pme'
      sDescr = ['Pressione media effettiva erogata dal motore, al netto di eventuali ausiliari meccanici ed elettrici. E'' la coppia'...
                ' utile motore divisa per la cilindrata'];
   case 'p_ambS'
      sDescr = ['pressione dell''aria secca dell''ambiente esterno al veicolo'];
   case 'p_ambT'
      sDescr = ['pressione totale (secca + vapore) dell''aria dell''ambiente esterno al veicolo'];
   case 'p_ambV'
      sDescr = ['pressione del vapore d''acqua dell''ambiente esterno al veicolo'];
   case 'p_ambVSat'
      sDescr = ['pressione in condizioni di saturazione del vapore d''acqua dell''ambiente esterno al veicolo'];
   case 'pos_acc'
      sDescr = ['Posizione pedale acceleratore'];
   case 'pos_brk'
      sDescr = ['Posizione pedale freno'];
   case 'pos_friz'
      sDescr = ['Posizione pedale frizione'];
   case 'pos_friz1'
      sDescr = ['Trasmissione DCT: posizione attuatore frizione ingresso cambio lato marce dispari (0: aperto; 1: chiuso)'];
   case 'pos_friz2'
      sDescr = ['Trasmissione DCT: posizione attuatore frizione ingresso cambio lato marce pari (0: aperto; 1: chiuso)'];
   case 'pos_frizLU'
      sDescr = ['Trasmissione AT: posizione attuatore frizione di bloccaggio convertitore di coppia (0: aperto; 1: chiuso)'];
   case 'rho_amb'
      sDescr = ['densità totale dell''aria dell''ambiente esterno al veicolo'];
   case 's_veh'
      sDescr = ['Spazio percorso dal veicolo da inizio manovra in direzione longitudinale e parallela alla tangente locale al profilo stradale'];
   case 'v_eng'
      sDescr = ['Velocità angolare motore termico. Trasmissione AT: rappresenta anche la velocità della pompa del convertitore di coppia'];
   case 'v_fdOut'
      sDescr = ['Velocità in uscita dalla riduzione finale del cambio (o ponte)'];
   case 'v_gbx'
      sDescr = ['Velocità in ingresso al cambio: sarà eliminato, usare v_gbxIn'];
   case 'v_gbxIn'
      sDescr = ['Velocità in ingresso alla parte meccanica del cambio'];
   case 'v_gbxIn1'
      sDescr = ['Trasmissione DCT: velocità dell''albero marce dispari del cambio'];
   case 'v_gbxIn2'
      sDescr = ['Trasmissione DCT: velocità dell''albero marce pari del cambio'];
   case 'v_gbxOut'
      sDescr = ['Velocità in uscita dal cambio, prima della riduzione finale'];
   case 'v_veh'
      sDescr = ['Velocità in direzione longitudinale sviluppata dal veicolo, valutata rispetto alla tangente locale al profilo stradale'];
   case 'v_vehMiss'
      sDescr = ['Obiettivo ("missione") di velocità longitudinale veicolo'];
   %10/07/2010 A.Piu
    case 'v_alt'
      sDescr = ['Velocità angolare alternatore'];
    case 'C_alt'
      sDescr = ['Coppia meccanica richiesta dall''alternatore al motore'];
    case 'C_alt_PQM'
      sDescr = ['Coppia meccanica richiesta dall''alternatore al motore compresa nel piano quotato motore'];
    case 'I_alt'
      sDescr = ['Corrente erogata dall''alternatore'];
    case 'I_bat'
      sDescr = ['Corrente carica/scarica della batteria'];
    case 'I_alt_exc'
      sDescr = ['Corrente di eccitazione dell''alternatore'];
    case 'SOC'
      sDescr = ['Stato carica della batteria'];
    case 'P_alt'
      sDescr = ['Potenza meccanica richiesta dall''alternatore al motore termico'];
    case 'I_loads'
      sDescr = ['Corrente assorbita dai carichi elettrici attivi'];
    case 'VMU_ICE_stop_req'
      sDescr = ['Segnale di richiesta stop motore termico (per S&S)'];
    case 'V_bat'
      sDescr = ['Tensione della batteria'];
    case 'V_ref'
      sDescr = ['Tensione di riferimento dell''alternatore'];
      % 12/04/2011 A.Piu R2.4.1 Clima
    case 'CompressoreSetPoint'
      sDescr = ['Pressione di controllo del compressore a cilindrata variabile a controllo esterno'];
    case 'LivelloVentolaCondensatore'
      sDescr = ['Livello di attivazione della ventola condensatore'];
    case 'Parzializzazione'
      sDescr = ['Livello del parzializzazione del compressore a cilindrata variabile'];
    case 'Phi'
      sDescr = ['Pressione di condensazione/pressione mandata compressore'];
    case 'Plow'
      sDescr = ['Pressione di evaporazione/pressione di aspirazione compressore'];
    case 'PortataAriaCondensatore'
      sDescr = ['Portata aria di lavaggio del condensatore'];
    case 'PortataAriaEvaporatore'
      sDescr = ['Portata aria di lavaggio dell'' evaporatore'];
    case 'PortataRefrigerante'
      sDescr = ['Portata di liquido refrigerante'];
    case 'PotenzaCompressore'
      sDescr = ['Potenza meccanica richiesta dal compressore clima al motore'];
    case 'PotenzaCondensatore'
      sDescr = ['Potenza termica scambiata dal condensatore'];
    case 'PotenzaEvaporatore'
      sDescr = ['Potenza termica scambiata dall''evaporatore'];
    case 'StatoCompressore'
      sDescr = ['Stato di attivazione del compressore clima'];
    case 'Tecomac'
        sDescr = ['Temperatura di controllo con strategia Ecomac'];
    case 'TemperaturaAbitacolo'
        sDescr = ['Temperatura media interno abitacolo'];
    case 'TemperaturaAriaCondensatore'
        sDescr = ['Temperatura a valle condensatore'];
    case 'TemperaturaAriaEvaporatore'
        sDescr = ['Tempeartura a valle evaporatore'];
    case 'TemperaturaBocchette'
        sDescr = ['Temperatura media uscita bocchette abitacolo'];
    case 'Tequivalente'
        sDescr = ['Temperatura di feed back per il controllo'];
    case 'Ttrattata'
        sDescr = ['Temperatura a valle del mixer evaporatore'];
    case 'UmiditaAbitacolo'
        sDescr = ['Valore di umidità interno abitacolo'];
%%%%%%%%%%%%%                      
    otherwise
      sDescr = 'description not available';
end

return
%
function tTH = rmOrgDataTH(tTH)

% elimina i dati originari dalle grandezze (spec a scopo salvataggio su
% file per ridurre spazio)

% racolta infos su grandezze
[cTorgSet, cQorg, cTorg, cQint] = historyTimeFields(tTH);

% elimino il tempo
for i = 1:length(cTorgSet)
    sF = cTorgSet{i};
    %
    tT = tTH.(sF);
    tT.('xAxis_org') = '';
    tT.('v_org') = [];
    %
    tTH.(sF) = tT;
    %
    % tTH = rmfield(tTH, cTorgSet{i});
end

% elimino ii campi di dati originari dalle grandezze
for i = 1:length(cQorg)
    sF = cQorg{i};
    %
    tQ = tTH.(sF);
    tQ.('xAxis_org') = '';
    tQ.('v_org') = [];
    %
    tTH.(sF) = tQ;
end


return
%
function tTH = interpolaTH(tTH, DtReq)
% interpola la tTH in ingresso al tempo di campionamento specificato t_s2

sTime = 'time';

% racolta infos su grandezze
[cTorgSet, cQorg, cTorg, cQint] = historyTimeFields(tTH);
%
% raccolta sample time: DtSet(cTorgSet)
% TODO: funziona con sole grandezze e tempi interpolati??? O ci vanno
% necessariamente le grandezze a sample time originale?

%%% tempo richiesto per l'interpolazione
if not(isempty(cQorg))
    [DtSet] = historySampleTime(tTH, cTorgSet);
    
    % raccolta valori dei sample time originari
    for i = 1:length(cTorgSet) % ciclo sui campi esclusi il tempo
        sFT = cTorgSet{i}; % ex: 'time_1'
        time_org = tTH.(sFT).v_org;
        %
        % individuazione estremi del tempo
        if i==1
            t_min = time_org(1);
            t_max = time_org(end);
        else
            % intersezione dei vari sample time
            t_min = max(t_min, time_org(1));
            t_max = min(t_max, time_org(end));
        end
    end
    
    % tempo richiesto per l'interpolazione
    % (finisce nel consueto campo v)
    timeReq = (t_min:DtReq:t_max)';
else
    % tempo interpolato
    timeReq = (tTH.(sTime).v(1): DtReq: tTH.(sTime).v(end))';
end


% interpolazione da GRANDEZZE ORIGINARIE (se presenti)
if not(isempty(cQorg))
    for i = 1:length(DtSet);
        %
        DtCurr = DtSet(i);
        sFT = cTorgSet{i}; % ex: 'time_1'
        time_org = tTH.(sFT).v_org;
        %
        % valuto se il sample time richiesto è un multiplo di quello originario
        bMult = resto(DtReq / DtCurr, 1) < DtCurr*1e-3;
        %
        % costruisco la matrice delle grandezze da interpolare
        bSt = strcmpi(cTorg, cTorgSet{i});
        cFcurr = cQorg(bSt); % grandezze al sample time corrente
        m = zeros(length(time_org), length(cFcurr));
        % riempio la matrice con le TH
        for j = 1:length(cFcurr)
            sF = cFcurr{j};
            [dum, val_y] = lengthCorrection(time_org, tTH.(sF).v_org, 2);
            m(:,j) = val_y;
        end
        %
        % interpolazione della matrice
        switch bMult
            case true
                % prendo i punti multipli
                m2 = m(1:arrotonda(DtReq/DtCurr, 1,'floor'):end,:);
            case false
                % interpolo linearmente
                m2 = interp1qsat(time_org, m, timeReq);
        end
        %
        % assegnazione valori interpolati alla time-history nel consueto campo
        % "v"
        for j = 1:length(cFcurr)
            sF = cFcurr{j};
            tTH.(sF).('v') = m2(:,j);
            tTH.(sF).('xAxis') = sTime;
        end
        
    end
end

% interpolazione da GRANDEZZE INTERPOLATE
%
if not(isempty(cQint))
    %
    time_org = tTH.('time').v;
    %
    DtCurr = historySampleTime(tTH, {'time'});
    % valuto se il sample time richiesto è un multiplo di quello originario
    bMult = resto(DtReq / DtCurr, 1) < DtCurr*1e-3;
    % costruisco la matrice delle grandezze da interpolare
    m = zeros(length(time_org), length(cQint));
    % riempio la matrice con le TH
    for j = 1:length(cQint)
        sF = cQint{j};
        [dum, val_y] = lengthCorrection(time_org, tTH.(sF).v, 2);
        m(:,j) = val_y;
    end
    %
    % interpolazione della matrice
    switch bMult
        case true
            % prendo i punti multipli
            m2 = m(1:arrotonda(DtReq/DtCurr, 1,'floor'):end,:);
        case false
            % interpolo linearmente
            m2 = interp1qsat(time_org, m, timeReq);
    end
    %
    % assegnazione valori interpolati alla time-history nel consueto campo
    % "v"
    for j = 1:length(cQint)
        sF = cQint{j};
        tTH.(sF).('v') = m2(:,j);
        tTH.(sF).('xAxis') = '';
    end
end

%%% assegnazione tempo interpolato
% copio tutti i sotto-campi
if not(isempty(cQorg))
    tTH.(sTime) = tTH.('time_1'); 
end
tTH.(sTime).('v') = timeReq;
tTH.(sTime).('v_org') = [];

return
%
function [cTorgSet, cQorg, cTorg, cQint] = historyTimeFields(tTH)

% cTorgSet = {time_1, time_2, time_3}
% cQorg = {C_brk, C_mot, C_alt, ...}
% cTorg = {time_1, time_1, time_1, ...};

% TODO: distingere qua dentro di quali grandezze appartiene il campo
% time_xxx e di quali c'è solo il campo time (ex: aggiunte in post)

sTint = 'time';

cF = fieldnames(tTH);
aOrg = 0; % contatore delle grandezze con sample time originali
% aInt = 0; % contatore delle grandezze con sample time interpolati
cFTo = cell(size(cF)); % ex: {'time_1', '', 'time_1',...}
cFTi = cell(size(cF)); % ex: {'', 'time', '',...}
cTorgSet = cell(size(cF));
% n = zeros(size())

% cell array dei set dei sample time
a = 0;
for i = 1:length(cF)
    sF = cF{i};
    if length(sF)>=6 && strcmp(sF(1:5), 'time_')
        % n(i) = str2double(sF(6:end));
        a = a+1;
        cTorgSet{a} = sF;
    end
end
cTorgSet = cTorgSet(1:a);
cTorgSet = sort(cTorgSet);

% cell array dei sample time

% ciclo su tutte le grandezza
for i = 1:length(cF)
    % stringa vuota
    cFTo{i} = '';
    cFTi{i} = '';
    %
    sF = cF{i};
    if not(any(strcmpi(sF, cTorgSet)))
        % se non è un tempo di campionamento originale
        if not(any(strcmpi(sF, sTint)))
            % se non è un tempo di campionamento interpolato
            if isfield(tTH.(sF), 'xAxis_org') && not(isempty(tTH.(sF).xAxis_org)) &&...
                    not(strcmpi(tTH.(sF).xAxis_org, sTint))
                % variabile con sample time originale
                cFTo{i} = tTH.(sF).('xAxis_org');
            else
                % variabile sneza sample time originale (solo interpolato)
                cFTi{i} = sTint;
            end
        end
    end
end

% grandezze originarie: tempi e grandezze
bIdx = not(strcmpi(cFTo, ''));
cTorg = cFTo(bIdx);
cQorg = cF(bIdx);

% grandezze interpolate: tempi e grandezze
bIdx = not(strcmpi(cFTi, ''));
cQint = cF(bIdx);

% % elenco sole grandezze y, cioè esclusi i canali del tempo
% [cQorg, idx] = setdiff(cF, [cTorgSet; cTint]); % sole grandezze con sample time originari
% cTorg = cFTo(idx); % 
% 
% % sole grandezze con sample time originari
% cQint = {''};


return
%
function [DtSet] = historySampleTime(tTH, cFT)

DtSet = zeros(size(cFT));
for i = 1:length(cFT)
    sF = cFT{i};
    if strcmpi(sF, 'time')
        sFv = 'v';
    else
        % ex: time_1
        sFv = 'v_org';
    end
    DtSet(i) = chop(mean(diff(tTH.(sF).(sFv))), 4);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% altre funzioni
%
function tTun = ctrlSmkBp(tTun)
% modifica i vettori tunbale nulli di tTun che rappresentano i breakPoint di qche LUT
% in modo che siano compatibili con Smk

cVars = fieldnames(tTun);

for i  =1:length(cVars)
   if length(cVars{i}) >= 2 && strcmp(cVars{i}(end-1:end), '_i') 
      if all(tTun.(cVars{i})==0)
         [r,c] = size(tTun.(cVars{i}));
         % vettore crescente
         val = 1:1:length(tTun.(cVars{i}));
         % preserva la dimensione del vettore originale
         if c==1
            % vettore colonna
            tTun.(cVars{i}) = val(:);
         elseif r==1
            % vettore riga
            tTun.(cVars{i}) = val(:)';
         end
         
      elseif any(diff(tTun.(cVars{i}))<=0)
         disp(['Attenzione: la variabile tunable ',cVars{i},' non è strettamente crescente.'])
      end
   end
end
return
%
function [tEn, tPrjWsp] = setRec(sModel, cMan, tPrjWsp)
% gestice i tempi di campionamento dei modelli a seconda del modello e della manovra correnti.

if strcmpi(cMan{2}, 'statica')
   tEn = struct();
   return
end
sMan = cMan{1}(length('calc_')+1:end);

% tempo di scrittura di DEFAULT del modello delle time-histories sul file mat
% creato dall'exe (serve per i conti, non per il salvataggio su file mat di out del lancio)
if any(strcmpi(sMan, {'FConsCycle','FConsSteady','FConsUser'}))
    % cicli guida
    t_samplDef = 0.25;
else
    % prestazioni
    t_samplDef = 0.02;
end

% scelta tempo scrittura file mat   
if cMan{3}.OutSampleTime == -1
    % impostazione automatica (default)
    t_sampl = t_samplDef;
else
    % valore specificato da interfaccia
    % il valore effettivo verrà saturato al sample time del modello
    % internamente a Simulink (t_sampl può quindi essere anche nullo)
    t_sampl = cMan{3}.OutSampleTime;
end
% valore di esportazione TH più grande del sample time di default di
% crezione delle TH: lo limito a quello di default altrimenti i
% risultati possono cambiare
t_sampl = min(t_sampl, t_samplDef);

%%% output
tEn.t_sampl = t_sampl;
tPrjWsp.Dt_postCalc = t_samplDef; % sample time per post-processamento dei risultati

return
%
function sMod = man2mod(cMan, sTrs, tParametriSim, varargin)
% fa corrispondere alla manovra da simulare il modello SimuLink più appropriato

% dipendenza dalla manovra, per ora disabilitata (ex: modello SDL per
% manovre di accelerazione AT invece di 2DOF std per ciclo guida)
% sMan = cMan{1}(length('calc_')+1:end);
% switch cMan{1}
%    case
%    case
% end

cHyb = {''};
if not(isempty(varargin))
   cHyb = varargin{1};
end


if isempty(tParametriSim.('MdlPath'))
   %%% non uso un eventuale modello asseganto dall'esterno
   
   if not(isempty(cHyb{1}))
      
      %%%% veicoli IBRIDI
      % modelli ibridi generali (uno per tipo di trasmissione)
      trsType = cHyb{5};
      sMod = ['exe_GenHyb_' trsType '_sdl.exe'];
      % quando sopra va bene anche per l'HDCT, purché il modello dell'HDCT si
      % chiami exe_GenHyb_HDCT_sdl.exe;
      % provvisoriamente: caso dell'Ecodriver
      if all( strcmpi(cHyb,{'PH','SS','DCL','GbI','AMT','std'}) )
         sMod = 'exe_Hyb_4DOF_AMT_sdl.exe';
      end   
      % provvisoriamente: caso dell'ibrido HDCT, il nome del modello dovrà essere
      % cambiato col nome definitivo, per adesso il nome è quello dell'ultimo modello modificato - R. Bray 21/07/11
       if all( strcmpi(cHyb,{'PH','DS','SCE','GbI','HDCT','std'}) )
         sMod = 'exe_model_HDCT_updated_14.exe';
      end  
      % provvisoriamente: caso dell'ibrido "Re Fiorentin"
      % if all( strcmpi(cHyb,{'PH','DS','DCL','GbO','AMT','kcs'}) )
      %   sMod='ReFiorentin.exe';
      % end 
      
   else
      
      %%%% veicoli TRADIZIONALI
      
      switch lower(sTrs)
         
         case {'amt','mta'}
            % trasmissioni AMT
            switch cMan{1}
               case {'calc_LaunchQS'}
                  % applicazione manuale equivalente
                  sMod = 'exe_2DOF_MT.exe';
               otherwise
                  if cMan{3}.ModGbxDet
                     sMod = 'exe_3DOF_AMT_sdl.exe';
                  else
                     sMod = 'exe_2DOF_AMT.exe';
                  end
            end
            
            
         case 'at'
            % trasmissioni AT
            if cMan{3}.ModGbxDet
               sMod = 'exe_5DOF_AT_sdl.exe';
            else
               sMod = 'exe_2DOF_AT.exe';
            end
            
         case 'dct'
            
            % tramissioni DCT
            switch cMan{1}
               case {'calc_LaunchQS'}
                  % applicazione manuale equivalente
                  sMod = 'exe_2DOF_MT.exe';
               otherwise
                  if cMan{3}.ModGbxDet
                     sMod = 'exe_4DOF_DCT_sdl.exe';
                  else
                     sMod = 'exe_2DOF_AMT.exe';
                  end
            end
            
            
         case 'mt'
            % riconoscimento parametro GSIOnOff da manovra
            % exe_2DOF_MT_GSI.exe
            
            % parametro GSI definito solo per manovre di consumo
            if cMan{3}.ModGbxDet
               sMod = 'exe_3DOF_MT_sdl.exe';
            else
               sMod = 'exe_2DOF_MT.exe';
            end
            
            
      end
   end
   
   pathMod = cd;
   sMod = fullfile(pathMod, sMod); 
else
   %%% uso il modello specificato dall'esterno
   sMod = tParametriSim.('MdlPath');
end

return
%
function [tMan] = addSimData(tMan, tSim, sMan, t_sampleReq)
% aggiunge alla struttura della manovra i dati(points e History) della simulazione
% le TH vengono interpolate al sample time richiesto da manovra

if not(isempty(sMan))
   % cut di "calc_" da nome manovra
   if strfind(sMan, 'calc_')
      sMan = sMan(length('calc_')+1:end);
   end
   % tempo di campionamento di out di default
   if strfindB(upper(sMan),upper({'Launch'}))
       t_samplDef = 0.10;
   elseif strfindB(upper(sMan),upper({'Creeping'}))
       t_samplDef = 0.02;
   elseif strfindB(upper(sMan),upper({'Acceleration'}))
       t_samplDef = 0.04;
   elseif strfindB(upper(sMan),upper({'Elasticity','F2D','Overtaking','TopSpeed'}))
       t_samplDef = 0.10;
   elseif strfindB(upper(sMan),upper({'FConsCycle','FConsSteady','FConsUser'}))
       t_samplDef = 0.25;
   else
       t_samplDef = 0.2;
   end
else
   %
   % manovra fittizia, tipo failed e null 
end

% tempo di campionamento di salvataggio (per salvataggio nel file mat e
% quindi esportazione delle TH)
if not(isempty(t_sampleReq))
   if t_sampleReq == -1
      % default
      t_sampleReq = t_samplDef;
   elseif t_sampleReq == 0
      % stesso sample time del salvataggio exe su mat, a sua volta in
      % questo caso coicidente con il sample time di esecuzione del modello
      t_sampleReq = historySampleTime(tSim.History(1,1), {'time'});
   end
else
   %
   % manovra fittizia, tipo failed e null 
end

% time history vuota (ex: failed)
bEmptyHist = isempty(tSim(1,1).History(1,1)) || (isstruct(tSim(1,1).History(1,1)) && isempty(fieldnames(tSim(1,1).History(1,1)))) ||...
          (isempty(sMan) || isempty(t_sampleReq));
% if not(bEmptyHist)
%    % limitazione del sample time alla durata manovra (ho almeno sempre 2
%    % punti nelle TH)
%    t_sampleReq = min(t_sampleReq, tSim.History(1,1).time.v(end) - tSim.History(1,1).time.v(1));
% end

% aggiunta di History e Points
[r1,c1] = size(tSim);
[r,c] = size(tSim(1,1).History);
for i1 = 1:r1
   for j1 = 1:c1
      for i = 1:r
         for j = 1:c
            %
            if isfield(tSim(i1,j1), 'Points')
               tMan(i1,j1).Points(i,j) = tSim(i1,j1).Points(i,j);
            end
            %
            if bEmptyHist
               tMan(i1,j1).History(i,j) = tSim(i1,j1).History(i,j);
            else
                % interpolo al sample time richiesto
                tTH = interpolaTH(tSim(i1,j1).History(i,j), t_sampleReq);
                % se necessario rimuovo i campi originari delle grandezze
                tTH = originalTH(tTH, t_sampleReq);
                % salvataggio
                tMan(i1,j1).History(i,j) = tTH;
            end
         end
      end
   end
end

return

function tTH = originalTH(tTH, Dt_req)

% racolta infos su grandezze
[cTorgSet, cQorg, cTorg, cQint] = historyTimeFields(tTH);

% se ci sono grandezze originali, decido se conservarle in base alla
% richiesta sul tempo di campionamento
if not(isempty(cQorg))
    % raccolta sample times
    [DtSet] = historySampleTime(tTH, cTorgSet);
    % se chiedo un sample time di esportazione più alto del maggiore sample
    % time originari,
    % allora cancello i dati originari
    if Dt_req > max(DtSet)
        tTH = rmOrgDataTH(tTH);
    end
end




return

