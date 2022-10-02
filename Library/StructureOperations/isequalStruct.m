function bEqual = isequalStruct(t1, t2)

% bEqual = isequalStruct(t1, t2)
%
% checks if the input structures t1, t2 are equal (same fields and same
% value in each fiels).
% If a fiels contains a structure, the check is iterated in depth to the structure
% (the fiels is checked to have same fields and same values), and again in
% depth.
% supports up to 5 dimensions indexed structs

bEqual = true;

[cF1, cF2, cFu] = fields(t1, t2);

% check if fields are the same
if isempty(cF1) && isempty(cF1)
    return
elseif not(isequal(cF1, cFu)) || not(isequal(cF2, cFu))
    bEqual = false;
    return
end

% check dimensions
[d1a, d1b, d1c, d1d, d1e] = size(t1);
[d2a, d2b, d2c, d2d, d2e] = size(t2);
if not(isequal(d1a,d2a)) ||...
        not(isequal(d1b,d2b)) ||...
        not(isequal(d1c,d2c)) ||...
        not(isequal(d1d,d2d)) ||...
        not(isequal(d1e,d2e))
    bEqual = false;
    return
end
da = d1a;
db = d1b;
dc = d1c;
dd = d1d;
de = d1e;

% check fields value
for ia = 1:da
    for ib = 1:db
        for ic = 1:dc
            for id = 1:dd
                for ie = 1:de
                    
                    % check algoritm
                    for iF = 1:length(cFu)
                        sF = cFu{iF};
                        val1 = t1(ia, ib, ic, id, ie).(sF);
                        val2 = t2(ia, ib, ic, id, ie).(sF);
                        % check
                        if isstruct(val1) && isstruct(val2)
                            % if both are structs, recall recursively the isequalStruct
                            if not(isequalStruct(val1, val2))
                                bEqual = false;
                                return
                            end
                        elseif (isstruct(val1) && not(isstruct(val2))) ||...
                                (not(isstruct(val1)) && isstruct(val2))
                            % if only one is struct
                            bEqual = false;
                            return
                        else
                            % check if values are the same
                            if not(isequal(val1, val2))
                                bEqual = false;
                                return
                            end
                        end
                    end
                    % end of check
                    
                end
            end
        end
    end
end



return

function [cF1, cF2, cFu] = fields(t1, t2)

cF1 = sort(fieldnames(t1));
cF2 = sort(fieldnames(t2));

cFu = union(cF1, cF2);

return