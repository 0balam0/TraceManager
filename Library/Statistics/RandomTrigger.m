function [nStatVal, errore] = RandomTrigger(sDistr, Media, sSigma, ...
                                            nRow, nCol, ...
                                            sSogliaDW, sSogliaUP, varargin)
                                         
% [nStatVal, errore] = RandomTrigger(sDistr, Media, sSigma, nRow, nCol, ...
%                                    sSogliaDW, sSogliaUP)
% [nStatVal, errore] = RandomTrigger(sDistr, Media, sSigma, nRow, nCol, ...
%                                    sSogliaDW, sSogliaUP, Prosegui)
% 
% Genera matrici casuali estratte dalla distribuzione indicata, mantenendo
% i valori all'interno dei limiti specificati.
%
% SDISTR:    stringa: nome della distribuzione.
% MEDIA:     numero:  valore medio della distribuzione.
% SSIGMA:    a) stringa che rappresenta un numero e termina con il caratte-
%               re "%": sigma della distribuzione, espressa in percentuale
%               rispetto al valore medio (privo di segno). 
%               ATTENZIONE: se MEDIA vale zero, allora anche la sigma della
%               distribuzione assegnata in questo modo è nulla;  
%            b) numero, o stringa che rappresenta un numero, senza carat-
%               tere "%":  sigma della distribuzione, espressa nella stessa
%               unità del valore medio. 
% NROW:      numero:  numero di righe della matrice dei risultati NSTATVAL.
% NCOL:      numero:  numero di colonne della matrice dei risultati NSTATVAL.
% SSOGLIADW: a) stringa che rappresenta un numero, inizia con il carattere
%               "-" e finisce con il carattere "%": limite inferiore per
%               l'accettabilità dei risultati, espresso come distanza
%               percentuale dal valor medio (trascurandone il segno).
%               ATTENZIONE: se MEDIA vale zero anche il limite inferiore di
%               accettabilità assegnato in questo modo vale zero e la gran-
%               dezza rimane invariata (nella versione di luglio 2006
%               invece dava errore);  
%            b) (analogo al caso (b) per SIGMA): limite inferiore per
%               l'accettabilità dei risultati, espresso nella stesse unità
%               del valore medio;
%            c) vuoto:  significa che non c'è un limite inferiore per
%               l'accettabilità dei risultati.
% SSOGLIAUP: a) (analogo al caso (a) per SIGMA): limite superiore per
%               l'accettabilità dei risultati, in modo simile a SSOGLIADW;
%               ATTENZIONE: se MEDIA vale zero, vedi sopra;
%            b) analogo al caso (b) per SSOGLIADW;
%            c) analogo al caso (c) per SSOGLIADW.
% PROSEGUI:  argomento opzionale, numerico, per scegliere il risultato
%            della funzione in caso di errore. In presenza di un errore, se
%            MEDIA è valido, la funzione RandomTrigger si comporta nel
%            seguente modo: se PROSEGUI è diverso da 0, restituisce una 
%            matrice delle dimensioni desiderate, con tutti i valori uguali
%            a MEDIA; se PROSEGUI manca o vale 0, restituisce una matrice
%            vuota. Se l'errore riguarda MEDIA, viene restituita una
%            matrice vuota. 
%
% ERRORE: se non ci sono errori, è una stringa vuota; altrimenti, è una
%         struttura compatibile con LASTERROR
%
% See also RANDOM.

% Versione del 31 agosto 2006. 
% Le differenze rispetto alla versione di luglio 2006 sono due: 
%  1) la generazione dei valori casuali estratti dalla distribuzione
%     statistica avviene in modo vettoriale anziché scalare;
%  2) la function accetta, senza più dare errore, di operare su grandezze
%     con valor medio uguale a zero  anche se la deviazione standard e le
%     soglie sono espresse in percentuale. 
% Modifiche del 5 settembre 2006: 
%  1) messaggi di errore in italiano;
%  2) accettazione di un valore di soglia (uno solo dei due) uguale al valor
%     medio;
%  3) possibilità, in caso di errore, di proseguire restituendo all'uscita,
%     invariato, il valore di ingresso.
% Modifiche dell'8 settembre 2006: 
%  correzione di un errore.
%
% See also RANDOM.

