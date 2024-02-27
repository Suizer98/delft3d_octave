%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-21 00:31:37 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: D3D_dep_s.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_dep_s.m $
%
%generate depths in rectangular grid 

%INPUT:
%   either:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   or:
%   -simdef.file.dep = full path to the dep-file [string] e.g. 'C:\Users\chavarri\temporal\210503_VOW\03_simulations\02_flume\01_input\dep\dep.dep'
%
%   -simdef.file.grd = full path to the grid file [string] e.g. 'c:\Users\chavarri\temporal\210503_VOW\03_simulations\02_flume\02_runs\r001\grd.grd'
%   -simdef.ini.etab0_type = type of initial bed elevation: 1=constant sloping bed in M-direction; 2=constant bed elevation
%   -simdef.grd.dx = horizontal discretization [m] [integer(1,1)]; e.g. [0.02] 
%   -simdef.ini.s = bed slope [-] [integer(1,1)] or [integer(nx-1,1)] from upstream to downstream; e.g. [3e-4] or linspace(0.005,0.003,101)
%   -simdef.grd.L = domain length [m] [integer(1,1)] [100]
%   -simdef.ini.etab = %initial downstream bed level [m] [double(1,1)] e.g. [0]
%
%OUTPUT:
%   -a .dep compatible with D3D is created in file_name
%
%ATTENTION:
%   -Very specific for 1D case in positive x direction
%   -Uniform slope
%   -Depth in D3D is defined positive downward and it is bed level and not flow depth
%   -The number of input is over defined. In this way we double check it. 
%
%150728->151118
%   -Introduction of boundary at the downstream end as input
%
%151118->151125
%   -Introduction of a varying slope

function D3D_dep_s(simdef)

%% RENAME

% if isfield(simdef.file,'dep')==0
% %     dire_sim=simdef.D3D.dire_sim; 
%     simdef.file.dep=fullfile(simdef.D3D.dire_sim,'dep.dep');
% end
path_dep=simdef.file.dep;

if isfield(simdef.file,'grd')==0
    error('provide grid file');
end
path_grd=simdef.file.grd;

if isfield(simdef.ini,'etab_noise')==0
    simdef.ini.etab_noise=0;
end
etab_noise=simdef.ini.etab_noise;

if isfield(simdef.ini,'etab0_type')==0
    simdef.ini.etab0_type=2;
end
etab0_type=simdef.ini.etab0_type;

switch etab0_type
    case 1
        if isfield(simdef.ini,'s')==0
            error('you need to input the slope')
        end
end

%only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

if strcmp(simdef.mdf.Dpsopt,'DP')==0
    error('This function is prepared for DPSOPT=DP. Worked with the read grid to change it')
end
%% read grid
% grd=wlgrid('read',path_grd);
% M=size(grd.X,1)+1;
% N=size(grd.X,2)+1;

grd=D3D_io_input('read',path_grd);
M=grd.mmax;
N=grd.nmax;
% M=size(grd.cor.x,2)+1;
% N=size(grd.cor.x,1)+1;

slope=simdef.ini.s; %slope (defined positive downwards)
% dx=simdef.grd.dx;
dx_m=diff(grd.cor.x,[],2);
dx=dx_m(1,1);
if ~all(abs(dx_m-dx)<1e-6,'all')
    error('sorry, this is made for a constant dx. Adjust the code!')
end
if simdef.ini.etab_noise==2
dy=simdef.grd.dy;
% warning('read from grid?')
B=simdef.grd.B;
end
% nx=simdef.grd.M;
% N=simdef.grd.N;
nx=M;

%L from grid
% L=simdef.grd.L;
L=grd.cor.x(end)-grd.cor.x(1);

etab=simdef.ini.etab;

%central with dummies
x_in=grd.cend.x(2:end-1,:);
y_in=grd.cend.y(2:end-1,:);

%other
ncy=N-2; %number of cells in y direction (N in RFGRID) [-]
d0=etab; %depth (in D3D) at the downstream end (at x=L, where the water level is set)

%varying slope flag
% if numel(slope)>1; flg_vars=
%% CALCULATIONS

