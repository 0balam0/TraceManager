function sF0 = modelPathCorrection(sF)
% in case name contains '/', name is corrected to double "//"


sF0 = char(zeros(1, 1024, 'int8'));
a = 1;
for i = 1:length(sF)
    sF0(a) = sF(i);
    if isequal(sF(i), '/')
        a = a+1;
        sF0(a) = '/';
    end
    a = a+1;
end
sF0 = sF0(1:a-1);

return