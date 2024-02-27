function ITHK_ind_costs_direct(sens)
% function ITHK_ind_costs_direct(sens)
%
% Computes the direct costs due to dredging, transportation and nourishing.
%
% The impact is computed with a formulation which computes a relative decrease
% in foreshore area. For this purpose a standard width of the foreshore is assumed.
% The formulation reads like this:
%
%      Direct costs  = Dreding + Transport + Nourish + Overhead
% 
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).NNmapping.costs
%              .PP(sens).GEmapping.costs
%              .PP(sens).GEmapping.costscum
%              .PP(sens).UBmapping.costs
%              .PP(sens).TTmapping.costs
%              .PP(sens).TTmapping.costscum
%              .PP(sens).output.kml_costs_direct1
%              .PP(sens).output.kml_costs_direct2
%              .PP(sens).output.kml_costs_direct3

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

% $Id: ITHK_ind_costs_direct.m 10973 2014-07-21 08:28:29Z boer_we $
% $Date: 2014-07-21 16:28:29 +0800 (Mon, 21 Jul 2014) $
% $Author: boer_we $
% $Revision: 10973 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/indicators/costs/ITHK_ind_costs_direct.m $
% $Keywords: $

%% code
global S

if S.userinput.indicators.costs == 1

    fprintf('ITHK postprocessing : Indicator for the direct costs due to dredging, transportation and nourishing\n');

    %% LOAD SETTINGS
    costs                                    = xml2struct(which('ITHK_ind_costs_direct.xml'),'structuretype','supershort');%xml_load(which('ITHK_ind_costs_direct.xml'));
    costs.classdefinition.small              = str2num(costs.classdefinition.small);
    costs.classdefinition.medium             = str2num(costs.classdefinition.medium);
    costs.classdefinition.large              = str2num(costs.classdefinition.large);
    costs.costprices.take_up                 = str2num(costs.costprices.take_up);
    costs.costprices.transport               = str2num(costs.costprices.transport);
    costs.costprices.nourish_foreshore       = str2num(costs.costprices.nourish_foreshore);
    costs.costprices.nourish_rainbow         = str2num(costs.costprices.nourish_rainbow);
    costs.costprices.nourish_beach           = str2num(costs.costprices.nourish_beach);
    costs.costprices.pipes                   = str2num(costs.costprices.pipes);
    costs.costprices.revetment               = str2num(costs.costprices.revetment);
    costs.costprices.groyne                  = str2num(costs.costprices.groyne);
    costs.distribution.beachtype.release     = str2num(costs.distribution.beachtype.release);
    costs.distribution.beachtype.rainbow     = str2num(costs.distribution.beachtype.rainbow);
    costs.distribution.beachtype.beach       = str2num(costs.distribution.beachtype.beach);
    costs.distribution.foreshoretype.release = str2num(costs.distribution.foreshoretype.release);
    costs.distribution.foreshoretype.rainbow = str2num(costs.distribution.foreshoretype.rainbow);
    costs.distribution.foreshoretype.beach   = str2num(costs.distribution.foreshoretype.beach);
    costs.indirectratio.beachtype            = str2num(costs.indirectratio.beachtype);
    costs.indirectratio.foreshoretype        = str2num(costs.indirectratio.foreshoretype);

    %% COMPUTE
    dsRough            = str2double(S.settings.plotting.barplot.dsrough);
    Ythr               = str2double(S.settings.indicators.costs.direct.Ythr);  % Ythr = threshold for costs icons (in euro/m along the coast)
    distance           = str2double(S.settings.indicators.costs.direct.transportdistance);
    idTYPE             = str2double(S.settings.indicators.costs.direct.locationtype);   % 1= foreshore; 2= predominantly beach
    idTYPE2            = mod(idTYPE,2)+1;
    costsUB.total      = zeros([size(S.PP(sens).coast.zcoast),2]);                      % initialise empty UBmapping of costs
    costsGE.total      = zeros([size(S.PP(sens).coast.zgridRough),2]);                  % initialise empty GEmapping of costs
    costsGE.structures = zeros([size(S.PP(sens).coast.zgridRough),2]);                  % initialise empty GEmapping of costs
    costsGE.nourish    = zeros([size(S.PP(sens).coast.zgridRough),2]);                  % initialise empty GEmapping of costs
    costsGE.transport  = zeros([size(S.PP(sens).coast.zgridRough),2]);                  % initialise empty GEmapping of costs
    costsGE.indirect   = zeros([size(S.PP(sens).coast.zgridRough),2]);                  % initialise empty GEmapping of costs
    %xcoast            = S.PP(sens).coast.xcoast;                                   % change of coastline since t0 (UBmapping)
    %ycoast            = S.PP(sens).coast.ycoast;                                   % change of coastline since t0 (UBmapping)
    zminz0             = S.PP(sens).coast.zcoast;                                   % change of coastline since t0 (UBmapping)
    zminz0Rough        = S.PP(sens).coast.zgridRough;                               % change of coastline since t0 (GEmapping)

    KMLdata0      = [];

    %% EVALUATE STRUCTURES
    fldname  = {'revetment','groyne'};
    for jj=1:length(fldname)
        if isfield(S.userinput,fldname{jj});
            for ii=1:length(S.userinput.(fldname{jj}))
                R.lon                          = S.userinput.(fldname{jj})(ii).length;
                R.lat                          = S.userinput.(fldname{jj})(ii).length;
                R.length                       = S.userinput.(fldname{jj})(ii).length;
                R.id                           = S.userinput.(fldname{jj})(ii).idRANGE(:);
                R.id2                          = S.userinput.(fldname{jj})(ii).idRANGE2(:);
                costs.(fldname{jj}).props(ii)  = R;
                costs.(fldname{jj}).costs(ii)  = costs.costprices.(fldname{jj}) * R.length;

                %% Put costs on grid
                idt                            = 1;
                for idTP=1:2
                costsUB.total(R.id,idt,idTP)        = costsUB.total(R.id,idt,idTP) + costs.(fldname{jj}).costs(ii)/length(R.id)/length(idt);
                costsGE.total(R.id2,idt,idTP)       = costsGE.total(R.id2,idt,idTP) + costs.(fldname{jj}).costs(ii)/length(R.id2)/length(idt);
                costsGE.structures(R.id2,idt,idTP)  = costsGE.structures(R.id2,idt,idTP) + costs.(fldname{jj}).costs(ii)/length(R.id2)/length(idt);
                end

                if jj==1
                    addtxt  = sprintf('Revetment with length %1.0fm. ',R.length);
                else
                    addtxt  = sprintf('Groyne with length %1.0fm. ',R.length);
                end
                KMLdata0 = [KMLdata0,ITHK_KMLcostsicons(S,fldname{jj},costs.(fldname{jj}).costs(ii),ii,R.lon,R.lat,addtxt)];
            end
        else
            costs.(fldname{jj}).costs  = 0;
        end 
    end

    %% EVALUATE NOURISHMENTS
    if isfield(S.userinput,'nourishment');
        for ii=1:length(S.userinput.nourishment)
            N=struct;
            N.tstart     =   S.userinput.nourishment(ii).start;
            N.tstop      =   S.userinput.nourishment(ii).stop;
            N.lat        =   S.userinput.nourishment(ii).lat;
            N.lon        =   S.userinput.nourishment(ii).lon;
            N.VOL        =   S.userinput.nourishment(ii).volume;
            N.WIDTH      =   S.userinput.nourishment(ii).width;
            N.volperm    =   N.VOL/N.WIDTH;
            if length(S.userinput.nourishment(ii).idRANGE(:))>size(S.PP(sens).coast.zcoast,1);
                N.id         =   S.userinput.nourishment(ii).idRANGE(1:end-1);
            else
                N.id         =   S.userinput.nourishment(ii).idRANGE(:);
            end
            N.id2        =   S.userinput.nourishment(ii).idRANGE2(:);
            N.distance   =   distance;
            costs.nourishment.props(ii) = N;
            %% Distinguish the nourishment type (nTYPE), the ratio for indirect costs, the distribution over the types of nourishment methods (beach, rainbow, release)
            if N.volperm < costs.classdefinition.small(2)
                nTYPE=1;
            elseif N.volperm < costs.classdefinition.medium(2)
                nTYPE=2;
            else
                nTYPE=3;
            end
            indirectratio(1) = costs.indirectratio.beachtype(nTYPE);
            indirectratio(2) = costs.indirectratio.foreshoretype(nTYPE);
            PRCTbeach    = [costs.distribution.beachtype.beach(nTYPE) costs.distribution.foreshoretype.beach(nTYPE)];
            PRCTrainbow  = [costs.distribution.beachtype.rainbow(nTYPE) costs.distribution.foreshoretype.rainbow(nTYPE)];
            PRCTrelease  = [costs.distribution.beachtype.release(nTYPE) costs.distribution.foreshoretype.release(nTYPE)];

            %% Compute costs per m3
            costs_nbeach           = (costs.costprices.take_up(nTYPE)+costs.costprices.nourish_beach(nTYPE)+costs.costprices.pipes(nTYPE)).*PRCTbeach/100;
            costs_nrainbow         = (costs.costprices.take_up(nTYPE)+costs.costprices.nourish_rainbow(nTYPE)).*PRCTrainbow/100;
            costs_nforeshore       = (costs.costprices.take_up(nTYPE)+costs.costprices.nourish_foreshore(nTYPE)).*PRCTrelease/100;

            costs_nourish(ii,:)    = costs_nbeach + costs_nrainbow + costs_nforeshore;
            costs_transport(ii)    = N.distance * costs.costprices.transport(nTYPE);
            costs_direct(ii,:)     = costs_nourish(ii,:) + costs_transport(ii);  % + costs.structures;
            costs_indirect(ii,:)   = costs_direct(ii,:).*(indirectratio/100.);
            costs_total(ii,:)      = costs_direct(ii,:) + costs_indirect(ii,:);

            %% Compute costs of whole nourishment
            costs.nourishment.time(ii)         = (N.tstart + N.tstop)/2;
            costs.nourishment.duration         = (N.tstop-N.tstart);
            costs.nourishment.costs(ii,:)      = sort(costs_total(ii,:)) * N.VOL * (N.tstop-N.tstart);

            %% Put costs on grid
            idt                           = [N.tstart:N.tstop-1];
            for idTP=1:2
            costsUB.total(N.id,idt,idTP)       = costsUB.total(N.id,idt,idTP)      + costs_total(ii,idTP) * N.VOL * (N.tstop-N.tstart)/length(N.id)/length(idt);
            costsGE.total(N.id2,idt,idTP)      = costsGE.total(N.id2,idt,idTP)     + costs_total(ii,idTP) * N.VOL * (N.tstop-N.tstart)/length(N.id2)/length(idt);
            costsGE.nourish(N.id2,idt,idTP)    = costsGE.nourish(N.id2,idt,idTP)   + costs_nourish(ii,idTP) * N.VOL * (N.tstop-N.tstart)/length(N.id2)/length(idt);
            costsGE.transport(N.id2,idt,idTP)  = costsGE.transport(N.id2,idt,idTP) + costs_transport(ii) * N.VOL * (N.tstop-N.tstart)/length(N.id2)/length(idt);
            costsGE.indirect(N.id2,idt,idTP)   = costsGE.indirect(N.id2,idt,idTP)  + costs_indirect(ii,idTP) * N.VOL * (N.tstop-N.tstart)/length(N.id2)/length(idt);
            end

            %% Make KML with direct costs for each of the noursihment locations
            %% add pop-up window
            if N.tstart==N.tstop
                addtxt  = sprintf(['This nourishment is characterised by a volume of %2.2f million m^3 over a width of %1.0f m which is placed in the year %1.0f. ',...
                                   'The costprices are about %2.2f to %2.2f euro/m^3 for the dredging and nourishing, about %2.2f euro/m^3/km for the transport and %2.2f to %2.2f euro/m^3 for indirect costs.'], ...
                                   N.VOL/10^6,N.WIDTH,N.tstart+S.PP(sens).settings.t0,min(costs_nourish(ii,:)),max(costs_nourish(ii,:)),costs_transport(ii),min(costs_indirect(ii,:)),max(costs_indirect(ii,:)));
            else
                addtxt  = sprintf(['This nourishment is characterised by a volume of %2.2f million m^3/yr over a width of %1.0f m which is placed between the year %1.0f and %1.0f. ',...
                                   'The costprices are about %2.2f to %2.2f euro/m^3 for the dredging and nourishing, about %2.2f euro/m^3/km for the transport and %2.2f to %2.2f euro/m^3 for indirect costs.'], ...
                                   N.VOL/10^6,N.WIDTH,N.tstart+S.PP(sens).settings.t0,N.tstop+S.PP(sens).settings.t0,min(costs_nourish(ii,:)),max(costs_nourish(ii,:)),costs_transport(ii),min(costs_indirect(ii,:)),max(costs_indirect(ii,:)));
            end
            KMLdata0 = [KMLdata0,ITHK_KMLcostsicons(S,'nourishment',costs.nourishment.costs(ii,:),ii,N.lon,N.lat,addtxt)];
        end
    else
        costs.nourishment.costs  = 0;
    end

    %% Classification of costs along the coast
    coststot                  = cumsum(costsGE.total(:,:,idTYPE),2)/dsRough;
    coststot_classes          = ones(size(coststot));
    coststot_classes(coststot>0 & coststot<=Ythr)         = 2;
    coststot_classes(coststot>Ythr & coststot<=2*Ythr)    = 3;
    coststot_classes(coststot>2*Ythr)                     = 4;

    %% Set output of costs indicator in fields of S-structure
    S.PP(sens).UBmapping.costs.direct.costs_total         = cumsum(costsUB.total(:,:,idTYPE),2);
    S.PP(sens).GEmapping.costs.direct.data                = costs;
    S.PP(sens).GEmapping.costs.direct.costs_total         = cumsum(costsGE.total(:,:,idTYPE),2);
    S.PP(sens).GEmapping.costs.direct.costs_nourish       = cumsum(costsGE.nourish(:,:,idTYPE),2);
    S.PP(sens).GEmapping.costs.direct.costs_transport     = cumsum(costsGE.transport(:,:,idTYPE),2);
    S.PP(sens).GEmapping.costs.direct.costs_indirect      = cumsum(costsGE.indirect(:,:,idTYPE),2);
    S.PP(sens).GEmapping.costs.direct.costs_structures    = cumsum(costsGE.structures(:,:,idTYPE),2);
    S.PP(sens).TTmapping.costs.direct.costs_total         = sum(cumsum(costsGE.total(:,:,idTYPE),2),1);
    %S.PP(sens).TTmapping.costs.direct.costs_total2       = sum(cumsum(costsGE.total(:,:,idTYPE2),2),1); costs for location in cross-shore profile that was not selected
    S.PP(sens).TTmapping.costs.direct.costs_nourish       = sum(cumsum(costsGE.nourish(:,:,idTYPE),2),1);
    S.PP(sens).TTmapping.costs.direct.costs_transport     = sum(cumsum(costsGE.transport(:,:,idTYPE),2),1);
    S.PP(sens).TTmapping.costs.direct.costs_indirect      = sum(cumsum(costsGE.indirect(:,:,idTYPE),2),1);
    S.PP(sens).TTmapping.costs.direct.costs_structures    = sum(cumsum(costsGE.structures(:,:,idTYPE),2),1);
    S.PP(sens).GEmapping.costs.direct.costs_total_classes = coststot_classes;

    %% Settings for writing to KMLtext
    PLOTscale1   = str2double(S.settings.indicators.costs.direct.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTscale2   = str2double(S.settings.indicators.costs.direct.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
    PLOToffset   = str2double(S.settings.indicators.costs.direct.PLOToffset);     % PLOT setting : plot bar at this distance offshore [m](default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTicons    = S.settings.indicators.costs.direct.icons;
    if isfield(S,'weburl')
        for kk=1:length(PLOTicons)
            PLOTicons(kk).url = [S.weburl '/img/hk/' strtrim(PLOTicons(kk).url)];
        end
    end
    colour       = {[0.7 0.0 0.7],[0.3 1 0.3]};
    fillalpha    = 0.7;
    popuptxt     = {'Direct costs','Direct costs of nourishments on the coast'};
    %% Write to kml
    KMLdata1      = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                  (S.PP(sens).GEmapping.costs.direct.costs_total-PLOTscale2), ...
                                  PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
    KMLdata2      = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                 S.PP(sens).GEmapping.costs.direct.costs_total_classes,PLOTicons,PLOToffset,sens,popuptxt);
    KMLdata3      = ITHK_KMLcostsbar(sens,-S.PP(sens).TTmapping.costs.direct.costs_total);

    S.PP(sens).output.kml_costs_direct0 = KMLdata0;
    S.PP(sens).output.kml_costs_direct1 = KMLdata1;
    S.PP(sens).output.kml_costs_direct2 = KMLdata2;
    S.PP(sens).output.kml_costs_direct3 = KMLdata3;

    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_costs_direct2','S.PP(sens).output.kml_costs_direct3'];
    % addtxt = '_costs1';
    % ITHK_io_writeKML(KMLdata1,addtxt,sens);
    % 
    % addtxt = '_costs2';
    % ITHK_io_writeKML(KMLdata2,addtxt,sens);
    % 
    % addtxt = '_costs3';
    % ITHK_io_writeKML(KMLdata3,addtxt,sens);
end
end


%% SUB-FUNCTION ITHK_KMLcostsicons
function KMLdata=ITHK_KMLcostsicons(S,measuretype,directcosts,ii,lon,lat,addtxt)
    iconlink      = [S.settings.basedir,'Matlab\postprocessing\indicators\costs\icons\euro-icon32x32.ico'];
    if length(directcosts)==1
        popuptxt  = {[measuretype,' ',num2str(ii)], ...
                    {[measuretype,' ',num2str(ii)], ...
                     [addtxt,'The estimated direct costs for this ',measuretype,' are ',num2str(directcosts/1e6,'%1.1f'),' million euro.']}};
    elseif length(directcosts)==2
        popuptxt  = {[measuretype,' ',num2str(ii)], ...
                    {[measuretype,' ',num2str(ii)], ...
                     [addtxt,'The estimated direct costs for this ',measuretype,' are between ',num2str(directcosts(1)/1e6,'%1.1f'), ...
                     ' and ',num2str(directcosts(2)/1e6,'%1.1f'),' million euro.']}};
    else
        return;
    end
    lookAt=0;
    KMLdata       = ITHK_KMLtextballoon(lon,lat,'name',popuptxt{1},'text_array',popuptxt{2},'logo','','icon',iconlink,'lookAt',lookAt);
    %popuptxt{2}   = {['nourishment ',num2str(ii)], ...
    %                 ['This nourishment is constructed in',num2str(N.tstart+S.PP(sens).settings.t0,'%1.0f'),'.', ...
    %                  'The volume of the nourishment is ',num2str(N.VOL/1e6,'%1.0f'),'Mm3 and the width is ',num2str(N.WIDTH,'%1.1f'),'km.', ...
    %                  'The estimated direct costs for this nourishment are between ',num2str(costs.totalVOL(ii,1)/1e6,'%1.1f'),' and ',num2str(costs.totalVOL(ii,2)/1e6,'%1.1f'),' million euro.']};
end
