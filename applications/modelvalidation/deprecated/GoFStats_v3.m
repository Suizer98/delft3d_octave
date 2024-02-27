% This script computes 'Goodness of Fit' scores. The script plotGoF_v2.m
% plots the target diagrams
%
% Information on 'Goodness of Fit' scores are explained in
% <a href="http://dx.doi.org/10.1016/j.jmarsys.2008.05.014">Jason K. Jolliff et al., 2009.</a> Summary diagrams for coupled hydrodynamic-
% ecosystem model skill assessment, Journal of Marine Systems 76 (2009) 64-82 .
%
% The statistics are computed for modeled timeseries Model assuming that
% the reference is provided by the in-situ measurements Meet.
%
% If option subset is deactivated, computes statistics on the whole model
% timeseries (default is option subset activated).
% 
% The script is adapted from earlier versions: author unknown, and loops
% now over several substances
%
% $Id: GoFStats_v3.m 7255 2012-09-20 12:30:02Z blaas $
% $Date: 2012-09-20 20:30:02 +0800 (Thu, 20 Sep 2012) $ 31/07/2012
% $Author: blaas $ Valesca Harezlak
% $Revision: 7255 $ v3
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/modelvalidation/deprecated/GoFStats_v3.m $
% $Keywords: preparing data for plotting GoF diagrams$ 

clear all
close all
clc

modeldir = 'd:\GEM-Egmond\meetdata\Gof_Files\modeldata\';
meetdir = 'd:\GEM-Egmond\meetdata\Gof_Files\meetdata\';

OPT.subset  = 1;

folders=dir(meetdir);

subsnames={'empty','empty','E','N','NH4','NO3','O2','P','PO4','SiO2',...
    'concentration_of_chlorophyll_in_water','concentration_of_suspended_matter_in_water','sea_water_salinity'};      %substance names as in measurement data
odsnames={'dummy','dummy','Ext','TOTN','NH4','NO3','OXY','TOTP',...
    'PO4','SI','Chlfa','IM1','Sal'};                                          %substance names as in model data

