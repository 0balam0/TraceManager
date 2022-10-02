function deploySmkModel_PSF()
%
% crea s-functions a partire dai Simulink selezionati da interfaccia
% La compilazione è effettuata mediante rtwsfcn.tlc
% Per ogni modello selezionato da interfaccia bisogna fornire nel file
% "listaPSF.m" l'elenco dei sottoblocchi che si vogliono compilare come
% s-functions.

% RICORDA:
% save_system('exe_2DOF_MT_PSF','exe_2DOF_MT_PSF','BreakUserLinks',true)

% promemoria di modelli e relativi file di workspace da cui trarre le
% variabili da tunare
uiwait(msgbox({'Ricorda: ', ''...
        'Ogni modello da compilare deve avere il nome "exe_modelName.mdl"','',...
        'Per ogni modello da compilare deve esistere nella directory corrente'...
        'un file da cui estrarre le variabili da tunare dal nome "wsp_modelName.mat"'},...
        'requisiti per compilazione',...
        'modal'));

% selezione modelli da compilare
[filename, sPath] = uigetfile({'*.mdl','modelli Simulink (*.mdl)'}, 'seleziona i modelli da compilare', 'MultiSelect','on');
if isnumeric(filename) && filename==0 % se premo "annulla"
   return
end
if ischar(filename) % cell array dei modelli
   filename = {filename};
end
cModelName = cell(length(filename),1);
for i=1:length(filename)
   cModelName{i} = filename{i}(5:end-4);
end     

% chiudo libreria simulink in memoria
close_system('SimuDynSBlockset')

%
% memorizzo e cancello il wsp base vecchio 
tWspBaseOld = wsp2struct('wsp','base');
evalin('base', 'clear') 
%

% estrazione dei soli sottoblocchi comuni ai vari modelli selezionati
[cComSF, cB] = unioneBlocchi(cModelName);

