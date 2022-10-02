function b = isAlphabeticString(sIn)
% determina dove la stringa sIn è alfabetica

b = int8(sIn)>=int8('A') & int8(sIn)<=int8('Z') | int8(sIn)>=int8('a') & int8(sIn)<=int8('z');

return