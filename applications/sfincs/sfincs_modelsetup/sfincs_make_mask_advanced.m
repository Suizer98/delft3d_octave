function msk = sfincs_make_mask_advanced(x,y,z,varargin)
% Leijnse april 18: included option to exclude points via polygon input
% Leijnse nov 21: complete revisit of code
%   contains:
%           1. Determine active grid based on either elevation and/or include-exclude polygons
%           2. Determine msk=1/2/3 values for boundary cells (closed/waterlevel/outflow)
%           3. Finalize
%           X.   Supporting functions - activegrid
%           XX.  Supporting functions - boundarycells
%           XXX. Supporting functions - general

varargin_activegrid = struct;
varargin_boundarycells = struct;
count_activegrid = 0;
count_boundarycells = 0;

% active grid
zlev = [-10000, 10000];
xy_in=[];
xy_ex=[];

% boundary cells
zlev_polygon = 5; %max elevation to apply msk=2 to 'waterlevelboundarypolygon' and minimum elevation to apply msk=3 for 'outflowboundarypolygon'
backwards_compatible = 0;
xy_bnd_closed=[];
xy_bnd_waterlevel=[];
xy_bnd_outflow=[];

% read varargin and order
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            
            % active grid            
            case{'zlev'} % here order specified by user matters
                zlev = varargin{ii+1};
                count_activegrid = count_activegrid + 1;
                varargin_activegrid(count_activegrid).action = 'zlev';
            case{'includepolygon'}
                xy_in = varargin{ii+1};
                count_activegrid = count_activegrid + 1;
                varargin_activegrid(count_activegrid).action = 'includepolygon';                
            case{'excludepolygon'}
                xy_ex = varargin{ii+1};
                count_activegrid = count_activegrid + 1;
                varargin_activegrid(count_activegrid).action = 'excludepolygon';  
                
            % boundary cells    
            case{'zlev_polygon'} % here order doesn't matter
                zlev_polygon = varargin{ii+1};         
                
            case{'closedboundarypolygon'} % here order specified by user matters
                xy_bnd_closed = varargin{ii+1};
                count_boundarycells = count_boundarycells + 1;
                varargin_boundarycells(count_boundarycells).action = 'closedboundarypolygon';                  
            case{'waterlevelboundarypolygon'}
                xy_bnd_waterlevel = varargin{ii+1};
                count_boundarycells = count_boundarycells + 1;
                varargin_boundarycells(count_boundarycells).action = 'waterlevelboundarypolygon';                  
            case{'outflowboundarypolygon'}
                xy_bnd_outflow = varargin{ii+1};      
                count_boundarycells = count_boundarycells + 1;
                varargin_boundarycells(count_boundarycells).action = 'outflowboundarypolygon';    
                
            case{'backwards_compatible'} % option like before based on pure elevation
                backwards_compatible = varargin{ii+1};
                count_boundarycells = count_boundarycells + 1;
                varargin_boundarycells(count_boundarycells).action = 'backwards_compatible';  
        end
    end
end

%% 0. Initialize matrix of mask
msk=zeros(size(z));

%% 1. Determine active grid based on either elevation and/or include-exclude polygons
disp('Info - start determine active grid')

if count_activegrid > 0

    for ii = 1:count_activegrid %use order as defined in varargin to do this
        
        if strcmp(varargin_activegrid(ii).action, 'zlev')
            [msk,z] = cut_mask_on_elevation(msk, z, zlev);
            
        elseif strcmp(varargin_activegrid(ii).action, 'includepolygon')
            if ~isempty(xy_in)
                [msk] = cut_mask_on_include_polygon(x,y,msk,xy_in);
            else
                warning('includepolygon is empty')
            end
        elseif strcmp(varargin_activegrid(ii).action, 'excludepolygon')
            if ~isempty(xy_ex)
                [msk,z] = cut_mask_on_exclude_polygon(x,y,msk,xy_ex);
            else
                warning('excludepolygon is empty')
            end            
        end
    end
    
else
   warning('No options to determine active grid are selected') 
end

% update z based on final msk > important for 'find_surrounding_points'

z(msk==0) = NaN;

disp('Info - finished determine active grid')
    
