function dmdt = cylMass2MassFlow(m_cyl, sUnCylMass, v_eng, sUnVeng, n_cyl, sUnMassFlow)
% OUTPUT
% dmdt: mass flow
%
% INPUT
% m_cyl: mass per cycle and per cylinder
% sUnCylMass: units of above
% v_eng: engine speed
% sUnVeng: units of above
% n_cyl: cilinder number
% sUnMassFlow: desired mass flow units

v_eng_rpm = angularSpdUm2Um(v_eng, sUnVeng, 'rpm');
m_cyl_mgcc = massUm2Um(m_cyl, sUnCylMass, 'mg/cc');
dmdt_mgs = m_cyl_mgcc .* (n_cyl/2) .*(v_eng_rpm/60); % [mg/s]
dmdt = massFlowUm2Um(dmdt_mgs, 'mg/s', sUnMassFlow);

return