function b = isNumericString(sIn)
% determina dove la stringa sIn è numerica

b = int8(sIn)>=int8('0') & int8(sIn)<=int8('9');
return