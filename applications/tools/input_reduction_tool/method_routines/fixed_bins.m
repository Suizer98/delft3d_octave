%% Non-linear wave bins

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

% Determination is based on non-linearity of link between wave height and
% sediment transport
%
% This script transfers data into a bidimentional wave climate
% Input:
%        data = [Nx3] matrix with the observations from the field. [Hs
%               Tp dir]
%        ndir   =   fixed number of directional bins, preferably even
%        nhs    =   number of height bins
%        equi = creates equidistant bins or not
%        equi = 1 - creates equidistant bins
%        equi = 0 - creates non-equidistant bins (default)
%  info_dir =   Information about the range of variation of the angle
%               info_dir = 1 means range of variation of 0 to 360
%               info_dir = 0 means angle relative to the
%               shore-normal, contains negative and positive values.
% Output:
%        v      =   contains representive wave conditions [k x [H dir tp]]
%        P      =   probabilities of occurance of rep wave cond
%       dirbin = directional bins (central value of the classes)
%       dirlim = limits of the classes of direction
%       hsbin = wave high bins (central value of the classes) - matrix 1D
%       when bins are equidistant and 2D when non-equidistant
%       hslim= limits of the classes of wave heigth
%       M04 = structure where:
%                       Result = matrix [cond x 4] with selected wave conditions and probability
%                       v = wave conditions (Hs,Tp,Dir);
%                       P = prob per bin


function [inds_f,v,bin_limits] = fixed_bins(data,ndir,nhs,equi,info_dir)


%% Initialization

N = size(data,1);

% Create the boundaries of the bins
make_plot = false;
[dirlim,hslim]=define_bins([data(:,1) data(:,3)],ndir,nhs,equi,make_plot);

inds_f = zeros(size(data,1),1); tel = 0;
% if ndir==1
%     [ind_dir]=find(data(:,3)>=dirlim(1) & data(:,3)<=dirlim(2));
%     class=data(ind_dir,:);
%     j=1;
%     
%     if equi==1
%         for i=1:nhs
%             tel=tel+1;
%             if i==nhs
%                 [ind_hs]=find(class(:,1)>=hslim(i) & class(:,1)<=hslim(i+1));
%             else
%                 [ind_hs]=find(class(:,1)>=hslim(i) & class(:,1)<hslim(i+1));
%             end
%             inds_f(ind_dir(ind_hs)) = tel;
%             bin=class(ind_hs,:);
%             count=size(bin,1);
%             p=count/N;
%             Climate(i,j)=p;
%             if isempty(bin)==1
%                 Climate_Mean(i,j,3)=nan;
%                 Climate_Mean(i,j,1)=nan;
%             else
%                 Climate_Mean(i,j,3)=mean_angle(bin(:,3));
%                 Climate_Mean(i,j,1)=(nansum(bin(:,1))/count);
%                 %                 Climate_Mean(i,j,1)=sum((bin(:,1).^m)*(1/count)).^(1/m);
%             end
%             Climate_Mean(i,j,2)=mean(bin(:,2));
%         end
%         
%     else
%         
%         for i=1:nhs
%             tel=tel+1;
%             if i==nhs
%                 [ind_hs]=find(class(:,1)>=hslim(i,j) & class(:,1)<=hslim(i+1,j));
%             else
%                 [ind_hs]=find(class(:,1)>=hslim(i,j) & class(:,1)<hslim(i+1,j));
%             end
%             inds_f(ind_dir(ind_hs)) = tel;
%             bin=class(ind_hs,:);
%             count=size(bin,1);
%             p=count/N;
%             Climate(i,j)=p;
%             if isempty(bin)==1
%                 Climate_Mean(i,j,3)=nan;
%                 Climate_Mean(i,j,1)=nan;
%             else
%                 Climate_Mean(i,j,3)=mean_angle(bin(:,3));
%                 Climate_Mean(i,j,1)=(nansum(bin(:,1))/count);
%                 %                 Climate_Mean(i,j,1)=sum((bin(:,1).^m)*(1/count)).^(1/m);
%             end
%             Climate_Mean(i,j,2)=mean(bin(:,2));
%         end
%     end
%     
% else
    
    for j=1:ndir
        if j==ndir
            [ind_dir]=find(data(:,3)>=dirlim(j) & data(:,3)<=dirlim(j+1));
        else
            [ind_dir]=find(data(:,3)>=dirlim(j) & data(:,3)<dirlim(j+1));
        end
        class=data(ind_dir,:);
