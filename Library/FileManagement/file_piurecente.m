function cOut=file_piurecente(varargin)

dir0=pwd;

prompt={'Di quale tipo sono i file da confrontare?'};
name  ='Scegli il tipo di file';
sugg  ={'*.m'};
% answer=inputdlg(prompt,'Scegli il tipo di file',1,{'*.m'});
% cTipo =answer(1);

switch nargin
   case 0
      dir1  =uigetdir(pwd,'Indica la prima delle due directory');
      dir2  =uigetdir(pwd,'Indica la seconda delle due directory');
      answer=inputdlg(prompt,'Scegli il tipo di file',1,{'*.m'});
      cTipo =answer(1);
   case 1
      dir1  =varargin{1};
      dir2  =uigetdir(pwd,'Indica la seconda delle due directory');
      answer=inputdlg(prompt,'Scegli il tipo di file',1,{'*.m'});
      cTipo =answer(1);
   case 2
      dir1  =varargin{1};
      dir2  =varargin{2};
      answer=inputdlg(prompt,'Scegli il tipo di file',1,{'*.m'});
      cTipo =answer(1);
   case 3
      dir1  =varargin{1};
      dir2  =varargin{2};
      cTipo =varargin(3);      
end

if isempty(dir1)
   dir1  =uigetdir(pwd,'Indica la prima delle due directory');
end
if isempty(dir2)
   dir2  =uigetdir(pwd,'Indica la seconda delle due directory');
end
   
% prende solo un tipo di file, il primo indicato dall'operatore, perché il
% comando "dir" di Matlab accetta solo un tipo di file
cSep={char(9), ';', ',', ' '};
for iSep=1:length(cSep)
   [dum, cTipo]=splitString(strtrim(cTipo{1}), cSep{iSep});
end
sTipo=cTipo{1};
if sTipo(1)=='.'
   % Se sTipo è una stringa che indica solo un'estensione, ad esempio
   %    ".ext", aggiungo l'asterisco e sTipo diventa "*.ext"
   sTipo=['*', sTipo];
end


try
   cd(dir1);
catch
   uiwait(msgbox('Prima directory non valida: riprova',...
                 'Invalid choice','error','modal'))
   dir1=uigetdir(pwd,'Indica la prima delle due directory');
   cd(dir1)
end   
a1   =dir(sTipo);
%%
i0=0;
for ii=1:length(a1)
   if ~a1(ii).isdir
      i0=i0+1;
      nomi1{i0,1}=a1(ii).name;
      date1(i0,1)=a1(ii).datenum-datenum('31-Aug-2005');
   end
end
i1=i0;
% nomi1=char(nomi1);
%%
try
   cd(dir2);
catch
   uiwait(msgbox('Seconda directory non valida: riprova',...
                 'Invalid choice','error','modal'))
   dir2=uigetdir(pwd,'Indica la seconda delle due directory');
   cd (dir2)
end
a2   =dir(sTipo);
%%
i0=0;
for ii=1:length(a2)
   if ~a2(ii).isdir
      i0=i0+1;
      nomi2{i0,1}=a2(ii).name;
      date2(i0,1)=a2(ii).datenum-datenum('31-Aug-2005');
   end
end
i2=i0;

cd(dir0)
clear a1 a2 % ii%%

% i1=length(nomi1);
% i2=length(nomi2);
cDir{1}=dir1;
cDir{2}=dir2;
disp(' ')
%
if i1*i2    
   % cioè, se i1>0 AND i2>0, ovvero se in entrambe le directory ci sono
   %    file del tipo in questione  
   letzt=[]; 
   % if i1
   nomi1=char(nomi1);
   % else
   %    nomi1=[];
   % end
   for jj=1:size(nomi1,1)
      x0=strcmpi(strtrim(nomi1(jj,:)), nomi2);
      x1=find(x0==1);
      if ~isempty(x1)
         if date1(jj)<date2(x1)
            % ultimo(jj,1)=2;
            letzt(end+1,1:3)=[jj 2 abs(date1(jj)-date2(x1))];
         elseif date1(jj)>date2(x1)
            % ultimo(jj,1)=1;
            letzt(end+1,1:3)=[jj 1 abs(date1(jj)-date2(x1))];
         else
            if ~isempty(x1)
               letzt(end+1,1:3)=[jj 0 0];
            end
            % ultimo(jj,1)=0;
         end
         if abs(date1(jj)-date2(x1))<=1/1440  % se la data differisce di 1 minuto al max
            letzt(end,2)=-letzt(end,2);
         end
         if abs(date1(jj)-date2(x1)) <= (1/24)*(1+1/60) && ...
            abs(date1(jj)-date2(x1)) >= (1/24)*(1-1/60) 
            % se la data differisce di 1 ora +/- 1 minuto 
            letzt(end,2)=-letzt(end,2);
         end
      end
   end
   if isempty(letzt)
      disp(['Nelle due directory non ci sono file del tipo "', sTipo, ...
            '" con lo stesso nome'])
   elseif all(letzt(:,2)==0)
      disp(['Tutti i file del tipo "', sTipo, '" presenti nelle due ', ...
            'directory'])
      disp(['hanno la stessa data e ora'])
   else
      disp('Lista dei file più recenti, e della directory in cui si trovano')
      disp(' ')
      % cerco le righe di letzt che si riferiscono a file con data diversa,
      % e tengo solo queste, mentre le altre vengono cancellate 
      idiff=find(letzt(:,2)>0);
      letzt1=letzt(idiff,:);
      nomiU=strtrim(nomi1(letzt1(:,1),:));
      for jk=1:size(letzt1,1)
         cOut{jk,1}=strtrim(nomiU(jk,:));
         cOut{jk,2}=cDir{letzt1(jk,2)};
         disp([nomiU(jk,:) '    ' cOut{jk,2}])
      end
      clear jk 
      sl1=size(letzt1,1);
      disp(' ')
      idiff=find(letzt(:,2)<0);
      letzt2=letzt(idiff,:);
      if ~isempty(idiff)
         disp('Lista dei file più recenti con differenze di data sospette,')
         disp('e della directory in cui si trovano')
         disp(' ' )
      end
      nomiU=strtrim(nomi1(letzt2(:,1),:));
      for jk=(1:size(letzt2,1))
         cOut{jk+sl1,1}=strtrim(nomiU(jk,:));
         cOut{jk+sl1,2}=cDir{-letzt2(jk,2)};
         cOut{jk+sl1,3}=letzt2(jk,3)*24*60*60; % diff di data in secondi
         disp([nomiU(jk,:) '    ' cOut{jk+sl1,2} ',   ' num2str(cOut{jk+sl1,3}) ' s'])
      end
      clear jk 
      
   end

else        % cioè, se in almeno una delle due directory non ci sono file
            %  del tipo in questione
   disp(['Non ci sono file del tipo "' sTipo '" da confrontare']);
end
clear x0 x1 jj date1 date2
% uu=find(ultimo(:,1)>0);

cd(dir0)

return