%
% ciclo sui modelli da compilare
for i = 1:length(cModelName)
   %
   % apro il modello simulink (vari comandi basati su get_param lo richiedono)
   sModel = ['exe_', cModelName{i}];
   open_system(sModel)
   %
   % carico le variabili necessarie ai modelli Simulink nel wsp base (solo lì va bene)
   tLoad = load(['wsp_', cModelName{i}, '.mat']);
   assignin2('base', tLoad)
   %
   %---aggiorno la lista di variabili tunable---
   refreshTunVars(sModel)
   save_system(sModel)
   rtwSystemTargetFileOrg = get_param(sModel,'rtwSystemTargetFile');
   rtwTemplateMakeFileOrg = get_param(sModel,'rtwTemplateMakeFile');
   % 
   % settaggi di RTWSFNC, modifico e salvo il modello
   set_param(sModel, 'rtwSystemTargetFile', 'rtwsfcn.tlc', 'rtwTemplateMakeFile','rtwsfcn_default_tmf');
   save_system(sModel)
   
   % directory di salvataggio s-functions e relativi modelli 
   sPSFDir = [sPath,'PSF'];
   if exist(sPSFDir,'dir')==0
      mkdir(sPSFDir);
   end
   % elenco delle s-functions da creare per ogni modello
   cSFs = cComSF{i};
   % ciclo sulle s-functions
   for j = 1:length(cComSF{i})
      if cB{i}{j}
         cSFs1 = [sModel,'/',cSFs{j}];
         % apro il sottoblocco e lo compilo
         try
            open_system(cSFs1)
            hSFmod = rtwbuild(cSFs1);

            % butto via il file autocreato del modello che contiene il link alla
            % S-function (solo per aggiornamento delle parti? Dovrei aggiornare il modello che contiene le s-functions...)
            %
            %%% cancello files di compilazione
            % nomi e percorsi
            sBlockName = get_param(hSFmod,'name'); % nome del blocco originario
            sSubModel = get_param(hSFmod,'parent'); % nome del file modello autocreato
            cMaskNames = get_param([sSubModel, '/', sBlockName, '/', sBlockName,'_sfcn'], 'MaskNames');
            cMaskValues = get_param([sSubModel, '/', sBlockName, '/', sBlockName,'_sfcn'], 'MaskValues');
            cFcnName = cMaskValues(strcmpi(cMaskNames,'rtw_sf_name')); % nome della s-function (può essere diverso dal blocco originario)
            sSfName = cFcnName{1};
            % cancellazione
            delete([sSfName,'.c'])
            delete([sSfName,'.h'])
            rmdir([sSfName,'cn_rtw'],'s')
            rmdir('slprj','s')
            % salvo in un'apposita directory il modello autocreato che sostituisce il sottosistema.mdl con
            % il link alla S-function, poi lo chiudo e chiudo il il sottosistema.mdl
            sSubModelNew = [sPSFDir, '\psf_',sBlockName]; % nome convenzionale
            save_system(sSubModel, sSubModelNew)
            close_system(sSubModelNew, 0)
            copyfile([sSfName,'.mexw32'], [sPSFDir,'\',sSfName,'.mexw32'], 'f')
            clear(sSfName) % rimuovo la s-fucn dalla memoria
            delete([sSfName,'.mexw32'])
            sSfunName = [sSfName,'un'];
            clear(sSfunName)
            if exist([sSfunName,'.mexw32'],'file') == 3
               delete([sSfunName,'.mexw32']) % eventuale file generato da stateflow/emf
            end
            %
            close_system(cSFs1)
            % TODO: collocamento in libreria dei sSubModelNew
            % Poi il modello complessivo:
            % save_system('exe_2DOF_MT_PSF.mdl','exe_2DOF_MT_PSF.mdl','BreakUserLinks',true)
         catch
            lasterr
            continue
         end
      else
         continue
      end
   end
   %
   %---parti finali---
   % ripristino settaggi precedenti settaggi
   ripristinaModello(sModel, rtwSystemTargetFileOrg, rtwTemplateMakeFileOrg)
end
%
% cancello altre directory di compilazione
if isdir('sfprj')
   rmdir('sfprj','s')
end
%
% ripristino il wsp base originale
evalin('base', 'clear') 
assignin2('base', tWspBaseOld)
%
return

function ripristinaModello(sModel, rtwSystemTargetFileOrg, rtwTemplateMakeFileOrg)

%
set_param(sModel, 'rtwSystemTargetFile', rtwSystemTargetFileOrg, 'rtwTemplateMakeFile',rtwTemplateMakeFileOrg);
if strcmp(get_param(sModel,'rtwSystemTargetFile'),'rsim.tlc')
   set_param(sModel, 'RSIM_PARAMETER_LOADING', 'on', 'MatFileLogging', 'on');
end
save_system(sModel)
close_system(sModel)
return

function [cComSF, cB] = unioneBlocchi(cModelName)

% lista modello per modello di tutti i blocchi da compilare
cComSF = cell(length(cModelName),1); 
% nome completo di tutti i blocchi
for i = 1:length(cModelName)
   sModel = ['exe_', cModelName{i}];
   cComSF{i} = listaPSF(sModel);
end
%
c0 = cell(length(cComSF{1}),1);
cB = cell(length(cModelName),1);
for i = 1:length(cComSF{1})
   [dum, c0{i}] = fileparts(cComSF{1}{i});
end
%
c2 = cComSF{1}; % contiene l'unione dei blocchi da compilare
a = length(c2);
for j = 1:length(c2)
   [dum, c2{j}] = fileparts(c2{j});
   cB{1}{j} = true; % dice quale blocchi compilare
end
%
% ciclo sui modelli
for i = 2:length(cModelName)
   c1 = cComSF{i};
   % ciclo sui blocchi
   for j = 1:length(c1)
      [dum, sBlockName] = fileparts(c1{j});
      if any(strcmpi(c2,sBlockName))
         % il blocco corrente è gia fra quelli comuni, non lo compilo
         cB{i}{j} = false;
      else
         % il blocco corrente non è ancora fra quelli comuni: da
         % aggiungere, lo compilo
         cB{i}{j} = true;
         a = a+1;
         c2{a} = sBlockName;
      end
   end
end

return
























