function [z_d, x_2i, y_2i] = mappatura(x,y,z, x_i,y_i, varargin)
% z_d(x_i, y_i) da triplette (x,y,z)
%
% tipicamente:
% x: coppia
% y: rpm


% output definition
[y_2i, x_2i] = meshgrid(y_i, x_i);
z_d = zeros(length(x_i),length(y_i));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% option management
% X direction extrapolation method
cMethodX = {'saturate'};
if not(isempty(varargin))
   cMethodX{1} = varargin{1};
   if length(varargin)>=2
      cMethodX{2} = varargin{2};
   end
end
% X direction polynomial degree
degPoly = 1;
if not(isempty(varargin))
    % polynomial degree
    a = find(strcmpi(varargin, 'degPoly'));
    if not(isempty(a))
        degPoly = varargin{a+1};
    end
end
% Y direction extrapolation method
cMethodY = {'saturate'};
if not(isempty(varargin))
    a = find(strcmpi(varargin, 'Ydir'));
    if not(isempty(a))
        cMethodY = varargin(a+1:end);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extension in X direction
%
% classification of input groups according to Y spacing 
% TODO: improve (v. mappatura_unique)
%[yArr, ID, ySet] = trovaGruppi(y, max(y)/100);
%R2016Av14 Caporali - cause of error in interpolation of losses of eletric motor 
[yArr, ID, ySet] = trovaGruppi(y, min(max(y)/100, diff(y))); 
%
% z1_d(x_i, rpmSet)
z1_d = zeros(length(x_i),length(ID));
for i = 1:length(ySet)
   [x1,idx] = unique(x(ID{i}));
   if i>1
      idx = idx + ID{i-1}(end);
   end
   z1 = z(idx);
   % interpolation procedure
   z1_d(:,i) = interpData(x1, z1, x_i, cMethodX, degPoly);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extension in Y direction
% z_d(x_i, y_i)
for j = 1:length(x_i)
    % interpolation procedure
    z_d(j,:) = interpData(ySet, z1_d(j,:), y_i, cMethodY, degPoly);
    % z_d(j,:) = interp1sat(ySet, z1_d(j,:), y_i);
end

return
%
function [z_i] = interpData(x1, z1, x_i, cMethodX, degPoly)

z_i = zeros(size(x_i));
% interpolazione
switch lower(cMethodX{1})
    
    case 'saturate'
        % interpolazione lineare con saturazione oltre punti exp
        z_i = interp1sat(x1, z1, x_i);
        
    case {'fit-linear', 'fit-quadratic', 'fit-poly'}
        % fit di tutti i punti ed estrapolazione con medesimo fit
        
        % fit order selection
        switch lower(cMethodX{1})
            case 'fit-linear'
                nOrd = 1;
            case 'fit-quadratic'
                nOrd = 2;
            case 'fit-poly'
                nOrd = degPoly;
        end
        % saturate with point numbers
        nOrd = min(nOrd, length(x1)-1);
        p = polyfitQ(x1, z1, nOrd);
        z_i = polyvalQ(p, x_i);
        
    case {'interp / extrap fit-linear',...
            'interp / extrap fit-linear continuous',...
            'interp / extrap fit-quadratic',...
            'interp / extrap fit-quadratic continuous',...
            'interp / extrap fit-poly',...
            'interp / extrap fit-poly continuous'}
        % interpolazione lineare e estrapolazione lineare con fit
        
        if strcmpi(cMethodX{1}, 'interp / extrap fit-poly')
            z_i = interp1Fit(x1, z1, x_i, 'poly', 'extrap', 'degPoly', degPoly);
        else
            %
            % punti dentro lo exp
            a = find(x_i>=x1(1) & x_i<=x1(end));
            switch lower(cMethodX{1})
                case {'interp / extrap fit-poly', 'interp / extrap fit-poly continuous'}
                    z_i(a) = interp1Fit(x1, z1, x_i(a), 'poly', 'extrap', 'degPoly', degPoly);
                otherwise
                    z_i(a) = interp1(x1, z1, x_i(a));
            end
            
            % fit order selection
            switch lower(cMethodX{1})
                case {'interp / extrap fit-linear', 'interp / extrap fit-linear continuous'}
                    nOrd = 1;
                case {'interp / extrap fit-quadratic', 'interp / extrap fit-quadratic continuous'}
                    nOrd = 2;
                case {'interp / extrap fit-poly', 'interp / extrap fit-poly continuous'}
                    nOrd = degPoly;
            end
            % saturate with point numbers
            nOrd = min(nOrd, length(x1)-1);
            p = polyfitQ(x1, z1, nOrd);
            
            % punti a sx dello exp
            if a(1)>1
                idx = 1:a(1)-1;
                z_i(idx) = polyvalQ(p, x_i(idx));
                % if continuous
                if strcmpi(cMethodX{1}, 'interp / extrap fit-linear continuous') ||...
                        strcmpi(cMethodX{1}, 'interp / extrap fit-quadratic continuous') ||...
                        strcmpi(cMethodX{1}, 'interp / extrap fit-poly continuous')
                    val1 = polyvalQ(p, x1(1));
                    z_i(idx) = z_i(idx) + (z1(1) - val1);
                end
            end
            % punti a dx dello exp
            if a(end)<length(x_i)
                idx = a(end)+1:length(x_i);
                z_i(idx) = polyvalQ(p, x_i(idx));
                % if continuous
                if strcmpi(cMethodX{1}, 'interp / extrap fit-linear continuous') ||...
                        strcmpi(cMethodX{1}, 'interp / extrap fit-quadratic continuous') ||...
                        strcmpi(cMethodX{1}, 'interp / extrap fit-poly continuous')
                    valEnd = polyvalQ(p, x1(end));
                    z_i(idx) = z_i(idx) + (z1(end) - valEnd);
                end
            end
        end
        
    otherwise
        % interpolazione lineare con estrapolazione oltre punti exp in base
        % a metodo scelto
        z_i = interp1(x1, z1, x_i, cMethodX{:});
end

return
