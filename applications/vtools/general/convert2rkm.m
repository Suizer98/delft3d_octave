%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17724 $
%$Date: 2022-02-03 13:41:30 +0800 (Thu, 03 Feb 2022) $
%$Author: chavarri $
%$Id: convert2rkm.m 17724 2022-02-03 05:41:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/convert2rkm.m $
%
%Given the x-y coordinates of a location it gives the 
%river-kilometer (rkm) of this location and viceversa.
%
%Input:
%   -path_rkm: path to the file with x, y, and river kilometers. Default file has 1 headerlines, delimiter by ',', and the input is x-coordinate, y-coordinate, river-branch, rkm
%       For x-y to rkm
%	-input 2: coordinates of the points; double(number of points,2); column 1 = x; column 2 = y 
%       For rkm to x-y
%   -input 2: rkm of the points; double(number of points,1)
%   -input 3: branch of the points; cell(number of points,1)
%       usual branch names (capitals are not considered):
%           -Rhein: rhein
%           -Waal: wa
%           -Pannerdensch Kanaal: pk
%           -Nederrijn: nr
%           -Lek: lek, le
%           -IJssel: ij
%
%Optional:
%	-'TolMinDist'
%	-'headerlines'
%	-'delimiter'
%	-'readString'
%	-'XCol'
%	-'YCol'
%	-'branchCol'
%	-'rkmCol'
%
%Output:
%       For x-y to rkm
%	-output 1: river kilometer; double(number of points,1)
%       For rkm to x-y
%   -output 1: x-y coordinates; double(number of points,2)
%
%e.g.
%rkm_br=convert2rkm('C:\Users\rkm.csv',cord_br);
%rkm_br=convert2rkm('C:\Users\rkm.csv',cord_br,'delimiter',',');
%xy=convert2rkm('C:\Users\rkm.csv',[985,750],{'lek','Rhein'});

function varargout=convert2rkm(path_rkm,varargin)

%% PARSE

ni=numel(varargin);
var_in=varargin{1}; %xy
np=size(var_in,1);

%if no input it is wrong
if ni==0
    error('Not enough input.');
end
%number of input is multiple of 2
if mod(ni,2)==0 %convert from rkm to xy
    rkm2xy=true;
    var_in=varargin{1}; %rkm
    var_in=[var_in,zeros(np,1)];
    branch_in=varargin{2};
    idx_varargin=3;
    
    if ~iscell(branch_in)
        error('The branch of the rkm should be a cell array.');
    end
    branch_in=deblank(lower(branch_in));
    idx_change=cell2mat(cellfun(@(X)strcmp(X,'lek'),branch_in,'UniformOutput',false));
    branch_in(idx_change)={'le'};
    %add others!
    
else
    rkm2xy=false;
    
    idx_varargin=2;
    
    if size(var_in,2)~=2
        error('In the columns of the input coordinates there should be x and y (i.e., 2 columns are expected).');
    end
end

%parser
parin=inputParser;

addOptional(parin,'TolMinDist',500,@isnumeric);
addOptional(parin,'headerlines',1,@isnumeric);
addOptional(parin,'delimiter',',');
addOptional(parin,'readString','%f %f %s %f');
addOptional(parin,'XCol',1);
addOptional(parin,'YCol',2);
addOptional(parin,'branchCol',3);
addOptional(parin,'rkmCol',4);
addOptional(parin,'disp_progress',false);

parse(parin,varargin{idx_varargin:end});

TolMinDist=parin.Results.TolMinDist;
headerlines=parin.Results.headerlines;
delimiter=parin.Results.delimiter;
readString=parin.Results.readString;
XCol=parin.Results.XCol;
YCol=parin.Results.YCol;
branchCol=parin.Results.branchCol;
rkmCol=parin.Results.rkmCol;
disp_progress=parin.Results.disp_progress;

%% READ FILE

fid=fopen(path_rkm,'r');
rkm_file=textscan(fid,readString,'headerlines',headerlines,'delimiter',delimiter);
fclose(fid);

nvc=numel(rkm_file{1,XCol});

if rkm2xy
    var_compare=[rkm_file{1,rkmCol},zeros(nvc,1)];
    var_out=[rkm_file{1,XCol},rkm_file{1,YCol}];

    %branch
    
%     tok=cellfun(@(X)regexp(X,'_','split'),rkm_file{1,branchCol},'UniformOutput',false); %e.g. 850.0_Rhein 
%     tok=cellfun(@(X)X{1,2},tok,'UniformOutput',false);

    sep_idx=strfind(rkm_file{1,branchCol},'_');
    sep_1_idx=cellfun(@(X)X(1),sep_idx,'UniformOutput',false); %first '_'
    tok=cellfun(@(X,Y)X(Y+1:end),rkm_file{1,branchCol},sep_1_idx,'UniformOutput',false);
    
    branch=cellfun(@(X)deblank(lower(X)),tok,'UniformOutput',false);
    
else
    var_compare=[rkm_file{1,XCol},rkm_file{1,YCol}];
    var_out=rkm_file{1,rkmCol};
    
    bol_branch=true(nvc,1);
end

%loop on points
var_get=NaN(np,size(var_out,2));

for kp=1:np
    if rkm2xy
        %get branch
        bol_branch=strcmp(branch,branch_in{kp});
    end
    var_out_branch=var_out(bol_branch,:);
    var_compare_branch=var_compare(bol_branch,:);

    %search for closest point
%     dist=sqrt(sum((var_compare_branch-var_in(kp,:)).^2,2));
%     [min_dist,min_idx]=min(dist);
%     var_get(kp,:)=var_out_branch(min_idx,:);

    %interpolating
%     %% begin debug
%     figure
%     hold on
%     plot(var_in(kp,1),var_in(kp,2),'*r');
%     plot(var_compare_branch(:,1),var_compare_branch(:,2),'ob')
%     
%     if kp==66
%         a=1;
%     end
%     %% end debug
    
    [min_dist,x_d_min,y_d_min,~,xc,~,~,~,~]=p_poly_dist(var_in(kp,1),var_in(kp,2),var_compare_branch(:,1),var_compare_branch(:,2));
    xc=max([1,xc]);
    dist_p2o=sqrt((x_d_min                   -var_compare_branch(xc,1))^2+(y_d_min                   -var_compare_branch(xc,2))^2);
    dist_p2p=sqrt((var_compare_branch(xc+1,1)-var_compare_branch(xc,1))^2+(var_compare_branch(xc+1,2)-var_compare_branch(xc,2))^2);
    frac=dist_p2o/dist_p2p;
    var_get(kp,:)=var_out_branch(xc,:)+frac*(var_out_branch(xc+1,:)-var_out_branch(xc,:));

    if min_dist>TolMinDist
        figure 
        hold on
        scatter(rkm_file{1,XCol},rkm_file{1,YCol},10,'r','o','filled')
        if rkm2xy
            
        else
            scatter(var_in(kp,1),var_in(kp,2),50,'b','s','filled')
        end
        axis equal

        error('The distance between point and the associated rkm is larger than %f m',TolMinDist)
    end
    if disp_progress
        fprintf('finding river km %4.2f %% \n',kp/np*100);
    end

end %kp

%% OUTPUT

varargout{1}=var_get;

