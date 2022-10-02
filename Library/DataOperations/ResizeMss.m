function ResizeMss(wspName, numPts)
% Resize mission profile in the GOFAST wsp
wsp = load(wspName);

timeOld = wsp.time_mt;
wsp.time_mt = linspace(0, max(wsp.time_mt), numPts);
wsp.dist_mt = linspace(0, max(wsp.dist_mt), numPts);

vars = {...
	'gear_mt'
	'speed_mt'
	'P_elLoad_d'
	'P_elLoadHV_d'
	'C_meccAux_d'
	'lockUp_d'
	'v_eng_mt'
	'C_eng_mt'
	'engMap_d'
	'Miss_AGS_d'
	'Miss_v_Htzfan_d'
	'bKeyOn_d'
	'cycle_d'
	'T_environment_d'
	'bTempReset_d'
	'bAcActivation_d'
	'spP_solarload_d'
	'relHumidity_d'
	'Miss_p_PS_d'
	'Miss_I_alt_d'
	'Miss_b_NSCdeNOx_d'
	'T_battCell_d'
	'T_EMA_d'
	'T_EMB_d'
	'RaggioCurv_mt'
	'pend_mt'
	'altitude_mt'
	'RetLev_d'
	'State_Tip_d'
	'T_Cabin_Des'
	'T_Cabin_Act'
    'T_MC1_d'
	'T_MC4_d'
	'Miss_T_eot_d'
	'Miss_T_ect_d'
	};
	

for i = 1:length(vars)
    disp(vars{i});
    if islogical(wsp.(vars{i})(1))
        gi = griddedInterpolant(timeOld, double(wsp.(vars{i})));
        wsp.(vars{i}) = false(size(wsp.time_mt));
        for j = 1:length(wsp.time_mt)
            wsp.(vars{i})(j) = logical(gi(wsp.time_mt(j)));
        end
    else
        gi = griddedInterpolant(timeOld, wsp.(vars{i}));
        wsp.(vars{i}) = zeros(size(wsp.time_mt));
        for j = 1:length(wsp.time_mt)
            wsp.(vars{i})(j) = gi(wsp.time_mt(j));
        end
        wsp.(vars{i}) = zeros(numPts, 1);
    end
end

save(wspName, '-struct', 'wsp');
return