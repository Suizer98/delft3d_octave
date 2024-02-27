%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17806 $
%$Date: 2022-03-03 18:38:35 +0800 (Thu, 03 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_fini.m 17806 2022-03-03 10:38:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_fini.m $
%
%generate water level and velocity in rectangular grid 

%INPUT:
%   -simdef.file.grd
%   -simdef.ini.s
%   -simdef.grd.K
%   -simdef.ini.h
%   -simdef.ini.etab
%   -simdef.mdf.secflow
%
%OUTPUT:
%   -a .ini compatible with D3D is created in file_name
%
%ATTENTION:
%   -Very specific for 1D case in positive x direction
%   -Uniform slope
%
%150728->151118
%   -Introduction of boundary at the downstream end as input
%
%151118->151125
%   -Introduction of a varying slope
%
function D3D_fini(simdef)
%% RENAME

%read grid
% grd=wlgrid('read',simdef.file.grd);
% M=size(grd.X,1)+1;
% N=size(grd.X,2)+1;

grd=D3D_io_input('read',simdef.file.grd);
M=grd.mmax;
N=grd.nmax;

slope=simdef.ini.s;
dx_m=diff(grd.cor.x,1,2);
dx=dx_m(1,1);
if ~all(abs(dx_m-dx)<1e-6,'all')
    error('sorry, this is made for a constant dx. Adjust the code!')
end
K=simdef.grd.K;
h=simdef.ini.h;
% u=simdef.ini.u;
etab=simdef.ini.etab;
% L=simdef.grd.L;
% L=grd.X(end)-grd.X(1);
L=grd.cor.x(end)-grd.cor.x(1);
I=simdef.ini.I0;
secflow=simdef.mdf.secflow;
etab0_type=simdef.ini.etab0_type;
u=simdef.ini.u;
v=0; %v velocity

%other
% ncy=N-2; %number of cells in y direction (N in RFGRID) [-]
% ny=ncy+2; %number of depths points in y direction
% ny=N; %number of depths points in y direction
% ny=N+4; %number of depths points in y direction

%% CALCULATIONS

water_levels=-9.99e2*ones(N,M); %initial water levels with dummy values
u_mat=-9.99e2*ones(N,M); %initial u velocity with dummy values
v_mat=-9.99e2*ones(N,M); %initial v velocity with dummy values
I_mat=-9.99e2*ones(N,M); %initial secondary flow velocity with dummy values

switch etab0_type %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation
    case 1

        if numel(slope)==1
            d0=h+etab; 
            %water level
            vd=d0+slope*L:-dx*slope:d0+dx*slope;
        elseif numel(slope)==M-1
            d0=etab;
            %water level
               %bed level 
            bl(M-1)=d0+slope(M-1)*dx/2;
            for kx=M-2:-1:1
                bl(kx)=bl(kx+1)+dx*slope(kx);
            end
                %bed level+water depth
            vd=NaN(M-2,1);    
            for kx=1:M-2
                vd(kx)=(h(kx)+bl(kx)+h(kx+1)+bl(kx+1))/2;
            end   
        else
            error('The input SLOPE can be a single value or a vector with nx+1 components')
        end
        water_levels(2:N-1,2:M-1)=repmat(vd,length(2:N-1),1);
    case 2
        water_levels(2:N-1,2:M-1)=h+etab;
    otherwise
        error('..')
end

%u velocity
u_mat(2:N-1,1:M-1)=u;

%v velocity
v_mat(2:N-1,1:M-1)=v;

%seconday flow intensity 
I_mat(2:N-1,1:M-1)=I;

%noise
switch simdef.ini.etaw_noise
    case 0
    case 5
        mu=simdef.ini.noise_x0;
        etab_max=simdef.ini.noise_amp;
        sig=simdef.ini.noise_Lb;
        
        x=grd.cend.x;
        noise=etab_max*exp(-(x-mu).^2/sig^2);
        
        water_levels=water_levels+noise;
%         u_mat=
end


%% WRITE

file_name=fullfile(simdef.file.fini);

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x=strcat(repmat('%0.7E ',1,M),'\n'); %string to write in x

%water level
for ky=1:N
    fprintf(fileID_out,write_str_x,water_levels(ky,:));
end
%u velocity
for kk=1:K
    for ky=1:N
        fprintf(fileID_out,write_str_x,u_mat(ky,:));
    end
end
%v velocity
for kk=1:K
    for ky=1:N
        fprintf(fileID_out,write_str_x,v_mat(ky,:));
    end
end
%secondary flow intensity
if secflow==1
    for ky=1:N
        fprintf(fileID_out,write_str_x,I_mat(ky,:));
    end
end
fclose(fileID_out);
