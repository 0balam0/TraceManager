function [varargout] = retry(func, cArgIn, Nmax, Dt, varargin)

% retry function call "sFunc", whose input arguments are stored into
% cArgIn, every Dt [s], until Nmax temptatives are reached
% could be suitable to avoid excessive ques when writing to disk

tWsp = struct();
if not(isempty(varargin))
    a = find(strcmpi(varargin,'wsp'));
    tWsp = varargin{a+1};
end

% assigns wsp variables
cF = fieldnames(tWsp);
if not(isempty(cF))
    for i = 1:length(cF)
        assignin2('current', {cF{i}}, {tWsp.(cF{i})});
    end
end

if ischar(func)
    % sting of function
    sFunc = func;
    hFunc = str2func(func);
else
    % function handle
    sFunc = func2str(func);
    hFunc = func;
end

nOut = nargout;
hRfFunc = str2func(sFunc);
if isempty(Dt)
    Dt = 0.25;
end
if isempty(Nmax)
    Nmax = 10;
end

for i = 1:Nmax
    try
        [varargout{1:nOut}] = hRfFunc(cArgIn{:});
        % if successful, exit loop
        break
    catch
        % if unsuccessful, pauses and then goes to next try
        pause(Dt)
        disp(['Warning: re-try function call of "', sFunc,'"'])
    end
end
return