for i=3:length(folders) %loop over substances; first two cells are dummies 
    
    substance=folders(i).name;
    meetdirectory=[meetdir,folders(i).name,'\'];
    cd (meetdirectory);
    fileinfo = dir([meetdirectory,'*.txt']);
    
    %% Reading measurement data
    for l=1:length(fileinfo)  %loop over stations with measurement data
        
        version1 = strrep(fileinfo(l).name,folders(i).name,'');
        version2 = strrep(version1,'_','');
        station= strrep(version2,'monitor.txt','');
        
        
        fid = fopen  (fileinfo(l).name,'r');
        disp('Scanning file, please wait ...')
        nt     = 0;
        
        while true
            tline = fgetl(fid);
            
            if ~ischar(tline), break
            end
            nt = nt + 1;
        end
        
        fseek(fid,0,-1); % rewind file
        
        disp(['found',num2str(nt),' lines.'])
        
        disp('Reading file, please wait ...')
        nrow = 0;
        
        for k=1:nt
            
            if mod(nrow,100)==0
                disp(['read',num2str(nrow),'lines.'])
            end
                        
            % Read data
            record = fgetl(fid);
            
            nrow = nrow + 1;
            
            %Interpret one line
            [tok{1}, record] = strtok(record);
            [tok{2}, record] = strtok(record);
            
            % write part of string to structure
            Meet.(station).(substance).time(nrow)=str2double(tok{1});
            Meet.(station).(substance).data(nrow) = str2double(tok{2});
            
            tok = {};
            
        end
        
        fclose(fid);
        
    end
       
    %% Reading model data
    
    substancemod=odsnames{i};
    modeldirectory=[modeldir,folders(i).name,'\'];
    cd (modeldirectory);
    fileinfo_model = dir([modeldirectory,'*.txt']);
    
    for z=1:length(fileinfo_model)
        
        version3 = strrep(fileinfo_model(z).name,odsnames{i},'');
        version4 = strrep(version3,'_','');
        stationmod= strrep(version4,'model.txt','');
               
        test = fopen  (fileinfo_model(z).name,'r');
        disp('Scanning file, please wait ...')
        nt     = 0;
        
        while true
            
            fline= fgetl(test);
            
            if ~ischar(fline), break
                
            end
            nt = nt + 1;
        end
        
        fseek(test,0,-1); % rewind file
        
        disp(['found',num2str(nt),' lines.'])
        
        disp('Reading file, please wait ...')
        nrow = 0;
        
        for x=1:nt
            
            if mod(nrow,100)==0
                disp(['read',num2str(nrow),'lines.'])
            end
            
            % Read data
            record = fgetl(test);
            
            nrow = nrow + 1;
            
            %Interpret one line
            [tok{1}, record] = strtok(record);
            [tok{2}, record] = strtok(record);
            
            % write part of string to structure
            Model.(stationmod).(substancemod).time(nrow)= str2double(tok{1});
            Model.(stationmod).(substancemod).data(nrow) = str2double(tok{2});
                       
            tok = {};
            
        end
      fclose(test);
    end
    Meetloc.(subsnames{i}).loc=fieldnames(Meet);
    Modelloc.(subsnames{i}).loc=fieldnames(Model);
end

%% filling .mat file with substances per station for all stations

for f=3:length(odsnames) %loop over substances
    for d=1:length(Meetloc.(subsnames{f}).loc)                                          %loop over measurement stations
        for e=1:length(Modelloc.(subsnames{f}).loc)                                     %loop over model stations
            if strcmpi (Meetloc.(subsnames{f}).loc{d},Modelloc.(subsnames{f}).loc{e})   %matching locations
                if strcmpi (subsnames(f),folders(f).name)                               %matching substances
                    if isfield(Meet.(Meetloc.(subsnames{f}).loc{d}),subsnames(f))       %check whether substance is measured for that particularly station
                        
                        NetCDFTime = Meet.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).time; 
                        NetCDFValues=Meet.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).data;   
                        
                        detlim=min(NetCDFValues);
                        
                        for i=1:365
                            if Model.(Modelloc.(subsnames{f}).loc{e}).(odsnames{f}).data(i)<detlim
                                Model.(Modelloc.(subsnames{f}).loc{e}).(odsnames{f}).data(i)=detlim;
                            end
                        end
                        
                        D3DTimePointstest= Model.(Modelloc.(subsnames{f}).loc{e}).(odsnames{f}).time;
                        D3DValuestest =Model.(Modelloc.(subsnames{f}).loc{e}).(odsnames{f}).data;
                        
                        for i=1:length(NetCDFValues)
                            h=NetCDFTime(i);
                            [~, array_position] = min(abs(D3DTimePointstest-h));
                            LB=max(D3DTimePointstest(array_position)-7,1);          %lower boundary is period 7 days before measurement (-7, min of daynumber 1)
                            UB=min(D3DTimePointstest(array_position)+7,364);        %upper boundary is period 7 days after measurement (+7, max of daynumber 364)
                            g=(LB:UB);
                            q=D3DValuestest(g);
                            [min_difference, array_position_a] = min(abs(q-NetCDFValues(i)));
                            MODEL.data(i)=q(array_position_a);
                            MODEL.time(i)=NetCDFTime(i);
                        end
                        
                        D3DTimePoints=MODEL.time;
                        
                        if strcmpi (odsnames{f},'Sal') ||strcmpi (odsnames{f},'Chlfa')
                            NetCDFValues=log(NetCDFValues);
                            D3DValues=log(MODEL.data);
                        else
                            D3DValues=MODEL.data;
                        end
                        
                       
                        %% combine timeseries:
                        %     %   - missing observations are replaced by NaNs
                        %     %   - missing model values are interpolated in time
                        
                        tmpTime = cat(2, squeeze(D3DTimePoints), squeeze(NetCDFTime));
                        
                        [Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).time, idx] = sort(tmpTime);
                        
                        newData.model = (squeeze(D3DValues));
                        
                        newData.obs   = NaN + zeros(size(squeeze(D3DTimePoints)));
                        tmpData.model = cat(2, squeeze(D3DValues)  , squeeze(newData.model));
                        tmpData.obs   = cat(2, squeeze(newData.obs), squeeze(NetCDFValues));
                        
                        combined_all.D3DTimePoints = tmpTime(idx);
                        combined_all.NetCDFTime    = tmpTime(idx);
                        combined_all.D3DValues     = tmpData.model(idx);
                        combined_all.NetCDFValues  = tmpData.obs(idx);
                       
                        %     %% Keep only (model) points that have an equivalent in the observations
                        %     %% and compute the statistics on this subset
                        
                        if (OPT.subset)
                            msk = find(~isnan(combined_all.NetCDFValues));
                            combined.D3DTimePoints = combined_all.D3DTimePoints(msk);
                            combined.NetCDFTime    = combined_all.NetCDFTime(msk);
                            combined.D3DValues     = combined_all.D3DValues(msk);
                            combined.NetCDFValues  = combined_all.NetCDFValues(msk);
                        else
                            combined.D3DTimePoints = combined_all.D3DTimePoints;
                            combined.NetCDFTime    = combined_all.NetCDFTime;
                            combined.D3DValues     = combined_all.D3DValues;
                            combined.NetCDFValues  = combined_all.NetCDFValues;
                        end
                        
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_comb = combined.D3DValues;
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_comb = combined.NetCDFValues;
                                            
                        %% compute means and stddev of normal distributions
                                               
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_mean   = nanmean(combined.D3DValues);
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_mean     = nanmean(combined.NetCDFValues);
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_stddev = nanstd (combined.D3DValues);
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_stddev   = nanstd (combined.NetCDFValues);
                        
                        %% compute residus of normal distributions
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_res    = combined.D3DValues - Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_mean;
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_res      = combined.NetCDFValues - Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_mean;
                                         
                        %% number of records
                                                
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).n = length(combined.D3DValues);
                        
                        %% correlation coefficient
                       
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).R = nanmean(Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_res.*...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_res)/ ...
                            (Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_stddev.*Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_stddev);
                        
                        
                        %% normalized standard deviation
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_stddev = Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_stddev/...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_stddev;
                        
                        %% total RMS difference
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).RMSD = sqrt(nanmean((Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_comb-...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_comb).^2));
                        
                        %% bias
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).bias = Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_mean...
                            - Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_mean;
                        
                        %% unbiased RMS difference
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).unbiased_RMSD = sqrt(nanmean((Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_res-...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_res).^2));
                       
                        %% normalized bias
                        
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_bias = (Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_mean -...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_mean)/ ...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_stddev;
                        %% normalized unbiased RMS difference
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_unbiased_RMSD = Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).unbiased_RMSD/...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_stddev;
                        
                        %% model efficiency
                                                
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_efficiency = 1.0 - ...
                            nansum((combined.D3DValues-combined.NetCDFValues).^2)/ ...
                            nansum(Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_res.^2);
                        
                        %% skill score
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).skill_score = 1.0 - ((1.0+Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).R)/2.)* ...
                            exp(-(Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_stddev-1)^2/0.18);
                        
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).CF = nanmean(abs(combined.D3DValues - combined.NetCDFValues))./ ...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_stddev;
                        
                        
                        %% Compute coordinates for the target diagrams
                       
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).xTarget = sign(Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).model_stddev-...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_stddev)*...
                            Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_unbiased_RMSD;
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).yTarget = Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).normalized_bias;
                        Data.(Meetloc.(subsnames{f}).loc{d}).(subsnames{f}).obs_name = Meetloc.(subsnames{f}).loc{d};
                        
                    end
                end
            end
        end
    end
end

cd d:\GEM-Egmond\scripts\
save Data