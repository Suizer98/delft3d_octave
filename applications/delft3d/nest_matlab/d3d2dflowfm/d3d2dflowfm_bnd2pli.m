function varargout = d3d2dflowfm_bnd2pli(filgrd,filbnd,filpli,varargin)

% d3d2dflowfm_bnd2pli: genarates pli file for D-Flow FM out of a D3D bnd file

%% initialisation
OPT.Salinity          = false;
OPT.Temperature       = false;
OPT.enclosure         = '';
OPT.bc0               = '';
OPT                   = setproperty(OPT,varargin);
[path_pli,name_pli,~] = fileparts(filpli);

%% Read the grid: OET-style
G           = delft3d_io_grd('read',filgrd,'nodatavalue',-999);
xc          = G.cend.x';
yc          = G.cend.y';
mmax        = size(xc,1);
nmax        = size(xc,2);
nr_harm     = 0;

%% Read the boundary file
D           = delft3d_io_bnd('read',filbnd);
mbnd        = D.m;
nbnd        = D.n;
no_bnd      = size(mbnd,1);

%% Read the bc0 file if requested
if ~isempty(OPT.bc0)
    bct = ddb_bct_io('read',OPT.bc0);
    Locations = {bct.Table.Location};
end

%% Determine (x,y)-values of boundary points
for i_bnd=1:no_bnd
    for i_side=1:2
        xb(i_bnd,i_side) = xc(mbnd(i_bnd,i_side),nbnd(i_bnd,i_side));
        yb(i_bnd,i_side) = yc(mbnd(i_bnd,i_side),nbnd(i_bnd,i_side));
    end
end

%% Type of bc (and determine signd for current and discharge bc)

