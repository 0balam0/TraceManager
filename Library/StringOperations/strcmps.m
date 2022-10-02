function idx = strcmps(c, s, bCaseSens)
% come strcmp ma posso decidere elemento per elemento di c se farlo case
% sensitive o no

idx = false(length(c),1);
idx(bCaseSens) = strcmp(c(bCaseSens), s);
idx(not(bCaseSens)) = strcmpi(c(not(bCaseSens)), s);

return