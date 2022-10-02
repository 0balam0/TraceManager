function [] = getPointsFromChart()

% asks for image to be read
[sFile, sPath] = uigetfile('*.*', 'select an image to be read...');
if isequal(sFile,0)
    return
end
sFileFull = fullfile(sPath, sFile);
[sPath, sName, sExt] = fileparts(sFileFull);

% reads figure
[map] = imread(sFileFull, sExt(2:end));

% displays image in a figure
figure();
image(map)
uiwait(msgbox(['select axes limits']))

% picks points
[x, y] = ginput(2);
xPointsLimit = [min(x) max(x)];
yPointsLimit = [min(y) max(y)];

% asks for limits
prompt = {'enter X limits [min max]', 'enter Y limits [min max]'};
name = 'chart limits';
numlines=1;
defaultanswer = {'0 200', '0 150'};
answer = inputdlg(prompt,name,numlines,defaultanswer);
xChartLimit = str2num(answer{1});
yChartLimit = str2num(answer{2});
yChartLimit = [yChartLimit(2) yChartLimit(1)]; % reverse

% pick up points
uiwait(msgbox(['select data points. When finished, press return']))
[x, y] = ginput();
xPointsData = x;
yPointsData = y;

% transform to chart coordinates
% xAxisLimit = get(gca, 'xlim');
% yAxisLimit = get(gca, 'ylim');
xChartData = interp1(xPointsLimit, xChartLimit, xPointsData, 'linear', 'extrap');
yChartData = interp1(yPointsLimit, yChartLimit, yPointsData, 'linear', 'extrap');

% save on file
sFileOut = fullfile(sPath, [sName,'.txt']);
cHead = {'point', 'x', 'y';...
         '-','-','-'};
mData = [(1:1:length(xChartData))', xChartData(:), yChartData(:)];
writePerfFile(sFileOut, struct([]), cHead, mData, 'newFormat', false)

return