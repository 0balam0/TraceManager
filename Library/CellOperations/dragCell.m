function cIn = dragCell(cIn, sDir)

% drag cells Excel-like into empty cells, in rows/ columns direction
% when a cell is find filled, the new value is dragged to next cells
%
% INPUT: 
% cIn: input cell array
% sDir: string for direction: 'row', 'col'
%
% OUTPUT: 
% cIn: output cell array

[r,c] = size(cIn);
switch sDir
    
    case 'row'
        % drag in row (vertical) direction
        for j = 1:c
            for i = 1:r
                if i == 1
                    % update the value to be drag
                    val = cIn{i,j};
                else
                    if isempty(cIn{i,j})
                        % fill with drag value
                        cIn{i,j} = val;
                    else
                        % update the value to be drag
                        val = cIn{i,j};
                    end
                end
            end
        end
        
    case 'col'
        % drag in column (horizontal) direction
        for i = 1:r
            for j = 1:c
                if j == 1
                    % update the value to be drag
                    val = cIn{i,j};
                else
                    if isempty(cIn{i,j})
                        % fill with drag value
                        cIn{i,j} = val;
                    else
                        % update the value to be drag
                        val = cIn{i,j};
                    end
                end
            end
        end
        
end


return