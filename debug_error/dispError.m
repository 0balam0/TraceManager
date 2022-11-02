function dispError(Me, lbl)
%     mex = getReport(Me, 'extended','hyperlinks','off');
%     uiwait(msgbox({['ID: ' Me.identifier]; ['Message: ' Me.message]; mex}, 'Error','Error','modal'))
    mex = getReport(Me)
    risp = errorTracking(Me);
    if nargin == 2 
        funWriteToInfobox(lbl, {}, 'clc');
        funWriteToInfobox(lbl, risp, 'cell');
    end
end