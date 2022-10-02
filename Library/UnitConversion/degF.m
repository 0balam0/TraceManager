function [offset, gain] = degF()

% [degC] = ([degF] + offset) * gain
offset = -32;
gain = 5/9;
return
