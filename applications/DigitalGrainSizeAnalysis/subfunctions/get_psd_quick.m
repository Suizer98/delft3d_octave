
function [P1,scale]=get_psd_quick(himt,density)
% 
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================
[rows,cols] = size(himt);

wave=zeros(67,length(1:density:rows));
counter=1;
for j=1:density:rows
    
    %     x=himt(j,:);
    if cols>1024
        x=himt(j,:); %himt(j,round((size(himt,2)-1024)/2)+1:round((size(himt,2)-1024)/2)+1024);
    else
        x=[himt(j,:),zeros(1,1024-size(himt,2))]; x=x(1:1024);
    end
    
    fileID = fopen('im.dat','w');
    fprintf(fileID,'%i\n',x);
    fclose(fileID);
    
    %run program
    system(['.',filesep,'wavecomp']);
    
    try
        dat=load('fort.6');
        if j==1
            scale=dat(15:end-7,2)';
        end
        
        wave(:,counter)=1./scale.*(dat(15:end-7,3))';
        counter=counter+1;
    catch
        continue
    end
end
scale=scale./2;

P1=var(wave,[],2);
P1=P1./sum(P1);

% 
% if max(scale) > (1024/3)
%     f=find(scale>(1024/3),1,'first');
%     scale=scale(1:f);
%     P1=P1(1:f);
% end
% P1=P1./sum(P1);

P1(1)=P1(1)/10;
P1=P1./sum(P1);

delete fort.6 im.dat



