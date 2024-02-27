function ITHK_ind_dunes_duneclasses(sens,varargin)

% -------------------------------------------------------------------
% Alma de Groot
% Ecoshape, WUR (Wageningen University and IMARES)
% funded by Ecoshape and Knowledge for Climate
% 12 June 2012
%
% This code is used in the Interactive Design Tool
% in de Building with Nature program
% It calculates potential for dune formation based on Unibest outcomes,
% in a post-processing mode.
%
% INPUT
%   UNIBEST output read from ...
%   time                Timeframe
%   stored              total volume of sediment stored in a cell due to accretion or erosion (Stored volume in each cell [10^6 m3]
%   xdist               alongshore distance
%   neticaJarkusLUT     a lookuptable that gives volume changes of parts of
%   the profile as function of total volume change, based on a Bayesian
%   network model of JARKUS data of the Holland Coast. Read from
%   neticaJarkusLUT.mat
%   
%
% OUTPUT 
%   cumdunes    cumulatieve dune volume compared to initial situation
%   duneclass   type of dunes that develop as a result of volume changes
%   richness    expected ecological richness of foredune area
%   dynamic     whether or not dunes are dynamic
%
%  Additional information can be found in the accompanying report
%  "Long-term dune development in the Interactive Design Tool"
%  by Alma de Groot 
%  available through the Building with Nature online wiki
%
% -------------------------------------------------------------------

global S

if S.userinput.indicators.dunes == 1

    fprintf('ITHK postprocessing : Indicator for dune class identification\n');

    %% EXTRACT AND INITIALISE MATRICES FOR COMPUTATIONS
    % this is a temporary datafile stored locally
    % => needs to be changed into correct local matrix
    if nargin>1
        reference=1;
        PRNdata = S.UB(sens).data_ref.PRNdata;
    else
        reference=0;
        PRNdata = S.UB(sens).results.PRNdata;
    end
    stored = PRNdata.stored;

    % -------------------------------------------------------------------
    %% STEP 1 DISTRIBUTE THE TOTAL VOLUME OVER THE BEACH, DUNES AND UNDERWATER

    % calculate values per year
    cellwidth = round(PRNdata.xdist(2) - PRNdata.xdist(1)) ;
    volumeyear = (stored - circshift(stored, [0 1])).*1e+006./cellwidth;  % transform into deltaV per year, in m3/m*year
    volumeyear (:,1) = stored(:,1).*1e+006./cellwidth;               % correct for the effect of circshift


    % calculate volume changes per profile section per year
    % obtain values from Netica lookuptable (LUT)
    [offshoreyear, beach2year, beach1year, dunesyear] = neticareadLUT(volumeyear);


    % calculate cumulative values with respect to initial situation
    cumdunes = dunesyear;
    cumbeach1 = beach1year;
    cumbeach2 = beach2year;
    cumunderwater = offshoreyear;
    for p = 2:size(cumdunes,2)
        cumdunes(:,p) = cumdunes(:,p) + cumdunes(:,p-1) ;
        cumbeach1(:,p) = cumbeach1(:,p) + cumbeach1(:,p-1) ;
        cumbeach2(:,p) = cumbeach2(:,p) + cumbeach2(:,p-1) ;
        cumunderwater(:,p) = cumunderwater(:,p) + cumunderwater(:,p-1) ;
    end


    % -------------------------------------------------------------------
    %% STEP 2 TRANSLATE CHANGES INTO DUNE CLASSES

    % underwater is not taken into account, can be done for other applications
    % if necessary

    % Classes:
    % - class 1 = erosive
    % - class 2 = normal and slight progradation
    % - class 3 = wide beach with potential for new dunes at the foot of the old
    %             dune
    % - class 4 = extremely wide beach with potential for new dunes
    % - class 5 = extremely wide beach with potential for new dunes including
    %             green beach 
    % classes are compared to the current situation

    % threshold values from one class to another (cumulatieve and yearly(?) volumes)
    % and other settings
    b1 = -30;                % from neutral to erosive (cumulative m3/m) 
    b2 = 100;                % upper boundary of stable situation 
    b3 = 400;                % upper boundary for slightly prograding situation 

    % assign classes
    duneclass = ones(size(cumdunes));
    duneclass (cumdunes < b1)                     = 1;    % erosive
    duneclass((cumdunes >= b1) & (cumdunes < b2)) = 2;    % stable
    duneclass((cumdunes >= b2) & (cumdunes < b3)) = 3;    % potential for new dunes adjacent to dune foot
    duneclass (cumdunes >= b3)                    = 4;    % mobile dunes

    % taking into account temporal effects of vegetation establishment
    thresholdyear = 10;                                        % how many years it takes before a wide beach becomes vegetated
    for q = thresholdyear+1 : size(duneclass,2)
        duneclass_q = duneclass(:,q);                         % select only this year
        duneclass_temp = duneclass(:, q-thresholdyear: q-1);  % select previous couple of years
        duneclass_temp_sum = sum(duneclass_temp , 2);         % add up the ordinal classes

        % everywhere where at least 5 years with duneclass 4 have been => class 5
        % but when eroding, a beach that has gone from 5 to 3, it cannot shift back to 5 again.
        thresholdcrossed = (duneclass_temp_sum >= thresholdyear.*4) & (duneclass_temp(:, end) > 3);
        duneclass_q(thresholdcrossed) = 5;
        duneclass(:,q) = duneclass_q;
    end


    if reference==0
        S.PP(sens).dunes.duneclass = duneclass;
    else
        S.PP(sens).dunes.duneclassref = duneclass;
    end

    for jj = 1:length(S.PP(sens).settings.tvec)
        S.PP(sens).GEmapping.dunes.duneclasses(:,jj) = interp1(S.PP(sens).settings.s0,duneclass(:,jj),S.PP(sens).settings.sgridRough,'nearest');
    end


    %% Settings for writing to KMLtext
    PLOTscale1   = str2double(S.settings.indicators.dunes.duneclasses.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTscale2   = str2double(S.settings.indicators.dunes.duneclasses.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
    PLOToffset   = str2double(S.settings.indicators.dunes.duneclasses.PLOToffset);     % PLOT setting : plot bar at this distance offshore [m] (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTicons    = S.settings.indicators.dunes.duneclasses.icons;
    if isfield(S,'weburl')
        for kk=1:length(PLOTicons)
            PLOTicons(kk).url = [S.weburl '/img/hk/' strtrim(PLOTicons(kk).url)];
        end
    end    
    colour       = {[1 1 0.0],[0.9 0.0 0.0]};
    fillalpha    = 0.7;
    popuptxt={'Dune class',{'This indicator provides information on the expected dune classes of the coast. These classes are:','',...
                            ' - class 1 = erosive',' - class 2 = normal and slight progradation',' - class 3 = wide beach with potential for new dunes ',...
                            '             at the foot of the olddune',' - class 4 = extremely wide beach with potential','             for new dunes',...
                            ' - class 5 = extremely wide beach with potential','             for new dunes including green beach'}};

    %% Write to kml BAR PLOTS / ICONS
    [KMLdata1]   = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                  (S.PP(sens).GEmapping.dunes.duneclasses-PLOTscale2), ...
                                  PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
    [KMLdata2]   = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                 S.PP(sens).GEmapping.dunes.duneclasses,PLOTicons,PLOToffset,sens,popuptxt);
    S.PP(sens).output.kml_dunes_duneclasses  = KMLdata1;
    S.PP(sens).output.kml_dunes_duneclasses2 = KMLdata2;
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_dunes_duneclasses2'];
end