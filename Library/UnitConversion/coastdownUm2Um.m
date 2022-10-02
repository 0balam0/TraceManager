function [zOut_d, bSupp, cUMsupp] = coastdownUm2Um(zIn_d, sUMin, sUMout, varargin)

 % list of available unit conversion functions
cF = {'coastdownAUm2Um';...
      'coastdownBUm2Um';...
      'coastdownCUm2Um'};
  
%#function coastdownAUm2Um
%#function coastdownBUm2Um
%#function coastdownCUm2Um

  
% loops over available function to find the right one
for i = 1:length(cF)
    hF = str2func(cF{i});
    [zOut_d, bSupp, cUMsupp] = hF(zIn_d, sUMin, sUMout, varargin{:});
    % if supported, gives right conversion
    if bSupp
        break
    end
end

return
%