nStatVal=[];
errore='';
THIS_FUNCTION=mfilename;
titolo=['Error in ', THIS_FUNCTION];

% controllo il numero degli argomenti di ingresso
if nargin < 7
   tF.message='La funzione richiede almeno sette argomenti all''ingresso';
   tF.stack=dbstack;
   msgbox(tF.message,titolo, 'error');
   errore=lasterror(tF);
   return
end

% leggo e controllo Prosegui (parametro opzionale)
if nargin > 7
   Prosegui=varargin{1};
   if isempty(Prosegui);      Prosegui=0; end
   if ~isnumeric(Prosegui);   Prosegui=0; end
   % Prosegui deve essere scalare: correggo "d'ufficio"
   Prosegui=Prosegui(1);
else
   Prosegui=0;
end

% leggo e controllo Media
if ischar(Media)
   % tF.message='MEDIA (distribution mean value) must be numeric';
   tF.message='MEDIA (valor medio della distribuzione) deve essere numerico';
   tF.stack=dbstack;
   msgbox(tF.message,titolo, 'error');
   errore=lasterror(tF);
   return
end   
if isempty(Media)
   % tF.message='Missing MEDIA (distribution mean value)';
   tF.message='Manca MEDIA (valor medio della distribuzione)';
   tF.stack=dbstack;
   msgbox(tF.message,titolo, 'error');
   errore=lasterror(tF);
   return
end   

% leggo e controllo Sigma 
k=findstr(sSigma,'%');
if isempty(k)
   Sigma=str2num(sSigma);
else
   Sigma=str2num(sSigma(1:k-1));
	Sigma=abs(Media)*Sigma/100;
end
if isempty(Sigma)
   % tF.message='Missing SIGMA';
   tF.message='Manca SIGMA';
   tF.stack=dbstack;
   msgbox(tF.message,titolo, 'error');
   errore=lasterror(tF);
   if Prosegui
      nStatVal=Media.*ones(nRow,nCol);
   end
   return
end
% Media e Sigma devono essere scalari: correggo "d'ufficio"
Media=Media(1);
Sigma=Sigma(1);
% se Sigma è negativo, prendo il valore assoluto (oppure, do errore)
Sigma=abs(Sigma);
% % % % if Sigma<0
% % % %    tF.message='SIGMA is less than zero';
% % % %    tF.message='SIGMA è minore di zero';
% % % %    tF.stack=dbstack;
% % % %    msgbox(tF.message,['Error in ', THIS_FUNCTION], 'error');
% % % %    errore=lasterror(tF);
% % % %    return
% % % % end

% leggo le soglie
Null=0;
if strcmpi(sSogliaDW , '') | isempty(sSogliaDW)
    Trg=0;
    SogliaDW=0;
else
    Trg=1;
    k=findstr(sSogliaDW,'%');
    if isempty(k)
%      valore "assoluto"
       SogliaDW=str2num(sSogliaDW);
    else
       SogliaDW=str2num(sSogliaDW(1:k-1));
       SogliaDW=Media*(1+sign(Media)*SogliaDW/100);
       if Media==0;  Null=1;   end        % aggiunta del 31/08/06
    end
end
if isempty(SogliaDW); SogliaDW=0; end
%
if strcmpi(sSogliaUP,'') | isempty(sSogliaUP)
    Trg=Trg+0;
    SogliaUP=0;
else
    Trg=Trg+2;
    k=findstr(sSogliaUP,'%');
    if isempty(k)
%      valore "assoluto"
       SogliaUP=str2num(sSogliaUP);
    else
       SogliaUP=str2num(sSogliaUP(1:k-1));
       SogliaUP=Media*(1+sign(Media)*SogliaUP/100);
       if Media==0;  Null=1;   end        % aggiunta del 31/08/06
    end
