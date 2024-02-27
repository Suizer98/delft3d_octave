function Plot_S_phi(input)
%plotS_phi.m : Plots S-phi output
%
%   Syntax:
%     function Plot_S_phi(input)
% 
%   Input:
%     input     structure with information on the S-Phi curves and plotting formats
%                    .dir         directory with files
%                    .file        RAY-file or GLO-file
%                    .reffile     reference RAY-file or GLO-file
%                    .test_id     run name (used for name of plotted graph)
%                    .fignum      figure number
%                    .output_dir  output directory for plots
%  
%   Output:
%     graph with S-Phi curves
%
%   Example:
%     input.dir=pwd;
%     input.file='file1.RAY';
%     input.reffile='file2.RAY';
%     input.test_id='DEF';
%     input.fignum=1;
%     input.output_dir='';
%     Plot_S_phi(input);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: Plot_S_phi.m 3493 2013-02-06 13:44:44Z huism_b $
% $Date: 2013-02-06 14:44:44 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3493 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/Plot_S_phi.m $
% $Keywords: $

%INPUT
color = [{'r'},{'b'}];
markers1 = {'.','none'};
markers2 = {'s','+'};
linewidth = [4,2.5];
fontsize = 12;
file  = {input.file,input.reffile};
addpath(genpath(input.dir));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% READ DATA                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:length(file)
    if strcmpi(file{ii}(end-3:end),'.ray')
        data(ii) = readRAY([file{ii}(1:end-4) '.RAY']);
        if isfield(data,'QSoffset')
            data(ii).QSoffset = data(ii).QSoffset/1000;
        end
    elseif strcmpi(file{ii}(end-3:end),'.glo')
        data(ii) = readGLO([file{ii}(1:end-4) '.GLO']);
    end
    for tt=1:length(data(ii).equi)
        D(ii).equi(tt)        = data(ii).equi(tt); 
        D(ii).c1(tt)          = data(ii).c1(tt); 
        D(ii).c2(tt)          = data(ii).c2(tt); 
        D(ii).Cangle(tt)      = data(ii).hoek(tt); 
        D(ii).QSoffset(tt)    = data(ii).QSoffset(tt); 
        
        D(ii).phi_e(tt)       = D(ii).Cangle(tt)-D(ii).equi(tt); 
        D(ii).Cequi(tt)       = data(ii).Cequi(tt); 
        if strcmpi(file{ii}(end-3:end),'.glo') 
            D(ii).rota{tt}        = data(ii).rota(:,tt); 
            D(ii).QScalc{tt}      = data(ii).QScalc(:,tt); 
            D(ii).QSapprox{tt}    = data(ii).QSapprox(:,tt); 
        end
        D(ii).phi{tt}         = [D(ii).phi_e(tt)-70:0.1:D(ii).phi_e(tt)+70]; 
        D(ii).phi_r{tt}       = D(ii).phi{tt}-D(ii).phi_e(tt); 
        
        %Process data 
        D(ii).Qs{tt}          = -D(ii).c1(tt).*D(ii).phi_r{tt}.*exp(-((D(ii).c2(tt).*D(ii).phi_r{tt}).^2)) +D(ii).QSoffset(tt)/1000; 
        
        %Transport at current angle 
        D(ii).Qc{tt}          = -D(ii).c1(tt).*(D(ii).Cangle(tt)-D(ii).phi_e(tt)).*exp(-(D(ii).c2(tt).*(D(ii).Cangle(tt)-D(ii).phi_e(tt))).^2) +D(ii).QSoffset(tt)/1000; 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT DATA                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for tt=1:length(data(ii).equi)
    if isfield(input,'visible')
        if input.visible==0
            f = figure('visible','off');
        else
            f = figure(1);
        end
    else
        f = figure(1);
    end
    
    HOR=1000;
    VER=300;
    SCALE=30;
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperType','a4letter');
    set(gcf,'PaperPositionMode','manual', ...
            'PaperOrientation','portrait', ...
            'PaperUnits','centimeters');
    set(gcf,'PaperPosition',[0 0 HOR/SCALE VER/SCALE], ...
            'PaperSize',[HOR/SCALE VER/SCALE], ...
            'Position',[65,5,HOR,VER], ...
            'PaperUnits','centimeters'); 
    set(gcf,'Color',[1 1 1]);
    
