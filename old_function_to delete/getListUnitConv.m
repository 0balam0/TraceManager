function c = getListUnitConv(sCurrUnit)
% searches for possible conversion
bSupp = false;
cPossUnits = {''};
if not(isempty(sCurrUnit))
    [dum, bSupp, cPossUnits] = mainUnitConversion(1, sCurrUnit, sCurrUnit);
end
% first is no conversion option
c = {'(no conv.)'};
% adds possible units
if bSupp
    c(2:length(cPossUnits)+1,1) = cPossUnits(:);
end
return
