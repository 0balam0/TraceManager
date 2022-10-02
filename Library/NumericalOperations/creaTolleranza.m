function toll = creaTolleranza(val,coeff)
%dato un numero, ne calcola la tolleranza dell'ordine di grandezza
%ricavabile da x*coeff in modo che sia multipla di 1,2,5,10...(non
%corretto, vedi esempio sotto)
%ex: x=5120 rpm; coeff = 0.01 --> toll = 50
if coeff == 0
    toll = 0;
    return
end
val = val*coeff; %ex: 51.2
sVal = sprintf('%0.1e', max(max(val))); %ex: 5.1e001 rpm
posE = strfind(sVal,'e');
sNum = sVal(1:posE-1); %ex: 5.1
sExp = sVal(posE:end); %ex: e001
tollNorm = str2double(sNum); %ex: 5.1
%prima cifra da impiegare come incremento per le scale (ex:5)
if (tollNorm >= 1 ) && (tollNorm <= 1.4)
    b = 1;
elseif (tollNorm >= 1.5) && (tollNorm <= 3.4)
    b = 2;
elseif (tollNorm >= 3.5) && (tollNorm <= 7.4)
    b = 5;
elseif (tollNorm >= 7.5) && (tollNorm < 10)
    b = 10;
end
toll = str2double([num2str(b),sExp]); %tolleranza arrotondata (ex:50) 
return