%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17374 $
%$Date: 2021-06-30 19:38:00 +0800 (Wed, 30 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_grd_rect.m 17374 2021-06-30 11:38:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_rect.m $
%
%grid files

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.D3D.grd = folder the grid files are [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\files\grd\'
%   -simdef.grd.L = domain length [m] [double(1,1)] e.g. [100]
%   -simdef.grd.dx = horizontal discretization [m] [double(1,1)]; e.g. [0.02] 
%   -simdef.grd.B = domain width [m] [double(1,1)] e.g. [2]
%   -simdef.grd.dy = transversal discretization [m] [double(1,1)]; e.g. [0.05]
%
%OUTPUT:
%   -a .grd file compatible with D3D is created in folder_out
%
%ATTENTION:
%   -
%
%HISTORY:
%   -161110 V. Creation of the grid files itself

function D3D_grd_rect(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

L=simdef.grd.L;
B=simdef.grd.B;
dx=simdef.grd.dx;
dy=simdef.grd.dy;

%in case we call directly
if isfield(simdef.grd,'M')==0 || isfield(simdef.grd,'N')==0
    simdef.grd.node_number_x=simdef.grd.L/simdef.grd.dx; %number of nodes 
    simdef.grd.node_number_y=simdef.grd.B/simdef.grd.dy; %number of nodes 
    simdef.grd.M=simdef.grd.node_number_x+2; %M (number of cells in x direction)
    simdef.grd.N=simdef.grd.node_number_y+2; %N (number of cells in y direction)
end

M=simdef.grd.M;
N=simdef.grd.N;
    
%% GRID

% grid=NaN(M-1,N-1);

%until 190919
% vx=0+dx:dx:L+dx;
% vy=0:dy:B;
%comparing with FM, it should not have the extra dx!
vx=0:dx:L;
vy=0:dy:B;

% xcord=NaN(M-1,N-1);
% ycord=NaN(M-1,N-1);

xcord=repmat(vx,N-1,1);
ycord=repmat(vy',1,M-1);

% nr=ceil((M-1)/5); %5 numbers per row

% for kny=1:ny
% xcord_r=NaN(5,nr); %fill transposed
% xcord_r(1:M-1)=vx;
% xcord_r=xcord_r';
% 
% grid=[xcord;ycord];

%% FILE

kl=1;
%preamble
data{kl  ,1}='*';kl=kl+1;
data{kl  ,1}='* chavobsky';kl=kl+1;
data{kl  ,1}='* FileCreationDate = today :D         ';kl=kl+1;
data{kl  ,1}='*';kl=kl+1;
data{kl  ,1}='Coordinate System = Cartesian';kl=kl+1;
data{kl  ,1}='Missing Value     =   -9.99999000000000024E+02';kl=kl+1;
data{kl  ,1}=sprintf('\t %d \t %d',M-1,N-1);kl=kl+1;
data{kl  ,1}=' 0 0 0';kl=kl+1;

% kk=7+1;
% for kc=1:2
    for ky=1:N-1
%         for kr=1:nr
            aux=strcat('ETA=   %d',repmat(' %11.10E',1,M-1));
            data{kl,1}=sprintf(aux,ky,vx);kl=kl+1;
%             kk=kk+1;
%         end
    end
    for ky=1:N-1
%         for kr=1:nr
            aux=strcat('ETA=   %d',repmat(' %11.10E',1,M-1));
            data{kl,1}=sprintf(aux,ky,ycord(ky,:));kl=kl+1;
%             kk=kk+1;
%         end
    end
        
% end
%     data{stu+(kf-1)*nlb+kf+0,1}=        '[Sediment]';
%     data{stu+(kf-1)*nlb+kf+1,1}=sprintf('   Name             = #Sediment%d#                   Name of sediment fraction',kf);


% end

%% WRITE

file_name=fullfile(dire_sim,'grd.grd');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s \n',data{kl,1});
end

fclose(fileID_out);

% %% COPY
% 
% from_grd=fullfile(dire_grd,sprintf('%dx1_%4.2f.grd',L,dx));
% from_enc=fullfile(dire_grd,sprintf('%dx1_%4.2f.enc',L,dx));
% [status(1),~]=system(sprintf('COPY %s %s',from_grd,fullfile(dire_sim,'grd.grd')));
% [status(2),~]=system(sprintf('COPY %s %s',from_enc,fullfile(dire_sim,'enc.enc')));
% 
% if any(status)
%     error('Grid files not found')
% end
