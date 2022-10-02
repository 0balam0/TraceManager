function [sStatus] = fileprint(Name_File_mss, ext, tWriteMSS, cIntest, mDati)

sStatus = 'failed';
flagMAP = ''; 
r = 0;
clist = fieldnames(tWriteMSS);
for i = 1:length(clist)
    if isfield(tWriteMSS.(clist{i}),'x')%maps
        bMap = 1;
        flagMAP = 'empty'; 
        if  ~isempty(tWriteMSS.(clist{i}).x) && isempty(tWriteMSS.(clist{i}).y)
            flagMAP = '1D';            
        elseif ~isempty(tWriteMSS.(clist{i}).y)
            flagMAP = '2D'; 
        end
    end
    
    if isfield(tWriteMSS.(clist{i}),'x') && ~isempty(tWriteMSS.(clist{i}).x) % find maps
        
        % write maps in string format
        sMap_format = ['[val][', tWriteMSS.(clist{i}).u, ']['];
        for j = 1:length(tWriteMSS.(clist{i}).v)
            sMap_format = [sMap_format, num2str(tWriteMSS.(clist{i}).v(j)), ';'];
        end
        % x struct
        sRowName = [ext,tWriteMSS.(clist{i}).x];
        sMap_format = [sMap_format,']+[row][', tWriteMSS.(sRowName).u, ']['];
        for z = 1:length(tWriteMSS.(sRowName).v)
            sMap_format = [sMap_format, num2str(tWriteMSS.(sRowName).v(z)), '|'];
        end
        % y struct if exists
        if isfield(tWriteMSS.(clist{i}),'y') && ~isempty(tWriteMSS.(clist{i}).y)
            sColName = [ext,tWriteMSS.(clist{i}).y];
            sMap_format = [sMap_format, ']+[col][', tWriteMSS.(sColName).u, ']['];
            for k = 1:length(tWriteMSS.(sColName).v)
                sMap_format = [sMap_format, num2str(tWriteMSS.(sColName).v(k)), '|'];
            end
            sMap_format = [sMap_format, ']'];
        else
            sMap_format = [sMap_format, ']+[col][][]'];
        end
        tWriteMSS.(clist{i}).v = sMap_format;
        tWriteMSS.(clist{i}).u = 'nDmap';
        tWriteMSS.(clist{i}) = rmfield(tWriteMSS.(clist{i}),'x');
        tWriteMSS.(clist{i}) = rmfield(tWriteMSS.(clist{i}),'y');
    end
        switch flagMAP
            case 'empty'
                sRowName = [clist{i},'_x_i'];
                sColName = [clist{i},'_y_i'];
                r = r + 1;
                toRemove(r)= {sRowName};
                r = r + 1;
                toRemove(r)= {sColName};
            case '1D'
                %sRowName = [ext,tWriteMSS.(clist{i}).x];
                r = r + 1;
                toRemove(r)= {sRowName};
                sColName = [clist{i},'_y_i'];
                r = r + 1;
                toRemove(r)= {sColName};       
            case '2D'
                %sRowName = [ext,tWriteMSS.(clist{i}).x];
                r = r + 1;
                toRemove(r)= {sRowName};
                %sColName = [ext,tWriteMSS.(clist{i}).y];
                r = r + 1;
                toRemove(r)= {sColName};
            otherwise
        end
        flagMAP = ''; 
end

if exist('toRemove','var')
    for i = 1:length(toRemove)
        tWriteMSS = rmfield(tWriteMSS,toRemove{i});
    end
end

% openFile
fid = fopen(Name_File_mss, 'w');

fprintf(fid, '<Info>\r\n');

clist = fieldnames(tWriteMSS);
for i = 1:length(clist)
    if ischar(tWriteMSS.(clist{i}).v)
        fprintf(fid,[clist{i}, '\t', tWriteMSS.(clist{i}).v, '\t[',tWriteMSS.(clist{i}).u, ']\r\n']);
    else
        fprintf(fid,[clist{i}, '\t', num2str(tWriteMSS.(clist{i}).v), '\t[',tWriteMSS.(clist{i}).u, ']\r\n']);
    end
end

fprintf(fid, '</Info>\r\n');

fprintf(fid, '<Dati>\r\n');

for i = 1:size(cIntest,2)
    fprintf(fid, '%s\t', cIntest{1,i});
end
fprintf(fid, '\r\n');

for i = 1:size(cIntest,2)
    fprintf(fid, '%s\t', cIntest{2,i});
end
fprintf(fid, '\r\n');

for j = 1:size(mDati,1)
    for i = 1:size(mDati,2)
        fprintf(fid, '%5.2f\t', mDati(j,i));
    end
    fprintf(fid, '\r\n');
end

fprintf(fid, '</Dati>');

fclose(fid);

sStatus = 'ok';

return
