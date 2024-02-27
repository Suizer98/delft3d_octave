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