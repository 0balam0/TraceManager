function [zOut_d, bSupp, cUMsupp] = mainUnitConversion(zIn_d, sUMin, sUMout, varargin)


zOut_d = [];
bSupp = false;
cUMsupp = {''};
if isempty(zIn_d)
    return
end

% list of available unit conversion functions
cF = {'massFlowUm2Um';...
      'massUm2Um';...
      'speedUm2Um';...
      'lengthUm2Um';...
      'pressureUm2Um';...
      'torqueUm2Um';...
      'powerUm2Um';...
      'volumeUm2Um'; ...
      'energyUm2Um'; ...
      'fueleconUm2Um';...
      'temperatureUm2Um';...
      'coastdownUm2Um';...
      'capacityfactorUm2Um';...
      'accelerationUm2Um';...
      'angularSpdUm2Um';...
      'angularAccelUm2Um';...
      'relativeUm2Um'};
  
%#function massFlowUm2Um
%#function massUm2Um
%#function speedUm2Um
%#function lengthUm2Um
%#function pressureUm2Um
%#function torqueUm2Um
%#function powerUm2Um
%#function volumeUm2Um
%#function energyUm2Um
%#function fueleconUm2Um
%#function temperatureUm2Um
%#function coastdownUm2Um
%#function capacityfactorUm2Um
%#function accelerationUm2Um
%#function angularSpdUm2Um
%#function angularAccelUm2Um
%#function relativeUm2Um

% if same units are required, output data is the same as input
if strcmp(sUMin, sUMout)
    zOut_d = zIn_d;
    return;
end
  
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