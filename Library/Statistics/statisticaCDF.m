% corretta da Petrolo il 2005-07-05 per gestire i nomi
% sia nel caso Up che Low sostituendo con IGNORE CASE
%           strcmpi >>>> strcmpi
% e per le funzioni non presenti

function p = statisticaCDF(name,x,varargin)
%CDF    Computes a chosen cumulative distribution function.
%   P = CDF(NAME,X,A) returns the named cumulative distribution
%   function, which uses parameter A, at the values in X.
%
%   P = CDF(NAME,X,A,B) returns the named cumulative distribution
%   function, which uses parameters A and B, at the values in X.
%   Similarly for P = CDF(NAME,X,A,B,C).
%
%   The name can be: 'beta' or 'Beta', 'bino' or 'Binomial',
%   'chi2' or 'Chisquare', 'exp' or 'Exponential',
%   'ev' or 'Extreme Value', 'f' or 'F', 
%   'gam' or 'Gamma', 'geo' or 'Geometric', 
%   'hyge' or 'Hypergeometric', 'logn' or 'Lognormal', 
%   'nbin' or 'Negative Binomial', 'ncf' or 'Noncentral F', 
%   'nct' or 'Noncentral t', 'ncx2' or 'Noncentral Chi-square',
%   'norm' or 'Normal', 'poiss' or 'Poisson', 'rayl' or 'Rayleigh',
%   't' or 'T', 'unif' or 'Uniform', 'unid' or 'Discrete Uniform',
%   'wbl' or 'Weibull'.
% 
%   CDF calls many specialized routines that do the calculations. 
%
%   See also ICDF, MLE, PDF, RANDOM.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.3 $  $Date: 2004/07/05 17:02:20 $
 
if nargin<2, error('stats:cdf:TooFewInputs','Not enough input arguments'); end

if ~isstr(name)
   error('stats:cdf:BadDistribution',...
         'First argument must be distribution name');
end

if nargin<5 
    a3=0;
else
    a3 = varargin{3};
end 
if nargin<4
    a2=0;
else
    a2 = varargin{2};
end 
if nargin<3
    a1=0;
else
    a1 = varargin{1};
end 

if     strcmpi(name,'beta') | strcmpi(name,'Beta'),  
    p = betacdf(x,a1,a2);
elseif strcmpi(name,'bino') | strcmpi(name,'Binomial'),  
    p = binocdf(x,a1,a2);
elseif strcmpi(name,'chi2') | strcmpi(name,'Chisquare'), 
 p = chi2cdf(x,a1);
elseif strcmpi(name,'exp') | strcmpi(name,'Exponential'),
    p = expcdf(x,a1);
elseif strcmpi(name,'ev') | strcmpi(name,'Extreme Value'),
    p = evcdf(x,a1,a2);
elseif strcmpi(name,'f') | strcmpi(name,'F'),     
    p = fcdf(x,a1,a2);
elseif strcmpi(name,'gam') | strcmpi(name,'Gamma'),   
    p = gamcdf(x,a1,a2);
elseif strcmpi(name,'geo') | strcmpi(name,'Geometric'),   
    p = geocdf(x,a1);
elseif strcmpi(name,'hyge') | strcmpi(name,'Hypergeometric'),  
    p = hygecdf(x,a1,a2,a3);
elseif strcmpi(name,'logn') | strcmpi(name,'Lognormal'),
    p = logncdf(x,a1,a2);
elseif strcmpi(name,'nbin') | strcmpi(name,'Negative Binomial'), 
   p = nbincdf(x,a1,a2);    
elseif strcmpi(name,'ncf') | strcmpi(name,'Noncentral F'),
    p = ncfcdf(x,a1,a2,a3);
elseif strcmpi(name,'nct') | strcmpi(name,'Noncentral T'), 
    p = nctcdf(x,a1,a2);
elseif strcmpi(name,'ncx2') | strcmpi(name,'Noncentral Chi-square'), 
    p = ncx2cdf(x,a1,a2);
elseif strcmpi(name,'norm') | strcmpi(name,'Normal'), 
    p = normcdf(x,a1,a2);
elseif strcmpi(name,'poiss') | strcmpi(name,'Poisson'),
    p = poisscdf(x,a1);
elseif strcmpi(name,'rayl') | strcmpi(name,'Rayleigh'),
    p = raylcdf(x,a1);
elseif strcmpi(name,'t') | strcmpi(name,'t di Student'),     
    p = tcdf(x,a1);
elseif strcmpi(name,'unid') | strcmpi(name,'Discrete Uniform'),  
    p = unidcdf(x,a1);
elseif strcmpi(name,'unif')  | strcmpi(name,'Uniform'),  
    p = unifcdf(x,a1,a2);
% -----aggiunta petrolo start------
elseif strcmpi(name,'inversegaussian')  || strcmpi(name,'inverse gaussian'),  
    spec = dfgetdistributions('inversegaussian');
    p = feval(spec.cdffunc,x,varargin{:});
elseif strcmpi(name,'birnbaumsaunders'),  
    spec = dfgetdistributions('birnbaumsaunders');
    p = feval(spec.cdffunc,x,varargin{:});
elseif strcmpi(name,'loglogistic')  || strcmpi(name,'log logistic'),  
    spec = dfgetdistributions('loglogistic');
    p = feval(spec.cdffunc,x,varargin{:});
elseif strcmpi(name,'nakagami'),  
    spec = dfgetdistributions('nakagami');
    p = feval(spec.cdffunc,x,varargin{:});
elseif strcmpi(name,'rician'),  
    spec = dfgetdistributions('rician');
    p = feval(spec.cdffunc,x,varargin{:});
elseif strcmpi(name,'tlocationscale') || strcmpi(name,'t location scale'),  
    spec = dfgetdistributions('tlocationscale');
    p = feval(spec.cdffunc,x,varargin{:});
elseif strcmpi(name,'non parametric') || strcmpi(name,'nonparametric'),    
    p = ksdensity(a1,x,'kernel','normal','support','unbounded','function','cdf');
% -----aggiunta petrolo end------
    
elseif strcmpi(name,'weib') | strcmpi(name,'Weibull') | strcmpi(name,'wbl')
    if strcmpi(name,'weib') | strcmpi(name,'Weibull')
        warning('stats:cdf:ChangedParameters', ...
'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    p = wblcdf(x,a1,a2);
else   
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:cdf:BadDistribution',...
             'Unrecognized distribution name: ''%s''.',name);
       return
    elseif length(spec)>1
       error('stats:cdf:BadDistribution',...
             'Ambiguous distribution name: ''%s''.',name);
       return
    end
    p = feval(spec.cdffunc,x,varargin{:});
end 
