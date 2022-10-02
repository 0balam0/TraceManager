function bOut = class2logical(val)
% converte il valore in ingresso in logico

if islogical(val)
   % ok, non faccio niente
   bOut = val;
elseif isnumeric(val) && (val==0 || val==1)
   % double --> logical
   bOut = logical(val);
else
   % stringa --> logical
   if any(strcmpi(val,{'1','0'}))
      bOut = logical(str2double(val));
   elseif any(strcmpi(val,{'true','false'}))
      bOut = str2num(val);  %#ok<ST2NM>
   elseif strcmpi(val,'Yes') || strcmpi(val,'Yeah') || strcmpi(val,'Si') || strcmpi(val,'Sì') || strcmpi(val,'On') || strcmpi(val,'Y')
      bOut = true;
   elseif strcmpi(val,'No') || strcmpi(val,'Off') || strcmpi(val,'N')
      bOut = false;
   else
      disp('Error: the input variable could not be converted to logical')
   end
end


return