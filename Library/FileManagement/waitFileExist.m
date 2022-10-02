function bCheckState = waitFileExist(sFile, varargin)

bCheckState = false;

% set pause time for checking
t_wait = 0.01;
t_max = 60;
if not(isempty(varargin))
    L = length(varargin);
    % refresh time
    if L>=1 && not(isempty(varargin{1}))
        t_wait = varargin{1};
    end
    if L>=2 && not(isempty(varargin{2}))
        t_max = varargin{2};
    end
end

% TODO: set bCheckState when a max time is reached
t = clock;
while exist(sFile,'file') == 0
    if etime(clock,t) > t_max
        disp(['Warning: reached max time for checking the existance of file: ', sFile])
        return
    end
    pause(t_wait)
end

bCheckState = true;

end

