function [Pos] = position_Stnd2Mat(h,nL,nT,nW,nH)

par_Pos=get(h,'Position');
Pos(1)=nL;
Pos(3)=nW;
Pos(4)=nH;
Pos(2)=par_Pos(4)-nT-nH;
return
