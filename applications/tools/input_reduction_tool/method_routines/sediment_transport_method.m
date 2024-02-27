function [v,inds_f,bin_limits,input_reduction_output]=sediment_transport_method(data,nhs,ndir,SN_angle)

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
%data=[hs tp dir transp];

%check if number of directional bins is even
if ~mod(ndir,2)==0
    error('Number of direction bins should be even!');
end

N=size(data,1);
data(:,5)=[1:size(data,1)]';

Hs1 = min(data(:,1));

ndir_or=ndir;
ndir=ndir_or/2;

% check for negative directions
min_dir_ori=min(data(:,3));
if min_dir_ori<0
    negative_angles=true;
else
    negative_angles=false;
    data(:,3)=convert_wave_dir(data(:,3),SN_angle,2);
end

    ind_neg=find(data(:,3)<0);
    neg=data(ind_neg,:);
    
    ind_pos=find(data(:,3)>=0);
    pos=data(ind_pos,:);

inds_f = nan(N,1);

for group=1:2
       
    if group==1
        data=abs(neg);
    elseif group==2
        data=pos;
    end
    
    dir_min=min(data(:,3));
    dir_max=max(data(:,3));
    
    classes=data(data(:,3)>=dir_min | data(:,3)<=dir_max & data(:,1)>=Hs1,:);
    total=sum(classes(:,4)); % total sediment transport
    directions(1,1)=dir_min;
    a=1;
    b=dir_min;
    
    for i=0.05:0.05:(dir_max-dir_min)
        if a==ndir
            class=classes(find(classes(:,3)>=b & classes(:,3)<=(dir_max)),:);
            directions(a+1,1)=dir_max;
        else
            class=classes(find(classes(:,3)>=b & classes(:,3)<(dir_min+i)),:);
            if isempty(class)==0
                if sum(class(:,4))>=total/ndir
                    eval(['classe_' num2str(a) '=class;'])
                    clear class
                    directions(a+1,1)=dir_min+i;
                    a=a+1;
                    b=dir_min+i;
                end
            end
        end
    end
    
    eval(['classe_' num2str(a) '=class;'])
    clear class total a b i;
    
        if group==1
            directions=directions.*-1;
        end
    
    if group==1
        ii=1;
    elseif group==2
        ii=1+((ndir_or*nhs)/2);
    end
    if group==1
        ic=1;
    elseif group==2
        ic=(ndir*nhs)+1;
    end
    i=1;
    
    for j=1:ndir
        eval(['aux=classe_' num2str(j) ';'])
        transp_dir=sum(aux(:,4));
        Hsf=max(aux(:,1));
        h1=Hs1;
        n=1;
        for h=(Hs1+0.005):0.005:Hsf
            a=find(aux(:,1)>=h1 & aux(:,1)<h);
            s=sum(aux(a,4));
            if n==nhs
                clear a s;
                a=find(aux(:,1)>=h1 & aux(:,1)<=Hsf);
                Hs_aux=aux(a,:);
                inds_f(aux(a,5)) = ic;
                table(i,1)=mean(Hs_aux(:,1));
                table(i,2)=mean(Hs_aux(:,2));
                if negative_angles
                    if group==1
                        table(i,3)=(mean_angle(Hs_aux(:,3)))*-1;
                    else
                        table(i,3)=(mean_angle(Hs_aux(:,3)));
                    end
                else
                    table(i,3)=(mean_angle(Hs_aux(:,3)));
                end
                table(i,4)=[size(Hs_aux,1)/N];
                bin_limits(i,1)=h1;
                bin_limits(i,2)=Hsf;
                bin_limits(i,3)=directions(j,1);
                bin_limits(i,4)=directions(j+1,1);
                transp(i,1)=sum(Hs_aux(:,4));
                i=i+1;
                ii=ii+1;
                ic=ic+1;
                n=1;
                clear Hs_aux  s
                break
            elseif s>=(transp_dir/nhs) && n<nhs
                Hs_aux=aux(a,:);
                inds_f(aux(a,5)) = ic;                
                table(i,1)=[mean(Hs_aux(:,1))];
                table(i,2)=[mean(Hs_aux(:,2))];
                if negative_angles
                    if group==1
                        table(i,3)=(mean_angle(Hs_aux(:,3)))*-1;
                    else
                        table(i,3)=(mean_angle(Hs_aux(:,3)));
                    end
                else
                    table(i,3)=(mean_angle(Hs_aux(:,3)));
                end
                table(i,4)=size(Hs_aux,1)/N;
                bin_limits(i,1)=h1;
                bin_limits(i,2)=h;
                bin_limits(i,3)=directions(j,1);
                bin_limits(i,4)=directions(j+1,1);
                transp(i,1)=sum(Hs_aux(:,4));
                i=i+1;
                ic=ic+1;
                clear  a  Hs_aux
                h1=h;
                n=n+1;
                
            end
            clear a s
        end
        clear Hsf n aux h1 transp_dir
    end
    
        if group==1
            table_neg=table;
            bin_limits_neg=bin_limits;
        elseif group==2
            table_pos=table;
            bin_limits_pos=bin_limits;
        end
        clear table bin_limits
        
end

    v=[table_neg;table_pos];
    bin_limits=[bin_limits_neg;bin_limits_pos];
  
     if negative_angles==0
         v(:,3)=convert_wave_dir(v(:,3),SN_angle,1);
         bin_limits(:,3)=convert_wave_dir(bin_limits(:,3),SN_angle,1);
         bin_limits(:,4)=convert_wave_dir(bin_limits(:,4),SN_angle,1);
     end
     
    tabs=array2table(flipud(sortrows(v,4)),'VariableNames',{'Hs','Tp','Dir','P'});
    input_reduction_output.v=tabs;
    input_reduction_output.bin_limits=bin_limits;
    input_reduction_output.cluster=inds_f;

end
