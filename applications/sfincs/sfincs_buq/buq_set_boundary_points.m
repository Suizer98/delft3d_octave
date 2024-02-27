function msk=buq_set_boundary_points(buq,msk,zb,varargin)

nb=length(buq.n);
% 
% buq1=buq0;
% msk=zeros(16,16,nb);
% zb1=zb0;

pol_include=[];
pol_exclude=[];
pol_open   =[];
open_polygon='';
outflow_polygon='';
zmin=-99999.0;
zmax= 99999.0;

iii =[ 1 2  3  4  5  6  7  8  9 10 11 12 13 14 15 16];

jjj1=[ 0 2  4  6  8 10 12 14 16  3  5  7  9 11 13 15];
jjj2=[ 0 3  5  7  9 11 13 15  2  4  6  8 10 12 14 16];

kkk1=[ 0 2  2  3  3  4  4  5  5  6  6  7  7  8  8  9];
kkk1=[ 0 9 10 10 11 11 12 12 13 13 14 14 15 15 16 16];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'zmin'}
                zmin=varargin{ii+1};
            case{'zmax'}
                zmax=varargin{ii+1};
            case{'open_polygon'}
                open_polygon=varargin{ii+1};
            case{'outflow_polygon'}
                outflow_polygon=varargin{ii+1};
        end
    end    
end

if ~isempty(open_polygon)
    pol_open=load_polygon(open_polygon);    
end

