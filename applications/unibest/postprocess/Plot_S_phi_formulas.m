function Plot_S_phi_formulas(input)
%plotS_Phi_formulas.m : Plots S-phi output
%
%   Syntax:
%     function Plot_S_phi(input)
% 
%   Input:
%     input     structure with information on the S-Phi curves and plotting formats
%                    .dir         directory with files
%                    .file        RAY-file or GLO-file
%                    .reffile     reference RAY-file or GLO-file
%  
%   Output:
%     graph with S-Phi curves
%
%   Example:
%     input.dir=pwd;
%     input.file='file1.RAY';
%     input.reffile='file2.RAY';
%     Plot_S_phi_formulas(input);
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

% $Id: Plot_S_phi_formulas.m 3493 2013-02-06 13:44:44Z huism_b $
% $Date: 2013-02-06 14:44:44 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3493 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/Plot_S_phi_formulas.m $
% $Keywords: $

%Input
addpath(genpath(input.dir));
for jj = 1:length(input.file)
    file{jj} = input.file;
    reffile{jj} = input.reffile;
end
legtext = {};
color = [{'r'},{'b'}, {'g'},{'k'}];

f = figure();set(gcf,'Position',[207 208 868 611]);set(gcf,'Color',[1 1 1]);
set(gcf,'PaperSize',[29.6774 20.984],'PaperPosition',[0 0 29.6774 20.984],'PaperUnits','centimeters','PaperType','A4','PaperPositionMode','manual');

for ii = 1:length(file)
    %Read data
    GLOdata(ii) = readGLO([file{ii}(1:end-4) '.GLO']);
%     temp(ii).rota = GLOdata(ii).rota
%     temp(ii).QScalc = GLOdata(ii).QScalc
    RAYdata(ii) = readRAY(file{ii});
    temp(ii).equi = RAYdata(ii).equi;
    temp(ii).angle = RAYdata(ii).hoek;
    temp(ii).c1 = RAYdata(ii).c1;
    temp(ii).c2 = RAYdata(ii).c2;

    %Process data
    temp(ii).phi_e = temp(ii).angle-temp(ii).equi;
    temp(ii).phi = [temp(ii).phi_e-70:temp(ii).phi_e+70];
    temp(ii).phi_r = temp(ii).phi-temp(ii).phi_e;
    temp(ii).Qs = -temp(ii).c1.*temp(ii).phi_r.*exp(-((temp(ii).c2.*temp(ii).phi_r).^2));

    %Transport at current angle
    temp(ii).Qc = -temp(ii).c1.*(temp(ii).angle-temp(ii).phi_e).*exp(-(temp(ii).c2.*(temp(ii).angle-temp(ii).phi_e)).^2);

    %Plot data
    hline(ii)=plot(temp(ii).phi,temp(ii).Qs,'Color',color{ii},'LineStyle','-','Marker','.');hold on;
    plot(GLOdata(ii).COASTangle-GLOdata(ii).rota,GLOdata(ii).QScalc,'x','Color',color{ii});hold on;
    xl = xlim; yl = ylim;
    %legtext{ii} = file{ii}; 
end
for ii = 1:length(file)
    plot([temp(ii).phi_e temp(ii).phi_e],[yl(1) yl(2)],'Color',color{ii},'LineStyle','--');
end
for ii = 1:length(reffile)
    %Read data
    GLOdata(ii) = readGLO([reffile{ii}(1:end-4) '.GLO']);
%     temp(ii).rota = GLOdata(ii).rota
%     temp(ii).QScalc = GLOdata(ii).QScalc
    RAYdata(ii) = readRAY(reffile{ii});
    temp(ii).equi = RAYdata(ii).equi;
    temp(ii).angle = RAYdata(ii).hoek;
    temp(ii).c1 = RAYdata(ii).c1;
    temp(ii).c2 = RAYdata(ii).c2;

    %Process data
    temp(ii).phi_e = temp(ii).angle-temp(ii).equi;
    temp(ii).phi = [temp(ii).phi_e-70:temp(ii).phi_e+70];
    temp(ii).phi_r = temp(ii).phi-temp(ii).phi_e;
    temp(ii).Qs = -temp(ii).c1.*temp(ii).phi_r.*exp(-((temp(ii).c2.*temp(ii).phi_r).^2));

    %Transport at current angle
    temp(ii).Qc = -temp(ii).c1.*(temp(ii).angle-temp(ii).phi_e).*exp(-(temp(ii).c2.*(temp(ii).angle-temp(ii).phi_e)).^2);

    %Plot data
    hline(ii)=plot(temp(ii).phi,temp(ii).Qs,'Color',color{ii},'LineStyle','-','Marker','None');hold on;
    plot(GLOdata(ii).COASTangle-GLOdata(ii).rota,GLOdata(ii).QScalc,'+','Color',color{ii});hold on;
    xl = xlim; yl = ylim;
    %legtext{ii} = reffile{ii}; 
end
plot([xl(1) xl(2)],[0 0],'k');
hold off;
set(gca,'FontSize',8);
xlabel('Coast angle (phi)');
ylabel('Total transport (Qs)');
% annotation('textbox',[0.35 0.86 0.20 0.04],'String',strcat('File=',file{1}),'interpreter','none','FontSize',8,'Edgecolor','none','Backgroundcolor',[1 1 0.5]);
% annotation('textbox',[0.35 0.82 0.20 0.04],'String',strcat('Equilibirium angle =',num2str(mod(temp(1).phi_e,360),'%10.2f')),'FontSize',8,'Edgecolor','none','Backgroundcolor',[1 1 0.5]);
% annotation('textbox',[0.35 0.78 0.20 0.04],'String',strcat('Q at current angle (Mm^3/y) =',num2str(temp(1).Qc,'%10.2f')),'FontSize',8,'Edgecolor','none','Backgroundcolor',[1 1 0.5]);
% annotation('textbox',[0.15 0.86 0.20 0.04],'String',strcat('File=',file{2}),'interpreter','none','FontSize',8,'Edgecolor','none','Backgroundcolor',[1 1 0.5]);
% annotation('textbox',[0.15 0.82 0.20 0.04],'String',strcat('Equilibirium angle =',num2str(mod(temp(2).phi_e,360),'%10.2f')),'FontSize',8,'Edgecolor','none','Backgroundcolor',[1 1 0.5]);
% annotation('textbox',[0.15 0.78 0.20 0.04],'String',strcat('Q at current angle (Mm^3/y) =',num2str(temp(2).Qc,'%10.2f')),'FontSize',8,'Edgecolor','none','Backgroundcolor',[1 1 0.5]);
% legtext = {[file{1} '_approximated'],[file{1} '_calculated'],[file{2} '_approximated'],[file{2} '_calculated']};
legend(legtext,'interpreter','none','location','SouthEast');
set(gca,'Xticklabel',num2str(mod(str2num(get(gca,'Xticklabel')),360)));
set(gca,'FontSize',8);
% HH = get(legend,'ColorOrder');
%Save figure
print(f,'-dpng','-r150',[input.dir,input.file,'.png']);
close(f);