end
if isempty(SogliaUP); SogliaUP=0; end
% anche le soglie UP e DW devono essere scalari: correggo "d'ufficio"
SogliaUP=SogliaUP(1);
SogliaDW=SogliaDW(1);

% controllo che le soglie di accettabilità siano messe bene; se c'è un
% errore, esco
bad=0;
% s0='SogliaUP (upper threshold) must be ';
s0='SogliaUP (soglia superiore) deve essere ';
% se ci fossero più errori, viene segnalato il primo che è stato trovato
if Trg==1 | Trg==3
   % if (SogliaDW >= Media) & ~Null
   if (SogliaDW > Media) & ~Null          % modifica del 5/09/06
      bad=bad+1;
      if bad==1
         % tF.message=[s0 'less than mean value'];
         % tF.message=[s0 'less than or equal to mean value'];
         % tF.message([7:13])='DW (low';
         tF.message=[s0 'minore o uguale al valor medio'];
         tF.message([7:8 18:21])='DWinfe';
         tF.stack=dbstack;
         errore=lasterror(tF);
      end
   end
end
if Trg==2 | Trg==3
   % if (SogliaUP <= Media) & ~Null
   if (SogliaUP < Media) & ~Null          % modifica del 5/09/06
      bad=bad+1;
      if bad==1
         % tF.message=[s0 'greater than mean value'];
         % tF.message=[s0 'greater than or equal to mean value'];
         tF.message=[s0 'maggiore o uguale al valor medio'];
         tF.stack=dbstack;
         errore=lasterror(tF);
      end
   end
end
if Trg==3 & Null==0                     % modifica dell'8/09/06
   % if SogliaDW > SogliaUP             
   if SogliaDW >= SogliaUP              % modifica del 5/09/06
      bad=bad+1;
      if bad==1
         % tF.message=[s0 'greater than SogliaDW (lower threshold)'];
         tF.message=[s0 'maggiore di SogliaDW (soglia inferiore)'];
         tF.stack=dbstack;
         errore=lasterror(tF);
      end
   end
end
% esco in caso di errore
if bad
   if bad>1
      titolo=['More errors in ', THIS_FUNCTION];
      msgbox([tF.message ', ed altro'], titolo, 'error');
   end   
   msgbox(tF.message , titolo, 'error');
   if Prosegui
      nStatVal=Media.*ones(nRow,nCol);
   end
   return
end
   
% Genero i valori casuali estratti dalla distribuzione statistica, in modo
% vettoriale
if Null
%  in questo caso, non c'è dispersione statistica   
   nStatVal=Media.*ones(nRow,nCol);
else
   if Trg
%     se c'è una qualche soglia
      stadentro=[];
      nAux=2;
      nStatAux0=[];
            
      while length(nStatAux0) < nRow*nCol
%          nAux=nAux+1;
         nStatAux=random(sDistr,Media,Sigma, nAux*nRow*nCol,1);
         switch Trg
            case 1
%           soglia DW
               stadentro=find(nStatAux >= SogliaDW);
            case 2
%           soglia UP
               stadentro=find(nStatAux <= SogliaUP);
            case 3
%           soglia UP-DW
               stadentro=find(nStatAux >= SogliaDW  &  nStatAux <= SogliaUP);
         end
         nStatAux0=[nStatAux0;nStatAux(stadentro)];
      end
      % ora i casi buoni sono in numero sufficiente: ne prendo il numero
      %  desiderato cominciando dal primo (volendo, posso prenderli al
      %  centro dell'insieme o da un'altra parte) 
      nStatVal=reshape(nStatAux0(1:nRow*nCol),nRow,nCol);
   else
%     se non c'è nessuna soglia
      nStatAux=random(sDistr,Media,Sigma, nRow*nCol,1);
      nStatVal=reshape(nStatAux,nRow,nCol);
   end
end


%    nStatVal
return;