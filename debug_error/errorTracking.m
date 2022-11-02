function risp = errorTracking(Me)
% {'selManovra' 281}
    switch Me.stack(1).name
        case 'selManovra'
            risp{1} = sprintf('Please, load the time histories in order!');
        otherwise
            assignin('base', 'Me', Me);
            risp{1} = sprintf('Untracked error: %s', Me.identifier);
            risp{2} = sprintf('Message:%s', Me.message);
            if length(Me.stack)>1
                to = 1;
            else
                to = length(Me.stack);
            for i=1:length(Me.stack)
                risp{end+1} = sprintf('\t-%s', Me.stack(i).name);
            end
    end
end