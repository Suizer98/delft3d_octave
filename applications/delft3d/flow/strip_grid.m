function GRID = strip_grid(GRID,default,enclosure)

% function - restricts the grid to the active grid within the enclosure
%
%% Initialize
mmax = size(GRID.X,1) + 1;
nmax = size(GRID.X,2) + 1;

%% Determine ncs values (active = 1, inactive = 0)
kcs = nesthd_det_icom(GRID.X,default,enclosure);

%% Fill points outside the enclosure with missing values
for m = 1: mmax -1
    for n = 1: nmax - 1
        if kcs(m  ,n  ) == 0 && kcs(m+1,n  ) == 0 && ...
           kcs(m  ,n+1) == 0 && kcs(m+1,n+1) == 0
            GRID.X(m,n) = default;
            GRID.Y(m,n) = default;
         end
    end
end
