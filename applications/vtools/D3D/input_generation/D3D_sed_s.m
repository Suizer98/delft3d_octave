%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_sed_s.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_sed_s.m $
%
%sediment file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.sed.dk = characteristic grain sizes [m] [double(nf,1)] e.g. [0.001,0.002]
%
%OUTPUT:
%   -a .sed file compatible with D3D is created in file_name

function D3D_sed_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

dk=simdef.sed.dk;

%other
nf=length(dk); %number of fractions (total-1)
stu=7; %start line sediment -1
nlb=8; %number of lines per block -1

%% FILE

%preamble
data{1  ,1}='[SedimentFileInformation]';
data{2  ,1}='   FileCreatedBy    = chavobsky         ';
data{3  ,1}='   FileCreationDate = today :D         ';
data{4  ,1}='   FileVersion      = 02.00                        ';
data{5  ,1}='[SedimentOverall]';
data{6  ,1}='   Cref             =  1.6000000e+003      [kg/m3]  CSoil Reference density for hindered settling calculations';
data{7  ,1}='   IopSus           = 0                             If Iopsus = 1: susp. sediment size depends on local flow and wave conditions';

%fractions
for kf=1:nf
    data{stu+(kf-1)*nlb+kf+0,1}=        '[Sediment]';
    data{stu+(kf-1)*nlb+kf+1,1}=sprintf('   Name             = #Sediment%d#                   Name of sediment fraction',kf);
    data{stu+(kf-1)*nlb+kf+2,1}=        '   SedTyp           = bedload                       Must be "sand", "mud" or "bedload"';
    data{stu+(kf-1)*nlb+kf+3,1}=        '   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density';
	data{stu+(kf-1)*nlb+kf+4,1}=sprintf('   SedDia           =  %0.7e      [m]      Minimum sediment diameter (D50)',dk(kf));
    % data{stu+(kf-1)*nlb+kf+4,1}=sprintf('   SedMinDia        =  %0.7e      [m]      Minimum sediment diameter (D50)',dk(kf)-0.00001);
    % data{stu+(kf-1)*nlb+kf+5,1}=sprintf('   SedMaxDia        =  %0.7e      [m]      Maximum sediment diameter (D50)',dk(kf)+0.00001);
    data{stu+(kf-1)*nlb+kf+6,1}=        '   CDryB            =  1.5900000e+003      [kg/m3]  Dry bed density';
    data{stu+(kf-1)*nlb+kf+7,1}=        '   IniSedThick      =  1.0000000e+000      [m]      Initial sediment layer thickness at bed (overuled if IniComp is prescribed)';
    data{stu+(kf-1)*nlb+kf+8,1}=        '   FacDSS           =  1.0000000e+000      [-]      FacDss * SedDia = Initial suspended sediment diameter. Range [0.6 - 1.0]';
end

%% WRITE

file_name=fullfile(dire_sim,'sed.sed');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s \n',data{kl,1});
end

fclose(fileID_out);