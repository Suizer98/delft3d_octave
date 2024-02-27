function structOut = delwaq_res_noise(structIn,Substance, Segment, estd, type)
%DELWAQ_RES_NOISE Add noise to a restart structure
%
%   Struct = DELWAQ_RES_NOISE(structIn,Substance, Segment, estd, type)
%   <structIn> must be the ouput of:
%              Struct = DELWAQ_RES('read','FileName',NSubstance,T0)
%   <Substance> The substances to be changed 0 if all
%   <Segment>  The segment to be changed 0 if all
%   <estd>     The standar deviation/percentace of the noise to be added
%   <type>     The type of error. 
%
%   Parameter  Value
%      'type'  'std' add normally distributed random numbers ~N(0,estd)
%              'pstd' add normally distributed random numbers ~N(0,pestd)
%              where pestd is a percentage of the current value
%              pestd = x.estd.
%              'perc' add a percentage of the current value perc[0 1]
                     
%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

if nargin <5
   type = 'std';
end

if Segment==0
   Segment = 1:structIn.NumSegm;
end

if ~isfield(structIn,'NumSubs')
   structIn.NumSubs = length(structIn.SubsName);
end

if isnumeric(Substance) && isscalar(Substance) && Substance==0  
   SubIndex = 1:structIn.NumSubs;
   NSubs = structIn.NumSubs;
   Substance = structIn.SubsName;
elseif isnumeric(Substance) && isscalar(Substance)
   SubIndex = Substance;
   NSubs = length(Substance);
   Substance = {structIn.SubsName{SubIndex}};     %#ok<CCAT1>
elseif iscell(Substance)
   NSubs = length(Substance);
   SubIndex = zeros(1:NSubs);
   for i = 1:NSubs
       if any(ismember(structIn.SubsName,Substance{i}))
          SubIndex(i) = find(ismember(structIn.SubsName,Substance{i}));
       end         
   end
elseif ischar(Substance)
    if any(ismember(structIn.SubsName,Substance))
       SubIndex = find(ismember(structIn.SubsName,Substance));
    else
       SubIndex = 0;
    end
    Substance = {Substance};
    NSubs = 1;      
end

for i = 1:NSubs
    isub = SubIndex(i);
    
    % Generating noise
    if isub==0 
        if strcmp(Substance{i},'TotN')
           CompName   = {'PON1','PON2','PON3','DON','NO3','NH4'};
           CompFactor = [1 1 1 1 1 1];
        
        elseif strcmp(Substance{i},'TotP')
           CompName   = {'POP1','POP2','POP3','PO4','DOP'};
           CompFactor = [1 1 1 1 1];
           
        elseif strcmp(Substance{i},'TOC')
           CompName   = {'POC1','POC2','POC3','DOC'};
           CompFactor = [0.5 0.6250 5 5];
        end
    [isub noise] = get_noise_comp(structIn,CompName,CompFactor,Segment,estd,type);   
    else
        % Noise
        noise = get_noise(estd,type,structIn.data(isub,Segment));
    end
    
   if isub==0
      disp(['Substance: ' Substance{i} ' does not exist'])
   else
       
 
      % Original data
      data = structIn.data(isub,Segment);
      

      % Adding noise
      data = data + noise;
      data(data<0) = 0;
      structIn.data(isub,Segment) = data;     
   end
    
end

structOut = structIn;



%--------------------------------------------------------------------------
% General Noise
%--------------------------------------------------------------------------
function noise = get_noise(estd,type,data)

[d1 d2] = size(data);

% Noise
if strcmp(type, 'perc')
   noise = (data*estd);

elseif strcmp(type, 'pstd')
   noise = randn(d1, d2).*(data*estd);

elseif strcmp(type, 'std')
   noise = randn(d1, d2).*estd;
end

%--------------------------------------------------------------------------
% Noise in the components
%--------------------------------------------------------------------------
function [isub noise] = get_noise_comp(structIn,CompName,CompFactor,Segment,estd,type)

isub = find_names(structIn.SubsName,CompName);
nsub = length(isub);
nseg = length(Segment);

% Original data
comp = structIn.data(isub,Segment);

for i = 1:nsub
    compRatio(i,:) = comp(i,:)*CompFactor(i); %#ok<AGROW>
end

total = sum(compRatio,1);

% Noise
lnoise = get_noise(estd,type,total);
noise = nan(nsub,nseg);
for i = 1:nsub
    noise(i,:) = (compRatio(i,:)./total).*lnoise;
end

%--------------------------------------------------------------------------
% Find names
%--------------------------------------------------------------------------
function iname = find_names(name1,name2)

for i = 1:length(name2)
    iname(i)= find(strcmp(name1,name2{i})); %#ok<AGROW>
end
