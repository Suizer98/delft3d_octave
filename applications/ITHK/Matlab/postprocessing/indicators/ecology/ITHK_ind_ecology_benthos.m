function ITHK_ind_ecology_benthos(sens)
% function ITHK_ind_ecology_benthos(sens)
%
% Computes the impact of measurements on the population of species at the coast.
%
% Typical measures are : Nourishments (Mega, Foreshore or Beach)
%                        Revetments
%                        Groynes
%
% The impact is computed with a logistic growth function (Shepard, J.J. & 
% L. Stojkov, 2007. The logistic population model with slowly varying 
% carrying capacity. ANZIAM J. 47 (EMAC2005), pp. C492-C506).
% 
% The logistic growth function uses a time variable carrying capacity (CC) 
% for the recovery of benthic communities that denotes the 'habitat quality'
% that needs to recover.
% 
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .userinput.duration
%              .settings.indicators.eco.offset
%              .PP(sens).GEmapping (similar for .PP(sens).UBmapping)
%              .PP(sens).GEmapping.supp_beach 
%              .PP(sens).GEmapping.supp_foreshore
%              .PP(sens).GEmapping.supp_mega
%              .PP(sens).GEmapping.rev
%              .PP(sens).GEmapping.gro
%              .PP(sens).coast.x0_refgridRough
%              .PP(sens).coast.y0_refgridRough
%      ECO(kk) structure from settings file with ecological parameters for different species
%              .k_s
%              .p0
%              .r
%              .k_beach_nourishment
%              .k_foreshore_nourishment
%              .k_mega_nourishment
%              .k_revetment
%              .k_groyne
%              .k_others
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).GEmapping.eco(kk).name (similar for .PP(sens).UBmapping.eco)
%              .PP(sens).GEmapping.eco(kk).P0          Initial population
%              .PP(sens).GEmapping.eco(kk).Ks          Maximum equilibrium carrying capacity
%              .PP(sens).GEmapping.eco(kk).r           Growth factor of species
%              .PP(sens).GEmapping.eco(kk).xindex      Location
%              .PP(sens).GEmapping.eco(kk).time        Output timesteps
%              .PP(sens).GEmapping.eco(kk).P           Field with population in time 
%              .PP(sens).GEmapping.eco(kk).K0          Carrying capacity in time
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_ind_ecology_benthos.m 7463 2012-10-12 08:25:14Z boer_we $
% $Date: 2012-10-12 16:25:14 +0800 (Fri, 12 Oct 2012) $
% $Author: boer_we $
% $Revision: 7463 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/indicators/ecology/ITHK_ind_ecology_benthos.m $
% $Keywords: $

%% code
global S

