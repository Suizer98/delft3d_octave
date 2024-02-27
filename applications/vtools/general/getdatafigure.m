%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18269 $
%$Date: 2022-08-01 12:31:19 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: getdatafigure.m 18269 2022-08-01 04:31:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/getdatafigure.m $
%
%Get data from a figure
%
%INPUT:
%   -paths_figure: path to the figure with the data to be taken; char
%
%OPTIONAL as pair argument:
%   -'XScale': indicates type of x-axis. Either 'log' or 'linear' (default); char
%   -'YScale': indicates type of y-axis. Either 'log' or 'linear' (default); char
%   -'fname_save': file name of the mat-file with the structure with the data; char
%   -'labels_x': x label; char
%   -'labels_y': y label; char

function getdatafigure(paths_figure,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fname_save',fullfile(pwd,'data.mat'));
addOptional(parin,'XScale','linear');
addOptional(parin,'YScale','linear');
addOptional(parin,'labels_x','');
addOptional(parin,'labels_y','');

parse(parin,varargin{:});

XScale=parin.Results.XScale;
YScale=parin.Results.YScale;
fname_save_mat=parin.Results.fname_save;
if contains(fname_save_mat,'.mat')==0
    fname_save_mat=sprintf('%s.mat',fname_save_mat);
end
fname_save_fig=strrep(fname_save_mat,'.mat','.png');
fname_save_csv=strrep(fname_save_mat,'.mat','.csv');
labels_x=parin.Results.labels_x;
labels_y=parin.Results.labels_y;

if any(strcmp(XScale,{'log','linear'}))==0
    error('XScale must be either ''linear'' or ''log''.')
end

if any(strcmp(YScale,{'log','linear'}))==0
    error('XScale must be either ''linear'' or ''log''.')
end

%% CALC

flg.debug=0;

%% open figure

im=imread(paths_figure);
han.fig=figure;
han.fig.Units='normalize';
han.fig.OuterPosition=[0,0,1,1];
imshow(im) 
hold on

%% get figure limits

if flg.debug
    x0_px=144;
    y0_px=733;
else
    fprintf('Click on lower-left end of the figure \n');
    [x0_px,y0_px,~]=ginput(1);
    scatter(x0_px,y0_px,20,'sg')
end

%% get input for scale

if flg.debug
    x_px_low=543;
    x_ax_low=1;
    x_px_high=942;
    x_ax_high=10;
    y_px_low=595;
    y_ax_low=25;
    y_px_high=235;
    y_ax_high=75;
else
    
    %this points do not need to be the limits of the figure, but the longer the distance the more accurate the result
    fprintf('Click on low x value \n');
    [x_px_low,y_aux,~]=ginput(1);
    scatter(x_px_low,y_aux,20,'sg')
    x_ax_low=input('Low x value = ');

    fprintf('Click on high x value \n');
    [x_px_high,y_aux,~]=ginput(1);
    scatter(x_px_high,y_aux,20,'sg')
    x_ax_high=input('High x value = ');

    fprintf('Click on low y value \n');
    [x_aux,y_px_low,~]=ginput(1);
    scatter(x_aux,y_px_low,20,'sg')
    y_ax_low=input('Low y value = ');

    fprintf('Click on high y value \n');
    [x_aux,y_px_high,~]=ginput(1);
    scatter(x_aux,y_px_high,20,'sg')
    y_ax_high=input('High y value = ');

end

%% compute limits axis

switch XScale
    case 'log'
        x_ax_low=log10(x_ax_low);
        x_ax_high=log10(x_ax_high);
end

x_s=(x_px_high-x_px_low)/(x_ax_high-x_ax_low); %px/ax
x0_ax=x_ax_low+(x0_px-x_px_low)/x_s;

switch YScale
    case 'log'
        y_ax_low=log10(y_ax_low);
        y_ax_high=log10(y_ax_high);
end

y_s=abs((y_px_high-y_px_low)/(y_ax_high-y_ax_low)); %px/ax pixels in y axis go from top to bottom.
y0_ax=y_ax_low-(y0_px-y_px_low)/y_s;

%% get data from figure

fprintf('Finish pressing bar. Points taken = %d \n',0)

c=1;
class=[];
while any(class==32)~=1 %escape with bar
[x_px(c),y_px(c),class(c)]=ginput(1);
if class(c)~=32
scatter(x_px(c),y_px(c),20,'xr')
fprintf('Finish pressing bar. Points taken = %d \n',c)
end
c=c+1;
end

x_px=x_px(1:end-1);
y_px=y_px(1:end-1);
class=class(1:end-1);

%% calculate value

%x-axis
x_ax=x0_ax+(x_px-x0_px)/x_s;

switch XScale
    case 'log'
        x_ax=10.^x_ax;
end

%y-axis
y_ax=y0_ax-(y_px-y0_px)/y_s;

switch YScale
    case 'log'
        y_ax=10.^y_ax;
end

%class
class_u=unique(class);
class_types=numel(class_u);
class_f=class';
for kc=1:class_types
    class_f(class_f==class_u(kc))=kc;
end

%% PLOT

han.fout=figure;
hold on
scatter(x_ax,y_ax,10,class_f,'filled')
switch XScale
    case 'log'
        set(gca,'XScale','log')
end
switch YScale
    case 'log'
        set(gca,'YScale','log')
end
xlabel(labels_x)
ylabel(labels_y)
print(han.fout,fname_save_fig,'-dpng','-r300')

%% SAVE

data=[x_ax',y_ax',class_f];
save_check(fname_save_mat,'data')
% fprintf('Data saved: %s \n',fname_save_mat)

%% EXPORT CSV

write_2DMatrix(fname_save_csv,data,'num_str','%+10e, %+10e, %d')

end %function

