function CursorDemo()
% demo function for cursors
%
% Example:
% type CursorDemo at the command line
h=figure('Name','Hold the left button down over the cursors to move them around the screen');
x=0:0.01:10;
y=sin(x);
for k=1:5
    sp(k) = subplot(5,1,k); hold on;
    plot(x,y,'Tag', 'line_asd');
end
plot(sp(3), x,y*2,'Tag', 'line_ciaomamma');
plot(sp(4), x,sin(3*x),'Tag', 'line_ciasd');
n1=CreateCursor(h);
SetCursorLocation(n1, 2.5);
n2=CreateCursor(h);
SetCursorLocation(n2, 7.5);
end
