
addpath('../functions_xb')

dir_profiles = '..\data\Profielen_input.xlsx';
dir_hbc = '..\data\Hydraulische_randvoorwaarden.xlsx';

[Profiles,sheets,fn,Scenarios,Category,Rp_in,Hs_in,Tp_in,D50,limits,lwb]= KPZSS_XBeach_input_2(dir_profiles,dir_hbc);

dir_xboutput = 'd:\Repositories\OET\matlab\applications\MorphAn\zss\example_xb\xbeach\'; 
fig_path = 'd:\Repositories\OET\matlab\applications\MorphAn\zss\example_xb\fig\';


%%


for s = [1]%[2:(size(Scenarios,2))+1]                  % Morfological scenario
for zss = [0]               % Sea level rise

for n = [21:26] %[1:15,17,19:25] % Bottom profiles

if s ==1
	b = 2:5;
elseif s ==2
	b = [2 6:8];
elseif s ==3
	b = [2 9:11];
elseif s ==4
	b = [2 12:14];
elseif s ==5
	b = [2 15:17]; 
elseif s ==6
 	b = [2 18:20];
end

if zss == 0
 	i = b(1);
elseif zss == 1 
 	i = b(2);
elseif zss == 2 
  	i = b(3);
elseif zss == 3 
  	i = b(4);
end 

for c = [3]%[1:5]
    try
    [Vremaining,Vrequired] = KPZSS_XBeach_visualisation_simple_2(n,s,c,zss,Profiles,sheets,fn,Scenarios,Category,Rp_in,Hs_in,Tp_in,limits,lwb,dir_xboutput,fig_path);
%     catch
%     count = count + 1


    end
Tsheets{n+26*(c-1),1} = sheets(n); 
Tzss(n+26*(c-1),1) = zss;
Ts{n+26*(c-1),1} = Scenarios(i-1);  
Tcat{n+26*(c-1),1} = Category(c);
TVremaining(n+26*(c-1),1) = [Vremaining];
TVrequired(n+26*(c-1),1) = [Vrequired];   


end

end
end
end

%%

T = table([Tsheets],[Ts],[Tzss],[Tcat],[TVremaining],[TVrequired],'VariableNames',{'Kustvak' 'Scenario' 'ZSS' 'Categorie' 'Vremaining' 'Vrequired'});

newT = rmmissing(T);

writetable(newT,'Xbeach_output_2.xlsx', 'Sheet', Scenarios(i-1));

close all