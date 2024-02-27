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