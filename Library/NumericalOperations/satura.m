function xOut = satura(xIn, xMin, xMax)

% xOut = satura(xIn, xMin, xMax)

   xOut = min(max(xIn, xMin), xMax);
return
%