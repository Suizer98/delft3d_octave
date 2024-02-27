function [varargout] = dethyps(varargin)

%% Initialisation
oetsettings ('quiet')

%% Run dependent parameter settings
OPT.grd    = 'cropped_ref2.grd';
OPT.dep    = 'frank_2005.dep';
OPT.out    = '2005_n.hyps';
OPT.new    = true;
OPT.dpsopt = 'DP';
OPT.filpol = '';

OPT.maxdep = NaN;
OPT.mindep = NaN;

OPT     = setproperty(OPT,varargin);

%% Open grid and depth file
grid                     = wlgrid('open',OPT.grd);
cmp.dps                  = wldep ('read',OPT.dep,grid);
cmp.dps(cmp.dps == -999) = NaN;

nmax = size(cmp.dps,1);
mmax = size(cmp.dps,2);

%% Fill missing X an Y values with missing value
grid.X(nmax,:) = grid.MissingValue;
grid.X(:,mmax) = grid.MissingValue;
grid.Y(nmax,:) = grid.MissingValue;
grid.Y(:,mmax) = grid.MissingValue;

%% put geographical data in structure geo
geo.xz(1:nmax,1:mmax) = NaN;
geo.yz(1:nmax,1:mmax) = NaN;
for n = 2:nmax
    for m = 2: mmax
        geo.xz(n,m) = 0.25*(grid.X(n-1,m  ) + grid.X(n  ,m  ) + ...
                            grid.X(n  ,m-1) + grid.X(n-1,m-1) ); 
        geo.yz(n,m) = 0.25*(grid.Y(n-1,m  ) + grid.Y(n  ,m  ) + ...
                            grid.Y(n  ,m-1) + grid.Y(n-1,m-1) );
    end
end
geo.x    = grid.X;
geo.y    = grid.Y;
geo.gsqs = detare(geo.x,geo.y,OPT.new);
geo.kcs  = detkcs(geo.x,geo.y,grid.MissingValue);

%% Determine depths at cell centres
if ~strcmpi(OPT.dpsopt,'DP')
    for n = 2: nmax
        for m = 2: mmax
             hlp (n,m) = 0.25*(cmp.dps(n,m) + cmp.dps(n-1,m) + cmp.dps(n,m-1) + cmp.dps(n-1,m-1));
        end
    end
    cmp.dps = hlp;
end


%% Determine total number of polygons and fill xpol and ypol with polygon coordinates
xpol                     = [];
ypol                     = [];
no_pol                   =  1;
if ~isempty(OPT.filpol)
    %% Read the polygon data file
    Fileinfo                 = tekal ('open',OPT.filpol,'loaddata');
    [xpol,ypol,noval,no_pol] = detpol (Fileinfo);
    clear Fileinfo;
end

for i_pol = 1: no_pol
    %% Determine inside polygon
    if ~isempty(xpol)
        kcss       = inpolygon (geo.xz,geo.yz,              ...
                                xpol(i_pol,1:noval(i_pol)), ...
                                ypol(i_pol,1:noval(i_pol)));
        kcss       = double(kcss);
    else
        kcss(1:nmax,1:mmax) = 1;
    end
    kcss       = kcss.*geo.kcs;
    
    %% Now determine hypsometric curves
    if isnan(OPT.maxdep) OPT.maxdep = max(max(dps,[],2)); end
    if isnan(OPT.mindep) OPT.mindep = min(min(dps,[],2)); end
    
    [rvol,rare,rdep] = hyps(kcss,cmp.dps,geo.gsqs,OPT.maxdep,OPT.mindep);
    Data(1,1:size(rdep,2),1) = squeeze(rdep);
    Data(1,1:size(rdep,2),2) = squeeze(rvol);
    Data(1,1:size(rdep,2),3) = squeeze(rare);
    
    clear geo cmp kcss dpss
    
    %% Fill output argument
    if nargout == 1
        varargout{1} = Data;
    end
    
    %% Finally write the data to TEKAL File (if specified)
    if ~isempty(OPT.out)
        fid = fopen (OPT.out,'w+');
        
        fprintf(fid,'%s \n','* Column 1 : Depth'   );
        fprintf(fid,'%s \n','* Column 2 : Volume');
        fprintf(fid,'%s \n','* Column 3 : Area');
        
        fprintf(fid,'%s \n', strcat('B',num2str(1,'%03i')));
        fprintf(fid,'%6i   %6i    \n', size(rdep,2), 3);
        for ihyps = 1: size(rdep,2);
            fprintf(fid,'%16.3f ' , Data (1, ihyps,1));
            fprintf(fid,'%16.3f   %16.3f' , Data (1,ihyps,2), Data (1,ihyps,3));
            fprintf(fid,(' \n'));
        end
    end
end
