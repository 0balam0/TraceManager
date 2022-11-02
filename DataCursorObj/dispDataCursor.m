function dispDataCursor(Cursor, x)
% switch nargin
%     case 1
%         fhandle=gcf;
%         CursorNumber=varargin{1};
%     case 2
%         fhandle=varargin{1};
%         CursorNumber=varargin{2};
% end
% [x, Cursor] = GetCursorLocation(fhandle, CursorNumber);
% disp(CursorNumber)
if ~isempty(x)
    for i=1:length(Cursor.TextInfo)
        strCum = mat2cell(zeros(length(Cursor.TextInfo{i}.UserData),1), length(Cursor.TextInfo{i}.UserData));
        Ystore = zeros(size(Cursor.TextInfo{i}.UserData));
        for j=1:length(Cursor.TextInfo{i}.UserData)
            l = Cursor.TextInfo{i}.UserData(j);
            [~, id] = min(abs(l.XData - x));
            try
                color = l.Color;
            catch
                try 
                    color = l.FaceColor;
                catch
                    color = [0,0,0];
                end
            end
            X = l.XData(id);
            Ystore(j) = l.YData(id);
            lineStyle = l.LineStyle;
            str = sprintf('\\color[rgb]{%.2f,%.2f,%.2f}{ %s: %.4f}', color(1), color(2), color(3), lineStyle, Ystore(j));
            strCum{j} = str;
        end
        Y = ((Cursor.TextInfo{i}.UserData(1).Parent.YLim(2)-...
            Cursor.TextInfo{i}.UserData(1).Parent.YLim(1))/2)+...
            Cursor.TextInfo{i}.UserData(1).Parent.YLim(1);
        if ~isempty(Cursor.TextInfo{i}.UserData)
            set(Cursor.TextInfo{i}, 'String', strCum,'interpreter', 'tex');
            set(Cursor.TextInfo{i}, 'Position', [X, Y, 0]);
        end
    end
    LabelHandle=findobj(Cursor.Handles, 'Type', 'text');
    set(LabelHandle, 'String', sprintf('%.3f', X));
    oldPos = get(LabelHandle, 'Position'); oldPos(1) = X;
    set(LabelHandle, 'Position', oldPos);
end
end

%     axs = findobj(fhandle, 'type', 'axes'); %trovo tutti gli obj assi
%     for i=1:length(axs) % per ogni asse
%         L = findobj(axs(i), 'type', 'line'); %trovo tutte le linee
%         toEval = ~strcmp(get(L, 'Tag'),'Cursor');
%         Leval = L(toEval);
%         strCum = '';
%         for j=1:length(Leval)
