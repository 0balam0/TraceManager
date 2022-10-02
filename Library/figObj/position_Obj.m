function [nLeft,nTop,nWidth,nHeight]=position_Obj(handles,sObj,Left,Top,Width,Height)
% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try  
    [sObj,h1]=getFieldReal(handles,sObj);
    if h1>0
        hPar=get(h1,'parent');
        par_Pos=get(hPar,'Position');
        obj_Pos=get(h1,'Position');
        
        [nL,nT,nW,nH] = position_Mat2Stnd(hPar,obj_Pos);
        [Pos] = position_Stnd2Mat(hPar,nL,nT,nW,nH);
        
        if isnumeric(Top)
            nTop=Top;
        else
            nTop=nT;
        end
        if isnumeric(Left)
            nLeft=Left;
        else
            nLeft=nL;
        end
        
        sW=Width(1);
        val=str2num(strrep(Width,sW,''));
        nWDx=par_Pos(3)-nLeft;
        switch sW
            case '='
                nWidth=nW;
            case '%'
                nWidth=nWDx*val/100;
            case 'w'
                nWidth=val;
            case 'r'
                nWidth=nWDx-val;
            case 'l'
                nWidth=val-nLeft;
        end

        sH=Height(1);
        val=str2num(strrep(Height,sH,''));
        nHDw=par_Pos(4)-nTop;
        switch sH
            case '='
                nHeight=nH;
            case '%'
                nHeight=nHDw*val/100;
            case 'h'
                nHeight=val;
            case 'b'
                nHeight=nHDw-val;
            case 't'
                nHeight=val-nTop;
        end

        [new_Pos] = position_Stnd2Mat(hPar,nLeft,nTop,nWidth,nHeight);
        set(h1,'Position',new_Pos) 
        
    end;
% % GESTIONE ERRORI
catch
    [sOut]=gestErr2(THIS_FUNCTION);
end
return;