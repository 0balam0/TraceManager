function out = listaColori(varargin)
% lista colori nel plottaggio delle linee

cColor = cell(20,1);
%
cColor{1} = [0,0,255]/255;
cColor{2} = [255,0,0]/255;
cColor{3} = [0,0,0]/255;
cColor{4} = [255,204,0]/255;
cColor{5} = [0,200,0]/255;
cColor{6} = [204,153,255]/255;
cColor{7} = [0,255,255]/255;
cColor{8} = [153,51,0]/255;
cColor{9} = [255,153,204]/255;
cColor{10} = [255,255,0]/255;
cColor{11} = [51,153,102]/255;
cColor{12} = [153,204,0]/255;
cColor{13} = [255,204,153]/255;
cColor{14} = [0,255,0]/255;
cColor{15} = [255,153,0]/255;
cColor{16} = [102,102,153]/255;
cColor{17} = [153,153,153]/255;
cColor{18} = [51,51,0]/255;
cColor{19} = [0,51,0]/255;
cColor{20} = [0,0,128]/255;
%
if not(isempty(varargin))
   out = cColor{varargin};
else
   out = cColor;
end
return