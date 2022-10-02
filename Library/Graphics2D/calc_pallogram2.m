function [xout, yout, zout]=calc_pallogram2(delta_y, delta_rpm, rpm_idle, ...
                                            rpmFL, pmeFL, timeH, giriH, pmeH, ...
                                            grInstH, flagTimeBsfc)
                                         
% [xout, yout, zout]=CALC:PALLOGRAM2(delta_y, delta_rpm, rpm_idle, ...
%                                    rpmFL, pmeFL, ...
%                                    timeH, giriH, pmeH, grInstH, ...
%                                    flagTimeBsfc)
%       
% parametri di input
% delta_y      spaziatura della palle lungo l'asse Y (carico motore: PME,
%              coppia, o potenza)  
% delta_rpm    spaziatura della palle lungo l'asse del regime (asse X) 
% rpm_idle     regime minimo del motore
% rpmFL, pmeFL curva di pieno carico del motore: vettori, della stessa
%              lunghezza, contenenti rispettivamente regime e carico max 
%              (PME, coppia, oppure potenza)
% timeH, giriH, pmeH, grInstH    
%              vettori, tutti della stessa lunghezza, contenenti la time
%              history da analizzare: tempo, regime, carico motore (PME,
%              coppia, o potenza), consumo istantaneo/emissioni istantanee
% flagTimeBsfc flag per scegliere se calcolare il pallogramma del consumo
%              oppure il pallogramma del tempo
% delta_y, pmeFL e pmeH devono riferirsi alla stessa grandezza (tutti e tre
%  in PME, oppure tutti e tre in coppia e così via)
% 
% 
% parametri di output 
% xout yout    matrici che rappresentano la suddivisione in celle (bin) del
%              piano di funzionamento del motore e degli assi X e Y. 
%              Il numero di righe delle matrici corrisponde al numero di
%              celle in cui è suddiviso il piano di funzionamento del motore. 
%              Le matrici hanno due colonne: nella prima ci sono i numeri
%              delle celle in cui è diviso l'asse X o Y cella, nella seconda
%              il valore X o Y corrispondente al centro della cella
% 
% zout         vettore, della stessa lunghezza di xout e yout, contenente
%              le percentuali di consumo/tempo cumulato spettanti a
%              ciascuna cella in cui è suddiviso il piano di funzionamento
%              del motore
%
% 12/02/2010, G. Guenna, FPT-RT



delta_t=mean(diff(timeH));
delta_bmep=delta_y;
delta_giri= delta_rpm;
min_rpm= arrotonda(rpm_idle,  delta_giri);
max_rpm= arrotonda(max(rpmFL),delta_giri,'ceil');   % regime max 

min_pme= 0;
max_pme= arrotonda(max(pmeFL),delta_bmep,'ceil');
stati_giri_min= min_rpm - (delta_giri/2);
stati_giri_max= max_rpm + (delta_giri/2);
stati_bmep_min= min_pme - (delta_bmep/2);
stati_bmep_max= max_pme + (delta_bmep/2);

nBin_bmep=(stati_bmep_max-stati_bmep_min) / delta_bmep;
nBin_giri=(stati_giri_max-stati_giri_min) / delta_giri;

nBin_bmep=ceil(nBin_bmep);
nBin_giri=ceil(nBin_giri);

centroBin_bmep= min_pme + delta_bmep*[0:nBin_bmep-1]';
centroBin_giri= min_rpm + delta_giri*[0:nBin_giri-1]';
shBin_bmep = rem(centroBin_bmep(1), delta_bmep);
shBin_giri = rem(centroBin_giri(1), delta_giri);

n_cella=zeros(nBin_bmep*nBin_giri,1); 


x=[fix((-0.1+[1:length(n_cella)])/nBin_bmep)+1]';
y=[mod([1:length(n_cella)],nBin_bmep)]';
y(y==0)=nBin_bmep;
x(:,2)=centroBin_giri(x(:,1));
y(:,2)=centroBin_bmep(y(:,1)); 

giri_Binned=arrotonda(giriH-shBin_giri, delta_giri)+shBin_giri;
giri_Binned=max(giri_Binned, min_rpm);
giri_Binned=min(giri_Binned, max(centroBin_giri));
giri_Binned=reshape(giri_Binned,[],1);

bmep_Binned=arrotonda(pmeH-shBin_bmep, delta_bmep)+shBin_bmep;
bmep_Binned=max(bmep_Binned, min_pme);
bmep_Binned=min(bmep_Binned, max(centroBin_bmep));
bmep_Binned=reshape(bmep_Binned,[],1);

n_cella=zeros(nBin_bmep*nBin_giri,1);

