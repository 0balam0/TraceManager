function dispError(Me)
    mex = getReport(Me, 'extended','hyperlinks','off');
    uiwait(msgbox({['ID: ' Me.identifier]; ['Message: ' Me.message]; mex}, 'Error','Error','modal'))
    mex = getReport(Me)
end