%% 2. Determine msk=1/2/3 values for boundary cells (closed/waterlevel/outflow)
disp('Info - start determine boundary cells')

if count_boundarycells > 0

    % Determine boundary cells
    msk_ids_edge = find_surrounding_points(msk, z);
    
    disp([' Msk values at boundary cells changed using zlev_polygon = ',num2str(zlev_polygon)])    
    
    % now start using polygons or backwards compatible version
    for ii = 1:count_boundarycells %use order as defined in varargin to do this
        if strcmp(varargin_boundarycells(ii).action, 'closedboundarypolygon')
            
            if ~isempty(xy_bnd_closed)
                msk = replace_boundary_cells_closed(x,y,msk,msk_ids_edge,xy_bnd_closed); %closed boundaries is independent of zlev_polygon on purpose!            
            else
                warning('closedboundarypolygon is empty')
            end               
            
        elseif strcmp(varargin_boundarycells(ii).action, 'waterlevelboundarypolygon')

            if ~isempty(xy_bnd_waterlevel)
                msk = replace_boundary_cells_waterlevel(x,y,msk,msk_ids_edge,z,xy_bnd_waterlevel,zlev_polygon);
            else
                warning('waterlevelboundarypolygon is empty')
            end                
            
        elseif strcmp(varargin_boundarycells(ii).action, 'outflowboundarypolygon')

            if ~isempty(xy_bnd_outflow)
                msk = replace_boundary_cells_outflow(x,y,msk,msk_ids_edge,z,xy_bnd_outflow,zlev_polygon);
            else
                warning('outflowboundarypolygon is empty')
            end         
            
        elseif strcmp(varargin_boundarycells(ii).action, 'backwards_compatible')

            msk = replace_boundary_cells_backwardscompatible(msk,msk_ids_edge);
            
        end                
    end
else
   warning('No options to determine boundary cells are selected')     
end

disp('Info - finished determine boundary cells')

%% 3. Finalize
disp('Debug - finished sfincs_make_mask_advanced')

%% X. Supporting functions - activegrid

function [msk, z] = cut_mask_on_elevation(msk, z, zlev)
    disp('Debug - call cut_mask_on_elevation')
    
    % Remove points below zlev(1)
    z(z<zlev(1)) = NaN;

    % Remove points above zlev(2)
    z(z>zlev(2)) = NaN;    
    
    % Set values in mask to 1 where z~=NaN 
    msk(~isnan(z)) = 1;

    disp('Debug - finished cut_mask_on_elevation')    
end

function [msk] = cut_mask_on_include_polygon(x,y,msk,xy_poly)
    disp('Debug - call cut_mask_on_include_polygon')

    msk_ids = inpolygon_to_grid(x,y,xy_poly); %in & on are included by as standard
    
    msk(msk_ids) = 1;    
    
    disp('Debug - finished cut_mask_on_include_polygon')    
end

function [msk,z] = cut_mask_on_exclude_polygon(x,y,msk,xy_poly)
    disp('Debug - call cut_mask_on_exclude_polygon')

    msk_ids = inpolygon_to_grid(x,y,xy_poly); %in & on are included by as standard
    
    z(msk_ids) = NaN;
    msk(msk_ids) = 0;

    disp('Debug - finished cut_mask_on_include_polygon')    
end