first          = true;
kcs            = [];
for i_bnd      = 1: no_bnd
    sign(i_bnd) = 1;
    type           = D.DATA(i_bnd).bndtype;
    if strcmpi(type,'c') || strcmpi(type,'q') || strcmpi(type,'t')
        if first && ~isempty(OPT.enclosure)
            % Determine kcs values (1 active, 0 inactive)
            kcs               = nesthd_det_icom(G.cor.x',G.nodatavalue,OPT.enclosure);
            % Coordinates of velocity points and wheter inflow is positive
            [Xuv, Yuv,positi] = nesthd_detxy (G.cor.x',G.cor.y',D,kcs,'UVp');
            first = false;
        end
        if ~isempty(kcs)
            if strcmpi(positi{i_bnd},'out') sign(i_bnd) = -1.0;end
            for i_side = 1: 2
                xb(i_bnd,i_side) = Xuv(i_bnd,i_side);
                yb(i_bnd,i_side) = Yuv(i_bnd,i_side);
            end
        end
    end
end

%% Reshape the boundary locations into polylines
irow         = 1;                     % is number of points in the polyline
iline        = 1;                     % is number of polylines
bc0(iline)   = false;

%% Set initial boundary orientation
dir_old = 'n';
if mbnd(1,1) == mbnd(1,2)
    dir_old = 'm';
end

for ibnd = 1 : no_bnd

    % Change in orientation or jump of more than 1 cell ==> new polyline
    if ibnd > 1
        if mbnd(ibnd,1) == mbnd(ibnd,2)
            dir       = 'm';
            diff      = abs(nbnd(ibnd,1) - nbnd(ibnd-1,2));
            if mbnd(ibnd,1) ~= mbnd(ibnd-1,2) diff = 1e6; end
        else
            dir       = 'n';
            diff      = abs(mbnd(ibnd,1) - mbnd(ibnd-1,2));
            if nbnd(ibnd,1) ~= nbnd(ibnd-1,2) diff = 1e6; end
        end
        if ~strcmp(dir,dir_old) || diff > 1 || ~strcmp(D.DATA(ibnd).bndtype,D.DATA(max(ibnd-1,1)).bndtype)
            dir_old    = dir;
            iline      = iline + 1;
            irow       = 1;
            bc0(iline) = false;
        end
    end

    %% Type of forcing
    astronomical = false;
    timeseries   = false;
    harmonic     = false;
    if strcmpi(D.DATA(ibnd).datatype,'a') && isempty(OPT.bc0);
        astronomical  = true;
    end
    if strcmpi(D.DATA(ibnd).datatype,'t') || ~isempty(OPT.bc0);
        D.DATA(ibnd).datatype = 'T';
        timeseries            = true;
    end
    if strcmpi(D.DATA(ibnd).datatype,'h') && isempty(OPT.bc0);
        harmonic      = true;
    end

    %% Fill LINE struct (starting with side A)
    
    LINE(iline).DATA{irow,1} = xb(ibnd,1);
    LINE(iline).DATA{irow,2} = yb(ibnd,1);
    string = sprintf(' %1s %1s ',D.DATA(ibnd).bndtype,D.DATA(ibnd).datatype);
    if astronomical && ~OPT.Salinity && ~OPT.Temperature 
        string = [string D.DATA(ibnd).labelA];
    end
    if timeseries   ||  OPT.Salinity || OPT.Temperature 
        string = [string D.DATA(ibnd).name 'sideA'];
    end
    if harmonic     && ~OPT.Salinity && ~OPT.Temperature 
        nr_harm = nr_harm + 1;
        string  = [string num2str(nr_harm,'%04i') 'sideA'];
    end

    %% Add sign to the string
    string = [string ' ' num2str(sign(ibnd))];
    LINE(iline).DATA{irow,3} = string;

    %% Fill LINE struct for side B (avoid double points by checking if it is not first point of next boundary segment)
    if ~(xb(ibnd,2) == xb(min(ibnd + 1,no_bnd),1) && yb(ibnd,2) == yb(min(ibnd +1,no_bnd),1)) 
       irow = irow + 1;
       LINE(iline).DATA{irow,1} = xb(ibnd,2);
       LINE(iline).DATA{irow,2} = yb(ibnd,2);
       string = sprintf(' %1s %1s ',D.DATA(ibnd).bndtype,D.DATA(ibnd).datatype);
       if astronomical && ~OPT.Salinity && ~OPT.Temperature 
           string = [string D.DATA(ibnd).labelB];
       end
       if timeseries   || OPT.Salinity || OPT.Temperature 
           string = [string D.DATA(ibnd).name 'sideB'];
       end
       if harmonic     && ~OPT.Salinity && ~OPT.Temperature 
           string  = [string num2str(nr_harm,'%04i') 'sideB'];
       end

       %% Add sign to the string
       string = [string ' ' num2str(sign(ibnd))];
       LINE(iline).DATA{irow,3} = string;
    end
    irow = irow + 1;

    %% Check if sea level anomolies are requested for this polygon (at least one boundary with additional signal)
    if ~isempty(OPT.bc0)
        if ~isempty(strmatch(D.DATA(i_bnd).name,Locations))
            bc0(iline) = true;
        end
    end
end

%% Write the pli-files for the separate polygons
for ipol = 1: length(LINE)

    %
    % Blockname = name of the file
    %

    if ~OPT.Salinity && ~OPT.Temperature && isempty(OPT.bc0)
       LINE(ipol).Blckname=[name_pli '_' num2str(ipol,'%3.3i')];
       dflowfm_io_xydata ('write',[filpli '_' num2str(ipol,'%3.3i') '.pli'],LINE(ipol));
    elseif ~isempty(OPT.bc0)
        if bc0(ipol)
            LINE(ipol).Blckname=[name_pli '_' num2str(ipol,'%3.3i') '_bc0'];
            dflowfm_io_xydata ('write',[filpli '_' num2str(ipol,'%3.3i') '_bc0.pli'],LINE(ipol));
        end
    elseif OPT.Salinity
       LINE(ipol).Blckname=[name_pli '_' num2str(ipol,'%3.3i') '_sal'];
       dflowfm_io_xydata ('write',[filpli '_' num2str(ipol,'%3.3i') '_sal.pli'],LINE(ipol));
    elseif OPT.Temperature
       LINE(ipol).Blckname=[name_pli '_' num2str(ipol,'%3.3i') '_tem'];
       dflowfm_io_xydata ('write',[filpli '_' num2str(ipol,'%3.3i') '_tem.pli'],LINE(ipol));
    end

    %
    % Fil varargout for later wriing of the file names to the external forcing file
    %

    if nargout > 0;
        filext{ipol} = [LINE(ipol).Blckname '.pli'];
    end
end

% now, write all polylines (only for hydrodynamic bc)

if ~OPT.Salinity && ~OPT.Temperature && isempty(OPT.bc0)
   dflowfm_io_xydata ('write',[filpli '_all.pli'],LINE);
end

varargout = {filext};
