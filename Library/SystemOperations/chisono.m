function [nomeUtente, nomePC] = chisono()
% CHISONO    trova il nome dell'utente e del computer
%                                            by Guenna,  1 ottobre 2002
%                                                       26 maggio 2006

% % [s, a]=system('net name');
% a=evalc('!net name');

% Il comando DOS "net name" produce la seguente tabellina 

%              riga vuota lasciata dal DOS
%Nome             
%--------------------------------------------------------------------------- 
%PD0299           
%PD0299$               (riga non sempre presente)
%GUENNA           
%Esecuzione comando riuscita.  
%              riga vuota lasciata dal DOS
 
% Perciò, per trovare i nomi del PC e dell'utente, faccio così: 
%  (1) cerco i ritorni a capo (char(10))
%  (2) nella quarta riga trovo il nome del PC, nella quinta o sesta quello
%      dell'utente 

% Se il computer non è connesso alla rete, il comando DOS "net name"
%  produce la seguente scritta

% Non ci sono voci nell'elenco.
%              riga vuota lasciata dal DOS

% Allora cerco i nomi dell'utente e del computer con il comando DOS "set",
%  "set username" e "set computername". Siccome questi comandi non richie-
%  dono la connsessione in rete, evitare di usare "net name"

% % a=strrep(a,' ','');    % tolgo gli spazi intermedi
% % x=find(a==char(10));
% % if length(x)>2         % in questo caso, il PC è connesso in rete
% %    nomePC = (a((x(3)+1):(x(4)-1)));
% %    % nomePC = deblank(nomePC);
% %    nomeUtente=a((x(4)+1):(x(5)-1));
% %    if strncmp(nomePC,nomeUtente,length(nomePC))
% %       nomeUtente=a((x(5)+1):(x(6)-1));
% %    end
% %    % nomeUtente=deblank(nomeUtente);
% % else
   [s, b]=system('set computername');
   if s==0
      b=b(b~=char(10));
      y=find(b=='=');   y=y(end);
      nomePC     = upper(b(y+1:end));
   else
      nomePC     = 'PC_ignoto';
   end
   [s, c]=system('set username');
   if s==0
      c=c(c~=char(10));
      y=find(c=='=');   y=y(end);
      nomeUtente = upper(c(y+1:end));
   else
      nomeUtente = 'Signor_X';
   end
% % end
clear s a b c x y

return