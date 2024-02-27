%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_read_sed.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_sed.m $
%
%read sediment data

function [dchar,sedtype]=D3D_read_sed(file_sed)

sed=delft3d_io_sed(file_sed);
sed_fields=fieldnames(sed);
nfields=numel(sed_fields);
dchar=[];
sedtype={};
dmin=[];
dmax=[];
dchar_f=[];
dchar_l=[];
dmin_f=[];
dmax_f=[];
kf=0;
for kfields=1:nfields
    sed_fields2=fieldnames(sed.(sed_fields{kfields,1}));
    nf2=numel(sed_fields2);
    for kf2=1:nf2
       if strcmp(sed_fields2{kf2,1},'SedDia')  
           kf=kf+1;
           dchar_l=[dchar_l,sed.(sed_fields{kfields,1}).(sed_fields2{kf2,1})];
           dchar_f=[dchar_f,kf];
%            dchar=[dchar,sed.(sed_fields{kfields,1}).(sed_fields2{kf2,1})];
       end
       if strcmp(sed_fields2{kf2,1},'SedTyp')  
           sedtype=[sedtype(:)',{sed.(sed_fields{kfields,1}).(sed_fields2{kf2,1})}];
       end
       if strcmp(sed_fields2{kf2,1},'SedMinDia')  
           kf=kf+1;
           dmin=[dmin,sed.(sed_fields{kfields,1}).(sed_fields2{kf2,1})];
           dmin_f=[dmin_f,kf];
       end
       if strcmp(sed_fields2{kf2,1},'SedMaxDia')  
           %if there is a SedMinDia, there is SedMaxDia
%            kf=kf+1;
           dmax=[dmax,sed.(sed_fields{kfields,1}).(sed_fields2{kf2,1})];
%            dmax_f=[dmax_f,kf];
       end
    end            
end

nf=kf;
dchar=NaN(1,nf);
dchar(dchar_f)=dchar_l;

dchar_mm=sqrt(dmin.*dmax); 
dchar(isnan(dchar))=dchar_mm;

end %function