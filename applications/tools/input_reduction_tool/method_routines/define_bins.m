% Creates equi and non-equidistant bins 

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

% Input:
%        data = wave data [hs dir]
%        ndir   =   fixed number of directional bins, preferably even
%        nhs    =   number of height bins
%        equi = creates equidistant bins or not
%        equi = 1 - creates equidistant bins
%        equi = 0 - creates non-equidistant bins
%
% Output:
%       dirbin = directional bins (central value of the classes) 
%       dirlim = limits of the classes of direction
%       hsbin = wave high bins (central value of the classes) - matrix 1D
%       when bins are equidistant and 2D when non-equidistant
%       dirbin= wave direction bins (central value of the classes)


function [dirlim,hslim]=define_bins(data,ndir,nhs,equi,make_plot)

min_dir=min(data(:,2));
max_dir=max(data(:,2));
range_dir=(max_dir-min_dir);

if range_dir==0
    range_dir    = 2;
    ndir         = 1;
    interval_dir = 2;
    
    classes_dir=[min_dir-1:interval_dir:max_dir+1];
else
    interval_dir = range_dir./ndir;
end

classes_dir=[min_dir:interval_dir:max_dir];
dirlim(:,1)=classes_dir';

%% Hs bin  
if equi==1
    max_hs=max(data(:,1));
    min_hs=min(data(:,1));
    range_hs=[max_hs-min_hs];
    interval_hs=range_hs/nhs;
    
    classes_hs=[min_hs:interval_hs:max_hs];
    hslim=repmat(classes_hs',1,ndir);

elseif equi==0
    for j=1:ndir
        if j==ndir
        ind=find(data(:,2)>=classes_dir(j) & data(:,2)<=classes_dir(j+1));
        else
        ind=find(data(:,2)>=classes_dir(j) & data(:,2)<classes_dir(j+1));
        end
        bin=data(ind,:);        
        range_hs_bin=max(bin(:,1))-min(bin(:,1));
        if isempty(bin)
            classes_hs = NaN(1,nhs+1);
        else
            classes_hs=linspace(min(bin(:,1)),max(bin(:,1)),nhs+1);
        end
        hslim(:,j)=classes_hs';
        
    end
end

if make_plot
    
    tel = 0;
for ii=1:size(dirlim,1)-1
    for jj=1:size(hslim,1)-1
        tel = tel + 1;
        box(tel,:) = [hslim(jj,min(ii,size(hslim,2))) hslim(jj+1,min(ii,size(hslim,2))) dirlim(ii) dirlim(ii+1)];
    end
end

        figure
        plot(data(:,3),data(:,1),'.b')
        hold on
        for i=1:length(box)
            plot([box(i,3) box(i,3)],[box(i,1) box(i,2)],'k-','linew',1);
            plot([box(i,4) box(i,4)],[box(i,1) box(i,2)],'k-','linew',1);
            plot([box(i,3) box(i,4)],[box(i,1) box(i,1)],'k-','linew',1);
            plot([box(i,3) box(i,4)],[box(i,2) box(i,2)],'k-','linew',1);
        end       

        xlabel('Wave Direction (degrees)')
        ylabel('Wave heigth (m)')
        title('Wave Classes - Non-equidistant')
end
end

