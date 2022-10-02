function done = process(data, varargin)
%PROCESS.M  compute the end-state of a thermodynamic process
%
%   state = process(data, param1, value1, ...)
%
%Computes the final thermodynamic state for a given mixture undergoing
%a process.  Constrain the state by specifying various properties at 
%the end state.  PROCESS will invert the relations in the data struct
%to compute the corresponding temperature and pressure.
%
%The arguments used by PROCESS are
%data       The structure array generated by JANLOAD.
%
%state      A structure generated by state.m, indicating the initial
%           state.
%
%PROCESS accepts the following parameter-value pairs:
%
%***** Constrain the end-state *****
%species    The species present in the end-state mixture.
%           (required)
%
%mass       The end-state mixture
%           (required)
%
%T          The end-state temperature
%
%P          The end-state pressure
%
%s          The end-state entropy
%
%h          The end-state enthalpy
%
%rho        The end-state density
%
%u          The end-state internal energy
%

% defaults
done.v = 0;
params = {'species--o','mass--od','T--od','P--od','s--od','h--od','rho--od','u--od'};
values = varargparam(params,varargin{:});
[done.species done.mass done.T done.P s h rho u] = deal(values{:});


Tdef = ~isempty(done.T);
Pdef = ~isempty(done.P);
sdef = ~isempty(s);
hdef = ~isempty(h);
rhodef = ~isempty(rho);
udef = ~isempty(u);
Ndef = Tdef + Pdef + sdef + hdef + rhodef + udef;

if (udef & hdef) | (udef & Tdef) | (hdef & Tdef)
    error('Over-constrained system. Cannot simultaneously constrain "u", "h", and "T".')
elseif Ndef<2
    error('Under-constrained system.  Need 2 constrained properties.')
elseif Ndef>2
    error('Over-constrained system.  Only need 2 constrained properties.')
else
    % deal with properties that depend on T only
    if udef
        done = utoT(data,u,done);
        Tdef = 1;
    elseif hdef
        done = htoT(data,h,done);
        Tdef = 1;
    end
    
    % deal with properties that depend on P only
    % - there are none

    % case out the inter-dependent functions 
    if Tdef & sdef
        done.P = 101300 * exp((entropy(data,done.species,done.mass,done.T) - s)./igconstant(data,done));
    elseif Tdef & rhodef
        done.P = rho .* igconstant(data,done) .* done.T;
    elseif Pdef & sdef
        % isolate the temperature-dependent component of entropy
        s0 = s+igconstant(data,done).*log(done.P/101300);
        done = stoT(data, s0, done);
    elseif Pdef & rhodef
        done.T = done.P/rho/igconstant(data,done);
    elseif rhodef & sdef
        done = srhotoTP(data,s,rho,done);
    end% if T and P are already defined... we're done.
end


%
% Enthalpy iteration routine
%
function state = htoT(data, h0,state)
state.T = 500;
h1 = enthalpy(data,state.species,state.mass,state.T);
while abs((h1-h0)/h0)>1e-8
    c = spheat(data,state.species,state.mass,state.T);
    state.T = state.T - (h1-h0)/c;
    h1 = enthalpy(data,state.species,state.mass,state.T);
end


%
% energy iteration routine
%
function state = utoT(data, u0,state)
state.T = 500;
R = igconstant(data,state.species,state.mass);
u1 = energy(data,state.species,state.mass,state.T);
while abs((u1-u0)/u0)>1e-8
    c = spheat(data,state.species,state.mass,state.T) - R;
    state.T = state.T - (u1-u0)/c;
    u1 = energy(data,state.species,state.mass,state.T);
end

%
% entropy iteration routine
%
function state = stoT(data, s0,state)
state.T = 500;
s1 = entropy(data,state.species,state.mass,state.T);
while abs((s1-s0)/s0)>1e-8
    c = spheat(data,state.species,state.mass,state.T)/state.T;
    state.T = state.T - (s1-s0)/c;
    s1 = entropy(data,state.species,state.mass,state.T);
end

%
% entropy and density iteration routine
%
function state = srhotoTP(data,s0,rho0,state)
state.T = 500;
R = igconstant(data,state);
state.P = rho0*R*state.T;
s1 = entropy(data,state);
while abs((s1-s0)/s0)>1e-8
    c = spheat(data,state.species,state.mass,state.T)/state.T;
    state.T = state.T - (s1-s0)/c;
    state.P = rho0*R*state.T;
    s1 = entropy(data,state);
end
