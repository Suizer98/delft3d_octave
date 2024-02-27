function msk=hurrywave_make_mask(x,y,z,zlev,varargin)
% Leijnse april 18: included option to exclude points via polygon input

xy_in=[];
xy_ex=[];
xy_bnd_closed=[];
xy_bnd_out=[];
zlev_bnd=[];
mask0=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'zlev_bnd'}
                zlev_bnd=varargin{ii+1};
            case{'includepolygon'}
                xy_in=varargin{ii+1};
            case{'excludepolygon'}
                xy_ex=varargin{ii+1};
            case{'closedboundarypolygon'}
                xy_bnd_closed=varargin{ii+1};
            case{'outflowboundarypolygon'}
                xy_bnd_out=varargin{ii+1};
            case{'mask0'}
                mask0=varargin{ii+1};
        end
    end
end


if ~isempty(xy_in)
    % Throw away points below zlev(1), but not points within polygon
    % Do this by temporarily raising these points to zlev(1)+0.01 
    for ip=1:length(xy_in)
        if length(xy_in(ip).x)>1
            %    xp=xy(:,1);
            %    yp=xy(:,2);
            xp=xy_in(ip).x;
            yp=xy_in(ip).y;
            inp=inpolygon(x,y,xp,yp);
            z(inp)=max(z(inp),zlev(1)+0.01);
        end
    end
end

if ~isempty(xy_ex)
    % Throw away points within polygon
    % Do this by temporarily setting these points to NaN
    for ip=1:length(xy_ex)
        if length(xy_ex(ip).x)>1
            %    xp=xy(:,1);
            %    yp=xy(:,2);
            xp=xy_ex(ip).x;
            yp=xy_ex(ip).y;
            exp=inpolygon(x,y,xp,yp);
            z(exp)=NaN;
        end
    end
%     xp_ex=xy_ex(:,1);
%     yp_ex=xy_ex(:,2);
%     inp_ex=inpolygon(x,y,xp_ex,yp_ex);
%     z(inp_ex)=NaN; %max(z(inp),zlev(1)+0.01);
end

% Remove points below zlev(1)
z(z<zlev(1))=NaN;

% Set values in mask to 1 where z~=NaN 
msk=zeros(size(z));
msk(~isnan(z))=1;

% % Larger matrix with two dummy rows
% zex=zeros(size(z,1)+2,size(z,2)+2); 
% zex(zex==0)=NaN;
% zex(2:end-1,2:end-1)=z;

% Boundary points

% Set outer edges of grid to 2 (boundary points)
msk(:,1)=2;
msk(:,end)=2;
msk(1,:)=2;
msk(end,:)=2;

imax=size(msk,1);
jmax=size(msk,2);

% Find any surrounding points that have a NaN value

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
    mskc=msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside)); % original mask of cell itself
    if isempty(zlev_bnd)
        ibnd= isnan(zb) & ~isnan(zc);                              % if bed level of cell itself is not nan and the neighbour's is, we have a boundary point
    else
        ibnd= isnan(zb) & ~isnan(zc) & zc<zlev_bnd;                % if bed level of cell itself is not nan and the neighbour's is, we have a boundary point
    end
    mskc(ibnd)=2;
    msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside))=mskc;
end

% Set boundary points to closed
if ~isempty(xy_bnd_closed)
    % Set msk to 1 inside polygon where it is now 2
    for ip=1:length(xy_bnd_closed)
        if length(xy_bnd_closed(ip).x)>1
            xp=xy_bnd_closed(ip).x;
            yp=xy_bnd_closed(ip).y;
            clsd=inpolygon(x,y,xp,yp);
            msk0=msk(clsd); % original value of mask inside polygon
            msk0(msk0==2)=1; % set to 1
            msk(clsd)=msk0;
        end
    end
end

% Set boundary points to closed
if ~isempty(xy_bnd_out)
    % Set msk to 3 inside polygon where it is now 2
    for ip=1:length(xy_bnd_out)
        if length(xy_bnd_out(ip).x)>1
            xp=xy_bnd_out(ip).x;
            yp=xy_bnd_out(ip).y;
            out=inpolygon(x,y,xp,yp);
            msk0=msk(out); % original value of mask inside polygon
            msk0(msk0==2)=3; % set to 1
            msk(out)=msk0;
        end
    end
end

% % Testing of removing boundary points
% if ~isempty(xy_ex)
%     % Set msk to 1 inside polygon where it is now 2 
%     for ip=1:length(xy_ex)
%         if length(xy_ex(ip).x)>1
%             xp=xy_ex(ip).x;
%             yp=xy_ex(ip).y;
%             inp=inpolygon(x,y,xp,yp);
%             msk0=msk(inp); % original value of mask inside polygon
%             msk0(msk0==2)=1; % set to 1
%             msk(inp)=msk0;
%         end
%     end
% end

if ~isempty(xy_in)
    msk(z>zlev(2)& ~inp)=0; % everything in include polygon we want to keep
else
    msk(z>zlev(2))=0;
end

msk(isnan(z))=0;
%msk0=msk;

% msk_dummy=zeros(size(msk,1)+2, size(msk,2)+2);
% msk_dummy(2:end-1,2:end-1)=msk;
% msk=msk_dummy;
% 
% 
% figure(123)
% %scatter(x,y,10,msk);colorbar;axis equal;
% pcolor(msk);shading flat;colorbar;axis equal;
% 
% msk22=zeros(size(msk,1)+2, size(msk,2)+2);
% % Now for HurryWave, set all msk=0 points that do not have a msk=1 neighbor to -1
% msk22(2:end-1,2:end-1)=msk;
% figure(124)
% %scatter(x,y,10,msk);colorbar;axis equal;
% pcolor(msk22);shading flat;colorbar;axis equal;
% 
% 
% nbl=msk22(2:end-1,1:end-2);
% nbr=msk22(2:end-1,3:end);
% nbb=msk22(1:end-2,2:end-1);
% nbt=msk22(3:end,2:end-1);
% nbs=msk+nbl+nbr+nbb+nbt;
% msk(nbs==0)=-1;
% 
% figure(1234)
% pcolor(msk);shading flat;colorbar;

