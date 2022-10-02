function [pa, pv, t, rho, pvSat] = atmosphere(p0, T0, H0, h0, height)
% Richard Rieber
% rrieber@gmail.com
% Updated 3/17/2006
%
% Function to determine temperature, pressure, density, and speed of sound
% as a function of height.  Function based on US Standard Atmosphere of
% 1976.  All calculations performed in metric units
% Assuming constant gravitational acceleration.
%
% Input 
%   height [m]
%   p0  = pressione di riferimento dell'aria umida [mbar]
%   T0  = temperatura di riferimento [°C]
%   H0  = umidità di riferimento [%]
%   h0  = altitudine di riferimento [m]
%
% Output
%   pa  = pressione dell'aria secca all'altitudine height [mbar]
%   pv  = pressione del vapore d'acqua [mbar]
%   T   = temperatura all'altitudine height [°C]
%   rho = densità dell'aria umida [kg/m^3]
%   a   = velocità del suono [m/s]


%
%Altitudes (m)
H1 = 11000;
H2 = 20000;
H3 = 32000;
H4 = 47000;
H5 = 51000;
H6 = 71000;
H7 = 84852; 
%
%Lapse Rates (K/m)
L1 = -0.0065;
L3 = .001;
L4 = .0028;
L6 = -.0028;
L7 = -.002;
%
% conversione Initial Values
T0 = T0 + 273.16; % [°C] --> K
P0 = p0*1e2;  % mbar --> pa
H0 = H0/100; % umidità relativa

% estraggo i soli valori non ripetuti dal vettore di altezze in ingresso
% per limitare i calcoli a questi soli ultimi (pensa a profilo di pendenza
% in piano, tutto alla stessa altezza)
[heightSet, idx1, idx2] = unique(height);

% preallocazione memoria
pSet = zeros(size(heightSet));
pvSet = zeros(size(heightSet));
tSet = zeros(size(heightSet));
rhoSet = zeros(size(heightSet));
pvSat = zeros(size(heightSet));


for j = 1:length(heightSet)
   if heightSet(j) < 0
      error('Height should be greater than 0')
   end
   %
   if heightSet(j) <= H1
        [TNew, PNew] = Gradient(h0, heightSet(j), T0, P0, L1);    
        
	elseif heightSet(j) > H1 && heightSet(j) <= H2
        [TNew, PNew] = Gradient(h0, H1, T0, P0, L1);
        [TNew, PNew] = IsoThermal(H1, heightSet(j), TNew, PNew);
        
	elseif heightSet(j) > H2 && heightSet(j) <= H3
        [TNew, PNew] = Gradient(h0, H1, T0, P0, L1);
        [TNew, PNew] = IsoThermal(H1, H2, TNew, PNew);
        [TNew, PNew] = Gradient(H2, heightSet(j), TNew, PNew, L3);
        
	elseif heightSet(j) > H3 && heightSet(j) <= H4
        [TNew, PNew] = Gradient(h0, H1, T0, P0, L1);
        [TNew, PNew] = IsoThermal(H1, H2, TNew, PNew);
        [TNew, PNew] = Gradient(H2, H3, TNew, PNew, L3);    
        [TNew, PNew] = Gradient(H3, heightSet(j), TNew, PNew, L4);
        
	elseif heightSet(j) > H4 && heightSet(j) <= H5
        [TNew, PNew] = Gradient(h0, H1, T0, P0, L1);
        [TNew, PNew] = IsoThermal(H1, H2, TNew, PNew);
        [TNew, PNew] = Gradient(H2, H3, TNew, PNew, L3);    
        [TNew, PNew] = Gradient(H3, H4, TNew, PNew, L4);
        [TNew, PNew] = IsoThermal(H4, heightSet(j), TNew, PNew);
        
	elseif heightSet(j) > H5 && heightSet(j) <= H6
        [TNew, PNew] = Gradient(h0, H1, T0, P0, L1);
        [TNew, PNew] = IsoThermal(H1, H2, TNew, PNew);
        [TNew, PNew] = Gradient(H2, H3, TNew, PNew, L3);    
        [TNew, PNew] = Gradient(H3, H4, TNew, PNew, L4);
        [TNew, PNew] = IsoThermal(H4, H5, TNew, PNew);    
        [TNew, PNew] = Gradient(H5, heightSet(j), TNew, PNew, L6);
	
	elseif heightSet(j) > H6 && heightSet(j) <= H7
        [TNew, PNew] = Gradient(h0, H1, T0, P0, L1);
        [TNew, PNew] = IsoThermal(H1, H2, TNew, PNew);
        [TNew, PNew] = Gradient(H2, H3, TNew, PNew, L3);    
        [TNew, PNew] = Gradient(H3, H4, TNew, PNew, L4);
        [TNew, PNew] = IsoThermal(H4, H5, TNew, PNew);    
        [TNew, PNew] = Gradient(H5, H6, TNew, PNew, L6);
        [TNew, PNew] = Gradient(H6, heightSet(j), TNew, PNew, L7);  
	else
        warning('Height is out of range')
   end
	
   
	tSet(j) = TNew - 273.16; % [C]
   % pressione totale
	pSet(j) = PNew/100; % [mbar]
   % densità aria umida
   pvSat(j) = pVapSat(tSet(j)); % pvSat
   H = Umidity(heightSet(j),H0,h0);
   rhoS = (1 - H*pvSat(j)/pSet(j)) * PNew/(287*TNew);
   rhoV = H * rhoVapSat(tSet(j));
	rhoSet(j) = rhoS + rhoV; % [kg/m^3]
   % calcolo pressione vapore
   pvSet(j) = pvSat(j) * H;
