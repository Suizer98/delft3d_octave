%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17062 $
%$Date: 2021-02-12 20:47:20 +0800 (Fri, 12 Feb 2021) $
%$Author: chavarri $
%$Id: D3D_mini_thk_s.m 17062 2021-02-12 12:47:20Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini_thk_s.m $
%
%generate thickness of active and substrate layers

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%
%OUTPUT:
%   -
%
%ATTENTION:
%   -


function D3D_mini_thk_s(simdef,varargin)

%% PARSE

if numel(varargin)>0
    frc=varargin{1};
end

%% RENAME

dire_sim=simdef.D3D.dire_sim; 

nx=simdef.grd.M;
N=simdef.grd.N;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
total_ThUnLyr=simdef.mor.total_ThUnLyr;
subs_type=simdef.ini.subs_type;

%other
ncy=N; %number of cells in y direction (N in RFGRID) [-]
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
ny=ncy+2; %number of depths points in y direction
ntl=MxNULyr+2; %number of total layers (active layer + substrate + large last layer)

%% CALCULATIONS

thk=NaN(ny,nx,ntl); %initial thickness with dummy values

%active layer
thk(:,:,1)=ThTrLyr;

%substrate
thk(:,:,2:end-1)=ThUnLyr;

%last layer
thk(:,:,end)=ThUnLyr*10;

%Struiksma
if subs_type==3
    tol=1e-5;
    thk(frc(:,:,:,end)>1-tol)=0;
end

%% WRITE

for kl=1:ntl
    fname_thk=sprintf('%s_%02d.thk','lyr',kl);
    file_name=fullfile(dire_sim,fname_thk);  
    write_2DMatrix(file_name,thk(:,:,kl),nx,ny)
end

end %function

%% 
%% FUNCTIONS
%%

function write_2DMatrix(file_name,matrix,nx,ny)

    %check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x=strcat(repmat('%0.7E ',1,nx),'\n'); %string to write in x

for ky=1:ny
    fprintf(fileID_out,write_str_x,matrix(ky,:));
end

fclose(fileID_out);

end %function
