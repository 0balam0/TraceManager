function [nL,nT,nW,nH] = position_Mat2Stnd(h,Pos)

par_Pos=get(h,'Position');
nL=Pos(1);
nW=Pos(3);
nH=Pos(4);
nT=par_Pos(4)-Pos(2)-nH;

return
