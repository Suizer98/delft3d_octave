function [xafslag,zafslag, xnat,znat, xgp,zgp, grensprf] = xbBOI_safetyindicators(xbdirout)
%
% FUNCTION xbBOI_safetyindicators
%	Returns xafslag & xnat
%
%       Input:	`xbdirout`  >> output directory of XBeach run
%
% ------------------------------------------------------------------------
%   Deze code is ontwikkeld voor het project BOI Zandige Waterkeringen.
%
%   Versie script:      25-04-2022
%
%   Ontwikkeld door:	Deltares & Arcadis
%   Contactpersoon:     Robbin van Santen (Arcadis)
%
%
    %%
    DEBUG = true;

    %%  Read input data
    % % wl input
    wlfilein    = fullfile(xbdirout,'tide.txt');        % Better implementation would be: read fname for water level input from params.txt       
    wl          = load(wlfilein);
    maxWLoff    = max(wl(:,2));
    
    % % wave input
    wavefilein  = fullfile(xbdirout,'jonswap.txt');     % Better implementation would be: read fname for wave input from params.txt    
    waves       = load(wavefilein);
    maxHsoff    = max(waves(:,1));
    maxTpoff    = max(waves(:,2));
    
    
    %%  Read XBEACH output
    % % XBeach output
    xbfileout   = fullfile(xbdirout,'xboutput.nc');
    
    % % Read metadata & varnames from nc-file
    finfo   	= nc_info(xbfileout);
    varnames    = {finfo.Dataset.Name}';
    
    % % Read static variables
    X           = nc_varget(xbfileout,'globalx');
    TGLOBAL     = nc_varget(xbfileout,'globaltime') ./ 3600;
    TMEAN       = nc_varget(xbfileout,'meantime')   ./ 3600;
        % remove spinup period (=tstart) from TGLOBAL & TMEAN:
        [TGLOBAL,TMEAN]     = deal(TGLOBAL-TGLOBAL(1),TMEAN-TGLOBAL(1));
        [TGLOBAL,TMEAN]     = deal(round(TGLOBAL,4),round(TMEAN,4));
    
    % % Variable dimensions
    nX          = length(X);
    nTGLOBAL    = length(TGLOBAL);
    nTMEAN      = length(TMEAN);
    
    % % Read dynamic variables
    START       = [0 0 0];          % order = [t,y,x]
    COUNT       = [-1 1 -1];        % order = [t,y,x]
    ZB          = squeeze(nc_varget(xbfileout,'zb',START,COUNT))';
    if ismember('zswet_max',varnames)
        zswet_exist	= true;
        ZSWETMAX    = squeeze(nc_varget(xbfileout,'zswet_max',START,COUNT))';  	ZSWETMAX( ZSWETMAX > 1e9 | ZSWETMAX < -1e9 ) = NaN;
    else
        warning('*** WARNING *** >> No mean-output is found in XBeach outputfile for (mandatory) variable `zswet`!');
        zswet_exist	= false;
    	ZSMAX       = squeeze(nc_varget(xbfileout,'zs_max',START,COUNT))';
        ZBMAX       = squeeze(nc_varget(xbfileout,'zb_max',START,COUNT))';
        ZSWETMAX    = NaN(size(ZSMAX));
    end

    
    %%  Process time info
    % % Get TIMERANGE
    TIME        = [TGLOBAL(1);TMEAN];
    TIMERANGE   = [TIME(1:end-1),TIME(2:end)];
   
    % % Find all IDS of TGLOBAL per TMEAN period
    [~,itglobalprev]    = min(abs(TGLOBAL-TIMERANGE(:,1)')); itglobalprev = itglobalprev';
    [~,itglobal]        = min(abs(TGLOBAL-TIMERANGE(:,2)')); itglobal     = itglobal';
    TIMERANGEchk        = TGLOBAL([itglobalprev itglobal]);  

    
    %%  Determine XAFSLAG
    % % XAFSLAG
    Zi      = ZB(:,1);
    Ze      = ZB(:,end);
    [xafslag,zafslag]	= get_xafslag_xbBOI(X,Zi,Ze);
    % [xafslag,zafslag]	= get_xafslag_ALT01_xbBOI(X,Zi,Ze);
    % [xafslag,zafslag]	= get_xafslag_ALT02_xbBOI(X,ZB);
    
        % % [OPTIONAL] XAFSLAG - per output timestep
        [xafslag_t,zafslag_t,itxafslag]	= get_xafslag_t_xbBOI(X,Zi,ZB);
        txafslag	= TGLOBAL(itxafslag);

        % % [DEBUG] plot XAFSLAG
        if DEBUG
            figure();hold on;grid on;box on
            plot(TGLOBAL,xafslag_t,'.-b')
            plot(TGLOBAL,ones(nTGLOBAL,1)*xafslag,'--b')
            plot(txafslag,xafslag,'ob')
            xlabel('Time [hrs]')
            ylabel('Position of erosion point [m]')
        end

        
    %%  Determine XNAT
    % % XNAT (per timestep)
    if zswet_exist
        % % XRUNUP - DEFAULT METHOD
        [xnat_t,znat_t]     = get_xnat_t_xbBOI(X,ZSWETMAX);
        
    else
        allow_alternative	= false;
        if allow_alternative
            % % XRUNUP - ALTERNATIVE METHOD [NOT PREFERRED TO USE]
            disp('*** WARNING *** >> An alternative approach is used to find an estimate for `xnat` [NON-PREFERRED METHOD!]');
            [xnat_t,znat_t]     = get_xnat_t_ALT_xbBOI(X,ZSMAX,ZBMAX);
                    
        else
            disp('*** WARNING *** >> No result for `xnat`!');
            [xnat_t,znat_t]     = deal(NaN(nTMEAN,1));
        end
        
    end

    % % XNAT (normative)
    slopeland   = 1/2;
    [xnat,znat,itxnat]	= get_xnat_xbBOI(xnat_t,znat_t,slopeland,X,Ze);
    txnat       = TMEAN(itxnat);
    
    % % [TEST ONLY] XNAT (normative)
    %     for it = 1:n[TMEAN
    %         [xnatTEST,znatTEST,itxnatTEST]	= get_xnat_xbBOI(xnat_t(1:it),znat_t(1:it),slopeland,X,ZB(:,itglobal(it)));
    %     end

    
    %%  Determine ADDHEIGHT
    ADDHEIGHT   = get_addheight_zbBOI();

    
    %% Determine GRENSPRF
    if ~isnan(xnat)
        
        % % GRENSPRF - shape
        [grensprf0, grensprfvol] = get_grensprofiel_shape_zbBOI(xnat,znat,ADDHEIGHT,maxWLoff);

            % % [OPTIONAL] GRENSPRF_TRDA - shape
            % >> IMPORTANT: ensure that correct settings for `slopesea` (=1/1), `slopeland` (=1/2) and `crestwidth` (=3m) are set in function `get_grensprofiel_shape`
            crestlvl_TRDA   = maxWLoff + max( 0 , 0.12*maxTpoff*sqrt(maxHsoff) );       % hoogte grensprofiel t.o.v. NAP
            [grensprf0_TRDA, grensprfvol_TRDA]	= get_grensprofiel_shape_zbBOI(xnat,znat,(crestlvl_TRDA-znat),maxWLoff);

            % % [TEST] grensprofiel_standaard(true,maxWLoff,maxHsoff,maxTpoff);


        % % GRENSPRF - fit grensprf in post-storm profile
        %
        % ###
        % ### THIS FUNCTION IS NOT YET IMPLEMENTED!
        % ###
        %
        grensprf    = grensprf0;

        % %  XGP,ZGP - most landward point of grensprf
        [xgp,zgp]   = deal(grensprf(end,1),grensprf(end,2));
        
    else
        [grensprf,grensprf0,grensprf0_TRDA] = deal([]);
        [grensprfvol,grensprfvol_TRDA]      = deal(NaN);
        [xgp,zgp]   = deal(NaN);
    end
    
    
    %% [DEBUG] PLOT RESULTS
    % % 
    if DEBUG
        % % Plot results
        figure();hold on;grid on;box on; set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3.5]);
        patch([X(1);X;X(end)],[-30;Ze;-30],[1 .94 .5],'EdgeColor','none');
        plot(X([1 end]),[1;1]*maxWLoff,'--k','Color',[.7 .7 .7])
        plot(X,Ze,'LineStyle','-','Color','k','LineWidth',1);
        plot(X,Zi,'--k','LineWidth',1);
        plot(X,ZSWETMAX(:,itxnat),'LineStyle','--','Color','b');
        plot(grensprf0_TRDA(:,1),grensprf0_TRDA(:,2),'--r');
        plot(grensprf0(:,1),grensprf0(:,2),'--m');
        plot(grensprf(:,1),grensprf(:,2),'m')
        plot(xnat_t,znat_t,'.-b');
        plot(xafslag,zafslag,'sr','MarkerSize',4,'LineWidth',1);
        plot(xnat,znat,'ob','MarkerSize',4,'LineWidth',1);   
        plot(xgp,zgp,'om','MarkerSize',4,'LineWidth',1);
        plot([1 1].*xafslag,[-20 30],':r')
        plot([1 1].*xnat,[-20 30],':b')
        plot([1 1].*xgp,[-20 30],':m')
        xlabel('Cross-shore distance [m]');ylabel('Level [m+NAP]');
        set(gca,'Layer','Top')
        xlim(xafslag+[-100 50]);ylim([-5 20]);
        
    end
    
%% END
end


%%
%% LOCAL FUNCTIONS
%%

%%
function [xafslag,zafslag] = get_xafslag_xbBOI(X,Zi,Ze)
%
% FUNCTION (LOCAL) get_xafslag_xbBOI
%	Returns xafslag,zafslag
%
%   Most landward point of erosion (dztol = 0.01m) 
%
%       Input:	`X`     >> cross-shore coordinates of profile
%               `Zi`    >> initial profile (dims: [nX,1])
%               `Ze`    >> erosion profile (dims: [nX,1])
%
    %%
    [xafslag,zafslag]   = deal(NaN);
    
    % % XEROSION
    dztol       = 1e-2;
    dz          = Zi-Ze;
    ix          = find(dz>=dztol,1,'last')+1;
    if isempty(ix) || ix>length(X)
        % No valid result
    else
        xafslag     = X(ix);
        zafslag     = Ze(ix);  
    end
    
%% END
end

%%
    function [xafslag,zafslag] = get_xafslag_ALT01_xbBOI(X,Zi,Ze)
%
% FUNCTION (LOCAL) get_xafslag_ALT01_xbBOI
%	Returns xafslag,zafslag
%
%   Erosion point based on two steps:
%     [1] find most landward point of substantial erosion (dztol1 = 0.1m) 
%     [2] find closest erosion point (dztol2 = 0.01m)
%
%       Input:	`X`     >> cross-shore coordinates of profile
%               `Zi`    >> initial profile (dims: [nX,1])
%               `Ze`    >> erosion profile (dims: [nX,1])
%
    %%
    [xafslag,zafslag]   = deal(NaN);
    
    % % XEROSION
    dztol1      = 1e-1;
    dztol2      = 1e-2;
    dz          = Zi-Ze;
    ix1         = find(dz>=dztol1,1,'last');
    if isempty(ix1) || ix1>length(X)
        % No valid result
    else   
        ix      = find(dz<=dztol2 & X>X(ix1),1,'first');
        if isempty(ix) || ix>length(X)
            % No valid result
        else
            xafslag     = X(ix);
            zafslag     = Ze(ix);
        end
    end
    
%% END
end

%%
    function [xafslag,zafslag] = get_xafslag_ALT02_xbBOI(X,ZB)
%
% FUNCTION (LOCAL) get_xafslag_ALT02_xbBOI
%	Returns xafslag,zafslag
%
%   Most landward point of erosion (dztol = 0.01m) 
%     >> use alternative initial profile, zb(:,2), to exclude effects of
%        initial avalanching of steep dune slopes (located landward of 
%        actual erosion point)
%   
%   *** NOTE ***
%     >> this only works properly when considering a simulation with
%        relatively mild conditions at beginning of storm (= no erosion)
%        AND approx. (half-)hourly output for global var. `zb`!
%
%       Input:	`X`     >> cross-shore coordinates of profile
%               `ZB`    >> all erosion profiles (dims: [nX,nT])
%
    %%
    % % XEROSION
    Zi_alt  = ZB(:,2);
    Ze      = ZB(:,end);
    [xafslag,zafslag]           = get_xafslag_xbBOI(X,Zi_alt,Ze);
    
%% END
end

%%
function [xafslag_t,zafslag_t,itxafslag] = get_xafslag_t_xbBOI(X,Zi,ZB)
%
% FUNCTION (LOCAL) get_xafslag_t_xbBOI
%	Returns xafslag_t,zafslag_t,itxafslag
%
%       Input:	`X`     >> cross-shore coordinates of profile
%               `Zi`    >> initial profile (dims: [nX,1])
%               `ZB`    >> erosion profile per timestep (dims: [nX,nt])
%
    %%
    nt	= size(ZB,2);
    [xafslag_t,zafslag_t]	= deal(NaN(nt,1));
    
    % %
    for it = 1:nt
        Zt	= ZB(:,it);
        [xafslag_t(it),zafslag_t(it)]	= get_xafslag_xbBOI(X,Zi,Zt);
        % [xafslag_t(it),zafslag_t(it)]	= get_xafslag_ALT01_xbBOI(X,Zi,Zt);
        % [xafslag_t(it),zafslag_t(it)]	= get_xafslag_ALT02_xbBOI(X,ZB);
    end
    itxafslag   = find(xafslag_t==max(xafslag_t),1,'first');
        if isempty(itxafslag); itxafslag = nt; end
    
%% END
end

%%
function [xnat_t,znat_t] = get_xnat_t_xbBOI(X,ZSWETMAX)
%
% FUNCTION (LOCAL) get_xnat_t_xbBOI
%	Returns xnat,znat per timestep (tmean)
%
%       Input:	`X`         >> cross-shore coordinates of profile
%               `ZSWETMAX`  >> max waterlevel along profile per mean-timestep (XB-var: `zswet_max`)
%
    %%
    nt	= size(ZSWETMAX,2);
    [xnat_t,znat_t]     = deal(NaN(nt,1));
    
    % % XRUNUP
    for it = 1:nt
        zsmax           = ZSWETMAX(:,it);
        ix              = find(~isnan(zsmax),1,'last');
        if isempty(ix)
        	% No valid result
        else
            xnat_t(it)      = X(ix);
            znat_t(it)      = ZSWETMAX(ix,it);
        end
    end
    
%% END
end

%%
    function [xnat_t_ALT,znat_t_ALT] = get_xnat_t_ALT_xbBOI(X,ZSMAX,ZBMAX)
%
% FUNCTION (LOCAL) get_xnat_t_ALT_xbBOI
%   Returns xnat,znat per timestep (tmean)
%
%	*** NOTE *** >> ALTERNATIVE APPROACH [NON-PREFERRED METHOD]
%
%       Input:	`X`         >> cross-shore coordinates
%               `ZSMAX`     >> max waterlevel along profile per mean-timestep (XB-var: `zs_max`)
%               `ZBMAX`     >> max bed level along profile per mean-timestep (XB-var: `zb_max`)
%
    %%
    nt	= size(ZSMAX,2);
    [xnat_t_ALT,znat_t_ALT]	= deal(NaN(nt,1));
    
    % % XRUNUP - ALTERNATIVE METHOD [NOT PREFERRED TO USE]
    for it = 1:nt
        tol             = 5e-2;
        zsmax           = ZSMAX(:,it);
        zbmax           = ZBMAX(:,it);
        ix              = find(zsmax>(zbmax+tol),1,'last');
        if isempty(ix)
        	% No valid result
        else
            xnat_t_ALT(it)  = X(ix);
            znat_t_ALT(it)  = ZSMAX(ix,it);
        end
    end
    
%% END
end

%%
function [xnat,znat,itxnat] = get_xnat_xbBOI(xnat_t,znat_t,slopeland,X,Ze)
%
% FUNCTION (LOCAL) get_xnat_xbBOI
%	Returns xnat,znat (normative)
%
%       Input:	`xnat_t`        >> cross-shore coordinates
%               `znat_t`        >> max waterlevel along profile per mean-timestep (XB-var: `zswet_max`)
%               `slopeland`     >> (anticipated) landward slope of `grensprf`
%               `X`             >> cross-shore coordinates of profile
%               `Ze`            >> final erosion profile (dims: [nX,1])
%
    %%
    [xnat,znat]     = deal(NaN);
    
    % % XRUNUP (normative)
    zref            = min(znat_t) * ones(size(znat_t));
    xref            = xnat_t + (znat_t - zref)/slopeland;
    
    [~,itxnat]      = max(xref);
    xnat            = xnat_t(itxnat);
    znat            = znat_t(itxnat);

    % % XNAT (normative) --> clip to erosion profile
    %   >> shift xnat landward to first profile-crossing at z = znat
    xnat0       = xnat;
    xtol        = 1e-2;
    dxmax       = 10;
    xcros       = findCrossings(X,Ze, [X(1);X(end)],[1;1]*znat);
    xcros_land  = xcros( xcros>=(xnat-xtol) );
    xnat        = min(xcros_land);                              % = first profile crossing  landward of xnat0
    xnat_backup = X(find( X>xnat0 | X==X(end) ,1,'first'));     % = first gridpoint landward of xnat0 (max value: x=X(end));
        if isempty(xcros)
            warning('No crossing found between znat-level and prf. No solution possible.');
            xnat = NaN;
        elseif isempty(xnat) || (xnat-xnat0)>dxmax
            warning(['No valid crossing found between znat-level and prf. Alternative solution is used: xnat = xnat_backup (dx = ' num2str((xnat_backup-xnat0),'%.1f') ' m).']);
            xnat = max( xnat0 , xnat_backup );
        end
        
    % % [DEBUG] PLOT
    locDEBUG = false;
    if locDEBUG
        figure();hold on;grid on;box on
        plot(X,Ze,'k')
        plot(xnat_t,znat_t,'.-m')
        plot([xnat_t,xref]',[znat_t,zref]','--m')
        plot(xref(itxnat),zref(itxnat),'xm')
        plot([xnat0;xnat],[1;1]*znat,':r')
        plot(xnat0,znat,'om')
        plot(xnat,znat,'or')
        xlim(xnat+[-100 50]);ylim(znat+[-10 10]);
    end
    
%% END
end

%%
function [addheight] = get_addheight_zbBOI()
%
% FUNCTION (LOCAL) get_addheight_zbBOI
%	Returns addheight
%
%   Additional height of grensprofiel above `znat`
%
%   NEW FUNCTION SHOULD BE DEFINED AFTER ADDITIONAL RESEARCH!
%   ADDHEIGHT PREFERABLY BASED ON NEARSHORE (SHORT) WAVEHEIGHT (OR SIMILAR)
%
    %%
    addheight   = 1.5;
    
%% END
end

%%
function [grensprf, grensprfvol] = get_grensprofiel_shape_zbBOI(xnat,znat,addheight,maxSSL)
%
% FUNCTION get_grensprofiel_shape_zbBOI
%   Returns grensprofiel at reference position `xnat`
%
%       Input:	`xnat`,`znat`	>> reference point [xnat,znat]
%               `addheight`     >> additional height of grensprf above znat
%               `maxSSL`        >> max. storm surge level (offshore)
%
    %%
    localDEBUG      = false;
    
    % % Basic setings
    crestwidth      = 3;
    slopesea        = 1/1;
    slopeland       = 1/2;

    % % Set output
    grensprf        = [];
    grensprfvol     = NaN;

    % % Define shape of profile
    crestlvl        = znat + addheight;
    crestheight     = crestlvl - maxSSL;
        if crestheight<=0; warning('No result possible when crestlvl <= maxSSL'); return; end

    dx1         = crestheight/slopesea;
    dx2         = crestwidth;
    dx3         = crestheight/slopeland;
    dx4         = (crestlvl-crestheight)/slopeland;

    xgrensprf  	= xnat + [0; dx1; dx1+dx2; dx1+dx2+dx3; dx1+dx2+dx3+dx4];
    zgrensprf  	= [maxSSL; crestlvl; crestlvl; maxSSL; 0];
    
    % % Extended seaward slope of grensprf
    xsea        = [-50;+100]*slopesea + xgrensprf(1);
    zsea        = [-50;+100]          + zgrensprf(1);

    % % Shift (dx) of x-coords xgrensprf (based on crossing with znat-level)
    dx          = min(findCrossings(xsea,zsea,xsea,[1;1]*znat));
        if isempty(dx); dx = 0; warning('No crossing found between z0-level and seaslope.'); end

    % % Finalize profile
    grensprf	= [xgrensprf - dx + xnat,zgrensprf];

    % % Volume above max SSL (storm surge level)
    [xp,zp]     = deal(xgrensprf(1:end-1),zgrensprf(1:end-1));
    grensprfvol = polyarea(xp,zp);

    % % [DEBUG] plot
    if localDEBUG
        figure();hold on;grid on;box on
        patch(xp,zp,[1. .9 .7],'EdgeColor','none')
        plot(xgrensprf([1 end]),[1;1]*maxSSL,'--b')
        plot(xgrensprf,zgrensprf,'r')
    end

%% END
end

%% EOF
