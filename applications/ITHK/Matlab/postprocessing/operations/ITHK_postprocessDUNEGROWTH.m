function ITHK_postprocessDUNEGROWTH(sens)
% function ITHK_postprocessDUNEGROWTH(sens)
% Computes dune development on the basis of PRN file with coastline development 
% in time.
% 
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB(sens).results.PRNdata      Structure with PRNdata
%              .settings.indicators.dunes     Structure with settings that deviate from standard settings
%                                             (fields overrule the default settings and can be set inidvidually)
%                                             .Hactdunes    Active height of the dunes (default=15m)
%                                             .yposinitial  Initial position of the dune front relative 
%                                                           to the initial coastline position. Either
%                                                           specify a single value (uniform along the coast)
%                                                           or variable dune position (array with same
%                                                           length as coastline in PRNfile). Note that 
%                                                           positive direction means further landward from
%                                                           coastline (Default=80m backwards of coastline).
%                                             .Cmax         Maximum dunegrowth-rate, which is sediment transport
%                                                           from the beach to the dunes (default = 35 m3/m/yr)
%                                             .Bthr         Equilibrium coastline width (default=80m)
%                                             .Bhalf        Relaxation parameter which defines how quickly 
%                                                           dunegrowth the goes from 0 at Bthr to Cmax/2 
%                                                           at a wider beach (default=50m).
%                                                            Vdunegrowth = Cmax * (1 - exp(-(B-Bthr)/Bhalf) )
%                                             .CSTorient    Coastline orientation [°N] (normal to the coast 
%                                                           in seaward direction). Can be specified as single
%                                                           value or array with size similar to coastline grid.
%                                                           An MDA filename can also be specified. The
%                                                           coastline orientation from this file is then used.
%    
% OUTPUT:
%      S      structure with ITHK data
%              .PP(sens).dunes.position.x            X-coordinate of dune face
%              .PP(sens).dunes.position.y            Y-coordinate of dune face
%              .PP(sens).dunes.position.ypos         The cross-shore position of the dune face relative to the reference line (compare to PRNdata.z)
%              .PP(sens).dunes.position.beachwidth   The beach width along the coast in time
%
% EXAMPLE:
%   run a model and generate 'test.PRN' and use 'test.MDA'
%   S.UB(sens).results.PRNdata  = ITHK_io_readPRN('test.PRN');
%   S.settings.indicators.dunes.yposinitial = 80;
%   ITHK_postprocessDUNEGROWTH(sens)
%
% Copyright: Deltares, 2011
% Created by B.J.A. Huisman

fprintf('ITHK postprocessing : Computing potential impact of coastline changes on dune development\n');

