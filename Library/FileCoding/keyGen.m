function k = keyGen()

% generazione di nuova chiave, 
% eventualmente da memorizzare in chiave.m
Lk = 100; % elementi della chiave
Nb = 127; % base della chaive
k = int8(rand(Lk,1) * Nb);

return