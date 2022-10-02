function m_cyl = massFlow2CylMass(dmdt, sUnMassFlow, v_eng, sUnVeng, n_cyl, sUnCylMass)
% OUTPUT
% m_cyl: mass per cycle and per cylinder
%
% INPUT
% dmdt: mass flow
% sUnMassFlow: units of above
% v_eng: engine speed
% sUnVeng: units of above
% n_cyl: cilinder number
% sUnCylMass: desired per cycle and per cylinder units

v_eng_rpm = angularSpdUm2Um(v_eng, sUnVeng, 'rpm');
v_eng_rpm = max(v_eng_rpm, 1e-3);
dmdt_mgs = massFlowUm2Um(dmdt, sUnMassFlow, 'mg/s');
m_cyl_mgcc = dmdt_mgs ./ ((n_cyl/2) .*(v_eng_rpm/60)); % [mg/s]
m_cyl = massUm2Um(m_cyl_mgcc, 'mg/cc', sUnCylMass);

return