end

% assegno i valori calcolati delle proprietà fisiche dell'atmosfera a
% vettori corrispondenti a quello dell'altezza fornito in ingresso
t = tSet(idx2);
pv = pvSet(idx2);
pa = pSet(idx2) - pv;
rho = rhoSet(idx2);
return

function [TNew, PNew] = Gradient(Z0, Z1, T0, P0, Lapse)
g = 9.80665;       %Acceleration of gravity (m/s/s)
R = 287;
TNew = T0 + Lapse*(Z1 - Z0);
PNew = P0*(TNew/T0)^(-g/(Lapse*R)); 

return

function [TNew, PNew] = IsoThermal(Z0, Z1, T0, P0)
g = 9.80665;       %Acceleration of gravity (m/s/s)
R = 287;
TNew = T0;         
PNew = P0*exp(-(g/(R*TNew))*(Z1-Z0));        
return

function pv = pVapSat(T)
%determinazione della pressione di vapore 
%Herman Wobus
%T=Temperatura [°C]
%H=umidità relativa[%]
%pv_sat(pressione di vapore saturo)=es0*p^-8 dove p=(c0+T*(c1+T*(c2+T*(c3+T*(c4+T*(c5+T*(c6+T*(c7+T*(c8+T*(c9)))))))))) 
%pv(pressione di vapore)=pv_sat*H
es0 = 6.1078;
c0 = 0.99999683;
c1 = -0.90826951*10^-2;
c2 = 0.78736169*10^-4;
c3 = -0.61117958*10^-6;
c4 = 0.43884187*10^-8;
c5 = -0.29883885*10^-10;
c6 = 0.21874425*10^-12;
c7 = -0.17892321*10^-14;
c8 = 0.11112018*10^-16;
c9 = -0.30994571*10^-19;
c = [c0 c1 c2 c3 c4 c5 c6 c7 c8 c9];
TT = [1;T;T^2;T^3;T^4;T^5;T^6;T^7;T^8;T^9];
pv = es0*((c*TT)^-8);
return

function rho = rhoVapSat(T)

% T : [°C]
% rho: [kg/M^3]


c0 = 488;
c1 = 34;
c2 = 0.87;
c3 = 0.02365;
c4 = 0.0000466;
c5 = 0.00000213;
c = [c0 c1 c2 c3 c4 c5];
TT = [1; T; T^2; T^3; T^4; T^5];
rho = c*TT * 10^-5;
return

function H = Umidity(h,H0,h0)
%determinazione dell'umidità ad una data altitudine
%Troposphere modelling in local GPS network - Joraslaw Bosy, Andrzej Borkowski
H = H0*exp(-0.0006396*(h-h0));
return
