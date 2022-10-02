function [d] = array2scatter(v,C,M)

[C_2i, v_2i] = meshgrid(C,v);
v0 = reshape(v_2i, numel(v_2i),1);
C0 = reshape(C_2i, numel(v_2i),1);
if size(M) ~= size(C_2i)
   M = M';
end
if size(M) ~= size(C_2i)
   disp('error in input dimension')
   d = [];
   return
end
e0 = reshape(M, numel(v_2i),1);

d = [v0,C0,e0];
return