function f = codifica(c, k, bCod)

% f = codifica(c, k, bCod)
% codifica il vettore c (int8) nel vettore f (int8) mediante la chiave k (int8)
% bCod: true per codificare, false per decodificare
% 
% verifica di funzionamento
% v = (0:1:N_el-1)'
% figure; plot(v,v,'b+-', v, codifica(codifica(v, [v; v], true), [v; v], false),'ro-' )

N_el = 128; % elementi della base

% controlla che c e k siano int8
if any(double(c) - double(int8(c))~=0) || any(double(k) - double(int8(k))~=0)
   disp('Error: input arguments c and k must be unit8 convertible without loss of precision')
   f = [];
   return
else
   c = double(c(:));
   k = double(k(:));
end


if bCod
   % codifica
   k1 = 1;
else
   % decodifica
   k1 = -1;
end

% processo
idxK = restoIdx((1:1:length(c))', length(k));
f = resto(c + k1 * k(idxK), N_el); % la base è il numero di elementi: 2^n
f = int8(f);

return