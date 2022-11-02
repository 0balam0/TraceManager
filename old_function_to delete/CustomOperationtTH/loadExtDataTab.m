function risp = loadExtDataTab(risp)

    [name, dir] = uigetfile('*.mat');
    tmp = load(strcat(dir,name));
    names = fieldnames(tmp);
    tableFound = {};
    for i =1:length(names)
        tab = tmp.(names{1});
        cmp1D = all(isfield(tab, {'x', 'y'}));
        cmp2D = all(isfield(tab, {'X', 'Y', 'V'}));
        if cmp1D || cmp2D
            tableFound{end+1} = names{1};
        end
    end

    for i=1:length(tableFound)
        risp.(tableFound{i}) = tmp.(tableFound{i});
    end
end
    