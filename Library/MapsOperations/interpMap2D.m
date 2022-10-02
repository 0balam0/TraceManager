function [tMapOut, sDisp] = interpMap2D(tInfo, cMAP2D)
%%% INPUT:
%   tInfo struct that contains structs of maps 2D.
%
%   tInfo.NAMEmap2D.v
%   tInfo.NAMEmap2D.u
%   tInfo.NAMEmap2D.x -> 'sName of row'
%   tInfo.NAMEmap2D.y -> 'sName of col'
%
%   tInfo.sNameofrow.v
%   tInfo.sNameofrow.u
%
%   tInfo.sNameofcol.v
%   tInfo.sNameofcol.u
%
% cMAP2D = {'NameMap', 'OutNameMap', 'OutName_X', 'OutName_Y', 'u2D', 'unitsOutX', 'unitsOutY', NpointsOutX, NpointsOutY, interpMode};
%
%%% OUTPUT
%
% tMapOut -> same format of tInfo.
%
% cMAP2D = {'vmu_KtOSMR_P_CostFactSOC_PBatShift_Po_SOC',     'KtOSMR_P_CostFactSOC_PBatShift_Po_SOC',   'KxOSMR_P_CostFactSOC_PBatShift_Po_Po',     'KyOSMR_P_CostFactSOC_PBatShift_Po_SOC',    'kW',   'kW',   '-',    10, 10, '',   [];...
%           'vmu_KtOSMR_r_CostFactSoc_Pos_Po',               'KtOSMR_r_CostFactSoc_Pos_Po',             'KxOSMR_r_CostFactSoc_Pos_Po_Po',           'KyOSMR_r_CostFactSoc_Pos_Po_SOC',          '-',    '-',    '-',    10, 10, '',   [];...
%           'vmu_KtOSMR_r_CostFactSoc_Neg_Po',               'KtOSMR_r_CostFactSoc_Neg_Po',             'KxOSMR_r_CostFactSoc_Neg_Po_Po',           'KyOSMR_r_CostFactSoc_Neg_Po_SOC',          '-',    '-',    '-',    10, 10, '',   [];...
%           'vmu_KtOPTR_P_BatPwrLossCost_Subj',               'KtOPTR_P_BatPwrLossCost_Subj',             'KxOPTR_P_BatPwrLossCost_Pbatt',           '',                                        'kW',    'kW',  '-',    21, 0, '',    [];...
%           };



% init 
sDisp = '';
tMapOut = struct();

% check dimension of instructions
if size(cMAP2D,2) ~= 10
    s = 'Error in "interpMap2D": cMAP2D number of column is incorrect';
    sDisp = updDispStr(sDisp, s);
    return
end

%
cMAP2Dcompact_names{1,1} = cMAP2D(:,1);
bIdx = isfield(tInfo,cMAP2Dcompact_names{:});

% check if maps are present
if sum(bIdx) == 0
    return
end

idx_map = find(bIdx);
for i = 1:length(idx_map)
    
    % extract info from cell array
    sMAPnameIn = cMAP2D{idx_map(i),1};
    sMAPname = cMAP2D{idx_map(i),2};
    sXname = cMAP2D{idx_map(i),3};
    sYname = cMAP2D{idx_map(i),4};
    sMAPunits = cMAP2D{idx_map(i),5};
    sXunits = cMAP2D{idx_map(i),6};
    sYunits = cMAP2D{idx_map(i),7};
    NptsX = cMAP2D{idx_map(i),8};
    NptsY = cMAP2D{idx_map(i),9};
    sinterpMode = cMAP2D{idx_map(i),10};
    
    % completes x and y fields
    if isfield(tInfo,sMAPnameIn)
        if ~isfield(tInfo.(sMAPnameIn), 'x')
            tInfo.(sMAPnameIn).x = '';
        end
        if ~isfield(tInfo.(sMAPnameIn), 'y')
            tInfo.(sMAPnameIn).y = '';
        end
    end
    
    % check existance of required fields for table
    if ~isfield(tInfo,sMAPnameIn) || ...
            ~isfield(tInfo.(sMAPnameIn), 'v') || ~isfield(tInfo.(sMAPnameIn), 'u')...
            || ~isfield(tInfo.(sMAPnameIn), 'x') || ~isfield(tInfo.(sMAPnameIn), 'y')
        s = ['Warning in "interpMap2D":', sMAPnameIn, ' variable has not correct format'];
        sDisp = updDispStr(sDisp, s);
        continue
    end
    
    
    val_map = mainUnitConversion(tInfo.(sMAPnameIn).v, tInfo.(sMAPnameIn).u, sMAPunits);
    if isempty(val_map)
        val_map = tInfo.(sMAPnameIn).v;
        s = ['Warning in "interpMap2D":', sMAPnameIn, ' variable units not converted'];
        sDisp = updDispStr(sDisp, s);
        %sMAPunits = tInfo.(sMAPnameIn).u;
    end
    
    if any(isnan(val_map)) %%%caso curve
        s = ['Warning in "interpMap2D":', sMAPnameIn, ' contains NaNs'];
        sDisp = updDispStr(sDisp, s);
        continue
    end
    
    
    %check the kind of map (0D - 1D - 2D)
    x_present = ~isempty(tInfo.(sMAPnameIn).x);
    y_present = ~isempty(tInfo.(sMAPnameIn).y);
    
    if x_present
        strX = tInfo.(sMAPnameIn).x;
        valX = tInfo.(strX).v;
        valX = mainUnitConversion(valX, tInfo.(strX).u, sXunits);
        if isempty(valX)
            valX = tInfo.(strX).v;
            s = ['Warning in "interpMap2D":', strX, ' variable units not converted'];
            sDisp = updDispStr(sDisp, s);
        end
        X_i = infittimento(valX, min(valX), max(valX), NptsX);
        
    end
    if y_present
        strY = tInfo.(sMAPnameIn).y;
        valY = tInfo.(strY).v;
        valY = mainUnitConversion(valY, tInfo.(strY).u, sYunits);
        if isempty(valY)
            valY = tInfo.(strY).v;
            s = ['Warning in "interpMap2D":', strY, ' variable units not converted'];
            sDisp = updDispStr(sDisp, s);
        end
        %stretch
        Y_i = infittimento(valY, min(valY), max(valY), NptsY);
    end
    
    map_out=val_map;
    if ~isempty(val_map)
        switch x_present+y_present
            case 0
                map_out=val_map;
            case 1
                if x_present
                    map_out = interp1sat(valX(:)', val_map(:), X_i(:), sinterpMode);
                    tMapOut.(sXname).v=X_i;
                    tMapOut.(sXname).u=sXunits;
                else
                    map_out = interp1sat(valY(:), val_map(:), Y_i(:), sinterpMode);
                    tMapOut.(sYname).v=Y_i;
                    tMapOut.(sYname).u=sYunits;
                end
                
            case 2
                %interp
                %map_out = interp2sat(tInfo.(strY).v(:),tInfo.(strX).v(:)',val_map,Y_i(:),X_i(:)');
                map_out = interp2sat(valY(:),valX(:)',val_map,Y_i(:),X_i(:)');
                tMapOut.(sXname).v=X_i;
                tMapOut.(sXname).u=sXunits;
                
                tMapOut.(sYname).v=Y_i;
                tMapOut.(sYname).u=sYunits;
        end
    end
    tMapOut.(sMAPname).v = map_out;
    tMapOut.(sMAPname).u = sMAPunits;
    tMapOut.(sMAPname).x = sXname;
    tMapOut.(sMAPname).y = sYname;
    
end

return