% Loop through blocks
for ib=1:nb
    
    [xz,yz]=buq_get_cell_coordinates(buq,ib);
    
    % Set points inside open polygon
    if ~isempty(pol_open)
        
        inp=inpolygon(xz,yz,pol_open.x,pol_open.y);
        
        if max(max(inp))>0
                        
            % At least one of the cells is inside open boundary polygon
            for m=2:16
                for n=2:16

                    inactive_neighbor=0;
                    
                    % Check if cell is inside polygon, active and below zmax
                    
                    if inp(n,m) && msk(n,m,ib)>0 && zb(n,m,ib)<zmax
                        
                        % Check this cell for inactive neighbors
                        
                        if m==2
                            % Left                            
                            % Check refinement level
                            if buq.md(ib)==0
                                % Same level
                                md=buq.md1(ib);
                                if md>0
                                    if msk(n,16,md)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    inactive_neighbor=1;
                                end
                            elseif buq.md(ib)==1
                                % Finer on the left
                                % md1
                                if n<=9
                                    md=buq.md1(ib);
                                else
                                    md=buq.md2(ib);
                                end
                                if msk(jjj1(n),16,md)==0
                                    inactive_neighbor=1;
                                end
                                % md2
                                if n<=8
                                    md=buq.md1(ib);
                                else
                                    md=buq.md2(ib);
                                end
                                if msk(jjj2(n),16,md)==0
                                    inactive_neighbor=1;
                                end
                            elseif buq.md(ib)==-1
                                % Coarser on the left
                                % check if this is an even
                                md=buq.md1(ib);
                                if buq.n(ib)==2*buq.n(md)
                                    % even
                                    if msk(kkk2(n),16,md)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    % odd
                                    if msk(kkk1(n),16,md)==0
                                        inactive_neighbor=1;
                                    end
                                end
                            end
                            
                        elseif m==16
                            % Right
                            % Check refinement level
                            if buq.mu(ib)==0
                                % Same level
                                mu=buq.mu1(ib);
                                if mu>0
                                    if msk(n,2,mu)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    % no neighboring block
                                    inactive_neighbor=1;
                                end
                            elseif buq.mu(ib)==1
                                % Finer on the right
                                % mu1
                                if n<=9
                                    mu=buq.mu1(ib);
                                else
                                    mu=buq.mu2(ib);
                                end
                                if msk(jjj1(n),2,mu)==0
                                    inactive_neighbor=1;
                                end
                                % mu2
                                if n<=8
                                    mu=buq.mu1(ib);
                                else
                                    mu=buq.mu2(ib);
                                end
                                if msk(jjj2(n),2,mu)==0
                                    inactive_neighbor=1;
                                end
                            elseif buq.mu(ib)==-1
                                % Coarser on the right
                                mu=buq.mu1(ib);
                                if buq.n(ib)==2*buq.n(mu)
                                    % even
                                    if msk(kkk2(n),2,mu)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    % odd
                                    if msk(kkk1(n),2,mu)==0
                                        inactive_neighbor=1;
                                    end
                                end
                            end
                            
                        else
                            % Regular
                            if msk(n,m-1,ib)==0
                                inactive_neighbor=1;
                            end
                            if msk(n,m+1,ib)==0
                                inactive_neighbor=1;
                            end
                        end

                        
                        
                        
                        if n==2
                            % Bottom                          
                            % Check refinement level
                            if buq.nd(ib)==0
                                % Same level
                                nd=buq.nd1(ib);
                                if nd>0
                                    if msk(16,m,nd)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    inactive_neighbor=1;
                                end
                            elseif buq.nd(ib)==1
                                % Finer below
                                % nd1
                                if m<=9
                                    nd=buq.nd1(ib);
                                else
                                    nd=buq.nd2(ib);
                                end
                                if msk(16,jjj1(m),nd)==0
                                    inactive_neighbor=1;
                                end
                                % nd2
                                if m<=8
                                    nd=buq.nd1(ib);
                                else
                                    nd=buq.nd2(ib);
                                end
                                if msk(16,jjj2(m),nd)==0
                                    inactive_neighbor=1;
                                end
                            elseif buq.nd(ib)==-1
                                % Coarser below
                                % check if this is an even
                                nd=buq.nd1(ib);
                                if buq.m(ib)==2*buq.m(nd)
                                    % even
                                    if msk(16,kkk2(m),nd)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    % odd
                                    if msk(16,kkk1(m),md)==0
                                        inactive_neighbor=1;
                                    end
                                end
                            end
                            
                        elseif n==16
                            % Above
                            % Check refinement level
                            if buq.nu(ib)==0
                                % Same level
                                nu=buq.nu1(ib);
                                if nu>0
                                    if msk(2,m,nu)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    % no neighboring block
                                    inactive_neighbor=1;
                                end
                            elseif buq.nu(ib)==1
                                % Finer above
                                % nu1
                                if m<=9
                                    nu=buq.nu1(ib);
                                else
                                    nu=buq.nu2(ib);
                                end
                                if msk(2,jjj1(m),nu)==0
                                    inactive_neighbor=1;
                                end
                                % nu2
                                if m<=8
                                    nu=buq.nu1(ib);
                                else
                                    nu=buq.nu2(ib);
                                end
                                if msk(2,jjj2(m),nu)==0
                                    inactive_neighbor=1;
                                end
                            elseif buq.nu(ib)==-1
                                % Coarser above
                                nu=buq.nu1(ib);
                                if buq.m(ib)==2*buq.m(nu)
                                    % even
                                    if msk(2,kkk2(m),nu)==0
                                        inactive_neighbor=1;
                                    end
                                else
                                    % odd
                                    if msk(2,kkk1(m),nu)==0
                                        inactive_neighbor=1;
                                    end
                                end
                            end
                            
                        else
                            % Regular
                            if msk(n-1,m,ib)==0
                                inactive_neighbor=1;
                            end
                            if msk(n+1,m,ib)==0
                                inactive_neighbor=1;
                            end
                        end
                        
                        
                        
                        if inactive_neighbor==1
                            msk(n,m,ib)=2;
                        end
                        
                    end
                    
                    
                    
                end
            end
            
        end
    end
    
end

%%
function p=load_polygon(fname)
data=tekal('read',fname,'loaddata');
np=length(data.Field);
for ip=1:np
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    p(ip).x=x;
    p(ip).y=y;
end
