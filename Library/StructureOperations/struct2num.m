
function [t] = struct2num(tOld)
%
% % COSTANTI
THIS_FUNCTION = mfilename;
% % INIZIO FUNCTION
try
    t = tOld;
    if isempty(tOld)
        return;
    end
    %
    cFields = fieldnames(tOld);
    for i = 1:length(cFields)
        val = str2double(tOld.(cFields{i}));
        if not(isnan(val))
           t.(cFields{i}) = val;
        end
    end
% % GESTIONE ERRORI 
catch
    gestErr2(THIS_FUNCTION);
end

return;