global S

    %% DEFAULT VALUES
    DUNES                = struct;
    settings             = struct;
    settings.Cmax        = 80;  %35;
    settings.Bthr        = 80;
    settings.Bhalf       = 150; %50;
    settings.yposinitial = 80;  % Intial dune face position at 80 meters landward of coastline position
    settings.Hactdunes   = 15;  % Active height of the dunes (default=15m)
    %settings.Hactcoast   = 10;  % Active height of the coast (default=10m) <- relevant if feedback from dunes to coast is considered in the future
    %settings.smoothsteps = 1;   % function to smooth data is not used

    %% OVERRULE DEFAULT VALUES FOR SETTING FIELDS THAT ARE SPECIFIED
    if nargin>1
        set2             = S.settings.indicators.dunes;
        fieldnames       = fields(set2);
        for ii=1:length(fieldnames)
            settings.(fieldnames{ii})=set2.(fieldnames{ii});
        end
    end
    if exist([S.settings.outputdir,S.settings.CLRdata.mdaname '.MDA'],'file')
        settings.CSTorient=[S.settings.outputdir,S.settings.CLRdata.mdaname '.MDA'];
    end
    
    %% READ PRN
    PRNdata = S.UB(sens).results.PRNdata;
    if isfield(PRNdata,'xSLR')
    PRNdata.x = PRNdata.xSLR;
    PRNdata.y = PRNdata.ySLR;
    PRNdata.z = PRNdata.zSLR;
    end

    %% SET INITIAL POSITION OF DUNES
    if isfield(settings,'yposinitial')
        if length(settings.yposinitial) == length(PRNdata.xdist2)
            % set variable yposition for coastline points if length is equal to length of coastline in PRN 
            % (ypos is defined relative to the initial shoreline)
            DUNES.ypos = PRNdata.z(:,1)-settings.yposinitial;
        else
            % set similar yposition for all coastline points
            % (ypos is defined relative to the initial shoreline)
            DUNES.ypos = PRNdata.z(:,1)-repmat(settings.yposinitial(1),[length(PRNdata.xdist2),1]);
        end
    end
    
    %% COMPUTE COASTANGLES
    if isfield(settings,'CSTorient')
        if isstr(settings.CSTorient)
           MDAdata=ITHK_io_readMDA(settings.CSTorient);
           DUNES.CSTorient = MDAdata.ANGLEcoast;     
        elseif length(settings.CSTorient) == length(PRNdata.xdist2)
            % set variable reference coastline orientation for coastline points 
            % if length is equal to length of coastline in PRN            
            DUNES.CSTorient = settings.CSTorient;
        else
            % set similar reference coastline orientation for all coastline points
            DUNES.CSTorient = repmat(settings.CSTorient(1),size(PRNdata.xdist2));
        end
    else
        % compute average coastangle from angles of coastline in PRN file 
        % (assuming model is at 1 angle)
        alfa = PRNdata.alfa(:,1)*pi/180;
        MEANcoastangle = mod(atan2(mean(sin(alfa)),mean(cos(alfa)))*180/pi,360);
        DUNES.CSTorient = repmat(MEANcoastangle,size(PRNdata.xdist2));
    end

    %% COMPUTE DUNE POSITION CHANGES  /  LOOP OVER TIME
    DUNES.B = PRNdata.z(:,1) - DUNES.ypos(:,1);
    for tt=1:length(PRNdata.year)-1
        % compute timestep [yrs]
        DT = PRNdata.year(tt+1)-PRNdata.year(tt);

        % compute beach width [m]
        coastT0 = PRNdata.z(:,tt);
        coastT1 = PRNdata.z(:,tt+1);
        DUNES.Bavg(:,tt) = (coastT1+coastT0)/2 - DUNES.ypos(:,tt);
        
        % compute dune growth [m3/m/yr]
        [Vdunegrowth(:,tt)]=computeDUNEGROWTH(DUNES.B(:,tt),settings.Bthr,settings.Cmax,settings.Bhalf);

        % compute changes in the dunes [m]
        dx_dunes(:,tt) = Vdunegrowth(:,tt)/settings.Hactdunes * DT;
        %dx_coast = Vdunegrowth/settings.Hactcoast * DT; <- no feedback to coast
        DUNES.ypos(:,tt+1) = DUNES.ypos(:,tt)+dx_dunes(:,tt);

        % take into account coastal erosion by assuming that the beach width is at least Bthr
        DUNES.ypos(:,tt+1) = min(DUNES.ypos(:,tt+1),coastT1-settings.Bthr);
        
        % compute actual beach width at t=t+1
        DUNES.B(:,tt+1)    = coastT1 - DUNES.ypos(:,tt+1);
    end

    %% POST_PROCESS RESULTS
    % determine average coastline orientation (used for finding x,y coordinates
    % of dune position normal to initial coastline.
    dx     = sin((DUNES.CSTorient+180)*pi/180);    %[dx] = SMOOTHVARS(dx,settings.smoothsteps);
    dy     = cos((DUNES.CSTorient+180)*pi/180);    %[dy] = SMOOTHVARS(dy,settings.smoothsteps);
    dx2    = dx./(dx.^2+dy.^2).^0.5;
    dy2    = dy./(dx.^2+dy.^2).^0.5;
    for tt=1:length(PRNdata.year)
        % export position of coastline (for completeness)
        DUNES.xcst(:,tt) = PRNdata.x(:,tt);
        DUNES.ycst(:,tt) = PRNdata.y(:,tt);
        % compute x,y location of dune position
        DUNES.x(:,tt) = DUNES.xcst(:,tt) + DUNES.B(:,tt) .* dx2;
        DUNES.y(:,tt) = DUNES.ycst(:,tt) + DUNES.B(:,tt) .* dy2;
    end

    %% PLOT OUTPUT (for debugging)
%     % figure;tt=1;plot(PRNdata.z(:,tt),'b-');hold on;plot(DUNES.ypos(:,tt),'b:');plot(DUNES.B(:,tt),'r');legend('Ypos coast [m wrt ref.line]','Ypos dunes [m wrt ref.line]','Beach width [m]');
%     % figure;tt=5;plot(PRNdata.z(:,tt),'b-');hold on;plot(DUNES.ypos(:,tt),'b:');plot(DUNES.B(:,tt),'r');legend('Ypos coast [m wrt ref.line]','Ypos dunes [m wrt ref.line]','Beach width [m]');
%     figure;plot(DUNES.xcst(:,1),DUNES.ycst(:,1),'k-','LineWidth',4);hold on;plot(DUNES.x(:,1),DUNES.y(:,1),'k-','LineWidth',4);
%     for tt=1:length(PRNdata.year)
%         plot(DUNES.xcst(:,tt),DUNES.ycst(:,tt),'r-');hold on;plot(DUNES.x(:,tt),DUNES.y(:,tt),'b.-');
%         %id = find(dy2==max(dy2));
%         %plot(DUNES.xcst(id,tt),DUNES.ycst(id,tt),'r*');hold on;plot(DUNES.x(id,tt),DUNES.y(id,tt),'r*');
%     end

    %% OUTPUT INFO
    S.PP(sens).dunes.position.x          = DUNES.x;     % X-coordinate of dune face
    S.PP(sens).dunes.position.y          = DUNES.y;     % Y-coordinate of dune face
    S.PP(sens).dunes.position.ypos       = DUNES.ypos;  % The cross-shore position of the dune face relative to the reference line (compare to PRNdata.z)
    S.PP(sens).dunes.position.beachwidth = DUNES.B;     % The beach width along the coast in time
    S.PP(sens).dunes.position.yposREL    = S.PP(sens).dunes.position.ypos-repmat(S.PP(sens).dunes.position.ypos(:,1),[1,size(S.PP(sens).dunes.position.ypos,2)]);
end

%% Sub-function 1 : SMOOTH FUNCTION
function [c]=SMOOTHVARS(a,smoothsteps)
    % function smooths array a
    % the results are conservative (total sum of a is similar to sum of c)
    c=a;
    for jj=1:smoothsteps
        b   = (a(2:end)+a(1:end-1))/2;
        c   = [(a(1)+b(1))/2;(b(2:end)+b(1:end-1))/2;(a(end)+b(end))/2];
    end
end

%% Sub-function 2 : computeDUNEGROWTH
function [Vdunegrowth]=computeDUNEGROWTH(B,Bthr,Cmax,Bhalf)
%function [Vdunegrowth]=computeDUNEGROWTH(B,Bthr,Cmax,Bhalf)
%Computes volume exchange from beach to the dune
% 
%                               -(B-Bthr)/Bhalf
%    Vdunegrowth = Cmax * (1 - e               )
%
% INPUT:
%    B              Actual beach width [m] (Y-Ydune)
%    Bthr           Equilibrium beach width [m]
%    Cmax           Maximum volume exchange towards the dunes [m3/yr]
%    Bhalf          Half of maximum volume exchange [m]
%    
% OUTPUT:
%    Vdunegrowth    Actual volume that is transported from the beach to the dunes [m3/m/yr]
%
% EXAMPLE:
%   B     = 80;
%   Bthr  = 80;
%   Cmax  = 35;
%   Bhalf = 50;
%   [Vdunegrowth]=computeDUNEGROWTH(B,Bthr,Cmax,Bhalf)
%
% Copyright: Deltares, 2011
% Created by B.J.A. Huisman

    Vdunegrowth = Cmax*(1-exp(-(B-Bthr)./Bhalf));
    Vdunegrowth(Vdunegrowth<0)=0;
end