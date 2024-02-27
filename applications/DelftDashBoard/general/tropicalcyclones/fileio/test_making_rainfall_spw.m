load('p:\11206515-flosup2021\02_data_analysis\recreated_hurricanes_JPM\spw_flosup_ipet\TC_0065\input_hurricanes_tc.mat');
load('p:\11206515-flosup2021\02_data_analysis\recreated_hurricanes_JPM\spw_flosup_ipet\TC_0065\input_hurricanes_spw.mat');

% spw.rain_relation =  'bacla_symmetrical_mode'
spw.rain_relation =  'bacla'
spw.rain_info.random = 1
spw.rain_info.asymmetrical = 0
spw.rain_info.perc = 50
spw.rain_info.bacla.data = 2;     % Stage IV blend data trained model
spw.rain_info.bacla.split = 4;    % xn forced to get pmax fit, bs based on area under graph
spw.rain_info.bacla.type = 1;     % vmax based model
spw.rain_info.bacla.loc = 2;      % land fit (constant pmax till rmax as in IPET, after rmax classic holland fit)
spw.rain_info.bacla.perc = 50;
[tc,spw] = wes4(tc,'tcstructure',spw,['cyclone.spw'])