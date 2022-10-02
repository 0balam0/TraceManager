function [sFileList]=CmbLst_FileList(handles,obj,sFolder,sFilter,varargin)
% % COSTANTI
THIS_FUNCTION=mfilename;


% % INIZIO FUNCTION
try  
    sFile=[sFolder '\' sFilter ];
    tFile = dir(sFile);
    cF={};
    nFile=length(tFile);
    sFileList='';

    j=0;
    if nargin==5
        cF{1,1}=varargin{1};
        j=1;
    end
    for i=1:nFile
        j=j+1;
        cF{j,1}=tFile(i).name;
    end
    [sFileList]=char(cF);
% controlla sia un oggetto esistente
    [obj,h1]=getFieldReal(handles,obj);
    if h1>0
        if nFile>0
            set(h1,'string',sFileList);
            set(h1,'value',1);
        else
            set(h1,'string','(...)');
            set(h1,'value',1);
        end
    end;
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end

return;