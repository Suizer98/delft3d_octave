%save_psd.m
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

mkdir([pwd,filesep,'outputs',filesep,'data'])

csvFunHead = @(str)sprintf('%s,',str); % for strinsg in strings
csvFunBody = @(str)sprintf('%f,',str); % for numbers in strings
zeroFun = @(x)x==0; % for converting zeros to nans

towrite=[];
for ii=1:length(sample)
    
    if ~isempty(sample(ii).dist)
        
        numhead=num2cell(sample(ii).dist(:,1)');
        numhead(cell2mat(cellfun(zeroFun,numhead,'UniformOutput',0)))={NaN};
        heads={'image','arith_mean','arith_sort','arith_skew','arith_kurt',...
            'geom_mean','geom_sort','geom_skew','geom_kurt',...
            'p=5','p=10','p=16','p=25','p=50','p=75','p=84','p=90','p=95',...
            'prc_silt','prc_sand','prc_gravel','prc_cobble'};
        
        outfile=[pwd,filesep,'outputs',filesep,'data',...
            filesep,sample(ii).name(1:regexp(sample(ii).name,'\.')-1),'_summ.csv'];
%         if exist(outfile,'file')==2
%             delete(outfile)
%         end       
        outfile=check_savedfile(outfile,'csv');

        fid=fopen(outfile,'wt');
        
        x=heads;
        xchar = cellfun(csvFunHead, x, 'UniformOutput', false);
        xchar = strcat(xchar{:});
        xchar = strcat(xchar(1:end-1));
        
        x=numhead;
        xchar2 = cellfun(csvFunBody, x, 'UniformOutput', false);
        xchar2 = strcat(xchar2{:});
        xchar2 = strcat(xchar2(1:end-1),'\r\n');
        fprintf(fid,[xchar,',',xchar2]);
        fprintf(fid,'\r\n');
        clear xchar xchar2 numhead x heads
        
        if sample(ii).resolution~=1 %assumes length unit is mm
            percent_silt = 100.*sum(sample(ii).dist(sample(ii).dist(:,1)<=0.063,2) );
            percent_sand = 100.*sum(sample(ii).dist(sample(ii).dist(:,1)>0.063 & sample(ii).dist(:,1)<=2,2));
            percent_gravel = 100.*sum(sample(ii).dist(sample(ii).dist(:,1)>2 & sample(ii).dist(:,1)<=64,2));
            percent_cobble = 100.*sum(sample(ii).dist(sample(ii).dist(:,1)>64,2) );
            num=num2cell([sample(ii).arith_moments,sample(ii).geom_moments,sample(ii).percentiles,...
                percent_silt,percent_sand,percent_gravel,percent_cobble,sample(ii).dist(:,2)']);
            num(cell2mat(cellfun(zeroFun,num,'UniformOutput',0)))={NaN};
            towrite=[num];
            
        else
            towrite=[num2cell([sample(ii).arith_moments,sample(ii).geom_moments,sample(ii).percentiles,...
                NaN,NaN,NaN,NaN,sample(ii).dist(:,2)'])];
        end
        
        x=towrite;
        xchar = cellfun(csvFunBody, x, 'UniformOutput', false);
        xchar = strcat(xchar{:});
        xchar = strcat(xchar(1:end-1),'\r\n');
        x={sample(ii).name};
        xchar2 = cellfun(csvFunHead, x, 'UniformOutput', false);
        xchar2 = strcat(xchar2{:});
        xchar2 = strcat(xchar2(1:end-1));
        
        fprintf(fid,[xchar2,',',xchar]);
        clear xchar xchar2 towrite x
        
    end
    
    fclose(fid);
    disp(['Results saved to ... ',outfile])
    
end

uiwait(msgbox('Results saved ','','modal'));


