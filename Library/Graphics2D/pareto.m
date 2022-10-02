function [hh,ax] = pareto(varargin)
%PARETO Pareto chart.
%   PARETO(Y,NAMES) produces a Pareto chart where the values in the
%   vector Y are drawn as bars in descending order.  Each bar will
%   be labeled with the associated name in the string matrix or 
%   cell array NAMES.
%
%   PARETO(Y,X) labels each element of Y with the values from X.
%   PARETO(Y) labels each element of Y with its index.
%
%   PARETO(AX,...) plots into AX as the main axes, instead of GCA.
%
%   [H,AX] = PARETO(...) returns a combination of patch and line object
%   handles in H and the handles to the two axes created in AX.
%
%   See also HIST, BAR.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.23.4.6 $  $Date: 2007/05/29 21:15:21 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

cax = newplot(cax);
fig = ancestor(cax,'figure');

hold_state = ishold(cax);
if nargs==0,
  error(id('NotEnoughInputs'),'Not enough input arguments.');
end
if nargs==1,
  y = args{1};
  m = length(sprintf('%.0f',length(y)));
  names = reshape(sprintf(['%' int2str(m) '.0f'],1:length(y)),m,length(y))';
elseif nargs==2
  y = args{1};  names = args{2};
  if iscell(names)
    names = char(names);
  elseif ~ischar(names)
    names = num2str(names(:));
  end
end

if (min(size(y))~=1),
   error(id('YMustBeVector'),'Y must be a vector.');
end
y = y(:);
[yy,ndx] = sort(y);
yy = flipud(yy); ndx = flipud(ndx);

% PARETO calls the 'v6' version of BAR, and temporarily modifies global
% state by turning the MATLAB:bar:DeprecatedV6Argument warning off and
% on again.
oldWarn = warning('query','MATLAB:bar:DeprecatedV6Argument');
warning('off','MATLAB:bar:DeprecatedV6Argument');
try
    h = bar('v6',cax,1:length(y),yy);
catch
    warning(oldWarn);
    rethrow(lasterror);
end
warning(oldWarn);

h = [h;line(1:length(y),cumsum(yy),'parent',cax)];
ysum = sum(yy);

if ysum==0
    ysum = eps; 
end

k = min(find(cumsum(yy)/ysum>1.00,1),10); % 0.95

if isempty(k), 
    k = min(length(y),10); 
end

set(cax,'xlim',[.5 k+.5])
set(cax,'xtick',1:k,'xticklabel',names(ndx,:),'ylim',[0 ysum])

raxis = axes('position',get(cax,'position'),'color','none', ...
             'xgrid','off','ygrid','off','YAxisLocation','right',...
             'xlim',get(cax,'xlim'),'ylim',get(cax,'ylim'), ...
             'HandleVisibility',get(cax,'HandleVisibility'), ...
             'parent',fig);
yticks = get(cax,'ytick');

if max(yticks)<.9*ysum,
  yticks = unique([yticks,ysum]);
end

set(cax,'ytick',yticks)
s = cell(1,length(yticks));
for n=1:length(yticks)
  s{n} = [int2str(round(yticks(n)/ysum*100)) '%'];
end
set(raxis,'ytick',yticks,'yticklabel',s,'xtick',[])
set(cax,'ytick',get(cax,'ytick'))
set(fig,'currentaxes',cax)
if ~hold_state, hold(cax,'off'), set(fig,'Nextplot','Replace'), end

if nargout>0, 
    hh = h; 
    ax = [cax raxis];
end

return

function str = id(str)
  str = ['MATLAB:pareto:' str];
return
