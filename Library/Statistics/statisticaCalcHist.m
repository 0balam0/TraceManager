% % -------------IMPLEMENTAZIONE FUNCTION-------------------------- 
% 28-02-2005: implementazione dell'errore
% % -------------CALL FUNCTION--------------------------  
% Non c'è la struttura dei dati ne output e tutti i parametri sono necessari
%     [PrC,PrC_L,PrC_U,XC,PrD,XD,PrCFit,PrDFit,XFit,Xmin,Xmax]=statisticaCalcHist(Samples,AlphaPerc,Distribuzione);
% % -------------FUNCTION--------------------------
function [PrC,PrC_L,PrC_U,XC,PrD,XD,PrCFit,PrDFit,XFit,Xmin,Xmax]=statisticaCalcHist(varargin)

% % COSTANTI
THIS_FUNCTION=mfilename;

% % INIZIO FUNCTION
try
    fAlphaBoundary=0.05;
    sDistribuzione='Normal';
    if nargin < 1
        inactiveBox(mfilename,['Numero di argomenti (',num2str(nargin),') errato in ']);
        return;   
    end
    
    if nargin >= 3
        sDistribuzione=strtrim(varargin{3});
    end
    
    if nargin >= 2
        fAlphaBoundary=(100-varargin{2})/100;
    end
    
    if nargin >= 1
        Samples=varargin{1};
%         elimino i valori null
        t = ~isnan(varargin{1});
        Data = Samples(t);
    end
% Probabilità cumulata  =  PrD
% densità di probabilità = PrC
    [PrC,XC,PrC_L,PrC_U] = ecdf(Data,'alpha',fAlphaBoundary,'Function','cdf' );
    binInfo.rule=1;
    [XD,E_Bins] = dfhistbins(Data,[],[],binInfo,PrC,XC);
    
    [PrD,XD] = ecdfhist(PrC,XC,'edges',E_Bins); % empirical pdf from cdf
    PrD=PrD';
    XD=XD';
    n=length(XD);
    d=(XD(n)-XD(1))/n;
    Xmin=min(min(XC),min(XD)-d);
    Xmax=max(max(XC),max(XD)+d);
    
    XFit=[];
    XFit = linspace(Xmin,Xmax,100);
    XFit=XFit';
    PrDFit=[];
    PrCFit=[];
    try
        [phat, pci] = statisticaMLE(Data, 'dist',sDistribuzione);  % Fit Logistic distribution;
    catch
       return; 
    end
    if strcmpi(sDistribuzione,'non parametric') || strcmpi(sDistribuzione,'nonparametric'), 
        PrDFit = statisticaPDF(sDistribuzione,XFit,Data);
        PrCFit = statisticaCDF(sDistribuzione,XFit,Data);
    else
        switch length(phat)
            case 1
                PrDFit = statisticaPDF(sDistribuzione,XFit,phat(1));
                PrCFit = statisticaCDF(sDistribuzione,XFit,phat(1));
            case 2
                PrDFit = statisticaPDF(sDistribuzione,XFit,phat(1), phat(2));
                PrCFit = statisticaCDF(sDistribuzione,XFit,phat(1), phat(2));
            case 3
                PrDFit = statisticaPDF(sDistribuzione,XFit,phat(1), phat(2), phat(3));
                PrCFit = statisticaCDF(sDistribuzione,XFit,phat(1), phat(2), phat(3));
        end
    end
% % GESTIONE ERRORI
catch
    [sOutput]=gestErr2(THIS_FUNCTION);
end
return;