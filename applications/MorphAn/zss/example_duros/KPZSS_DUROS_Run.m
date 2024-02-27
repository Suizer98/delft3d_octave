function KPZSS_DUROS_Run(profile,category,scenario)

%   --------------------------------------------------------------------
%   Matlab script to load input for DUROS-calculations and loop through
%   multiple profiles and scenarios. Subplots of the DUROS-calculations
%   will be saved as well as a Excel table with the numerical values of the
%   output
%   M.Q.T. Groenewegen 
%   maurits.groenewegen@rws.nl
%   03-nov-2021
%
%   Syntax:
%   KPZSS_DUROS_Run(profile,category,scenario)
%
%   Example:
%   KPZSS_DUROS_Run(7,[1:5],[1:6]);
%
%   Input:
%   profile     - number of bottom profile [1:26]
%   category    - flooding probability category [1:5]
%   scenario    - morphological scenario [1:6]
%   --------------------------------------------------------------------

% Input
addpath('../functions_duros')
dir_profiles    = '..\data\Profielen_input.xlsx';
dir_hbc         = '..\data\Hydraulische_randvoorwaarden.xlsx';
[Profiles,sheets,fn,Scenarios,Rp_in,Hs_in,Tp_in,D50,limits,lwb]= KPZSS_DUROS_input(dir_profiles,dir_hbc);

for n = profile
 
for c = category
    
    Samenvatting = [];
    
for s = scenario
    
    [Summary,ctitle] = KPZSS_DUROS_visualisation_5(n,s,c,sheets,Profiles,fn,Scenarios,Rp_in,Hs_in,Tp_in,D50,limits,lwb);
    Samenvatting     = cat(1,Samenvatting,Summary);
    
end

    close all

    writetable(Samenvatting,'DUROS_output.xlsx', 'Sheet', [char(sheets(n)),'_',ctitle]);
    
end
end
end