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