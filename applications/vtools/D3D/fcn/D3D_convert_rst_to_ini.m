%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18256 $
%$Date: 2022-07-22 19:08:11 +0800 (Fri, 22 Jul 2022) $
%$Author: chavarri $
%$Id: D3D_convert_rst_to_ini.m 18256 2022-07-22 11:08:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_convert_rst_to_ini.m $
%
%Modification from WO function

function D3D_convert_rst_to_ini(varargin)

%% PARSE

fpath_rst_in=varargin{1,1};
fpath_ini=varargin{1,2};
if nargin==3 %retain legacy input
    ini_suffix=sprintf('_%s',varargin{1,3});
else
    ini_suffix='';
end

%% type of rst

if isfolder(fpath_rst_in) %all rst in a folder
    dire=dir(fpath_rst_in);
    nf=numel(dire);
    fpath_rst_c={};
    for kf=1:nf
        if dire(kf).isdir
            continue
        end
        if strcmp(dire(kf).name(end-6:end),'_rst.nc')~=1
            continue
        end
        fpath_rst_c=cat(1,fpath_rst_c,fullfile(fpath_rst_in,dire(kf).name));            
    end %kf
elseif ischar(fpath_rst_in) %single file
    fpath_rst_c{1,1}=fpath_rst_in;
elseif iscell(fpath_rst_in) %already a cell of the rst to use
    fpath_rst_c=fpath_rst_in;
else
    error('Do not know what to do')
end

%% CALC

%% read rst

[fdir_ini,~,~]=fileparts(fpath_ini);
nr=numel(fpath_rst_c);

xz=[];
yz=[];
s1=[];
ucx=[];
ucy=[];

%bl available
ncinf=ncinfo(fpath_rst_c{1,1}); %if available in one, available in all
write_bl=false; 
if ~isnan(find_str_in_cell({ncinf.Variables.Name},{'FlowElem_bl'})) 
    write_bl = true; 
    bl=[];
end

for kr=1:nr

    fpath_rst=fpath_rst_c{kr,1};

    %x,y
    xz=cat(1,xz,ncread(fpath_rst,'FlowElem_xzw')); 
    yz=cat(1,yz,ncread(fpath_rst,'FlowElem_yzw')); 

    %s1 
    s1=cat(1,s1,ncread(fpath_rst,'s1')); 

    %ucx,uxy
    ucx=cat(1,ucx,ncread(fpath_rst, 'ucx')); 
    ucy=cat(1,ucy,ncread(fpath_rst, 'ucy')); 
    
    %bl
    if write_bl
        bl=cat(1,bl,ncread(fpath_rst, 'FlowElem_bl')); 
    end

end

%% write samples

waterlevelfile = fullfile('waterlevel', sprintf('waterlevel%s.xyz',ini_suffix));
savesamples( fdir_ini, waterlevelfile, xz, yz, s1); 
if write_bl
    bedlevelfile = fullfile('bedlevel', sprintf('bedlevel%s.xyz',ini_suffix));
    savesamples( fdir_ini, bedlevelfile, xz, yz, bl); 
end
velocityxfile = fullfile('velocity', sprintf('velocity_x%s.xyz',ini_suffix));
savesamples( fdir_ini, velocityxfile, xz, yz, ucx); 

velocityyfile = fullfile('velocity', sprintf('velocity_y%s.xyz',ini_suffix));
savesamples( fdir_ini, velocityyfile, xz, yz, ucy); 

%% write ini

Info = inifile('new');
C='General'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='fileVersion'; Value = '2.00';
Info = inifile('set', Info, C, K, Value);
K='fileType';    Value = 'iniField';
Info = inifile('set', Info, C, K, Value);

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='quantity';            Value = 'waterlevel';
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFile';            Value = waterlevelfile;
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value);
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value);
K='operand';             Value = 'O';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingType';       Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingRelSize';    Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingNumMin';     Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingPercentile'; Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='extrapolationMethod'; Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='locationType';        Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='value';               Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);

if write_bl
    C='Initial'; 
    [Info, IndexChapter] = inifile('add', Info, C);
    K='quantity';            Value = 'bedlevel';
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='dataFile';            Value = bedlevelfile;
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='dataFileType';        Value = 'sample';
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='interpolationMethod'; Value = 'triangulation';
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='operand';             Value = 'O';
    Info = inifile('set', Info, IndexChapter, K, Value);
end

warning('<initialvelocityx/y> is not yet handled in the ini file! It needs to be in the old external file')

% QUANTITY     =initialvelocityy
% FILENAME     =../../../../initial_conditions/hr/hr2023/ini_BOI/gemgetijzs_Q10000/velocity/velocity_y.xyz    
% FILETYPE     =7
% METHOD       =5
% OPERAND      =O

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='quantity';            Value = 'initialvelocityx';
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFile';            Value = velocityxfile;
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value);
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value);
K='operand';             Value = 'O';
Info = inifile('set', Info, IndexChapter, K, Value);

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='quantity';            Value = 'initialvelocityy';
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFile';            Value = velocityyfile;
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value);
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value);
K='operand';             Value = 'O';
Info = inifile('set', Info, IndexChapter, K, Value);

Info = inifile('write', fpath_ini, Info);


end %function

%%
%% FUNCTIONS
%%

function savesamples( samplepath, samplefile, xz, yz, zz)
    samplefullfile = fullfile(samplepath, samplefile); 
    [samplefullpath,~,~] = fileparts(samplefullfile); 
    if ~(exist(samplefullpath) == 7)
        mkdir(samplefullpath);
    end
    samples('write',samplefullfile,xz,yz,zz);
end
