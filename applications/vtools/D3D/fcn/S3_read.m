%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: S3_read.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_read.m $
%
%this function is crappy ad-hox and should be made decent. It is terrible!
%It should actually read nc rather than csv


function out_read=S3_read(simdef,in_read)

%% INPUT

switch simdef.flg.which_v
    case 2
        paths_file=fullfile(simdef.D3D.dire_sim,'output','h.csv');
    case 12
        paths_file=fullfile(simdef.D3D.dire_sim,'output','etaw.csv');
    otherwise 
        error('not done')
end

%% READ

fid=fopen(paths_file,'r');
fstr='%s %f %f %s %f %f';
% 00/01/01 00:00:00,9.99950300363246,0,Channel1,9.959,1.80190004919931
%time [-],x,y,branch,chainage,Water level [m AD]
data=textscan(fid,fstr,'headerlines',1,'delimiter',',');
fclose(fid);

%% REWORK

nd=size(data{1,1},1);

time_d=NaT(1,nd);

for kd=1:nd
%     12345678901234567
%     00/01/01 03:00:00
    ye=str2double(strcat('20',data{1,1}{kd,1}(1:2)));
    mo=str2double(data{1,1}{kd,1}(4:5));
    da=str2double(data{1,1}{kd,1}(7:8));
    ho=str2double(data{1,1}{kd,1}(10:11));
    mi=str2double(data{1,1}{kd,1}(13:14));
    se=str2double(data{1,1}{kd,1}(16:17));
    
time_d(kd)=datetime(ye,mo,da,ho,mi,se);


end %kd

etaw=data{1,6};
chain=data{1,5};

%% SEPARATE

endT=time_d(end); %make this input

tidx=find(time_d==endT);

etaw_p=etaw(tidx);
chain_p=chain(tidx);

out_read.SZ=chain_p;
out_read.z=etaw_p;

% figure
% plot(chain_p,etaw_p)


end %function