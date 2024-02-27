%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_read_sed_old.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_sed_old.m $
%
function sediment_data=delft_3d_sed_v_150717(file)

%number of fractions
file_id=fopen(file);
raw_string=textscan(file_id,'%s'); %file read as strings for avoiding problems of blanck spaces after the '[Sediment]' string
nf=numel(find(ismember(raw_string{1,1},'[Sediment]')));
fclose(file_id);

raw=cell(1,nf);
sediment_data=NaN(2,nf);
for kf=1:nf
    file_id=fopen(file);
    raw{kf}=textscan(file_id,'%s %f %s','delimiter','=','headerlines',7+(kf-1)*9+3);
    fclose(file_id);
    sediment_data(1,kf)=raw{1,kf}{1,2}(2,1);
    sediment_data(2,kf)=raw{1,kf}{1,2}(3,1);
end
