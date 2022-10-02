function [x0, tau] = fitExp(t, x, varargin)
% regressione della funzione esponenziale:
% x = x0 * (1 - exp(-(t-t0)/tau))
% dxdt = x0 / tau  * exp(-(t-t0)/tau)
%
% v. tuningTurbolag.m in Analisi per confronto sulla procedura.
%
% log(tau) + t0/tau = -log(dxdt) + log(x0);
% A*v = b;
% v = [log(x0);t0];

t0 = [];
if not(isempty(varargin{1}))
   t0 = 0;
end

% TODO: prevedere approccio ricorsivo per la stima di t0

% vettori colonna
t = t(:);
x = x(:);
% calcolo la derivata della funzione
dxdt = gradient(x,t);
% elimino dati con dxdt negativa (ci faccio il logaritmo)
idx = dxdt>0;
t = t(idx);
dxdt = dxdt(idx);
% costante di tempo
tau = regrExp2(t, dxdt);
% ampiezza funzione
x0 = regrExp4(t, dxdt, t0, tau);


return

function [tau] = regrExp2(t, dxdt)
% regressione della derivata della funzione esponenziale:
% x = x0 * (1 - exp(-(t-t0)/tau))
% dxdt = x0 / tau  * exp(-(t-t0)/tau)

% log(tau) + t0/tau = -log(dxdt) + log(x0);
% A*v = b;
% v = [log(x0);t0];

% vettori colonna
t = t(:);
dxdt = dxdt(:);
% elimino dati con dxdt negativa (ci faccio il logaritmo)
idx = dxdt>0;
t = t(idx);
dxdt = dxdt(idx);

% regressione 
A = [ones(size(t)) t]; % sarebbe A = [ones(size(t)) (t-t0)]  ma si scopre che il risultato non dipende da t0
b = -log(dxdt); % sarebbe b = -log(dxdt) + log(x0) ma si scopre che il risultato non dipende da x0
v = A\b;

% out
tau = 1/v(2);
% o anche: tau = exp(v(1));
return

function [x0] = regrExp4(t, dxdt, t0, tau)
% regressione della derivata della funzione esponenziale:
% x = x0 * (1 - exp(-(t-t0)/tau))
% dxdt = x0 / tau  * exp(-(t-t0)/tau)

% log(x0) = log(dxdt) + log(tau) + (t-t0)/tau;
% A*v = b;
% v = [log(x0);t0];

% vettori colonna
t = t(:);
dxdt = dxdt(:);

% elimino dati con dxdt negativa (ci faccio il logaritmo)
idx = dxdt>0;
t = t(idx);
dxdt = dxdt(idx);

% regressione
A = ones(size(t));
b = log(dxdt) + log(tau) + (t-t0)/tau;
v = A\b;

% out
x0 = exp(v);
return