function [v,inds_f,bin_limits]=energy_flux_method(data,nhs,ndir)

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

%
% Energy Flux method (Adaptaded from Joao Dobrochinski and Lindino Benedet)
% selects the classes with equal energy flux
% Input:
% data = wave data [Hs Tp Dir] - Dir must vary from 0 to 360 (no negative values)
% Hs1 = minimal value of Hs to be used in the analysis
% nhs = number of hs bins
% ndir = number of directional bins
% disc = check for discontinuity in the angles, if range is discontinuos
% (eg. 225 to 5) disc=1 if range is continuos, disc=0
%        r = how many random runs

%Output:
%result = Hs Tp Dir P, where P frequency of occurence of representative wave
%condition
tic
g=9.81;
pho=1025;

% check for nans in the data
filter=find(data>=999 | isnan(data));
[I,J]=ind2sub(size(data),filter);
data(I,:)=[];

Hs1 = min(data(:,1));

%check for negative directions
min_dir_ori=min(data(:,3));
if min_dir_ori<0
    data(:,3) = data(:,3)-min_dir_ori;
end

data(:,4)=(1/8)*pho*g*(data(:,1).^2)*(1/2)*(g/(2*pi)).*data(:,2); %calculates energy flux for the complete data

angulot=naut2cart(data(:,3))*(pi/180);
data(:,5)=cos(angulot).*data(:,4);%componente x do vetor energia para o caso bitterbal
data(:,6)=sin(angulot).*data(:,4);%componente y do vetor energia para o caso bitterbal

data(:,7)=[1:size(data,1)]';

disc = 0;
ma   = mean_angle(data(:,3));
if ma < 90 && ma > -90
    if max(data(:,3))>270 & min(data(:,3))<90
        disc = 1;
    end
end

if disc==1
    data(:,3)=data(:,3)+180;  %fix discontinuity in angles range
    data(data(:,3)>360,3)=(data(data(:,3)>360,3))-360;
end

dir_min=min(data(:,3));
dir_max=max(data(:,3));

classes=data(data(:,3)>=dir_min | data(:,3)<=dir_max & data(:,1)>=Hs1,:);
total=sum(classes(:,4)); % total energy
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

if disc==1
    data(:,3)=data(:,3)-180;
    data(data(:,3)<0,3)=data(data(:,3)<0,3)+360;
    
    classes(:,3)=classes(:,3)-180;
    classes(classes(:,3)<0,3)=classes(classes(:,3)<0,3)+360;
    
    directions=directions-180;
    directions(directions<0)=directions(directions<0)+360;
    
end

inds_f = nan(size(classes,1),1);
i=1;
for j=1:ndir
    eval(['aux=classe_' num2str(j) ';'])
    energy_dir=sum(aux(:,4));
    Hsf=max(aux(:,1));
    h1=Hs1;
    n=1;
    for h=(Hs1+0.005):0.005:Hsf
        a=find(aux(:,1)>=h1 & aux(:,1)<h);
        e=sum(aux(a,4));
        if n==nhs
            clear a e;
            a=find(aux(:,1)>=h1 & aux(:,1)<=Hsf);
            Hs_aux=aux(a,:);
            inds_f(aux(a,7)) = i;
            her=sum(Hs_aux(:,5));
            hnr=sum(Hs_aux(:,6));
            if her>=0 & hnr>=0
                dir_result=90-atan(hnr/her)*180/pi;
            elseif her<0 & hnr>=0
                dir_result=270+atan(hnr/(her*-1))*180/pi;
            elseif her<0 & hnr<0
                dir_result=270-atan((hnr*-1)/(her*-1))*180/pi;
            elseif her>=0 & hnr<0
                dir_result=90+atan((hnr*-1)/her)*180/pi;
            end
            result_mean=((her/size(Hs_aux,1))^2+(hnr/size(Hs_aux,1))^2)^(1/2);
            table(i,1)=(16*result_mean/(pho*g*(g/(2*pi))*(mean(Hs_aux(:,2)))))^(1/2);
            table(i,2)=mean(Hs_aux(:,2));
            table(i,3)=dir_result;
            table(i,4)=size(Hs_aux,1)/size(data,1);
            bin_limits(i,1)=h1;
            bin_limits(i,2)=Hsf;
            bin_limits(i,3)=directions(j,1);
            bin_limits(i,4)=directions(j+1,1);
            %             limits(i,5)=min(Hs_aux(:,2));
            %             limits(i,6)=max(Hs_aux(:,2));
            energy(i,1)=sum(Hs_aux(:,4));
            i=i+1;
            n=1;
            clear her hnr dir_result result_media Hs_aux  e
        elseif e>=(energy_dir/nhs)
            Hs_aux=aux(a,:);
            inds_f(aux(a,7)) = i;
            her=sum(Hs_aux(:,5));
            hnr=sum(Hs_aux(:,6));
            if her>=0 & hnr>=0
                dir_result=90-atan(hnr/her)*180/pi;
            elseif her<0 & hnr>=0
                dir_result=270+atan(hnr/(her*-1))*180/pi;
            elseif her<0 & hnr<0
                dir_result=270-atan((hnr*-1)/(her*-1))*180/pi;
            elseif her>=0 & hnr<0
                dir_result=90+atan((hnr*-1)/her)*180/pi;
            end
            result_mean=((her/size(Hs_aux,1))^2+(hnr/size(Hs_aux,1))^2)^(1/2);
            table(i,1)=(16*result_mean/(pho*g*(g/(2*pi))*(mean(Hs_aux(:,2)))))^(1/2);
            table(i,2)=mean(Hs_aux(:,2));
            table(i,3)=dir_result;
            table(i,4)=size(Hs_aux,1)/size(data,1);
            bin_limits(i,1)=h1;
            bin_limits(i,2)=h;
            bin_limits(i,3)=directions(j,1);
            bin_limits(i,4)=directions(j+1,1);
            %             limits(i,5)=min(Hs_aux(:,2));
            %             limits(i,6)=max(Hs_aux(:,2));
            energy(i,1)=sum(Hs_aux(:,4));
            i=i+1;
            clear her hnr dir_result a result_media Hs_aux
            h1=h;
            n=n+1;
            
        end
        clear a e
    end
    clear Hsf n aux h1 energia_dir
end

if min_dir_ori<0
    data(:,3) = data(:,3)+min_dir_ori;
    classes(:,3) = classes(:,3)+min_dir_ori;
    directions = directions+min_dir_ori;
    bin_limits(:,[3 4]) = bin_limits(:,[3 4])+min_dir_ori;
    table(:,3) = table(:,3)+min_dir_ori;
end

v=table;

bin_limits;

end