function out = LPfilter(time, in, tau, in0)


out = zeros(size(in));
% valore iniziale
cumul = in0 * tau;
out(1) = in0;

for i = 2:length(in)
    cumulNew = cumul + (in(i) - cumul/tau)  * (time(i)-time(i-1));
    out(i) = 1 / tau * cumulNew;
    % aggiorno
    cumul = cumulNew;
end


return