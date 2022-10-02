function b = isemptyFields(t, sF)

% verifica se gli n campi sF della struttura t(n).sF sono vuoti

[r,c] = size(t);
b = false(r,c);
for i = 1:r
    for j = 1:c
        b(i,j) = isempty(t(i,j).(sF));
    end
end

return