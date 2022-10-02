function tOut = aggiungiCampi(tOut, tAdd, varargin)
% aggiunge alla struttura tOut i campi di tAdd, sovrascrivendo quelli
% eventualmente già presenti.In pratica fa lavoro di fieldAppend ma in 
% modo più veloce (secondo l'help Matlab); non ha la gestione errori integrata

% varargin management
bAddEmpty = true;
if not(isempty(varargin))
    % adds empty fiels
    a = find(strcmpi(varargin, 'AddEmptyFields'));
    if not(isempty(a))
        bAddEmpty = varargin{a+1};
    end
end

% values
sV = 'v';

cFields = fieldnames(tAdd);
if isempty(tAdd) || not(isstruct(tAdd))
    return
else
    if isstruct(tOut)
        for i = 1:length(cFields)
            val = tAdd.(cFields{i});
            % gets value if present
            if isfield(val, sV)
                val = val.(sV);
            end
            % adds empty data only if allowed
            if not(isempty(val)) || bAddEmpty
                tOut(1).(cFields{i}) = tAdd.(cFields{i});
            end
        end
    end
end
return