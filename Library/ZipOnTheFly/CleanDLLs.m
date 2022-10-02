function CleanDLLs()
% One liner to delete DLL files after runtime
% Part of the set of functions that does dynamic zipping at runtime.
%
% 1/5/2021  t2631vs

delete('*_win64.dll');

return