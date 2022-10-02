function xr=arrotonda(x,varargin)
%
% Modi di funzionamento:
%   XR=ARROTONDA(X)
%   XR=ARROTONDA(X,APPROX)
%   XR=ARROTONDA(X,APPROX,MODO)
%   XR=ARROTONDA(X,MODO)
% dove
%   X      è la matrice da arrotondare;
%   APPROX è il valore a cui arrotondare (anche diverso da 10^n); di
%            default, vale circa X*10^-6;
%   MODO   è il modo di arrotondare: puo valere 'round' (default), 'ceil',
%           'floor', 'fix';
% 
% versione rivista, 12/02/2010, G. Guenna FPT-R&T

% valori di default
   opz='round';
   % arrotondo a 1 ppm circa; faccio in modo che il valore a cui
   %   arrotondare abbia una sola cifra significativa 
   r1=abs(x*0.7e-6);
   r2=round(r1./10.^floor(log10(r1)));
   r3=r2.*10.^floor(log10(r1));
   r=r3;
      
   if nargin<2
      r=r3;   % arrotondo a 1 ppm circa
   end      
   if nargin>=2
      if isnumeric(varargin{1})
         r=varargin{1};
      else
         opz=varargin{1};
      end
   end   
   if nargin==3
      opz=varargin{2};
   end

   % controllo su r: deve essere diverso da zero, reale e positivo
   if r==0
      % r=abs(round(x*0.7))*1e-6;
      r=abs(r3);
   else
      r=abs(r);
   end
   %
   switch lower(opz)
      case 'fix'
         xr=fix(x./r).*r;
      case 'ceil'
         xr=ceil(x./r).*r;
      case 'floor'
         xr=floor(x./r).*r;
      otherwise   
         xr=round(x./r).*r;
   end      
   %
return