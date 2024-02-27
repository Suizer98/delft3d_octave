function varargout = particle_tracker(X_locs_grid,Y_locs_grid,X_vel_grid,Y_vel_grid,X_locs_trac,Y_locs_trac,varargin);
%
% particle_tracker   Used for tracking particles in an (ir)regular flow field:
%
%[<X_p_new> <Y_p_new> <P_age_new>] = particle_tracker(X,Y,U,V,X_p,Y_p,<keyword>,<value>,<'quiet'>)';
%
%  particle_tracker computes the new locations of particles from the old
%  locations (X_p and Y_p), based on the supplied flow field (X,Y,U,V) in
%  combination with the 'inverse distance weighting' 2D interpolation procedure.
%  New particles are added if the total number of particles is less than a
%  maximum number (default = 100). Particles will dissapear when flowing
%  out of the domain (default is X_min <--> X_max and Y_min <--> Y_max,
%  but a polygon can also be specified) or when they decay over time (this
%  decay time is set to Inf by default, see the optional keywords below).
%  Finally, some 'inverse distance weighting' settings can be specified, as
%  well as some other parameters (see below).
%
%
%       REQUIRED INPUT VARIABLES
%
%   X      : Vector [1xN] or [Nx1] of X-locations where flow field is known
%   Y      : Vector [1xN] or [Nx1] of Y-locations where flow field is known
%   U      : Vector [1xN] or [Nx1] of flow component U (in X-direction)
%   V      : Vector [1xN] or [Nx1] of flow component V (in Y-direction)
%   X_p    : Vector [1xM] or [Mx1] of X-locations of tracking particles
%   Y_p    : Vector [1xM] or [Mx1] of X-locations of tracking particles
%
%           Where N and M should be at least 1 (though N>2 is advised)
%           The X_p and Y_p vectors can contain NaN's. This indicates that
%           no particle is specified for this indice.
%
%
%       OUTPUT VARIABLES (Note that these are all optional and can also be
%                         specified with 0, 1, 2 or 3 output variables, all
%                         combinations are possible and will supply the 
%                         results as 'intuitively' expected, as indicated
%                         here is an advised format)
%
%   X_p_new  : Variable name for the new X-locations of tracking particles
%   Y_p_new  : Variable name for the new Y-locations of tracking particles
%   P_age_new: Variable for specifying the new age (in steps) of each 
%              tracking particle, sized [Mx1]*
%
%      * This output variable can only be used 
%        when the keyword 'track age' is used.
%
%
%       OPTIONAL INPUT KEYWORDS AND VARIABLES
%
%   ...,'polygon',VAR,...        : Only the area inside the 'polygon' will 
%                                  spawn tracking particles. VAR should be
%                                  a [2xK] or [Kx2] matrix containing [X,Y]
%                                  values. K should be at least 3 (while 
%                                  defining an area, else a while loop will
%                                  never comply its final statement)
%
%   ...,'track age',VAR,...      : 'track age' activates the age option for
%                                  each tracking particle. VAR is a vector
%                                  [1xM] or [Mx1] containing the 'age' of
%                                  each particle (in steps). When
%                                  activating this option, it is advised to
%                                  define 'max track age' as well, though it
%                                  will use the default amount (100 steps)
%
%   ...,'max track age',VAR,...  : 'max track age' specifies the maximum age
%                                  (in steps) for each particle for when it
%                                  will decay. VAR should be a single
%                                  value. Note that 'max track age' can only
%                                  be used if the 'track age' keyword is
%                                  specified as well.
%
%   ...,'max num parts',VAR,...  : 'max num parts' specifies the maximum
%                                  number of particles, it overrules the
%                                  specified X_p and Y_p vectors. If they
%                                  are too small, NaN's are added. If they
%                                  are too large, indices are deleted to
%                                  end up with an ['max num parts'x1]
%                                  vector. VAR should be a single value,
%                                  valued at at least 1.
%
%   ...,'power parameter',VAR,...: 'power parameter' specifies the power
%                                  parameter p as used in the 'Inverse
%                                  distance weighting' irregular 2D
%                                  interpolation procedure. VAR should be a
%                                  single value not smaller than 2 (2 is
%                                  advised and default). Nearby values get 
%                                  a higher weighting for larger 
%                                  power parameter values, thus less
%                                  smoothing for larger values, see also
%                                  http://en.wikipedia.org/wiki/Inverse_distance_weighting
%
%   ...,'num interp pts',VAR,... : 'num interp pts' specifies the number of
%                                  nearest points to be used in the
%                                  interpolation procedure. VAR should be a
%                                  single integer. The default value is 4,
%                                  but all integers from 1 to N are
%                                  allowed. Note that 'num interp pts' = 1
%                                  simply uses the velocities of the
%                                  nearest point. Note that 'num interp
%                                  pts' = 3 is probably preferred for 
%                                  triangular meshes, while 'num interp
%                                  pts' = 4 is probably more appropriate
%                                  for curvilinear/quadrangle type meshes.
%                                  Though overall, the interpolation
%                                  procedure should work properly for 'num
%                                  interp pts' values from 3 up.
%  
%   ...,'trac factor',VAR,...    : 'trac factor' specifies a factor that
%                                  translates flow velocities to a viewable
%                                  change in distance on the spatial
%                                  coordinate system. The default value is
%                                  computed by assuming a velocity of 1
%                                  over the diagonal of X_min <--> X_max 
%                                  and Y_min <--> Y_max. Given the
%                                  trac factor, a particle will move over
%                                  this diagonal in 100 steps (with
%                                  velocity 1). VAR should be a single
%                                  value [-]. Note that this trac factor
%                                  works for all local, UTM & GEO etc.
%                                  coordinate systems. Please avoid
%                                  grid-cell extrapolation in each function
%                                  call.
%
%   ...,'growth factor',VAR,...  : 'growth factor' specifies the number of
%                                  tracking particles that will spawn 
%                                  within one function call. A
%                                  growth factor of 0.1 will add a maximum 
%                                  of 10% of the maximum number of tracking
%                                  particles. VAR should be a single value
%                                  anywhere from 0 to 1. Particles will
%                                  only spawn if NaN's are present in the
%                                  X_p and Y_p vectors.
%
%   ...,'quiet');                : Use this closing keyword to suppress all
%                                  messages within the function. Note that
%                                  these messages will indicate some
%                                  default values and some computed
%                                  variables. It is advised to call this
%                                  keyword when calling particle_tracker
%                                  within a loop, to prevent the command
%                                  window to get flooded. Note that the
%                                  'quiet' keyword can only be added at the
%                                  end of all input variables.
%
%
%       NUMERICAL REMARK
%
%
%  particle_tracker computes the new locations of the particles at
%  locations X_p and Y_p from the flow field U, V at X, Y. It uses the
%  inverse distance weighting approach, with a specified number of nearest
%  points (default 4) used for each particle. For more information on this
%  approach, refer to http://en.wikipedia.org/wiki/Inverse_distance_weighting
%  Note that the trac factor is used to translate the flow velocities to a
%  viewable change in distance on the spatial coordinate system. Please be
%  aware that this factor can result in siginificant errors when particles
%  get 'transported' over multiple grid cells in one function call. As we
%  are dealing with linear extrapolation from the start point of each
%  tracking particle.
%
% |
% |       EXAMPLE
% |__(1)___________________________________________________________________
% X_locs      = reshape(repmat(0:10,11,1),[],1);
% Y_locs      = reshape(repmat([0:10]',1,11),[],1);
% 
% X_vel_grid  = rand(121,1);
% Y_vel_grid  = rand(121,1);
% 
% X_locs_trac = nan(100,1);
% Y_locs_trac = nan(100,1);
% 
% polygon     = [1,1;3,9;5,6;8,9;9,1;1,1];
% 
% for ii=1:1000
%     [X_locs_trac Y_locs_trac] = particle_tracker(X_locs,Y_locs,...
%                                                  X_vel_grid,Y_vel_grid,...
%                                                  X_locs_trac,Y_locs_trac,...
%                                                  'polygon',polygon,...
%                                                   'quiet');
%     eval(['p' num2str(ii) ' = plot(X_locs_trac,Y_locs_trac,''r.'');']);
%     if ii>1
%         delete(eval(['p' num2str(ii-1)])); clear(['p' num2str(ii-1)]);
%     else
%         hold on;
%         plot(polygon(:,1),polygon(:,2),'k');
%         set(gca,'xlim',[0 10],'ylim',[0 10]);
%     end
%     drawnow;
% end
%
% |
% |       EXAMPLE
% |__(2)___________________________________________________________________
% X_locs      = reshape(repmat(0:10,11,1),[],1);
% Y_locs      = reshape(repmat([0:10]',1,11),[],1);
% 
% X_vel_grid  = -sin(2*pi.*Y_locs./10);
% Y_vel_grid  = sin(2*pi.*X_locs./10);
% 
% X_locs_trac = nan(100,1);
% Y_locs_trac = nan(100,1);
% trac_age    = nan(100,1);
% 
% for ii=1:1000
%     [X_locs_trac Y_locs_trac trac_age] = particle_tracker(X_locs,Y_locs,...
%                                                  X_vel_grid,Y_vel_grid,...
%                                                  X_locs_trac,Y_locs_trac,...
%                                                  'track age',trac_age,...
%                                                  'max track age',50,...
%                                                  'max num parts',100,...
%                                                  'power parameter',2,...
%                                                  'trac factor',0.1,...
%                                                  'growth factor',0.2,...
%                                                  'num interp pts',5,...
%                                                  'quiet');
%     eval(['p' num2str(ii) ' = plot(X_locs_trac,Y_locs_trac,''r.'');']);
%     if ii>10
%         delete(eval(['p' num2str(ii-10)])); clear(['p' num2str(ii-10)]);
%     else
%         hold on;
%         set(gca,'xlim',[0 10],'ylim',[0 10]);
%     end
%     drawnow;
% end
%
% See also: curvec, inpolygon, dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Freek Scheel
%
%       <Freek.Scheel@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Do some input data checks and transpose to [N 1] from [1 N] if needed
%
if isvector(X_locs_grid)
    if size(X_locs_grid,1)==1
        X_locs_grid = X_locs_grid';
    end
    if size(X_locs_grid,1) < 4
        error('Input vector of X-values should have at least 4 points');
    end
else
    error('Input of X-values for the known locations is not a vector');
end

if isvector(Y_locs_grid)
    if size(Y_locs_grid,1)==1
        Y_locs_grid = Y_locs_grid';
    end
    if size(Y_locs_grid,1) < 4
        error('Input vector of Y-values should have at least 4 points');
    end
else
    error('Input of Y-values for the known locations is not a vector');
end

if isvector(X_vel_grid)
    if size(X_vel_grid,1)==1
        X_vel_grid = X_vel_grid';
    end
    if size(X_vel_grid,1) < 4
        error('Input vector of X-velocities should have at least 4 points');
    end
else
    error('Input of X-velocities at known locations is not a vector');
end

if isvector(Y_vel_grid)
    if size(Y_vel_grid,1)==1
        Y_vel_grid = Y_vel_grid';
    end
    if size(Y_vel_grid,1) < 4
        error('Input vector of Y-velocities should have at least 4 points');
    end
else
    error('Input of Y-velocities at known locations is not a vector');
end

if isvector(X_locs_trac)
    if size(X_locs_trac,1)==1
        X_locs_trac = X_locs_trac';
    end
else
    error('Input of X-locations of trackers is not a vector');
end

if isvector(Y_locs_trac)
    if size(Y_locs_trac,1)==1
        Y_locs_trac = Y_locs_trac';
    end
else
    error('Input of Y-locations of trackers is not a vector');
end

if ~(isequal(size(X_locs_grid),size(Y_locs_grid)) & isequal(size(Y_locs_grid),size(X_vel_grid)) & isequal(size(X_vel_grid),size(Y_vel_grid)))
    error('Not all vectors of input (locations and currents) have the same length');
end

if ~isequal(size(X_locs_trac),size(Y_locs_trac))
    error('Not all vectors of tracker point locations have the same length');
end


%% Check all keywords and set some variables
%
if size(varargin,2) ~= 0
    used_keywords = varargin(1,[1:2:size(varargin,2)])';
else
    used_keywords = 'nothing specified';
end
keywords_assigned = 0;

if strcmp(used_keywords(end,1),'quiet')==1
    quiet_on = 1;
    keywords_assigned = keywords_assigned + 1;
else
    quiet_on = 0;
end

if sum(strcmp(used_keywords,'polygon'))==1
    keywords_assigned = keywords_assigned + 1;
    pol_ind = (((find(strcmp(used_keywords,'polygon')==1)-1)*2)+1);
    polygon = varargin{1,pol_ind+1};
    if min(size(polygon))>1
        if size(polygon,1)==2 & size(polygon,2)>2
            polygon = polygon';
        elseif size(polygon,1)>2 & size(polygon,2)==2
            % Polygon is correct
        else
            error('Polygon should have at least 3 points...');
        end
    else
        error('Polygon should have at least 3 points...');
    end
elseif sum(strcmp(used_keywords,'polygon'))>1
    error('Keyword ''polygon'' is found more than once');
else % No polygon specified    
    polygon = [min(min(X_locs_grid)) min(min(Y_locs_grid)); min(min(X_locs_grid)) max(max(Y_locs_grid)); max(max(X_locs_grid)) max(max(Y_locs_grid)); max(max(X_locs_grid)) min(min(Y_locs_grid))];
end

if sum(strcmp(used_keywords,'track age'))==1
    keywords_assigned = keywords_assigned + 1;
    trac_age_ind = (((find(strcmp(used_keywords,'track age')==1)-1)*2)+1);
    trac_age = varargin{1,trac_age_ind+1};
    if isvector(trac_age)
        if size(trac_age,1)==1
            trac_age = trac_age';
        end
        if size(trac_age,1)~=size(X_locs_trac,1)
            error('The trac age vector should have the same length as the number of tracking points');
        end        
    else
        error('track age contents should be a vector...');
    end
elseif sum(strcmp(used_keywords,'track age'))>1
    error('Keyword ''track age'' is found more than once');
else % No track age specified  
    trac_age_ind = 0;
end

if sum(strcmp(used_keywords,'max track age'))==1
    keywords_assigned = keywords_assigned + 1;
    max_trac_age_ind = (((find(strcmp(used_keywords,'max track age')==1)-1)*2)+1);
    max_trac_age = varargin{1,max_trac_age_ind+1};
    if max(size(max_trac_age))~=1 | ~isfloat(max_trac_age)
        error('Maximum tracker age (steps) should be one number');
    end
    if trac_age_ind == 0;
        error('max track age is supplied, but no trac_age array is given');
    end
elseif sum(strcmp(used_keywords,'max track age'))>1
    error('Keyword ''max track age'' is found more than once');
else % No max track age specified  
    if trac_age_ind ~= 0
        if quiet_on == 0;
            disp(' ');
            disp('No max track age is supplied, but a track age vector is supplied');
            disp('Therefore, we use a default value of 100 steps');
        end
        max_trac_age = 100;
    end
end

if sum(strcmp(used_keywords,'max num parts'))==1
    keywords_assigned = keywords_assigned + 1;
    max_no_parts_ind = (((find(strcmp(used_keywords,'max num parts')==1)-1)*2)+1);
    max_no_parts = varargin{1,max_no_parts_ind+1};
    if max(size(max_no_parts))~=1 | ~isfloat(max_no_parts)
        error('Maximum number of particles should be one number');
    elseif max_no_parts<1
        error('At least one particle should be tracked');
    end
    if max_no_parts==size(X_locs_trac,1)
        % Do nothing;
    elseif max_no_parts>size(X_locs_trac,1)
        old_size = size(X_locs_trac,1);
        X_locs_trac((old_size+1):max_no_parts,1)=NaN;
        Y_locs_trac((old_size+1):max_no_parts,1)=NaN;
        if trac_age_ind~=0
            trac_age((old_size+1):max_no_parts,1)=NaN;
        end
    elseif max_no_parts<size(X_locs_trac,1)
        X_locs_trac = X_locs_trac(1:max_no_parts,1);
        Y_locs_trac = Y_locs_trac(1:max_no_parts,1);
        if trac_age_ind~=0
            trac_age = trac_age(1:max_no_parts,1);
        end
    end
elseif sum(strcmp(used_keywords,'max num parts'))>1
    error('Keyword ''max num parts'' is found more than once');
else % No max num parts specified
    if quiet_on == 0;
        disp(' ');
        disp('No max maximum number of particles is supplied');
        disp(['Therefore, we use the number of specified particles (' num2str(size(X_locs_trac,1)) ')']);
    end
    max_no_parts = size(X_locs_trac,1);
end

if sum(strcmp(used_keywords,'power parameter'))==1
    keywords_assigned = keywords_assigned + 1;
    power_param_ind = (((find(strcmp(used_keywords,'power parameter')==1)-1)*2)+1);
    power_param = varargin{1,power_param_ind+1};
    if max(size(power_param))~=1 | ~isfloat(power_param)
        error('Power parameter should be one number, preferably 2 (or larger)');
    end
    if quiet_on == 0;
        if power_param < 2
            disp(' ');
            disp('It is preffered to use a power parameter of 2 (or larger)');
        elseif power_param > 2
            disp(' ');
            disp('Note that increasing the power parameter larger than 2 results in nearby points weighting more');
        end
    end
elseif sum(strcmp(used_keywords,'power parameter'))>1
    error('Keyword ''power parameter'' is found more than once');
else % No power parameter specified
    % Power parameter for inverse weighting interpolation
    if quiet_on == 0;
        disp(' ');
        disp('No power parameter is supplied');
        disp('Therefore, we use the default value 2');
    end
    power_param = 2;
end

if sum(strcmp(used_keywords,'num interp pts'))==1
    keywords_assigned = keywords_assigned + 1;
    num_interp_pts_ind = (((find(strcmp(used_keywords,'num interp pts')==1)-1)*2)+1);
    num_interp_pts = varargin{1,num_interp_pts_ind+1};
    if max(size(num_interp_pts))~=1 | ~isfloat(num_interp_pts)
        error('Number of interpolation points should be one number');
    end
    if num_interp_pts<3
        if quiet_on == 0;
            disp(' ');
            disp('Please be aware that interpolating with less than 3 points is not advised');
        end
    end
elseif sum(strcmp(used_keywords,'num interp pts'))>1
    error('Keyword ''num interp pts'' is found more than once');
else % No num interp pts specified
    % num interp pts for inverse weighting interpolation
    if quiet_on == 0;
        disp(' ');
        disp('No num interp pts is supplied');
        disp('Therefore, we use the default value 4');
    end
    num_interp_pts = 4;
end

if sum(strcmp(used_keywords,'trac factor'))==1
    keywords_assigned = keywords_assigned + 1;
    trac_factor_ind = (((find(strcmp(used_keywords,'trac factor')==1)-1)*2)+1);
    trac_factor = varargin{1,trac_factor_ind+1};
    if max(size(trac_factor))~=1 | ~isfloat(trac_factor)
        error('trac factor should be one number');
    end
    if quiet_on == 0;
        disp(' ');
        disp('Manually specified a track factor');
    end
elseif sum(strcmp(used_keywords,'trac factor'))>1
    error('Keyword ''trac factor'' is found more than once');
else % No trac factor specified
    trac_factor = ((sqrt((diff([min(polygon(:,1)) max(polygon(:,1))])^2)+(diff([min(polygon(:,2)) max(polygon(:,2))])^2)))/100);
    if quiet_on == 0;
        disp(' ');
        disp(['Trac factor was determined manually to be ' num2str(trac_factor,'%3.3f')]);
        disp('This works for either local X,Y, geo or UTM zones');
    end
end

if sum(strcmp(used_keywords,'growth factor'))==1
    keywords_assigned = keywords_assigned + 1;
    growth_factor_ind = (((find(strcmp(used_keywords,'growth factor')==1)-1)*2)+1);
    growth_factor = varargin{1,growth_factor_ind+1};
    if max(size(growth_factor))~=1 | ~isfloat(growth_factor)
        error('growth factor should be one number');
    end
    if growth_factor<0 | growth_factor>1
        if quiet_on == 0;
            disp(' ');
            disp('Growth factor is outside valid domain (0 to 1)');
            disp('Therefore, set to default value 0.1');
        end
        growth_factor = 0.1;
    end        
    if quiet_on == 0;
        disp(' ');
        disp('Manually specified a growth factor');
    end
elseif sum(strcmp(used_keywords,'growth factor'))>1
    error('Keyword ''growth factor'' is found more than once');
else % No growth factor specified
    if quiet_on == 0;
        disp(' ');
        disp('growth factor is set to default of 10% (0.1)');
    end
    growth_factor = 0.1;
end

%% Some final checks
%
if strcmp(used_keywords,'nothing specified')
    keywords_assigned = keywords_assigned + 1;
end

if keywords_assigned < size(used_keywords,1)
    if (size(used_keywords,1)-keywords_assigned) > 1
        error([num2str(size(used_keywords,1)-keywords_assigned) ' invalid keywords were used, please check your spelling using the help']);
    elseif (size(used_keywords,1)-keywords_assigned) == 1
        error([num2str(size(used_keywords,1)-keywords_assigned) ' invalid keyword was used, please check your spelling using the help']);
    else
        error('error');
    end
end

if round(num_interp_pts)>size(X_locs_grid,1)
    error(['The number of interpolation points (' num2str(round(num_interp_pts)) ') is smaller than the number of available points (' num2str(size(X_locs_grid,1)) ')']);
end

%% Final function computations:

% For each tracker (ii), compute the new location of the tracker *_new
for ii=1:size(X_locs_trac,1)
	% Only do this for non-NaN values
	if ~isnan(X_locs_trac(ii,1)) | ~isnan(Y_locs_trac(ii,1));
        cur_dist_all    = sqrt(((X_locs_grid-X_locs_trac(ii,1)).^2)+((Y_locs_grid-Y_locs_trac(ii,1)).^2));
        cur_dist_sort   = sortrows([cur_dist_all [1:size(cur_dist_all,1)]'],1);
        inds            = round(cur_dist_sort(1:round(num_interp_pts),2));
        % Only do this with a minimum distance to a point larger than 0
        if min(cur_dist_all(inds))~=0
            X_locs_trac_new(ii,1) = X_locs_trac(ii,1) + trac_factor * (sum((1./((cur_dist_all(inds)).^power_param)).*(X_vel_grid(inds)))/(sum(1./((cur_dist_all(inds)).^power_param))));
            Y_locs_trac_new(ii,1) = Y_locs_trac(ii,1) + trac_factor * (sum((1./((cur_dist_all(inds)).^power_param)).*(Y_vel_grid(inds)))/(sum(1./((cur_dist_all(inds)).^power_param))));
        else % else just use the point it lies on top on (no interpolation needed)
            zero_ind = find(cur_dist_all(inds)==min(cur_dist_all(inds)));
            X_locs_trac_new(ii,1) = X_locs_trac(ii,1) + trac_factor * X_vel_grid(inds(zero_ind,1));
            Y_locs_trac_new(ii,1) = Y_locs_trac(ii,1) + trac_factor * Y_vel_grid(inds(zero_ind,1));
        end
    else % Make sure that 1 NaN is also NaN's for 1+1
        X_locs_trac_new(ii,1) = NaN;
        Y_locs_trac_new(ii,1) = NaN;
        if trac_age_ind~=0
            trac_age(ii,1)    = NaN;
        end
    end
end


if trac_age_ind~=0
    trac_age_new = trac_age+1;
    % First remove all trackers lasting longer than max steps (max track age)
    if size(find(trac_age_new>=max_trac_age),1)>0
        X_locs_trac_new(find(trac_age_new>=max_trac_age),1)=NaN;
        Y_locs_trac_new(find(trac_age_new>=max_trac_age),1)=NaN;
        trac_age_new(find(trac_age_new>=max_trac_age),1)=NaN;
    end
end

% Now remove all tracers outside the polygon (or min/max area)
if (sum(~inpolygon(X_locs_trac_new,Y_locs_trac_new,polygon(:,1),polygon(:,2)))-(sum(isnan(X_locs_trac_new))))>0
	inds_rem = find(~inpolygon(X_locs_trac_new,Y_locs_trac_new,polygon(:,1),polygon(:,2))==1);
	X_locs_trac_new(inds_rem,1) = NaN;
	Y_locs_trac_new(inds_rem,1) = NaN;
	trac_age_new(inds_rem,1)    = NaN;
end

% Add new tracers when locations(and trac_age) are set to NaN
if sum(isnan(X_locs_trac_new))>0
	additional_vel_points = min([sum(isnan(X_locs_trac_new)) ceil(growth_factor*max_no_parts)]);
	if additional_vel_points>0
        add_inds              = find(isnan(X_locs_trac_new)==1,additional_vel_points);
        new_points = [];
        while size(new_points,1)~=additional_vel_points
            tmp_X_new = min(polygon(:,1))+(diff([min(polygon(:,1)) max(polygon(:,1))])*rand(1,1));
            tmp_Y_new = min(polygon(:,2))+(diff([min(polygon(:,2)) max(polygon(:,2))])*rand(1,1));
            if inpolygon(tmp_X_new,tmp_Y_new,polygon(:,1),polygon(:,2)) == 1;
                new_points(size(new_points,1)+1,1:2) = [tmp_X_new tmp_Y_new];
            end
        end
        X_locs_trac_new(add_inds,1)  = new_points(:,1);
        Y_locs_trac_new(add_inds,1)  = new_points(:,2);
        if trac_age_ind~=0
            trac_age_new(add_inds,1) = ones(additional_vel_points,1);
        end
    end
end

%% Make output according to number of output variables supplied
%

if nargout == 0
    disp(' ');
    if trac_age_ind == 0;
        disp('[X_p_new Y_p_new]');
        disp(' ');
        disp([X_locs_trac_new Y_locs_trac_new]);
    elseif trac_age_ind ~= 0;
        disp('[X_p_new Y_p_new P_age_new]');
        disp(' ');
        disp([X_locs_trac_new Y_locs_trac_new trac_age_new]);
    end
    disp(' ');
    disp('Note that these variables are not saved (also not in ans), since no output variable names were specified ');
end

if nargout == 1
    if trac_age_ind == 0;
        varargout{1} = [X_locs_trac_new Y_locs_trac_new];
    elseif trac_age_ind ~= 0;
        varargout{1} = [X_locs_trac_new Y_locs_trac_new trac_age_new];
    end
end

if nargout == 2
    if trac_age_ind == 0;
        varargout{1} = X_locs_trac_new;
        varargout{2} = Y_locs_trac_new;
    elseif trac_age_ind ~= 0;
        varargout{1} = [X_locs_trac_new Y_locs_trac_new];
        varargout{2} = trac_age_new;
    end
end

if nargout == 3
    if trac_age_ind ~= 0;
        varargout{1} = X_locs_trac_new;
        varargout{2} = Y_locs_trac_new;
        varargout{3} = trac_age_new;
    elseif trac_age_ind == 0;
        varargout{1} = X_locs_trac_new;
        varargout{2} = Y_locs_trac_new;
        varargout{3} = 'No particle tracking age used, specify with the keyword ''track age''';
        if quiet_on == 0;
            disp('When using 3 ouput variables, please use the keyword ''track age'' as well');
            disp('or simply remove the third output variable');
        end
    end
end

if nargout>3
    error('Please use a maximum of 3 output variables');
end

if quiet_on == 0;
    disp(' ');
    disp('Please use the keyword ''quiet'' at the end of all keywords to suppres these messages');
    disp('Resort to ''help particle_tracker'' for more information');
end

end