% Per ogni punto della time history, calcolo in quale cella di PME, coppia
%  e giri va a cadere;  conto quanti valori sono caduti in ciascuna cella 
[qc_bmep, n_bmep]=qualecella(bmep_Binned,centroBin_bmep, 'real');
[qc_giri, n_giri]=qualecella(giri_Binned,centroBin_giri, 'real');

% Per ogni punto della time history, calcolo in quale cella delle matrici
%  regime-pme e coppia-pme  va a cadere  
qc_PQ=nBin_bmep*(qc_giri-1)+qc_bmep;

% Trovo le celle che contengono almeno un punto, ed eseguo i calcoli che
%  seguono solo per le celle non vuote. 
% bs, bd e bn sono variabili ausiliarie; do per scontato che qc_PQ e
%  qc_PT non siano vuoti
bs=sort(qc_PQ); 
% bd=[1; diff(bs)]; 
bn=find([1; diff(bs)]~=0); 
ncp=length(bn);
celle_piene=bs(bn);
[dum, z_cella]=qualecella(qc_PQ, celle_piene, 'integer');
for zz=1:ncp
    n_cella(celle_piene(zz))=z_cella(zz);
end
clear bs bn

% Calcolo la distribuzione del consumo (o altra grandezza) cumulato sul
%  piano regime-pme, eseguendo il calcolo solo per le celle piene 
% consumo cumulato cella per cella
FC_pq1=zeros(nBin_bmep*nBin_giri,1);
FC_pq0=zeros(ncp,1);
switch flagTimeBsfc
   case 'time'
      % for icp=1:ncp
      %    FC_pq0(icp)=sum(timeH(qc_PQ==celle_piene(icp))).*delta_t;
      %    FC_pq1(celle_piene(icp),1)=FC_pq0(icp);
      % end
      timeD=([delta_t; diff(timeH)]+[diff(timeH); delta_t])/2; 
      % timeD durata di ogni campione
      for icp=1:ncp
         % FC_pq0(icp)=sum(timeH(qc_PQ==celle_piene(icp))).*delta_t;
         FC_pq0(icp)=sum(timeD(qc_PQ==celle_piene(icp)));
         FC_pq1(celle_piene(icp),1)=FC_pq0(icp);
      end
   case 'bsfc'
      for icp=1:ncp
         FC_pq0(icp)=sum(grInstH(qc_PQ==celle_piene(icp))).*delta_t;
         FC_pq1(celle_piene(icp),1)=FC_pq0(icp);
      end
end

FC_pq1perc=FC_pq1./sum(FC_pq0)*100;    % uso sum(FC_pq0) per avere
                                       %  come somma 100% esatto
xout=x;
yout=y;
zout=FC_pq1perc;

consumo_tot=sum(FC_pq0); % a scopo di controllo

return



function [qc,n]=qualecella(x, centro_cella, modo)
   % versione modificata del 19/11/2007 (Guenna)
   THIS_FUNCTION=mfilename;
   titolo=['Error in ', upper([THIS_FUNCTION '\qualecella'])];

   % X deve essere un vettore colonna, con valori già riportati a quelli
   %   presenti in CENTRO_CELLA
   % CENTRO_CELLA deve essere un vettore
   % MODO può avere i valori 'real' e 'integer': nel modo "real" (il modo
   %   di default), anziché cercare l'uguaglianza esatta, si ammette una
   %   tolleranza;  nel modo "integer", si cerca l'uguaglianza esatta.
   %
   % QC indica in quale cella si trova ciascun elemento di X: ha la stessa
   %    lunghezza di X
   % N  indica quanti elementi di X ci sono in ciascuna cella; ha la stessa
   %    lunghezza di CENTRO_CELLA

   ncelle=length(centro_cella);
   switch lower(modo)
      case 'integer'
         xi=int16(x);
         centroi=int16(centro_cella);
         for ic=1:ncelle
            b=(xi==centroi(ic));
            n(ic,1)=sum(b);
            q(:,ic)=int16(ic.*b);
         end
         qc=sum(q,2);

      otherwise      % default: caso "real"
         % anziché usare l'operatore == (uguale esatto), consento una tolleranza
         vmax=max(abs(centro_cella));
         toll=vmax*1e-7;
         for ic=1:ncelle
            b=(abs(x-centro_cella(ic))<=toll);
            n(ic,1)=sum(b);
            q(:,ic)=ic.*b;
         end
         qc=sum(q,2);
   end

   if sum(n)~=length(x)
      tF.message='Qualche punto è sfuggito alla ripartizione in celle';
      tF.stack=dbstack;
      msgbox(tF.message,titolo, 'error');
      errore=lasterror(tF);
      return
   end

return