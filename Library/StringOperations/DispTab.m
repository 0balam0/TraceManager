% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 29-08-06 : implementazione 
% % -------------CALL FUNCTION--------------------------  
%     DispTab(X);
% % -------------FUNCTION--------------------------
function sDisp=DispTab(varargin)
global file_log
% % COSTANTI
THIS_FUNCTION=mfilename;
% % INIZIO FUNCTION
try
   
   nSpace=0;
   s='';
   sStr='';
   if nargin == 0
      nSpace=1;
   elseif nargin == 1
      nSpace=varargin{1};
   else
      nSpace=varargin{1};
      nStr=nargin-1;
      for i =1 : nStr
         sStr=[sStr,num2str(varargin{1+i})];
      end
   end
   s(1:nSpace)=' ';
   sDisp=[s,sStr];
   disp(sDisp);

   
% % GESTIONE ERRORI 
catch
   [sOutput]=gestErr2(THIS_FUNCTION);
end

return;




