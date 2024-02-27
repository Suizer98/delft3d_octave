%FILTERFLAGS_CHLA Filter data according with the flags
%   [INDEX DATA] = filterflags(DATA,FLAGNUMBER,INDEX)
%   INDEX(p,q) = 1 if DATA(p,q) in not label FLAGNUMBER
%   otherwise INDEX(p,q) = 0.
%   Arguments:
%   <DATA> Meris data
%   <FLAGNUMBER> The flags to be removed
%   <INDEX> [NOT NECESARY] if some index must be consider. INDEX must be
%   logical
%   See also: FLAGS, BITAND, MERIS_NAME2META, MERIS_MASK

%     History: 23-mar-2010 delete values smaller that 0 
%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 17.02.2010
%      Author: S. Gaytan Aguilar 
%                 (Adapted for use with chlorophyll a values by Carlos de Lannoy)
% -------------------------------------------------------------------------
function [indexOut data] = filterflags_chla(data,flagNumber,index)

% Settings
maxChla = 200;
minChla = 0;
maxstd = 'exp';
maxstd2 = 150;
valKd = -1;
maxchisq = 200;
maxP = 0.99;

if ~exist('index','var');
   index = true(size(data.L2_flags.data));
else
    if ~islogical(index)
       index = ~isnan(index);
    end        
   disp(['meris_mask: removed bit ',num2str(24),' : OUTSIDE MASK'])
end

iflag = true(size(data.L2_flags.data));

iland = flagNumber==24;
if any(iland)
   flagNumber(iland)=[];
   flagNumber(end+1) = 24;
end

for i = 1:length(flagNumber)
    
    % Filtering regular flags [0 to 23]
    if flagNumber(i)<=23 && flagNumber(i)>=0
          iflag = meris_mask(data.L2_flags.data,flagNumber(i));
          iflag = ~isnan(iflag);
   
    % Filtering values inside the north sea mask
    elseif flagNumber(i) == 24
        data.longitude.data(~index) = nan;
        data.latitude.data(~index) = nan;
        iflag = inmask(data.longitude.data,data.latitude.data,'lonlat');
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : OUTSIDE MASK'])
   
   % Filtering large values of TSM
    elseif flagNumber(i) == 25
        iflaga = data.TSM.data<= maxTSM;
        iflagb = data.TSM.data> minTSM;
        iflag = iflaga & iflagb;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : TSM > ' num2str(maxTSM)])
    
   % Filtering large standard deviations
    elseif flagNumber(i) == 26
        if strcmp(maxstd,'exp')

           iflag1 = data.Chla_std_err.data <= data.Chla.data;
           iflag2 = data.TSM_std_err.data <= data.TSM.data;
           iflag = iflag1 & iflag2;

           disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : sigma > ' 'exp'])
        else
           iflag = data.Chla_std_err.data <= maxstd;
           disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : sigma > ' num2str(maxstd)])
        end
        
    % Filtering negative Kd
    elseif flagNumber(i) == 27 && isfield(data,'Kd')
        iflag = data.Kd.data(:,:,1)~= valKd;       
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : Kd == ' num2str(valKd)])

    % Filtering big chisq values
    elseif flagNumber(i) == 28 && isfield(data,'chisq')
       iflag = data.chisq.data <= maxchisq;
       disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : x^2 > ' num2str(maxchisq)])

    % Filtering large P values
    elseif flagNumber(i) == 29 && isfield(data,'P')
        iflag = 10.^-(data.P.data)<= maxP;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : P > ' num2str(maxP)])
    
    % Filtering values ==0
    elseif flagNumber(i) == 30
        iflag = data.TSM.data> minTSM;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : TSM < ' num2str(minTSM)])

    % Filtering values ==0
    elseif flagNumber(i) == 31
        iflag = data.Chla.data> minChla;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : Chla < ' num2str(minChla)])
    
    % Filtering values with low chisq AND high standard deviation
    elseif flagNumber(i) == 32
        iflag1 = data.Chla_std_err.data <= maxstd2;
        iflag2 = data.chisq.data >= 0.1;
        iflag = iflag1 | iflag2;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : sigma > ' num2str(maxstd2),' & X2 < 0.1'])
        
    % Filtering borders from pictures, using L2 FLags 14 to 20
    % simultaneously, removing borders of zeros.
    elseif flagNumber(i) == 33
        iflag = data.L2_flags.data ~= 2080768;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : L2 Flags 14 to 20'])
    
    % Filtering Chla above 200 mg m-3 in bloom season (march - may), and
    % Chla above 120 mg m-3 during the rest of the year.
    elseif flagNumber(i) == 34
        Start_bloom = 62/365;
        End_bloom = 151/365;
        iflagTime = data.time.data/365.25;
        iflagTime = iflagTime - floor(iflagTime);
        if iflagTime < Start_bloom || iflagTime > End_bloom
            iflag = data.Chla.data <=120;
        else
            iflag = data.Chla.data <= 200;
        end            
    disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : Chla >120 not near coast, June - Feb'])
    
    % Filtering values with extremely (i.e. unlikely) low standard deviation.
    elseif flagNumber(i) == 35
        iflag = data.Chla_std_err.data >1*10^-2;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : seChla < 10^-2'])
        
    % Filtering large values of Chla
    elseif flagNumber(i) == 36
        iflag = data.Chla.data<= maxChla;
        disp(['meris_mask: removed     ',num2str(flagNumber(i)),' : Chla > ' num2str(maxChla)]) 
    end
    
    index = iflag & index;
  
end

indexOut = nan(size(data.Chla.data));
indexOut(index) = 1;

