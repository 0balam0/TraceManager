function M = trafficLight(varargin)

% OUTPUT: 
% M : mappe di colore (ex: uso in isolivello) con colori semaforo
% INPUT: 
% nColors: numero di righe di M

% di default prendo la mappa di colore della figura corrente
% nColors = size(get(gcf,'colormap'),1);

% colori
nColors = 64;
alpha = 0;
if not(isempty(varargin))
    % numero di colori della mappa di out
    a = find(strcmpi(varargin, 'numColors'));
    if not(isempty(a))
        nColors = varargin{a+1};
    end
    % alpha
    a = find(strcmpi(varargin, 'alpha'));
    if not(isempty(a))
        alpha = varargin{a+1};
    end
end
alpha = max(min(alpha, 1), 0);

% definisco mappa di colore (codifica [R G B])
% verde (essendo la riga più bassa della matrice di colore) è associata ai
% valori più bassi delle isolivello
% rosso (essendo la riga più alta della matrice di colore) è associata ai
% valori più alti delle isolivello 
% giallo intermedio
% m = [0 1 0;... % verde % attenuato: [0.4 1 0]
%      1 1 0;... % giallo
%      1 0 0;... % rosso
%      ];
m = [alpha 1     alpha;... % verde % attenuato: [0.4 1 0]
     1     1     alpha;... % giallo
     1     alpha alpha]; % rosso

% interpolo
M = interp1(linspace(0,1,size(m,1)), m, linspace(0,1,nColors));
return