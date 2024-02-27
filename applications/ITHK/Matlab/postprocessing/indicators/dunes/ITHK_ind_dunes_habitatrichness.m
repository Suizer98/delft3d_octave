function ITHK_ind_dunes_habitatrichness(sens)

% dunerules_19apr12.m

% -------------------------------------------------------------------
% Alma de Groot
% Ecoshape, WUR
% 19 apr 2012
% Modified by B.J.A. Huisman (Deltares, July 2012)

% Calculates potential for dune formation based on Unibest outcomes.
% Post-processing tool based on UNIBEST outcomes
% used in Interactive Design Tool
% -------------------------------------------------------------------

global S

if S.userinput.indicators.dunes == 1

    fprintf('ITHK postprocessing : Indicator for dune habitat richness\n');

    if nargin<1
    sens=1;
    end


    if ~isfield(S.PP(sens),'dunes')
        return
    end

    %% STEP 4: ECOLOGICAL VARIATION
    % roughly: number of habitat types expected
    % H2110 (embryonic dunes % annuals)
    % H2120 (white dunes)
    % H1310 (green beach)
    % H1330 (green beach)
    % H2190 (green beach)
    % grey dunes not taken into account

    duneclass = S.PP(sens).dunes.duneclass;
    richness = duneclass.*0;
    richness (duneclass == 1) = 1;     % 1 = low/normal (low is the standard for the current coast)
    richness (duneclass == 2) = 1; 
    richness (duneclass == 3) = 2;     % 2 = intermediate
    richness (duneclass == 4) = 2;  
    richness (duneclass == 5) = 3;     % 3 = rich
    S.PP(sens).dunes.richness = richness;

    for jj = 1:length(S.PP(sens).settings.tvec)
        S.PP(sens).GEmapping.dunes.habitatrichness(:,jj) = interp1(S.PP(sens).settings.s0,richness(:,jj),S.PP(sens).settings.sgridRough,'nearest');
    end


    %% Settings for writing to KMLtext
    PLOTscale1   = str2double(S.settings.indicators.dunes.habitatrichness.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTscale2   = str2double(S.settings.indicators.dunes.habitatrichness.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
    PLOToffset   = str2double(S.settings.indicators.dunes.habitatrichness.PLOToffset);         % PLOT setting : plot bar at this distance offshore [m] (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTicons    = S.settings.indicators.dunes.habitatrichness.icons;
    if isfield(S,'weburl')
        for kk=1:length(PLOTicons)
            PLOTicons(kk).url = [S.weburl '/img/hk/' strtrim(PLOTicons(kk).url)];
        end
    end    
    colour       = {[1 1 0.0],[0.9 0.0 0.0]};
    fillalpha    = 0.7;
    popuptxt={'Dune habitat richness',{'This indicator provides information on the expected habitat richness of the coast. These classes are:','',...
                            ' - class  1 = low/normal (=default for current coast)',' - class 2 = intermediate',' - class 3 = rich'}};

    %% Write to kml BAR PLOTS / ICONS
    [KMLdata1]   = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                  (S.PP(sens).GEmapping.dunes.habitatrichness-PLOTscale2), ...
                                  PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
    [KMLdata2]   = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                 S.PP(sens).GEmapping.dunes.habitatrichness,PLOTicons,PLOToffset,sens,popuptxt);
    S.PP(sens).output.kml_dunes_habitatrichness  = KMLdata1;
    S.PP(sens).output.kml_dunes_habitatrichness2 = KMLdata2;
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_dunes_habitatrichness2'];
end