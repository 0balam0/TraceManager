function tInfoOut = completeInfoMaps(tInfo, cMap2Ddefault, varargin)

% cMap2Ddefault = {'sName', val_2d, val_x, valy, sU_2d, sU_x, sU_y};

tInfoOut = tInfo;
Nvars = size(cMap2Ddefault,1);

% options
% mode can be 'full' to force complete struct even if values are empty

sMode = '';
if ~isempty(varargin)
    % mode
    posMode = find(strcmpi(varargin, 'mode'));
    if ~isempty(posMode)
        sMode = varargin{posMode+1};
    end
end

for i = 1:Nvars
    
    sName = cMap2Ddefault{i,1};
    val_2d = cMap2Ddefault{i,2};
    val_x = cMap2Ddefault{i,3};
    val_y = cMap2Ddefault{i,4};
    sU_2d = cMap2Ddefault{i,5};
    sU_x = cMap2Ddefault{i,6};
    sU_y = cMap2Ddefault{i,7};
    
    % check if maps needs to be completed
    if ~isfield(tInfo, sName) || isempty(tInfo.(sName)) ||...
            ~isfield(tInfo.(sName), 'v') || isempty(tInfo.(sName).v)
        % needs to be completed
        tInfoOut.(sName).v = val_2d;
        tInfoOut.(sName).u = sU_2d;
        tInfoOut.(sName).x = '';
        tInfoOut.(sName).y = '';
        sName_x = [sName, '_x_i'];
        sName_y = [sName, '_y_i'];
        tInfoOut.(sName_x).u = '';
        tInfoOut.(sName_y).u = '';
        %
        if ~isempty(val_x) || strcmpi(sMode, 'full')
            tInfoOut.(sName).x = sName_x;
            tInfoOut.(sName_x).v = val_x;
            tInfoOut.(sName_x).u = sU_x;
        end
        %
        if ~isempty(val_y) || strcmpi(sMode, 'full')
            tInfoOut.(sName).y = sName_y;
            tInfoOut.(sName_y).v = val_y;
            tInfoOut.(sName_y).u = sU_y;
        end
    end
    
end

return
