function tOutput = struct2DArrayTo3D(tInput, maxPages)

% INPUT: struct-array, ogni campo è una sottostruttura 1x1 dotata di campo
% "v", contenente il valore (vettore o matrice 2D).
% La funzione accetta anche valori pari a "[]", in tal caso non effettua
% nessuna operazione su quel campo.
% Per ogni campo, le dimensioni dei dati (valori) devono essere le stesse
% in tutti gli elementi dell'array.
%
% Se il contenuto è una matrice 2D, essa deve essere associata a due vettori
% (ad esempio, "vectX" e "vectY", associati rispettivamente alla seconda ed
% alla prima dimensione della matrice).
% In tal caso, allora, devono essere presenti anche i campi "x" e "y",
% contenenti il nome (char string) del relativo vettore di riferimento (che
% deve essere presente nella sottostruttura, sotto un campo avente lo stesso
% nome indicato dalla stringa, ed all'interno del loro sottocampo "v").
%
% ----- esempio -----
% tInput = 1x2 struct array with fields:
%     v_engPQM_i
%     m_fPQM_i
%     C_indCorrPQM_d
% MATRICE 2D:
% tInput(1).C_indCorrPQM_d = 
%     v: [100x102 double]
%     x: 'm_fPQM_i'
%     y: 'v_engPQM_i'
% VETTORE X (dimensione 2 della matrice):
% tInput(1).m_fPQM_i = 
%     v: [102x1 double]
% VETTORE Y (dimensione 1 della matrice):
% tInput(1).v_engPQM_i = 
%     v: [100x1 double]
%
% Per ogni campo contenente matrici 2D, la funzione alloca le matrici
% stesse (corrispondenti ai singoli elementi dello struct-array) in una
% matrice 3D (una "pagina" per elemento di array).
% Nel caso in cui i vettori di riferimento siano diversi tra i vari
% elementi dello struct-array, viene effettuata un'interpolazione su base
% comune, in modo da ottenere dei vettori di riferimento condivisi tra le
% varie "pagine" delle matrici 3D.
%
% OUTPUT: 1x1 struct, con gli stessi campi di tInput.
% Dove c'erano matrici 2D, ora ci sono le 3D.
% Dove c'erano i vettori di riferimento, ora ci sono quelli "condivisi"
% (generati con span uniforme tra il min e il max di tutti i vettori
% omologhi presenti nei vari elementi di tInput, eccetto il caso di vettori
% omologhi tutti uguali - ed allora ne prende uno)
%
% ----- esempio (maxPages=5) -----
% MATRICE 3D (solo le prime due "pagine" sono nonzero):
% tOutput.C_indCorrPQM_d = 
%     v: [100x102x5 double]
%     x: 'm_fPQM_i'
%     y: 'v_engPQM_i'
% VETTORE X "condiviso" (dimensione 2 della matrice):
% tOutput.m_fPQM_i = 
%     v: [102x1 double]
% VETTORE Y "condiviso" (dimensione 1 della matrice):
% tOutput.v_engPQM_i = 
%     v: [100x1 double]

Nmaps = length(tInput);
if Nmaps <= maxPages
    %allocazione vettori/matrici in struct 1x1
    tOutput = mtxAllocation(tInput, maxPages); 
    %interpola su base comune, in caso di vettori diversi
    tOutput = mapInterpolation(tOutput, Nmaps); 
else
    % troppi elementi: si deve piantare
    disp(['Error: length of tInput cannot be greater than ', num2str(maxPages), '.'])
    clear tOutput
end

return

function tOutput = mtxAllocation(tInput,maxPages)

% Primo step: allocazione.
% Metto i vettori per colonne all'interno di matrici 2D, e metto le matrici
% 2D all'interno di matrici 3D con numero di "pagine prefissato ("maxPages")
% INPUT: struct-array
% OUTPUT: 1x1 struct, compattato nel modo descritto
Nmaps = length(tInput);

% assumes first is full
tOutput = tInput(1);

fieldsIn = fields(tInput);
for b = 1:length(fieldsIn)
    try
        fieldB = fieldsIn{b};
        var = tOutput.(fieldB).v;  %valore (vett, mtx, [], ...)
        if isempty(var)
            %la variabile relativa a "fieldB" non è stata definita a monte, non
            %ha senso allocare nelle matrici
            mtx = [];
        else
            sz = size(var);
            if all(sz==1)
                % scalars
                mtx = zeros(maxPages, 1);
                for a = 1:Nmaps
                    var = tInput(a).(fieldB);
                    if not(isempty(var))
                        %se effettivamente l'elem dell'array è stato riempito
                        var = var.v;
                        mtx(a) = var;
                    end
                end
                
            elseif any(sz==1) && not(all(sz==1))
                %se è un vettore, lo alloco in una matrice 2D nelle posizioni
                %occupate (altrove, rimangono gli zeri)
                mtx = zeros(max(sz), maxPages);
                for a = 1:Nmaps
                    var = tInput(a).(fieldB);
                    if not(isempty(var))
                        %se effettivamente l'elem dell'array è stato riempito
                        var = var.v;
                        var = reshape(var,max(sz),1);  %se non era colonna, lo diventa
                        mtx(:,a) = var;
                    end
                end
                
            elseif all(sz>1)
                %se è una matrice 2D, la alloco in una matrice 3D nelle
                %posizioni occupate (altrove, rimangono gli zeri)
                mtx = zeros([sz maxPages]);
                for a = 1:Nmaps
                    var = tInput(a).(fieldB);
                    if not(isempty(var))
                        %se effettivamente l'elem dell'array è stato riempito
                        var = var.v;
                        if not(isempty(var))
                            mtx(:,:,a) = var;
                        end
                    end
                end
            else
                %caso non gestito, eventualmente da modificare...
                disp(['Attenzione, il campo ' fieldB ' non contiene vettori o matrici'])
                mtx = [];
            end
        end
        tOutput.(fieldB).v = mtx;  %sovrascrivo il valore nel nuovo 1x1 struct
        
    catch
        % generic error
        continue
    end
end

return

function tOutput = mapInterpolation(tInput,Nmaps)

% Secondo step: unificazione dei riferimenti (interpolazione su base comune).
% INPUT: 1x1 struct contenente, nei sottocampi "v", matrici 2D di vettori
% colonna di riferimento, e matrici 3D di mappe 2D (in tal caso, oltre al
% sottocampo "v", sono presenti i sottocampi "x" e "y").
% OUTPUT: 1x1 struct versione finale, con vettori "condivisi" e matrici 3D
% interpolate sulla base comune (nel caso di riferimenti diversi tra i PQM)

tOutput = tInput;
fieldsIn = fields(tInput);

% A - creazione vettori "condivisi" a partire dalle matrici 2D di vettori
% colonna, nel caso di disomogeneità di riferimenti: creo uno span equispaziato
% che copre il range di tutti i vettori
for b = 1:length(fieldsIn)
    try
        fieldB = fieldsIn{b};
        var0 = tOutput.(fieldB).v;
        if length(size(var0))==2 && not(isempty(var0))
            %se è una matrice di vettori colonna, elimino le colonne di zeri
            %(compatto) ed aggiungo i vettori comuni
            var = var0(:,not(all(var0==0)));
            if isempty(var)
                % means zero was the right value
                var = zeros(size(var0(:,1)));
            end
            %
            Ncol = size(var,2);
            Nelm = size(var,1);
            varMin = min(min(var));
            varMax = max(max(var));
            sComm = [fieldB '_comm'];
            %
            % in generale faccio uno span uniforme
            tOutput.(sComm).v = linspace(varMin, varMax, Nelm)';
            tOutput.(sComm).IntFlag = 1;
            %
            % se c'è una colonna sola (derivante da una tInput 1x1), oppure
            % se sono tutte uguali, prendo il primo vettore della matrice
            if Ncol ==1 || all(diff(var,1,2)==0)
                tOutput.(sComm).v = var(:,1);
                tOutput.(sComm).IntFlag = 0;
            end
            % se ci sono più colonne, cerco di usare comunque gli elementi comuni
            if Ncol >1
                % intersection
                varInter = var(:,1);
                for i = 2:Ncol
                    varInter = intersect(varInter, var(:,i));
                end
                % check if some elements are left
                if isempty(varInter)
                    continue
                end
                %
                tOutput.(sComm).v = infittimento(varInter, varMin, varMax, Nelm);
                tOutput.(sComm).IntFlag = 1;
            end
        end
    catch
        continue
    end
end

% B - interpolazione delle "pagine" delle matrici 3D sulle nuove basi
% comuni "condivise"
for b = 1:length(fieldsIn)
    try
        fieldB = fieldsIn{b};
        var = tOutput.(fieldB);
        if length(size(var.v))==3
            % interpolo solo se è una matrice 3D
            mtx3D = var.v;                         %matrice 3D
            Xname = var.x;
            varX = tOutput.(Xname).v;              %matrice 2D delle variabili x (per colonne)
            varXcomm = tOutput.([Xname '_comm']);  %vettore comune variabile x
            Yname = var.y;
            varY = tOutput.(Yname).v;
            varYcomm = tOutput.([Yname '_comm']);
            if varXcomm.IntFlag || varYcomm.IntFlag
                %se almeno uno dei due vettori di riferimento cambiava nei vari
                %elementi di "tInput", devo interpolare sulla base comune
                for a = 1:Nmaps
                    m3D = mtx3D(:,:,a);
                    if not(all(all(m3D==0)))
                        %se la "pagina" non è tutta di zeri, significa che è
                        %stata occupata
                        mtx3D(:,:,a) = interp2sat(varX(:,a),varY(:,a)',m3D,varXcomm.v,varYcomm.v');
                    end
                end
            end
            tOutput.(fieldB).v = mtx3D;  %sovrascrivo la matrice 3D con quella nuova
        end
    catch
        continue
    end
end

% C - sostituisco le matrici 2D di vettori colonna con i vettori comuni, ed
% elimino i campi ausisliari (non più utili)
for b = 1:length(fieldsIn)
    try
        fieldB = fieldsIn{b};
        var = tOutput.(fieldB).v;
        if length(size(var))==2 && not(isempty(var))
            %se è una matrice 2D di vettori colonna...
            fieldBcomm = [fieldB '_comm'];
            tOutput.(fieldB).v = tOutput.(fieldBcomm).v;
            tOutput = rmfield(tOutput,fieldBcomm);
        end
    catch
        continue
    end
end

return
