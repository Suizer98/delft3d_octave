function [buq1,msk,zb1]=buq_make_mask(buq0,zb0,varargin)

nb=length(buq0.n);

buq1=buq0;
msk=zeros(16,16,nb);
zb1=zb0;

pol_include=[];
pol_exclude=[];

include_polygon='';
exclude_polygon='';
open_polygon='';
outflow_polygon='';
zmin=-99999.0;
zmax= 99999.0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'zmin'}
                zmin=varargin{ii+1};
            case{'zmax'}
                zmax=varargin{ii+1};
            case{'include_polygon'}
                include_polygon=varargin{ii+1};
            case{'exclude_polygon'}
                exclude_polygon=varargin{ii+1};
        end
    end    
end

ib1=0;

for ib0=1:nb
    
    zbb=squeeze(zb0(:,:,ib0));
    zbb(:,1)=NaN;
    zbb(1,:)=NaN;
    
    [xz,yz]=buq_get_cell_coordinates(buq0,ib0);
    
    % Check if cells are in include polygon
    mskc = zeros(16,16);
    mskc(zbb>zmin & zbb<zmax)=1;

    % Include points inside include polygon
    if ~isempty(pol_include)
        inp=inpolygon(xz,yz,pol_include.x,pol_include.y);
        mskc(inp)=1;
    end

    % Exclude points inside exclude polygon
    if ~isempty(pol_exclude)
        inp=inpolygon(xz,yz,pol_exclude.x,pol_exclude.y);
        mskc(inp)=0;
    end
        
    % But points that do not have an elevation are excluded
    mskc(isnan(zbb))=0;
    
    if max(max(mskc))>0
        % Active cells in this block
        ib1=ib1+1;
        buq1.level(ib1)=buq0.level(ib0);
        buq1.n(ib1)=buq0.n(ib0);
        buq1.m(ib1)=buq0.m(ib0);
        msk(:,:,ib1)=mskc;
        zb1(:,:,ib1)=zb0(:,:,ib0);
    end
        
end

buq1.level=buq1.level(1:ib1);
buq1.n=buq1.n(1:ib1);
buq1.m=buq1.m(1:ib1);
msk=msk(:,:,1:ib1);
zb1=zb1(:,:,1:ib1);
