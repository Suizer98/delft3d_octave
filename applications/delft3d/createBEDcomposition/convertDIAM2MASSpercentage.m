function [MASSprct]=convertDIAM2MASSpercentage(varargin)
%   The function 'convertDIAM2MASSpercentage.m' computes the mass fraction of sediment
%   for pre-specified sieve fractions on the basis of D10, D50 and D90 values.
%   For this purpose a log-normal distribution is fitted on the D10, D50 and D90 values.
%
%   Syntax:
%       function [MASSprct]=convertDIAM2MASSpercentage(GRDfile,D10file,D50file,D90file,SIEVEsizes)
%         OR
%       function [MASSprct]=convertDIAM2MASSpercentage(D10file,D50file,D90file,SIEVEsizes)
%
%   Input: 
%       GRDfile      String with grid filename
%       D10file      String with D10 filename (similar format as depth file)
%       D50file      String with D50 filename (similar format as depth file)
%       D90file      String with D90 filename (similar format as depth file)
%       SIEVEsizes   = '';
%
%   Output:
%       MASSprct     Structure with compute mass percentages of each of the sediment fractions of the bed
%                     .sieves         cell with range of specified sieve fraction
%                     .sievesize      array with size of sieve fractions
%                     .wght           array with mass of each sediment fraction (e.g. to be used as input field for Delft3D)
%
%   Example
%       SIEVEsizes = [1.18, 0.600, 0.425, 0.300, 0.212, 0.150, 0.063];
%       D10 = 129;
%       D50 = 198;
%       D90 = 336;
%       [MASSprct]=convertDIAM2MASSpercentage(D10,D50,D90,SIEVEsizes);
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 <COMPANY>
%       B.J.A. Huisman
%
%       bas.huisman@deltares.nl
%
%       Boussinesqweg 1, 2629 HV, Delft, The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Apr 2015
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $


    %% READ INPUT INFORMATION
    plotfigure=0;
    if nargin==4
        %D10file,D50file,D90file,SIEVEsizes
        D10 = varargin{1}; %D10file;
        D50 = varargin{2}; %D50file;
        D90 = varargin{3}; %D90file;
        SIEVEsizes = varargin{4};
        D50file = ['D50 = ',num2str(D50,'%1.0f')];
    elseif nargin==5 && (isempty(varargin{1}) && isnumeric(varargin{2}))
        %'',D10file,D50file,D90file,SIEVEsizes
        D10 = varargin{2}; %D10file;
        D50 = varargin{3}; %D50file;
        D90 = varargin{4}; %D90file;
        SIEVEsizes = varargin{5};
        D50file = ['D50 = ',num2str(D50,'%1.0f')];
    elseif nargin==5
        %GRDfile,D10file,D50file,D90file,SIEVEsizes
        GRD = wlgrid('read',varargin{1});
        D10 = wldep('read',varargin{2},GRD);D10(D10==-999)=nan;
        D50 = wldep('read',varargin{3},GRD);D50(D50==-999)=nan;
        D90 = wldep('read',varargin{4},GRD);D90(D90==-999)=nan;
        SIEVEsizes = varargin{5};
        [pthnm,D50file,extnm] = fileparts(varargin{3});
    else
        fprintf('Error : Input not specified correctly!\n');
    end

    %% CHECKS ON THE DIMENSIONS OF THE SIEVES AND D50
    if mean(SIEVEsizes)/min(D50(~isnan(D50)))>1000
        D10=D10.*1000;
        D50=D50.*1000;
        D90=D90.*1000;
        fprintf('Warning : Dimensions of specified D50 and sievesizes possibly not in accordance!\n')
        fprintf('           -> Scaled up the D50 value by a factor 1000\n')
    elseif mean(SIEVEsizes)/min(D50(~isnan(D50)))<0.001
        SIEVEsizes = SIEVEsizes*1000;
        fprintf('Warning : Dimensions of specified D50 and sievesizes possibly not in accordance!\n')
        fprintf('           -> Scaled up the sievesize by a factor 1000\n')   
    end

    %% ASSESS MASS PERCENTAGE PER SIEVE
    h = waitbar(0,'Please wait...');
    DIAM2=[];iijj=[];
    MASSprct = nan(size(D50));
    for ii=1:1:size(D50,1)
        for jj=1:1:size(D50,2)
            waitbar(((ii-1)*size(D50,2)+jj)/(size(D50,1)*size(D50,2)),h)
            %fprintf('ii=%5.0f,jj=%5.0f\n',ii,jj)
            %if ii==90 && jj==2
            %    stopscript=1;
            %end

            if isnan(D50(ii,jj))
                MASSprct(ii,jj).sieves = [];
                MASSprct(ii,jj).sievesize = [];
                MASSprct(ii,jj).wght = nan(length(SIEVEsizes)-1,1);
            else
                PERC = [10,50,90];
                %DIAM = [129,198,336];
                DIAM = [D10(ii,jj),D50(ii,jj),D90(ii,jj)];
                DIAM2 = [DIAM2;round(D90(ii,jj)*1e9+D50(ii,jj)*1e6+D10(ii,jj)*1000)];iijj=[iijj;ii,jj];
                IDdiam2 = find(DIAM2(1:end-1)==DIAM2(end),1);
                if ~isempty(IDdiam2)
                    ii2 = iijj(IDdiam2,1);
                    jj2 = iijj(IDdiam2,2);
                    MASSprct(ii,jj) = MASSprct(ii2,jj2);
                else

                    if DIAM(2)<10;
                        DIAM=DIAM*1000;
                    end

                    dx = 20;
                    szi = [dx:dx:max(1000,D90(ii,jj)*1.2)];
                    D50b=DIAM(2);D10b=DIAM(1);D90b=DIAM(3);
                    mu = D50b;
                    sigma1 = (D50b-D10b)/2.6;
                    sigma2 = (D90b-D50b)/2.6;
                    sigma = mean([sigma1,sigma2]);


                    %% FIT A COMPOSITE NORMAL DISTRIBUTION (DIFFERENT SIGMA ON LEFT AND RIGHT SIDE OF PEAK)
                    PDFnormal1 = 1./(sqrt(2*pi)*sigma) .* exp( -((szi-mu).^2 ./ (2*sigma1.^2)) );
                    PDFnormal2 = 1./(sqrt(2*pi)*sigma) .* exp( -((szi-mu).^2 ./ (2*sigma2.^2)) );
                    ID1 = find(szi<=mu);
                    ID2 = find(szi>mu);
                    PDFnormal1(ID1(end));
                    PDFnormal2(ID2(1));
                    PDFnormal = [PDFnormal1(ID1),PDFnormal2(ID2)];
                    if plotfigure==1 || jj==1
                    figure(79);clf;plot(szi,PDFnormal1,'b:');hold on;plot(szi,PDFnormal2,'r:');plot(szi,PDFnormal,'k.-')
                    end
                    sigma3 = sigma/10;
                    %[estimates,WGHTclassiFIT] = getFUNCTIONfit(DIAM,100-PERC,'lognormal',[0,1,1]);
                    %A=estimates(1);B=estimates(2);C=estimates(3);
                    %PERCi = 100 - C./(sqrt(2*pi) .* szi .*B) .* exp( -((log(szi)-A).^2 ./ (2*B.^2)) );
                    %figure;plot(DIAM,PERC,'r*');hold on;plot(szi,PERCi,'b-');

                    %% FIT A CUMULATIVE LOG NORMAL DISTRIBUTION
                    % uses the cumulative log-normal distribution
                    % Fx_lognormal = 0.5*erfc(-(ln(xdata)-mu)/(sigma*sqrt(2)));
                    [estimates,WGHTclassiFIT] = getFUNCTIONfit(DIAM,PERC/100,'lognormalcumulative',[12,22]); 
                    mu3=estimates(1); %log(30);
                    sigma3=estimates(2);
                    lognormfitdata = 0.5*erfc(-(log(DIAM)-mu3)./(sigma3*sqrt(2)));
                    lognormfit = 0.5*erfc(-(log(szi)-mu3)./(sigma3*sqrt(2)));

                    %% CREATE LOG-NORMAL DISTRIBUTION
                    % uses the log-normal distribution
                    % lognorm = 1./(xdata.*sqrt(2*pi)*sigma) .* exp( -((log(xdata)-mu).^2 ./ (2*sigma.^2)) );
                    PDFlognormal = 1./(szi.*sqrt(2*pi)*sigma3) .* exp( -((log(szi)-mu3).^2 ./ (2*sigma3.^2)) );
                    IDperc=[];
                    for kk=1:length(DIAM);IDperc(kk)=find(abs(szi-DIAM(kk))==min(abs(szi-DIAM(kk))),1);end

                    %% COMPUTE D10, D50 AND D90 FOR FITTED LOG-NORMAL DISTRIBUTION
                    %PDFintegral and SIZE10prct etc used for checking output
                    %PDFintegral = cumsum(PDFlognormal)*dx;              %PDFintegral = cumsum(PDFnormal)*dx;
                    %SIZE10prct = interp1(PDFintegral,szi,0.1);
                    %SIZE50prct = interp1(PDFintegral,szi,0.5);
                    %SIZE90prct = interp1(PDFintegral,szi,0.9);

                    %% COMPUTE THE MASS AT EACH 'SIEVE' (USING CUMULATIVE DISTRIBUTION)
                    if max(SIEVEsizes)<50;SIEVEsizes=SIEVEsizes*1000;end
                    if SIEVEsizes(1)==max(SIEVEsizes) && SIEVEsizes(1)~=inf;SIEVEsizes=[inf,SIEVEsizes,0];symbolstr={'>','<'};end
                    if SIEVEsizes(1)==min(SIEVEsizes) && SIEVEsizes(1)~=0;SIEVEsizes=[0,SIEVEsizes,inf];symbolstr={'<','>'};end
                    lognormfitsieves = 0.5*erfc(-(log(SIEVEsizes)-mu3)./(sigma3*sqrt(2)));
                    if ii==1 && jj==1;MASSprct=struct;end
                    MASSprct(ii,jj).sieves{1,1} = [symbolstr{1},num2str(SIEVEsizes(2),'%1.0f'),'um'];
                    for kk=2:length(SIEVEsizes)-2
                        MASSprct(ii,jj).sieves{kk,1} = [num2str(min(SIEVEsizes(kk),SIEVEsizes(kk+1)),'%1.0f'),'um - ',num2str(max(SIEVEsizes(kk),SIEVEsizes(kk+1)),'%1.0f'),'um'];
                    end
                    MASSprct(ii,jj).sieves{kk+1,1} = [symbolstr{2},num2str(SIEVEsizes(kk+1),'%1.0f'),'um'];
                    MASSprct(ii,jj).sievesize = [SIEVEsizes(2:end)',SIEVEsizes(1:end-1)'];
                    MASSprct(ii,jj).wght = (round(abs(diff(lognormfitsieves))*10e5)/10e5)';

                    %% COMPUTE THE MASS AT EACH 'SIEVE' (USING LOG-NORMAL DISTRIBUTION)
                    % PERCsv=[];
                    % for kk=1:length(SIEVEsizes)-1
                    %     SVdiam = [SIEVEsizes(kk+1),SIEVEsizes(kk)];
                    %     SVdiamavg(kk) = mean(SVdiam);
                    %     IDsv = find(szi>SVdiam(1) & szi<SVdiam(2));
                    %     PERCsv(kk) = sum(dx.*PDFlognormal(IDsv));
                    % end
                    %% PLOT CUMULATIVE LOG-NORMAL DISTRIBUTION AND LOG-NORMAL DISTRIBUTION
                    if plotfigure==1 || jj==1
                        figure(80);clf;
                        subplot(2,1,1);plot(DIAM,lognormfitdata,'b*');hold on;plot(szi,lognormfit,'r-');title('cumulative distribution function');xlabel('diameter [mu]');ylabel('cum. frequency of occurence [-]')
                        subplot(2,1,2);plot(szi,PDFlognormal,'r-');hold on;title('cumulative distribution function');xlabel('diameter [mu]');ylabel('frequency of occurence [-]')
                        for kk=1:length(DIAM);
                            plot(szi([IDperc(kk),IDperc(kk)]),[0,PDFlognormal(IDperc(kk))],'b-');
                        end
                        ha = annotation('textbox',[.3 .5 0.92 .08],'String',[D50file,' (ii=',num2str(ii),',jj=',num2str(jj),')'],'LineStyle','none','HorizontalAlignment','center');
                    end
                end
            end
        end
    end
    close(h);
end