if S.userinput.indicators.eco == 1

    fprintf('ITHK postprocessing : Indicator for direct impact on benthos population\n');

    %% READ INPUT VARIABLES from a settings file
    % Ecological parameters are read from the file 'eco_input.txt':
    %   r  = growth rate
    %   P0 = starting population size
    %   Ks = limiting value for K(et) as t --> infinity
    %   k_meastype  = reduction of population (%) as a result of this measurement

    Ythr            = str2double(S.settings.indicators.ecology.benthos.Ythr);
    ecosettingsfile = [S.settings.basedir 'Matlab/postprocessing/indicators/eco/ITHK_ind_ecology_benthos_input.txt'];
    if ~exist(ecosettingsfile,'file')
    ecosettingsfile = which('ITHK_ind_ecology_benthos_input.txt');
    end
    ECO=ITHK_ind_ecology_benthos_read(ecosettingsfile);

    %% COMPUTE IMPACT ON POPULATION (for species 1:kk and coastal section 1:nrsections in time 1:nryears)
    pptype = {'UBmapping','GEmapping'};
    for pp = 2:length(pptype)                                                  % <---- CURRENTLY ONLY GEMAPPING!!!
        ppmapping  = S.PP(sens).(pptype{pp});
        nryears    = S.userinput.duration;                                     % get the time length (tend - t0)
        nrsections = size(ppmapping.supp_beach,2);                             % nr. of coastline sections (i.e. grid cells) along the Holland coast

        for kk = 1: length(ECO)                                                % nr. of species.
            Ks     = ECO(kk).k_s;                                              % default carrying capacity (CC) of the system
            P0     = ECO(kk).p0;                                               % in initial population (used as reference only)
            r      = ECO(kk).r;                                                % logistic growth rate benthic community (polychaetes: r = 4, bivalves r = 2).
            e      = [2 , 1 , 0.5, 1, 1, 1];epsval=2;                          % epsilon determines recovery time of CC. Beach e = 2, shoreface e = 1, mega e = 0.5.
            s      = 1.;                                                       % sigma, where sigma = s = 1 
            dt     = 1;
            time   = [0:dt:nryears];                                           % timeframe of simulation
            K0     = zeros(nrsections,nryears+1);
            P      = zeros(nrsections,length(time));

            for ii = 1: nrsections                                             % nr. of coastline sections (i.e. grid cells) along the Holland coast
                K0(ii,1) = Ks;                                                 % set initial carrying capacity (CC0)
                P(ii,1)  = P0;                                                 % set initial population (P0)
    %             tsub     = 0;
    %             ttsub    = 1;

                for tt = 1:length(time)-1                                                 
                    % check if there is a nourishment (or construction)
                    % which reduces the population and carrying capacity
                    FLDname_measures = {'k_beach_nourishment','k_foreshore_nourishment','k_mega_nourishment','k_revetment','k_groyne','k_others'};
                    FLDsupps = {'supp_beach','supp_foreshore','supp_mega','rev','gro'};  % Type of nourishemnt that is used! (isoort = 1=beach, 2=foreshore, 3=mega)
                    for jj=1:length(FLDsupps)
                        supp2 = ppmapping.(FLDsupps{jj});
                        if  supp2(tt,ii)==1                                    % t==S.userinput.nourishment.start+1 && i>=idsth && i<=idnrth
                            P0red = ECO(kk).(FLDname_measures{jj});            % reduction in pop. size after nourishment is 1%
                            K0red = ECO(kk).(FLDname_measures{jj});            % reduction in CC after nourishment (e.g. mega: back to 5%, beach/shoreface back to 50%)
                            P(ii,tt) = P(ii,tt)*(100-P0red)/100;
                            K0(ii,tt) = K0(ii,tt)*(100-K0red)/100;
    %                         tsub          = time(tt);
    %                         ttsub         = tt;
                            epsval = min(epsval,e(jj));
                            epsval = min(epsval,r/2);                          % make sure that epsilon never is larger than 50% of growth rate
                        end
                    end

                    % Equation 17 in Shepard & Stojkov, 2007: 
                    %Kold = Ks/(1+((Ks/K0(ii,ttsub))^s-1)*exp(-s*epsval*(time(tt+1)-tsub))).^(1/s);% compute carrying capacity in next timestep
                    K = Ks/(1+((Ks/K0(ii,tt))^s-1)*exp(-s*epsval*dt)).^(1/s);
                    % Equation 18 of Shepard & Stojkov, 2007:
                    %    a = alpha in Eq. 18
                    %    b = beta in Eq. 18
                    % exact solution (discrete version)
                    a          = r/(r-epsval)*((Ks/K0(ii,tt))^s-1);
                    b          = (Ks/P(ii,tt))^s-1;                                      % different from Eq. 18 which is probably wrong. Ks instead of K0 !!
                    P(ii,tt+1) = Ks/(1+a*exp(-epsval*s*dt)+(b-a)*exp(-r*s*dt))^(1/s);    % time variable pop. size

                    %   % approximation 1
                    %   P(ii,tt+1) = (K*P(ii,tt)*exp(r*(time(tt+1)-tsub))) ...
                    %    ./ (K+P(ii,tt)*(exp(r*(time(tt+1)-tsub))-1));             % compute population in next time step
                    %   % approximation 2
                    %   P(ii,tt+1) = P(ii,tt)+r*P(ii,tt)*(1-P(ii,tt)/mean([K,K0(ii,tt)]))*dt;

                    % time variable pop. size
                    K0(ii,tt+1) = K;
                end
            end
            % determine classes
            Pclass                                         = ones(size(P));
            Pclass(P>=(Ks*(1-Ythr))   & P<(Ks*.999))       = 2;
            Pclass(P>=(Ks*(1-2*Ythr)) & P<(Ks*(1-Ythr)))   = 3;
            Pclass(P<(Ks*(1-2*Ythr)))                      = 4;

            ppmapping.ecology.benthos(kk).name   = ECO(kk).name; 
            ppmapping.ecology.benthos(kk).P0     = ECO(kk).p0;
            ppmapping.ecology.benthos(kk).Ks     = ECO(kk).k_s;
            ppmapping.ecology.benthos(kk).r      = ECO(kk).r;
            ppmapping.ecology.benthos(kk).xindex = [1:1:nrsections];
            ppmapping.ecology.benthos(kk).time   = time;
            ppmapping.ecology.benthos(kk).P      = P;
            ppmapping.ecology.benthos(kk).K0     = K0;
            ppmapping.ecology.benthos(kk).Pclass = Pclass;
        end
        S.PP(sens).(pptype{pp}) = ppmapping;
    end

    for kk = 1: length(ECO)
        %% Settings for writing to KMLtext
        PLOTscale1   = str2double(S.settings.indicators.ecology.benthos.PLOTscale1) / ECO(kk).k_s;     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
        PLOTscale2   = str2double(S.settings.indicators.ecology.benthos.PLOTscale2) / ECO(kk).k_s;     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
        PLOToffset   = str2double(S.settings.indicators.ecology.benthos.PLOToffset) + str2double(S.settings.indicators.ecology.benthos.PLOToffsetDX)*kk;     % PLOT setting : plot bar at this distance offshore [m](default initial value can be replaced by setting in ITHK_settings.xml)
        PLOTicons    = S.settings.indicators.ecology.benthos.icons;
        outlineVAL   = ppmapping.ecology.benthos(kk).Ks;
        if isfield(S,'weburl')
            for mm=1:length(PLOTicons)
                PLOTicons(mm).url = [S.weburl '/img/hk/' strtrim(PLOTicons(mm).url)];
            end
        end        
        colour       = {[0.2 0.6 0.2],[0.9 0.2 0.2]};
        fillalpha    = 0.7;
        popuptxt     = {['Benthos ',num2str(kk)],['Direct impact of nourishments on benthos population for species nr. ',num2str(kk)]};

        %% Write to kml BAR PLOTS / ICONS
        [KMLdata1]   = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                      (S.PP(sens).GEmapping.ecology.benthos(kk).P-PLOTscale2), ...
                                      PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,outlineVAL);
        [KMLdata2]   = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                     S.PP(sens).GEmapping.ecology.benthos(kk).Pclass,PLOTicons,PLOToffset,sens,popuptxt);
        S.PP(sens).output.kml_ecology_benthos{kk}  = KMLdata1;
        S.PP(sens).output.kml_ecology_benthos2{kk} = KMLdata2;
        S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,['S.PP(sens).output.kml_ecology_benthos2{' num2str(kk) '}']];
    end
end

%% PLOT THE POPULATION IN TIME
% figure;
% plot(1:21,P(1:21,11),'-or');hold on;
% plot(1:21,K0(1:21,11),'-+g');grid on;

