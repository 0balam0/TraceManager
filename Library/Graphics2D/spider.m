function [f, ca, o] = spider(data, tle, rng, nl, lbl, leg, posFig, alphaVal)
% esepio di uso:
% 
% SINGOLO:  
% dati = [4 5 6]';
% limiti = [3; 7]';
% numeroLinee = 4;
% posFig = [50 50 600 600];
% alphaVal = 0.2; % valore di trasparenza della patch (se [] non le disegna)
% spider(dati, '', limiti, numeroLinee, {'asse1','asse2','asse3'}, {'serie1'}, posFig, alphaVal)
%
% CONFRONTO
% dati = [4 9 4; 5 8 10]';
% limiti = [3 0 0; 6 9 12]';
% numeroLinee = 6;
% posFig = [50 50 600 600];
% alphaVal = 0.2; % valore di trasparenza della patch (se [] non le disegna)
% spider(dati, '', limiti, numeroLinee, {'asse1','asse2','asse3'}, {'serie1','serie2'}, posFig, alphaVal)
% 
%
% VECCHIO HELP
% create a spider plot for ranking the data
% function [f, ca, o] = spider(data,tle,rng,lbl,leg,f)
%
% inputs  6 - 5 optional
% data    input data (NxM) (# axes (M) x # data sets (N))     class real
% tle     spider plot title                                   class char
% rng     peak range of the data (Mx1 or Mx2)                 class real
% lbl     cell vector axes names (Mxq) in [name unit] pairs   class cell
% leg     data set legend identification (1xN)                class cell
% f       figure handle or plot handle                        class real
%
% outptus 3 - 3 optional
% f       figure handle                                       class integer
% x       axes handle                                         class real
% o       series object handles                               class real
%
% michael arant - jan 30, 2008
%
% to skip any parameter, enter null []
% 
% examples

% data check
if nargin < 1; help spider; error('Need data to plot'); end

% size segments and number of cases
[r c] = size(data);
% exit for too few axes
if r < 3
	errordlg('Must have at least three measuremnt axes')
	error('Program Termination:  Must have a minimum of three axes')
end

% title
if ~exist('tle','var') || isempty(tle) || ~ischar(tle)
	tle = '';
end

% check for maximum range
if ~exist('rng','var') || isempty(rng) || ~isreal(rng)
	% no range given or range is in improper format
	% define new range
	rng = [min([min(data,[],2) zeros(r,1)],[],2) max(data,[],2)];
	% check for negative minimum values
	if ~isempty(ismember(-1,sign(data)))
		% negative value found - adjust minimum range
		for ii = 1:r
			% negative range for axis ii - set new minimum
			if min(data(ii,:)) < 0
				rng(ii,1) = min(data(ii,:)) - ...
							0.25 * (max(data(ii,:)) - min(data(ii,:)));
			end
		end
	end
elseif size(rng,1) ~= r
	if size(rng,1) == 1
		% assume that all axes have commom scale
		rng = ones(r,1) * rng;
	else
		% insuffent range definition
		uiwait(msgbox(char('Range size must be Mx1 - number of axes x 1', ...
			sprintf('%g axis ranges defined, %g axes exist',size(rng,1),r))))
		error(sprintf('%g axis ranges defined, %g axes exist',size(rng,1),r))
	end
elseif size(rng,2) == 1
	% assume range is a maximum range - define minimum
	rng = sort([min([zeros(r,1) min(data,[],2) - ...
						0.25 * (max(data,[],2) - min(data,[],2))],[],2) rng],2);
end

% check for axis labels
if ~exist('lbl','var') || isempty(lbl)
	% no labels given - define a default lable
	lbl = cell(r,1); for ii = 1:r; lbl(ii) = cellstr(sprintf('Axis %g',ii)); end
elseif size(lbl,1) ~= r
	if size(lbl,2) == r
		lbl = lbl';
	else
		uiwait(msgbox(char('Axis labels must be Mx1 - number of axes x 1', ...
			sprintf('%g axis labels defined, %g axes exist',size(lbl,1),r))))
		error(sprintf('%g axis labels defined, %g axes exist',size(lbl,1),r))
	end
elseif ischar(lbl)
	% check for charater labels
	lbl = cellstr(lbl);
end

if ~exist('leg','var') || isempty(leg)
	% no data legend - define default legend
	leg = cell(1,c); 
   for ii = 1:c; 
      leg(ii) = cellstr(sprintf('Set %g',ii));
   end
elseif numel(leg) ~= c
	uiwait(msgbox(char('Data set label must be 1XN - 1 x number of sets', ...
		sprintf('%g data sets labeled, %g exist',numel(leg),c))))
	error(sprintf('%g data sets labeled, %g exist',numel(leg),c))
end



% generating a new figure
f = figure; 
ca = gca(f); 
cla(ca); 
hold on
if isempty(posFig)
   posFig = [50 50 800 600];
end
set(f, 'position', posFig)

% set the axes to the current text axes
axes(ca)
% set to add plot
set(ca,'nextplot','add');

% clear figure and set limits
set(ca,'visible','off'); set(f,'color','w')
set(ca,'xlim',[-1.25 1.25],'ylim',[-1.25 1.25]); axis(ca,'equal','manual')
% title
text(0,1.3,tle,'horizontalalignment','center','fontweight','bold');


% define data case colors
col = listaColori;

% arrotonda i range con formato automatico
for i = 1:r
    if rng(i,1)<rng(i,2)
        % asse std
        tick = suddividi(rng(i,1), rng(i,2), nl);
        rng(i,:) = [tick(1) tick(end)];
    elseif rng(i,1)>rng(i,2)
        % asse con min e max invertiti
        tick = suddividi(rng(i,2), rng(i,1), nl);
        rng(i,:) = [tick(end) tick(1)];
    else
        % asse con limiti coincidenti
        disp(['Errore nel settaggio delle scale del ',num2str(i),'^o asse.'])
    end
    
end

% scale by range
angw = linspace(0,2*pi,r+1)';
mag = (data - rng(:,1) * ones(1,c)) ./ (diff(rng,[],2) * ones(1,c));
% scale trimming
mag(mag < 0) = 0; mag(mag > 1) = 1;
% wrap data (close the last axis to the first)
ang = angw(1:end-1); 
magw = [mag; mag(1,:)];


% make the plot
% define the axis locations
start = [zeros(1,r); cos(ang')]; stop = [zeros(1,r); sin(ang')];
% plot the axes
plot(ca,start,stop,'color','k','linestyle','-'); 
axis equal
% plot axes markers
% inc = linspace(rng(1,1), rng(1,2), nl+1) / rng(1,2);
inc = linspace(0, rng(1,2), nl+1) / rng(1,2);
mk = .025 * ones(1, length(inc));
tx = 4 * mk; 
% loop each axis ang plot the line markers and labels
% add axes
Xgrid = zeros(r+1, length(mk));
Ygrid = zeros(r+1, length(mk));
for ii = 1:r
	% plot tick marks
   x = [cos(ang(ii)) * inc + sin(ang(ii)) * mk; cos(ang(ii)) * inc - sin(ang(ii)) * mk];
   y = [sin(ang(ii)) * inc - cos(ang(ii)) * mk ; sin(ang(ii)) * inc + cos(ang(ii)) * mk];
   % plot grid
   Xgrid(ii,:) = mean(x, 1);
   Ygrid(ii,:) = mean(y, 1);
	% label the tick marks
	for jj = 1:length(inc)
		temp = text(cos(ang(ii)) * inc(jj) + sin(ang(ii)) * tx(jj), ...
                    sin(ang(ii)) * inc(jj) - cos(ang(ii)) * tx(jj), ...
                    num2str(rng(ii,1) + inc(jj)*diff(rng(ii,:))), ...
                    'fontsize',8);
      set(temp,'fontweight', 'bold')
		% flip the text alignment for lower axes
		if ang(ii) >= pi
			set(temp,'HorizontalAlignment','right')
		end
	end
	% label each axis
	temp = text([cos(ang(ii)) * 1.1 + sin(ang(ii)) * 0], ...
			[sin(ang(ii)) * 1.1 - cos(ang(ii)) * 0], ...
			char(lbl(ii,:)));
   set(temp, 'fontweight', 'bold')
	% flip the text alignment for right side axes
	if ang(ii) > pi/2 && ang(ii) < 3*pi/2
		set(temp,'HorizontalAlignment','right')
	end
end
Xgrid(r+1,:) = Xgrid(1,:);
Ygrid(r+1,:) = Ygrid(1,:);

% plot and set grid
hGrid = zeros(length(mk),1);
for i = 1:length(mk)
   hGrid(i) = line(Xgrid(:,i), Ygrid(:,i));
   
end
set(hGrid, 'linestyle', ':', 'color',[0.5 0.5 0.5])

% plot the data (polar coordinates)
teta = angw*ones(1,c);
o = polar(ca, teta, magw);
% set color of the lines
for ii = 1:c; 
   set(o(ii), 'color',col{ii,:}, 'linewidth',1.5); 
end

% plot patches
if not(isempty(alphaVal))
   x = magw .* cos(teta);
   y = magw .* sin(teta);
   z = ones(size(x));
   hPatch = zeros(c,1);
   for ii = 1:c; 
      hPatch(ii) = patch(x(:,ii), y(:,ii), z(:,ii), col{ii,:});
   end
   set(hPatch, 'EdgeAlpha',0, 'FaceAlpha', alphaVal)
end

% apply the legend
hL = legend(ca, o,leg, 'location','northeastoutside');
set(hL,'position',[0.82 0.84 0.15 0.15])

return

% integer test
function [res] = isint(val)
% determines if value is an integer
% function [res] = isint(val)
%
% inputs  1
% val     value to be checked              class real
%
% outputs 1
% res     result (1 is integer, 0 is not)  class integer
%
% michael arant     may 15, 2004
if nargin < 1; help isint; error('I / O error'); end

% check for real number
if isreal(val) & isnumeric(val)
%	check for integer
	if round(val) == val
		res = 1;
	else
		res = 0;
	end
else
	res = 0;
end
return