%% XX. Supporting functions - boundarycells
function msk_ids_edge = find_surrounding_points(msk, z)
    disp('  Debug - call find_surrounding_points')

    % Find any surrounding points that have a NaN value    
    msk_ids_edge = zeros(size(msk));

    imax=size(z,1);
    jmax=size(z,2);

    % Left
    iside=1;
    ii1a(iside)=1;
    ii2a(iside)=imax;
    jj1a(iside)=1;
    jj2a(iside)=jmax-1;
    ii1b(iside)=1;
    ii2b(iside)=imax;
    jj1b(iside)=2;
    jj2b(iside)=jmax;
    % Right
    iside=2;
    ii1a(iside)=1;
    ii2a(iside)=imax;
    jj1a(iside)=2;
    jj2a(iside)=jmax;
    ii1b(iside)=1;
    ii2b(iside)=imax;
    jj1b(iside)=1;
    jj2b(iside)=jmax-1;
    % Bottom
    iside=3;
    ii1a(iside)=1;
    ii2a(iside)=imax-1;
    jj1a(iside)=1;
    jj2a(iside)=jmax;
    ii1b(iside)=2;
    ii2b(iside)=imax;
    jj1b(iside)=1;
    jj2b(iside)=jmax;
    % Top
    iside=4;
    ii1a(iside)=2;
    ii2a(iside)=imax;
    jj1a(iside)=1;
    jj2a(iside)=jmax;
    ii1b(iside)=1;
    ii2b(iside)=imax-1;
    jj1b(iside)=1;
    jj2b(iside)=jmax;

    % Find points with neighboring NaN value and set mask for these points to 2
    for iside=1:4
        zb=z(ii1a(iside):ii2a(iside),jj1a(iside):jj2a(iside));     % bed level of neighbour
        zc=z(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));     % bed level cell itself
        mskc=msk_ids_edge(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside)); % original mask of cell itself
        ibnd= isnan(zb) & ~isnan(zc);                              % if bed level of cell itself is not nan and the neighbour's is, we have a boundary point
        mskc(ibnd)=true;
        msk_ids_edge(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside))=mskc;
    end

    msk_ids_edge = logical(msk_ids_edge);
    
    disp('  Debug - finished find_surrounding_points')    
end

function msk = replace_boundary_cells_closed(x,y,msk,msk_ids_edge,xy_poly)
    disp('Debug - call replace_boundary_cells_closed')
    
    msk_ids = inpolygon_to_grid(x,y,xy_poly); %in & on are included by as standard

    msk_ids_closed = msk_ids_edge == true & msk_ids == true;

    msk(msk_ids_closed) = 1;

    disp('Debug - finished replace_boundary_cells_closed')    
end
   
function msk = replace_boundary_cells_waterlevel(x,y,msk,msk_ids_edge,z,xy_poly,zlev_polygon)
    disp('Debug - call replace_boundary_cells_waterlevel')
    
    msk_ids = inpolygon_to_grid(x,y,xy_poly); %in & on are included by as standard

    zlev_polygon_ids = z <= zlev_polygon; %only set to msk=2 if below/equal elevation of zlev_polygon (default is 5m)
    
    msk_ids_waterlevel = msk_ids_edge == true & msk_ids == true & zlev_polygon_ids == true;

    msk(msk_ids_waterlevel) = 2;

    disp('Debug - finished replace_boundary_cells_waterlevel')    
end

function msk = replace_boundary_cells_outflow(x,y,msk,msk_ids_edge,z,xy_poly,zlev_polygon)
    disp('Debug - call replace_boundary_cells_outflow')
    
    msk_ids = inpolygon_to_grid(x,y,xy_poly); %in & on are included by as standard

    zlev_polygon_ids = z > zlev_polygon; %only set to msk=3 if above elevation of zlev_polygon (default is 5m)
    
    msk_ids_outflow = msk_ids_edge == true & msk_ids == true & zlev_polygon_ids == true;

    msk(msk_ids_outflow) = 3;

    disp('Debug - finished replace_boundary_cells_outflow')    
end

function msk = replace_boundary_cells_backwardscompatible(msk,msk_ids_edge)
    disp('Debug - call replace_boundary_cells_backwardscompatible')
    
    msk(msk_ids_edge) = 2; % as in old version of sfincs_make_mask.m where all boundary cells are set to msk=2

    disp('Debug - finished replace_boundary_cells_backwardscompatible')    
end


%% XXX. Supporting functions - general
function msk_ids = inpolygon_to_grid(x,y,xy_poly)
    disp('  Debug - call inpolygon_to_grid')
    
    if ~isempty(xy_poly)
        msk_ids = zeros(size(x));    

        for ip=1:length(xy_poly) % can be multiple polygons
            if length(xy_poly(ip).x)>1

                xp=xy_poly(ip).x;
                yp=xy_poly(ip).y;

                [msk_ids_tmp,~] = inpolygon(x,y,xp,yp);    

                msk_ids = max(msk_ids,msk_ids_tmp);  
            end
        end
        msk_ids = logical(msk_ids);

    end
    disp('  Debug - finished inpolygon_to_grid')
end

end
