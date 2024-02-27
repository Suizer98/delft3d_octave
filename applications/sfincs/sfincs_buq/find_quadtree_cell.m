function indx=find_quadtree_cell(buq, x, y)

buq.cosrot=cos(buq.rotation*pi/180);
buq.sinrot=sin(buq.rotation*pi/180);
buq.nr_levels=max(buq.level);

for ilev=1:buq.nr_levels
    buq.dxr(ilev)=buq.dx*2^(1-ilev);
    buq.dyr(ilev)=buq.dy*2^(1-ilev);
end

xtmp =   buq.cosrot*(x - buq.x0) + buq.sinrot*(y - buq.y0);
ytmp = - buq.sinrot*(x - buq.x0) + buq.cosrot*(y - buq.y0);
%
for iref = buq.nr_levels:-1:1
    %
    nmx = buq.nmax*2^(iref - 1);
    %
    n  = floor(ytmp/buq.dyr(iref)) + 1;
    m  = floor(xtmp/buq.dxr(iref)) + 1;
    nm = (m - 1)*nmx + n;
    %
    % Find nm index of this point
    %
    i1 = buq.first_point_per_level(iref);
    i2 = buq.last_point_per_level(iref);
    %
%    indx = binary_search(buq.nm_indices(i1:i2), i2 - i1 + 1, nm);
    [ism,indx] = ismember(nm,buq.nm_indices(i1:i2));
    %
    if indx>0
        %
        % Now check if this is the point we're actually interested in (could also be another point with another refinement level with the same nm index)
        %
        if buq.level(i1 + indx - 1) == iref
            %
            % This must be our point
            %
            indx = indx + i1 - 1;
            break
            %
        end
        %
    end
    %
end
