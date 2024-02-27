function ITHK_dunerules(sens,varargin)

global S

% dunerules.m

% Alma de Groot
% Ecoshape, WUR
% 15 nov 2011

% calculates potential for dune formation based on Unibest outcomes
% not finished yet: gradual long-term behaviour does not lead to right
% results => also use zminz0 in itself??

% clear all 
% close all


% extract and initialise matrices for computations
%load PRNdata
if nargin>1
    reference=1;
    PRNdata = S.UB(sens).data_ref.PRNdata;
else
    reference=0;
    PRNdata = S.UB(sens).results.PRNdata;
end
stored = PRNdata.stored;
if S.userinput.indicators.slr == 1
    for jj=1:length(S.PP(sens).settings.tvec)
        zminz0(:,jj) = PRNdata.zSLR(:,jj)-PRNdata.zSLR(:,1);
    end    
else
    zminz0 = PRNdata.zminz0;
end
year   = PRNdata.year;
% duneclasstemp = ones(size(stored(1),1));  % initialise matrix for calculations
duneclass = ones(size(stored));           % initialise matrix for results


% settings
cumyear = 5; 			% integration time of budgets/coastline changes
% switching conditions from one class to another (% zoek nog na met werkelijke strandbreedtes)
b1 = 0;                 % erosive
b2 = 10 * cumyear;      % number is accretion rate per year for new dune formation
b3 = -10 * cumyear;     % number is erosion rate per year

% calculate cumulative over past x years
% for coastline
cumzminz0 = zminz0 - circshift(zminz0, [0 cumyear]);
cumzminz0(:,1:cumyear) = zminz0(:,1:cumyear); % - repmat(zminz0(:,1), 1, cumyear);  (begin is zero anyway)
% for budgets
cumstored = stored;
for p = 1:(cumyear-1)
    cumstored = cumstored + circshift(stored, [0 p]);  % gaat dit goed voor cumyear = 1?***
end


% the calculations
for q = 2:size(stored,2) % not for year 1
  
    duneclasstemp = ones(size(zminz0,1),1);  % reset/initialise temporary matrix for dune classes. 
	% ones because class 1 (erosive) is sort of standard at this coast.
    
    case1 = (cumzminz0(:,q) < b1)  & ...
        (duneclass(:,q-1) == 1 | duneclass(:,q-1) == 2 );
    case2 = (cumzminz0(:,q) >= b1)& (cumzminz0(:,q) < b2)   & ...
        (duneclass(:,q-1) == 1 | duneclass(:,q-1) == 2 );
    case3 = (cumzminz0(:,q) >= b2) & ...
        (duneclass(:,q-1) == 1 | duneclass(:,q-1) == 2 );
    case4 = (cumzminz0(:,q)  < b3) & ...
        (duneclass(:,q-1) == 3 );
    case5 = (cumzminz0(:,q) >= b3) & ...
        (duneclass(:,q-1) == 3 );
    
    duneclasstemp(case1) = 1;   % erosive
    duneclasstemp(case2) = 2;   % balance and slight new dune formation ('normal')
    duneclasstemp(case3) = 3;   % new dune formation on wide beach
    duneclasstemp(case4) = 2;   % from wide beach to normal
    duneclasstemp(case5) = 3;   % wide beach remains
    
    duneclass(:,q) = duneclasstemp;
	
	% check if calculation is ok
    if sum(case1 + case2 + case3 + case4 + case5) ~= size(case1,1)
        disp('warning: not all point classified correctly. Binary matrices may be incorrect.')
    end
end

if reference==0
    S.PP(sens).dunes.duneclass = duneclass;
else
    S.PP(sens).dunes.duneclassref = duneclass;
end

for jj = 1:length(S.PP(sens).settings.tvec)
    S.PP(sens).dunes.duneclassRough(:,jj) = interp1(S.PP(sens).settings.s0,duneclass(:,jj),S.PP(sens).settings.sgridRough,'nearest');
end

ITHK_kmlicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough,S.PP(sens).dunes.duneclassRough,S.settings.indicators.dunes.icons,str2double(S.settings.indicators.dunes.offset))

%{
% plot beach changes
% figure; imagesc(zminz0); colorbar
% xlabel('time (year)')
% ylabel('distance along coast')
% title('beach changes')

% plot dune classes
% figure
% imagesc(duneclass);
% xlabel('time (year)')
% ylabel('distance along coast')
% colorbar
% title('dune class')



%% alternative classification based on z0 only
b11 = 0;
b12 = 75;   % zoek nog na met werkelijke strandbreedtes
b13 = 200;  % zoek nog na met werkelijke strandbreedtes
duneclass_alt = ones(size(zminz0));
duneclass_alt(zminz0 < b11) = 1; 						% erosive
duneclass_alt((zminz0 < b12) & (zminz0 >= b11)) = 2;	% normal and slight progradation
duneclass_alt(zminz0 >= b12) = 3; 						% wide beach with potential for new dunes
duneclass_alt(zminz0 >= b13) = 4; 						% extremely wide beach with potential for new dunes

% plot dune classes
% figure
% imagesc(duneclass_alt);
% xlabel('time (year)')
% ylabel('distance along coast')
% colorbar 	% legenda van colorbar nog aanpassen met klassen
% title('dune class based on difference with initial situation')
%}
