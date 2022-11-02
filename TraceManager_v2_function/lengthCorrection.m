function [xOut, yOut] = lengthCorrection(xIn, yIn, deltaLmax)
% forza la lunghezza del vettore Y pari a quello X (può accadere che per errori di
% esportazione la lunghezza di Y sia "poco" diversa da X)
% deltaLmax = 2; % numerosità di diversità consentita

Lx = length(xIn);
Ly = length(yIn);
%
xOut = xIn;
yOut = yIn;
if Ly ~= Lx
    % dimensioni diverse
    if Ly < Lx % && Ly >= Lx - deltaLmax
        % Y un pò più corto di X, aggiungo punti uguali all'ultimo
        yOut(end:Lx) = yIn(end);
    elseif Ly > Lx % && Ly <= Lx + deltaLmax
        % Y un pò più lungo di X, lo tronco
        yOut = yIn(1:Lx);
    else
        % Y troppo diverso da X
        disp('Error: X and Y data have different dimensions')
    end
else
    % stesse dimensioni, tutto ok
end

return
