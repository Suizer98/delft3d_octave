%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 23:44:11 +0800 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: create_m_file_from_type2.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/create_m_file_from_type2.m $
%

function create_m_file_from_type2(flg,ffulname,fsave)

fprintf('Start processing file: %s\n',ffulname);
fid=fopen(ffulname,'r');
%1-9
for kl=1:9 
    raw=fgetl(fid);
end
%10
raw=fgetl(fid);
tok=regexp(raw,'SYSTEM = ''(\w+)''','tokens');
if isempty(tok)
    error('Cannot get coordinate system')
else
   cord_system=tok{1,1}{1,1}; 
end
%11-21
for kl=1:11
    raw=fgetl(fid);
end
%22
raw=fgetl(fid);
tok=regexp(raw,'NUMBEROFDEPTHS = (\d+)','tokens');
if isempty(tok)
    error('Cannot get coordinate number of depths')
else
   nd=str2double(tok{1,1}{1,1}); 
end
%23
raw=fgetl(fid);
tok=regexp(raw,'NUMBEROFROWS = (\d+)','tokens');
if isempty(tok)
    error('Cannot get coordinate number of rows')
else
   nr=str2double(tok{1,1}{1,1}); 
end
%24-26
for kl=1:3
    raw=fgetl(fid);
end
tok=regexp(raw,'(\w+)','tokens');
if strcmp(tok{1,1}{1,1},'VALUES')==0
    error('not last line!')
end

nb=nr/nd;
if rem(nr,nb)~=0
    error('Strange...')
end

kls=1;
% data_blocks=struct('time',[],'cords',[]);
for kb=1:nb
    data_block(kls)=read_block(fid,nd,cord_system); %preallocating would be cool...
    kls=kls+1;
    if flg.debug
        fprintf('Number of blocks = %d \n',numel(data_block));
    end    
end

fclose(fid);
% [ffolder,fname,~]=fileparts(ffulname);
% fsave=fullfile(ffolder,sprintf('%s.mat',fname));
save(fsave,'data_block');
fprintf('File created: %s\n',fsave);
end %function

%%

function data_block=read_block(fid,nl,cord_system)

% 'EAST NORTH Z DATE+TIME BOTTOMHEIGHT EASTVEL NORTHVEL VELMAGN VELDIR ERRVEL' 

data_block.depth=NaN(nl,1);
data_block.vmag=NaN(nl,1);
data_block.vdir=NaN(nl,1);
data_block.veast=NaN(nl,1);
data_block.vnorth=NaN(nl,1);
data_block.vvert=NaN(nl,1);
data_block.verr=NaN(nl,1);
data_block.backscatter=NaN(nl,4);
data_block.percentgood=NaN(nl,1);
data_block.discharge=NaN(nl,1);

for kl=1:nl
    raw=fgetl(fid);
    switch cord_system
        case 'WGS84'
            tok=regexp(raw,'(\d+).(\d+).(\d+).(\d+)\s+(\d+).(\d+).(\d+).(\d+)\s+(-?\d+.\d+)\s+(\d{8})\s+(\d{6})\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)','tokens');
            lon=str2double(tok{1,1}{1,1})+str2double(tok{1,1}{1,2})/60+str2double(tok{1,1}{1,3})/3600+str2double(tok{1,1}{1,4})/3600/100;
            lat=str2double(tok{1,1}{1,5})+str2double(tok{1,1}{1,6})/60+str2double(tok{1,1}{1,7})/3600+str2double(tok{1,1}{1,8})/3600/100;
            idx_n=9;
        case 'RDV'
            tok=regexp(raw,'(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(\d{8})\s+(\d{6})\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)\s+(-?\d+.\d+)','tokens');
            x_cord=str2double(tok{1,1}{1,1});
            y_cord=str2double(tok{1,1}{1,2});
            [lon,lat]=convertCoordinates(x_cord,y_cord,'CS1.code',28992,'CS2.code',4326);
            idx_n=3;
    end

    %check no change in coordinates. We are recomputing time and assuming
    %it is the same. 
    if isfield(data_block,'cords')
        if sum(data_block.cords-[lon,lat])~=0
            error('Different coordinate at same location!')
        end
    else
        data_block.cords=[lon,lat];
    end
    
    %20180720 100956
    data_block.time=datetime(str2double(tok{1,1}{1,idx_n+1}(1:4)),str2double(tok{1,1}{1,idx_n+1}(5:6)),str2double(tok{1,1}{1,idx_n+1}(7:8)),str2double(tok{1,1}{1,idx_n+2}(1:2)),str2double(tok{1,1}{1,idx_n+2}(3:4)),str2double(tok{1,1}{1,idx_n+2}(5:6)));
    
    data_block.distance=NaN;
    data_block.timetravel=NaN;
    data_block.distance_north=NaN;
    data_block.distance_east=NaN;

    %COLS = 'EAST NORTH Z DATE+TIME BOTTOMHEIGHT EASTVEL NORTHVEL VELMAGN VELDIR ERRVEL'
    %Z=idx_n
    %BOTTOMHEIGHT=idx_n+3
    %EASTLEVEL=idx_n+4;
    %...
    
    data_block.depth(kl,1)      =str2double(tok{1,1}{1,idx_n});
    data_block.vmag(kl,1)       =clean_velocity_type2(str2double(tok{1,1}{1,idx_n+6}));
    data_block.vdir(kl,1)       =clean_velocity_type2(str2double(tok{1,1}{1,idx_n+7}));
    data_block.veast(kl,1)      =clean_velocity_type2(str2double(tok{1,1}{1,idx_n+4}));
    data_block.vnorth(kl,1)     =clean_velocity_type2(str2double(tok{1,1}{1,idx_n+5}));
    data_block.vvert(kl,1)      =clean_velocity_type2(NaN                            );
    data_block.verr(kl,1)       =clean_velocity_type2(str2double(tok{1,1}{1,idx_n+8}));
    data_block.backscatter(kl,:)=NaN;
    data_block.percentgood(kl,1)=NaN;
    data_block.discharge(kl,1)  =NaN;

end


end %read_block







