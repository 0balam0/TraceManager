function yOut_d = invertiMappa(xIn_i, yIn_i, zIn_d, xOut_i, zOut_i)

% FUNCTION
% yOut_d = invertiMappa(xIn_i, yIn_i, zIn_d, xOut_i, zOut_i)
%
% INPUT:
% zIn_d(xIn_i, yIn_i)
%
% OUTPUT: 
% yOut_d(xOut_i, zOut_i)

% y0_d(xIn_i, zOut_i);
y0_d = zeros(length(xIn_i), length(zOut_i));
for i = 1:length(xIn_i)
    % ricerco elementi monotoni crescenti
    idx = [1 diff(zIn_d(i,:))]>0;
    if sum(int8(idx)) >=2
        % interpolo tenendo costanti gli estremi
        y0_d(i,:) = interp1sat(zIn_d(i,idx), yIn_i(idx), zOut_i);
    elseif i>1
        % copio il precedente
        y0_d(i,:) = y0_d(i-1,:);
    end
end

% yOut_d(xOut_i, zOut_i)
yOut_d = zeros(length(xOut_i), length(zOut_i));
for j = 1:length(zOut_i)
    % interpolo tenendo costanti gli estremi
    yOut_d(:,j) = interp1sat(xIn_i, y0_d(:,j), xOut_i);
end


return