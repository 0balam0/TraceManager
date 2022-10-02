function [zOut_d, bSupp, cUMsupp] = massFlowUm2Um(zIn_d, sUMin, sUMout, varargin)
 
% bSupp indica se la conversione richeista è correttametne supportata
% zOut_d è la grandezza convertita
%
% zIn_d è la grandezza da convertire
% sUMin, sUMout sono le unità di misura di ingresso / uscita, a scelta fra
% quelle supportate
% 
% P2_i [kW] (opzionale)
% dens [g/l] = [kg/m^3] (opzionale)

% controllo ingresso vuoto
if isempty(zIn_d)
   zOut_d = zIn_dM;
   return
end


% gestione varargin
if not(isempty(varargin)) && length(varargin) >= 1
   P2_i = varargin{1}; % [kW]
end
dens = 1;
if not(isempty(varargin)) && length(varargin) >= 2
   dens = varargin{2}; % [g/l]
end

% elimino la dipendenza case-sensitive, non dovrebbe dare problemi perchè
% le u.m. sono abbastanza chiare
sUMin = lower(sUMin);
sUMout = lower(sUMout);

%%% controllo unità di misura correttamente gestite
% elenco u.m. supportate
cUMsupp = {'mg/h', 'g/h', 'kg/h', 'mg/s', 'g/s', 'kg/s',...
           'g/cvh', 'g/kwh',...
           'm^3/h', 'm^3/s', 'l/h', 'l/s', 'l/cvh', 'l/kwh'};
bSupp = any(strcmpi(sUMin, cUMsupp)) & any(strcmpi(sUMout, cUMsupp));
if not(bSupp)
   zOut_d = [];
   return
end

% % per gestire litri
% % TODO; attenzione: non converte la densità
% if strcmp(sUMin(1),'l') && strcmp(sUMout(1),'l')
%    sUMin(1) = 'g';
%    sUMout(1) = 'g';
% end

% fattore di passaggio da CV a kW
k_CV2kW = CV2kW(1);

%%% unifico la grandezza in ingresso 
switch sUMin
   
   case {'m^3/h', 'm^3/s', 'l/h', 'l/s'}
      % VOLUME (ASSOLUTO)
      % porto in l/h
      switch sUMin
         case 'm^3/h'
            k = 1e3;
         case 'm^3/s'
            k = 1e3 * 3.6e3;
         case 'l/h'
            k = 1;
         case 'l/s'
            k = 3.6e3;
      end
      sIn = 'ass';
      zIn_d = zIn_d * k;
      %
      % porto in kg/h
      k = dens/1000; % [g/l] o [kg/m^3]
      zIn_d = zIn_d * k;
   
   case {'mg/h', 'g/h', 'kg/h', 'mg/s', 'g/s', 'kg/s'}
      % MASSA (ASSOLUTO)
      % porto in kg/h
      switch sUMin
         case 'mg/h'
            k = 1e-6;
         case 'g/h'
            k = 1e-3;
         case 'kg/h'
            k = 1;
         case 'mg/s'
            k = 3600 / 1e6;
         case 'g/s'
            k = 3600 / 1e3;
         case 'kg/s'
            k = 3600;
      end
      sIn = 'ass';
      zIn_d = zIn_d * k;
      
   case {'g/cvh', 'g/kwh'}
      % MASSA (SPECIFICHE)
      % porto in g/kWh
      switch sUMin
         case 'g/cvh'
            k = 1/k_CV2kW;
         case 'g/kwh'
            k = 1;
      end
      sIn = 'spec';
      zIn_d = zIn_d * k;
      
   case {'l/cvh', 'l/kwh'}
      % VOLUME (SPECIFICHE)
      % porto in l/kwh
      switch sUMin
         case 'l/cvh'
            k = 1/k_CV2kW;
         case 'l/kwh'
            k = 1;
      end
      sIn = 'spec';
      zIn_d = zIn_d * k;
      %
      % porto in g/kwh
      k = dens; % [g/l] o [kg/m^3]
      zIn_d = zIn_d * k;
end


%%% trasformo per uscita
switch sUMout
   
   case {'mg/h', 'g/h', 'kg/h', 'mg/s', 'g/s', 'kg/s'}
      % MASSA (ASSOLUTO)
      switch sIn
         case 'ass'
            % passo da kg/h ad una assoluta
            switch sUMout
               case 'mg/h'
                  k = 1e6;
               case 'g/h'
                  k = 1e3;
               case 'kg/h'
                  k = 1;
               case 'mg/s'
                  k = 1e6 / 3600;
               case 'g/s'
                  k = 1e3 / 3600;
               case 'kg/s'
                  k = 1 / 3600;
            end
            zOut_d = zIn_d * k;
         case 'spec'
            % passo da g/kWh ad una assoluta
            switch sUMout
               case 'mg/h'
                  k = 1e3;
               case 'g/h'
                  k = 1;
               case 'kg/h'
                  k = 1e-3;
               case 'mg/s'
                  k = 1e3 / 3600;
               case 'g/s'
                  k = 1 / 3600;
               case 'kg/s'
                  k = 1e-3 / 3600;
            end
            zOut_d = k * zIn_d .* P2_i;
            zOut_d(isinf(zOut_d)) = NaN;
      end
      
   case {'m^3/h', 'm^3/s', 'l/h', 'l/s'}
      % VOLUME (ASSOLUTO)
      switch sIn
         case 'ass'
            % passo da kg/h ad una assoluta
            switch sUMout
               case 'm^3/h'
                  k = 1;
               case 'm^3/s'
                  k = (1/3.6e3);
               case 'l/h'
                  k = 1e3;
               case 'l/s'
                  k = 1e3/3.6e3;
            end
            zOut_d = zIn_d * k / dens;
         case 'spec'
            % passo da g/kWh ad una assoluta
            switch sUMout
               case 'm^3/h'
                  k = 1e-3;
               case 'm^3/s'
                  k = (1e-3 / 3.6e3);
               case 'l/h'
                  k = 1;
               case 'l/s'
                  k = 1 / 3.6e3;
            end
            zOut_d = zIn_d * k / dens .* P2_i;
            zOut_d(isinf(zOut_d)) = NaN;
      end
      
   case {'g/cvh', 'g/kwh'}
      % MASSA (SPECIFICA)
      switch sIn
         case 'ass'
            % passo da kg/h ad una specifca
            switch sUMout
               case 'g/cvh'
                  k = 1e3 * k_CV2kW;
               case 'g/kwh'
                  k = 1e3;
            end
            zOut_d = k * zIn_d  ./ P2_i;
         case 'spec'
            % passo da g/kWh ad una specifca
            switch sUMout
               case 'g/cvh'
                  k = 1 * k_CV2kW;
               case 'g/kwh'
                  k = 1;
            end
            zOut_d = zIn_d * k;
      end
      
   case {'l/cvh', 'l/kwh'}
      % VOLUME (SPECIFICO)
      switch sIn
         case 'ass'
            % passo da kg/h ad una specifca
            switch sUMout
               case 'l/cvh'
                  k = 1e3 / dens * k_CV2kW;
               case 'l/kwh'
                  k = 1e3 / dens;
            end
            zOut_d = k * zIn_d  ./ P2_i;
         case 'spec'
            % passo da g/kWh ad una specifca
            switch sUMout
               case 'l/cvh'
                  k = 1 * k_CV2kW / dens;
               case 'l/kwh'
                  k = 1 / dens;
            end
            zOut_d = zIn_d * k;
      end
      
end





return
%