function EHY_crop(varargin)
%% EHY_crop
%
% This function crops the surrounding area of a figure based on the
% background color.
%
% Example1: EHY_crop
% Example2: EHY_crop('D:\output.png');
% Example3: EHY_crop('D:\output.png','suffix',''); % save cropped fig at same location
% Example4: EHY_crop('D:\output.png','suffix','','disp',0); % save cropped fig at same location, don't disp to Command Window
%
% created by Julien Groenenboom, April 2017
%
%% load figure and set settings
% default settings

OPT.bgColor=[];
OPT.border=2; %pixels to have a small border
OPT.prefix='';
OPT.suffix='_cropped';
OPT.tol=3; %tolerance in color
OPT.disp=1; % display created figure

if nargin>0
    file=varargin{1};
else
    disp('Open a figure')
    [filename, pathname]=uigetfile('*.*','Open a figure');
    if isnumeric(filename); disp('EHY_crop stopped by user.'); return; end
    file=[pathname filename];
end
[pathstr,name,ext]=fileparts(file);
if isempty(pathstr); pathstr = '.'; end

% set <keyword>,<values>
if length(varargin)>1
    OPT = setproperty(OPT,varargin(2:end));
end
%%
img_uint8=imread(file);
img=double(img_uint8);

% get bgColor
if isempty(OPT.bgColor)
    r_c1=mode(img(:,1,1));
    g_c1=mode(img(:,1,2));
    b_c1=mode(img(:,1,3));
else
    r_c1=OPT.bgColor(1);
    g_c1=OPT.bgColor(2);
    b_c1=OPT.bgColor(3);
end

check=(abs(img(:,:,1)-r_c1)<OPT.tol)+(abs(img(:,:,2)-g_c1)<OPT.tol)+(abs(img(:,:,3)-b_c1)<OPT.tol);

cols=sum(check~=3,1);
rows=sum(check~=3,2);

m_min=max([find(rows~=0,1,'first')-OPT.border 1]);
m_max=min([find(rows ~=0,1,'last')+OPT.border size(img,1)]);

n_min=max([find(cols~=0,1,'first')-OPT.border 1]);
n_max=min([find(cols ~=0,1,'last')+OPT.border size(img,2)]);

fileName=[pathstr filesep OPT.prefix name OPT.suffix ext];
imwrite(img_uint8(m_min:m_max,n_min:n_max,:),fileName)
if OPT.disp
    disp(['EHY_crop created file: ' fileName])
end