switch etab0_type %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation
    case 1 %sloping bed
        ny=ncy+2; %number of depths points in y direction

        depths=-9.99e2*ones(ny,nx); %initial depths with dummy values

        if numel(slope)==1
%             vd=-(d0+slope*(L+dx/2):-dx*slope:d0+dx/2*slope); %depths vector 
            depths(1:end-1,:)=-(d0+slope*(L-grd.cend.x(1:end-1,:)));
        elseif numel(slope)==nx-1
            vd(nx-1)=d0+slope(nx-1)*dx/2;
            for kx=nx-2:-1:1
                vd(kx)=vd(kx+1)+dx*slope(kx);
            end
            vd=-vd;
            depths(1:ny-1,1:nx-1)=repmat(vd,length(1:ny-1),1);
        else
            error('The input SLOPE can be a single value or a vector with nx+1 components')
        end

        
    case 2 %constant bed elevation
        ny=ncy+2; %number of depths points in y direction

        depths=-etab*ones(ny,nx); 
    case 3
%         depths=simdef.ini.xyz;
        error('..')
end


%add noise
noise=zeros(ny,nx);
rng(0)
switch etab_noise
    case 0
%         noise=zeros(ny,nx);
    case 1 %random noise
        warning('Check indeces after changin ny def')
        noise_amp=simdef.ini.noise_amp;
        noise(1:end-3,3:end-1)=noise_amp.*(rand(ny-3,nx-3)-0.5);
    case 2 %sinusoidal
        %noise parameters
        noise_amp=simdef.ini.noise_amp;
        noise_Lb=simdef.ini.noise_Lb;
        

        
        %cross-sectional variation
        if ncy==1 %1D, you actually want no variation in transverse direction
            Ay=-1; %the amplitude is -1 contrary to FM because the sign of the bed is different!
        else
            Ay=sin(pi*(y_in-B/2)./B);
        end
        
        noise_in=noise_amp*Ay.*cos(2*pi*x_in/noise_Lb-pi/2); %total noise
        noise_in=flipud(noise_in); %consistency with FM
        noise(2:end-1,:)=noise_in;
        
        %% BEGIN DEBUG
%         figure
%         hold on
%         scatter3(x_in(:),y_in(:),noise_in(:),10,noise_in(:),'filled')
%         view([0,0])
%          xlim([550,650])

        %END DEBUG
    case 3 %random noise including at x=0
        warning('Check indeces after changin ny def')
        noise_amp=simdef.ini.noise_amp;
%         noise(1:end-3,2:end-1)=noise_amp.*(rand(ny-3,nx-2)-0.5);
        noise(1:end-3,1:end)=noise_amp.*(rand(ny-3,nx)-0.5);
    case 4 %trench
        noise_amp=simdef.ini.noise_amp;
        noise_trench_x=simdef.ini.noise_trench_x;
        
        %identify patch coordinates
        xedge=-dx/2:dx:L-dx/2;
        [~,x0_idx]=min(abs(xedge-noise_trench_x(1)));
        [~,xf_idx]=min(abs(xedge-noise_trench_x(2)));
        
        noise(:,x0_idx:xf_idx)=noise_amp;
    case 6
        mu=simdef.ini.noise_x0;
        etab_max=simdef.ini.noise_amp;
        sig=simdef.ini.noise_Lb;
        
        noise(2:end-1,:)=-etab_max.*exp(-((x_in-mu(1)).^2/sig^2+(y_in-mu(2)).^2/sig^2)); %factor 2 missing in the denominator?
    otherwise
        error('say something about it!')
end

depths=depths+noise;

%% WRITE

write_2DMatrix(path_dep,depths);
messageOut(NaN,sprintf('dep-file created: %s',path_dep))

% file_name=fullfile(dire_sim,'dep.dep');  
% 
% %check if the file already exists
% if exist(file_name,'file')
%     error('You are trying to overwrite a file!')
% end
% 
% fileID_out=fopen(file_name,'w');
% write_str_x=strcat(repmat('%0.7E ',1,nx),'\n'); %string to write in x
% 
% for ky=1:ny
%     fprintf(fileID_out,write_str_x,depths(ky,:));
% end
% 
% fclose(fileID_out);