%         if equi==1
%             tel=tel+1;
%             for i=1:nhs
%                 if i==nhs
%                     [ind_hs]=find(class(:,1)>=hslim(i) & class(:,1)<=hslim(i+1));
%                 else
%                     [ind_hs]=find(class(:,1)>=hslim(i) & class(:,1)<hslim(i+1));
%                 end
%                 inds_f(ind_dir(ind_hs)) = tel;
%                 bin=class(ind_hs,:);
%                 count=size(bin,1);
%                 p=count/N;
%                 Climate(i,j)=p;
%                 if isempty(bin)==1
%                     Climate_Mean(i,j,3)=nan;
%                     Climate_Mean(i,j,2)=nan;
%                     Climate_Mean(i,j,1)=nan;
%                 else
%                     Climate_Mean(i,j,3)=mean_angle(bin(:,3));
%                     Climate_Mean(i,j,2)=mean(bin(:,2));
% %                     Climate_Mean(i,j,1)=(nansum(bin(:,1))/count);
%                     Climate_Mean(i,j,1)=nanmean(bin(:,1).*bin(:,4)) ./ nanmean(bin(:,4));
%                     %                 Climate_Mean(i,j,1)=sum((bin(:,1).^m)*(1/count)).^(1/m);
%                 end
%             end
%             
%         else
            
            for i=1:nhs
                tel=tel+1;
                if i==nhs
                    [ind_hs]=find(class(:,1)>=hslim(i,j) & class(:,1)<=hslim(i+1,j));
                else
                    [ind_hs]=find(class(:,1)>=hslim(i,j) & class(:,1)<hslim(i+1,j));
                end
                inds_f(ind_dir(ind_hs)) = tel;
                bin=class(ind_hs,:);
                count=size(bin,1);
                p=count/N;
                Climate(i,j)=p;
                if isempty(bin)==1
                    Climate_Mean(i,j,3)=nan;
                    Climate_Mean(i,j,2)=nan;
                    Climate_Mean(i,j,1)=nan;
                else
                    Climate_Mean(i,j,3)=mean_angle(bin(:,3));
                    Climate_Mean(i,j,2)=mean(bin(:,2));
%                     Climate_Mean(i,j,1)=(nansum(bin(:,1))/count);
                    Climate_Mean(i,j,1)=nanmean(bin(:,1).*bin(:,4)) ./ nanmean(bin(:,4));
                    %                 Climate_Mean(i,j,1)=sum((bin(:,1).^m)*(1/count)).^(1/m);
                end
                
            end
        end
%     end
% end

if info_dir==1
    temp=squeeze(Climate_Mean(:,:,3));
    temp(temp<0)=temp(temp<0)+360;
    Climate_Mean(:,:,3)=temp;
end

for c=1:ndir
%     aux=squeeze(Climate_Mean(:,c,:));
    aux=reshape(Climate_Mean(:,c,:),[nhs,3]);
%     aux_p=squeeze(Climate(:,c));
    aux_p=reshape(Climate(:,c),[nhs,1]);
    if c==1
        v=aux;
        P=aux_p;
    else
        v=cat(1,v,aux);
        P=cat(1,P,aux_p);
    end
    clear aux aux_p
end

tel = 0;
for ii=1:size(dirlim,1)-1
    for jj=1:size(hslim,1)-1
        tel = tel + 1;
        bin_limits(tel,:) = [hslim(jj,min(ii,size(hslim,2))) hslim(jj+1,min(ii,size(hslim,2))) dirlim(ii) dirlim(ii+1)];
    end
end

% This is no longer needed:

% if size(data,2)>3
%         for iii=1:size(bin_limits,1)
%         [val1 aux1]=findnearest(data(:,1),bin_limits(iii,1));
%         bin_limits(iii,1)=data(aux1,4);
%         [val2 aux2]=findnearest(data(:,1),bin_limits(iii,2));
%         bin_limits(iii,2)=data(aux2,4);
%     end
% end

v=[v P];
% v=sortrows(v,2);
k=ndir*nhs;
    
%     for iii=1:k
%         aux=find(inds_f==iii);
%         bin_limits(iii,1)=min(data(aux,4));
%         bin_limits(iii,2)=max(data(aux,4));
%     end


end

