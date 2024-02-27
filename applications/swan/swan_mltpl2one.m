%% swan_mltpl2one.m
% The spectral outputs are divided according to the number of processors
% used for the simulations. This script unified the files and also permits
% to the user to choose a subdomain for further analysis.
%
% Written by stylianos.flampouris@gmail.com
% Version 0.90 : 21st of May 2013
% 
% Calling Matlab Scripts:
% 1. swan_io_spectrum
%
% fn        : filename without the increasing number of the processor, e.g.
%             htfl
% wd        : directory where the data are, optional
% subd      : 2X2 array [min_x_coor, max_x_coor; min_y_coor, max_y_coor],
%             optional
%
% td_out    : is a structure with the same format as the structures of 
%             input data imported by swan_io_spectrum.m
%
%% TODO     : Next version should have error messages...
%
%%
function dt_out = swan_mltpl2one (fn, wd, subd)
% tic;
disp(['The swan_mltpl2one started and it will merge the files: ',fn,'*'])

if nargin < 2 || isempty(wd)
   wd = pwd;
end
cd(wd)
%
lst_fl = dir([fn,'*']);
if ~isempty(lst_fl)
% 
NoF = length(lst_fl);
dt_in = [];
min_x_all = [];
max_x_all = [];
min_y_all = [];
max_y_all = [];

for i_fl = 1:1:NoF
    dt_in = [dt_in; swan_io_spectrum(lst_fl(i_fl).name)];
    disp(['Imported Data: ', num2str(100*i_fl/NoF),'%']);
%     
    ind_x = find((size(dt_in(i_fl).x) == dt_in(i_fl).mxc)==1);
     
    [min_x] = min(dt_in(i_fl).x,[],ind_x);
    [max_x] = max(dt_in(i_fl).x,[],ind_x);
    ind_y = find((size(dt_in(i_fl).y) == dt_in(i_fl).myc)==1);
    [min_y] = min(dt_in(i_fl).y,[],ind_y);
    [max_y] = max(dt_in(i_fl).y,[],ind_y);

    min_x_all = [min_x_all;min_x(1)];
    min_y_all = [min_y_all;min_y(1)];
    max_x_all = [max_x_all;max_x(1)];
    max_y_all = [max_y_all;max_y(1)];
    
    if (i_fl>=2)
        diff_max_x_all = diff(max_x_all);
        diff_max_y_all = diff(max_y_all);
        
        if diff_max_x_all(end)~=0
            [~,col] = find(data.x==min_x_all(i_fl));
             if diff(col)~=0
                error('Multiple y-coordinates with the same minimum')
             end
            data.x (:, col(1):col(1)+size(dt_in(i_fl).x,2)-1) = dt_in(i_fl).x;
            data.y (:, col(1):col(1)+size(dt_in(i_fl).y,2)-1) = dt_in(i_fl).y;
            data.AcDens (:,col(1):col(1)+size( dt_in(i_fl).AcDens,2)-1,:,:) = dt_in(i_fl).AcDens;            
        elseif diff_max_y_all(end)~=0
            [row,col] = find(data.y==min_y_all(i_fl)); %#ok<NASGU>
            if diff(row)~=0
                error('Multiple x-coordinates with the same minimum')
            end
            data.y (row(1):row(1)+size(dt_in(i_fl).y,1)-1, :) = dt_in(i_fl).y;
            data.x (row(1):row(1)+size(dt_in(i_fl).x,1)-1, :) = dt_in(i_fl).x;
            data.AcDens (row(1):row(1)+size(dt_in(i_fl).AcDens,1)-1,:,:,:) = dt_in(i_fl).AcDens;
        end
        
    elseif (i_fl==1)
        data.x = dt_in(i_fl).x;
        data.y = dt_in(i_fl).y;
        data.AcDens = dt_in(i_fl).AcDens;
        dxy = data.x(1,4)-data.x(1,3);
        dxy = [dxy;data.y(4,1)-data.y(3,1)];
        
    end   
end
%% If subdomain has been declared 
if nargin>=3 & size(subd)==2 %#ok<AND2>
    index = subd(1,:)./dxy(1);
    index = round([index;subd(2,:)./dxy(2)]+1);
    dt_out.x = data.x(index(2,1):index(2,2),index(1,1):index(1,2));
    dt_out.y = data.y(index(2,1):index(2,2),index(1,1):index(1,2));
    dt_out.AcDens = data.AcDens (index(2,1):index(2,2),index(1,1):index(1,2),:,:);
else
    dt_out = data;
end
dt_out.fullfilename = fn;
dt_out.frequency = dt_in(1).frequency;
dt_out.frequency_type = dt_in(1).frequency_type;
dt_out.direction_convention = dt_in(1).direction_convention;
dt_out.directions = dt_in(1).directions;
dt_out.quantity_names = dt_in(1).quantity_names;
dt_out.quantity_exception_values = dt_in(1).quantity_exception_values;
dt_out.quantity_units = dt_in(1).quantity_units;
%%
else
    dt_out=[];
end
toc;
%% EoF swan_mltpl2one.m
