function assignin2(option,variable,varargin)
% assignin2(option,variable,value)
% assignin2(option,tVar)
% ASSIGNIN2 crea variabili nel workspace corrente o nel base, non nel
% chiamante, per il quale ci va ASSIGNIN
%
% option: ['current','base'];
% variable: vettore cell array dei nomi delle varibili da assegnare
% value: vettore cell array del contenuto da assegnare 
%
% esempio: assignin2('current',{'a','b'},{[1 2],'ciao!'})

% controllo opzione 
switch option
   case 'caller' % "caller" non è gestita
      disp('per questa opzione è necessario chiamare la funzione Matlab predefinita "assignin"')
      return
   case 'current' %il caso corrente è per questa funzione il chiamante
      option = 'caller';
   case 'base' %il base è sempre il base
      option = 'base';
end
%assegnazione variabili
if isstruct(variable) % se variable è struttura di salvataggio dati
    fNames = fieldnames(variable);
    for i=1:length(fNames)
        assignin(option, fNames{i}, variable.(fNames{i}));
    end
else
   value = varargin{1};
    L = length(variable);
    if L>1 %se vettore di variabili
       %controllo coerenza lunghezza di value e variable   
       if length(variable) ~= length(value)
          disp('la lunghezza di variable deve essere pari a quella di value!')
          return
       end
       %ciclo di assegnazione
       for i=1:L
          assignin(option, variable{i},value{i});
       end
    elseif  L==1 % lunghezza 1 può significare sia un solo elemento che vettori vuoti
       if not(isempty(variable{1})) &&  not(isempty(value{1})) % per una variabile sola posso avere sia contenuto (nome e valore) specificato in cell array che in modo diretto
           try 
              assignin(option, variable{1},value{1});
           catch
              assignin(option, variable(1),value(1));
           end
        else %se vettori vuoti non faccio niente
       end
    end
end
return