%     set(gcf,'Position',[60 300 1000 300]);set(gcf,'Color',[1 1 1]);hold off;
%     set(gcf,'PaperSize',[9.8925    3.4973],'PaperPosition',[0 0 9.8925    3.4973],'PaperUnits','centimeters','PaperType','A4','PaperPositionMode','manual');
    for ii = 1:length(file)
        hline(ii)   = plot(D(ii).phi{tt},D(ii).Qs{tt}*1000,'LineStyle','-','Color',color{ii},'LineWidth',linewidth(ii),'Marker',markers1{ii},'MarkerSize', 6);hold on;
        if strcmpi(file{ii}(end-3:end),'.glo')
            plot(D(ii).Cangle(tt)-D(ii).rota{tt},D(ii).QScalc{tt}*1000,'LineStyle','none','Color',color{ii},'LineWidth',linewidth(ii),'Marker',markers2{ii},'MarkerSize', 6);hold on;
        end
        xl = xlim; yl = ylim;
    end
    ii=1;plot([D(ii).Cangle(tt) D(ii).Cangle(tt)],[yl(1) yl(2)],'Color','k','LineStyle',':','Marker','None','LineWidth',1);
    for ii = 1:length(file)
        %% Plot equilibrium line
        plot([D(ii).Cequi(tt) D(ii).Cequi(tt)],[yl(1) yl(2)],'Color',color{ii},'LineStyle','--','Marker','None','LineWidth',1);
    end
    if yl(1)<=0 && yl(2)>=0
        plot([xl(1) xl(2)],[0 0],'k','LineWidth',1);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FORMAT PLOT                                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(gca,'FontSize',fontsize);
    xlabel('Coast angle (phi [°])');
    ylabel('Total transport (Qs [10^3 m^3/yr])');
    annotation('textbox',[0.15 0.86 0.30 0.05],'String',strcat('File=',file{1}),'interpreter','none','FontSize',fontsize-1,'Edgecolor','none','FontAngle','italic'); %,'Backgroundcolor',[1 1 0.9]'Backgroundcolor',[1 1 0.5]
    annotation('textbox',[0.15 0.82 0.30 0.05],'String',strcat('Coastangle [°N]  = ',num2str(round(D(1).Cangle(tt)*10)/10)),'FontSize',fontsize-1,'Edgecolor','none');
    annotation('textbox',[0.15 0.78 0.30 0.05],'String',strcat('Eq. angle [°N] = ',num2str(round(mod(D(1).Cequi(tt),360)*10)/10),' (ref: ',num2str(round(mod(D(2).Cequi(tt),360)*10)/10),')'),'FontSize',fontsize-1,'Edgecolor','none');
    annotation('textbox',[0.15 0.74 0.30 0.05],'String',strcat('Qcoast [10^3 m^3/y] = ',num2str(round(D(1).Qc{tt}*1000*10)/10),' (ref: ',num2str(round(D(2).Qc{tt}*1000*10)/10),')'),'FontSize',fontsize-1,'Edgecolor','none');
    if strcmpi(file{ii}(end-3:end),'.glo')
      legtext = {[file{1} '_approximated'],[file{1} '_calculated'],['Reference_approximated'],['Reference_calculated'],'current coastline'};
    else
      legtext = {[file{1} ''],[file{1} '_reference'],'current coastline'};
    end
    legend(legtext,'interpreter','none','location','SouthEast');
    set(gca,'Xticklabel',num2str(mod(get(gca,'Xtick'),360))');
    set(gca,'FontSize',fontsize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE DATA                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(data(ii).equi)==1
        %outputname for normal GLO/RAY
        pname = [input.test_id '_fig' num2str(input.fignum)];
    else
        %outputname for timeseries
        pname = [input.test_id '_fig' num2str(input.fignum),'_',num2str(tt,'%03.0f')];
    end
    saveplot(f, input.output_dir, pname);
    close all;
end