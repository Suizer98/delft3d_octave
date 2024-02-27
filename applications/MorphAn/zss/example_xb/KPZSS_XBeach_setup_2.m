%   --------------------------------------------------------------------
%   Matlab script to create input files for Xbeach calculations and a file
%   to run the calculations on a High Performance Werkplek (HPW) 
%   M.Q.T. Groenewegen 
%   maurits.groenewegen@rws.nl
%   3-nov-2021
%   --------------------------------------------------------------------

addpath('../functions_xb')

dir_profiles = '..\data\Profielen_input.xlsx';
dir_hbc = '..\data\Hydraulische_randvoorwaarden.xlsx';

[Profiles,sheets,fn,Scenarios,Category,Rp_in,Hs_in,Tp_in,D50,limits,lwb]= KPZSS_XBeach_input_2(dir_profiles,dir_hbc);

%% Selectie 

n = [21:26];  %profile
s = ([2]);
% s = ([20]);
% s = ([2 5 8 11 14 17 20]);
%s = ([3 4 6 7 9 10 12 13 15 16 18 19]);
%s = [2:(size(Scenarios,2))+1];
cat = [3];

locatie = ['xbeach'];

%% Create Xbeach inputfiles

%   --------------------------------------------------------------------
%   This code will create the required input files for the Xbeach 
%   calculations. The inputfiles are saved in folderstructure (profile ->
%   scenario -> flooding probability category)
%   --------------------------------------------------------------------

cd(locatie)

for k=n
    if( isnumeric(Profiles.(fn{k})) )
        folder_name = sheets(k);    % First order subfolder with profile
            a = size(Scenarios,2)+1;
            for i = s
                Profielen = [];
                Profielen = Profiles.(fn{k});
                Profielen(any(isnan(Profielen), 2), :) = [];
                
                x_Jrk = Profielen(:,1);
                x_Jrk = rmmissing(x_Jrk);

                z_Jrk = Profielen(:,i);
                z_Jrk = rmmissing(z_Jrk);
                folder_name_2 = Scenarios(i-1); % Second order subfolder with scenario
                    for c = cat
                    folder_name_3 = Category(c);  % Third order subfolder with flooding probability category        
                        if c == 1
                            Rp_in2 = Rp_in.Rp_I;
                            Hs_in2 = Hs_in.Hs_I;
                            Tp_in2 = Tp_in.Tp_I;
                        elseif c == 2 
                            Rp_in2 = Rp_in.Rp_II;
                            Hs_in2 = Hs_in.Hs_II;
                            Tp_in2 = Tp_in.Tp_II;
                        elseif c == 3                     
                            Rp_in2 = Rp_in.Rp_III;
                            Hs_in2 = Hs_in.Hs_III;
                            Tp_in2 = Tp_in.Tp_III;
                        elseif c == 4 
                            Rp_in2 = Rp_in.Rp_IV;
                            Hs_in2 = Hs_in.Hs_IV;
                            Tp_in2 = Tp_in.Tp_IV;
                        elseif c == 5 
                            Rp_in2 = Rp_in.Rp_V;
                            Hs_in2 = Hs_in.Hs_V;
                            Tp_in2 = Tp_in.Tp_V; 
                        end 
                        
                        if i == 2
                            b = 3;
                        elseif ismember(i,[3,6,9,12,15,18]) == 1
                            b = 4;
                        elseif ismember(i,[4,7,10,13,16,19]) == 1
                            b = 5;  
                        elseif ismember(i,[5,8,11,14,17,20]) == 1
                            b = 6; 
                        end

                        Rp_bc = Rp_in2(k,b);
                        Hs_bc = Hs_in2(k,b);
                        Tp_bc = Tp_in2(k,b);
                        D50_bc = D50(k,3);
                        
                        dest = [num2str(folder_name),'\',num2str(folder_name_2),'\',num2str(folder_name_3)];

                        KPZSS_setupXBeachParams(x_Jrk,z_Jrk,Rp_bc,Hs_bc,Tp_bc,D50_bc,dest)
                    end                  



            end
    end
end

%% Create modeldir list

%   --------------------------------------------------------------------
%   This code will create a list with the location of the input files for
%   the calculations that have to be performed. This list will be part of
%   the bat-file (created in the next section). Variables that can be
%   changed are 'k', 'i' and 'c', which are the profiles, scenarios and
%   flooding probability category respectively 
%   --------------------------------------------------------------------


count=0;
modeldirs = cell(1);
for k= n%[1:15,17,19:25] % Selection profiles
    if( isnumeric(Profiles.(fn{k})) )
        folder_name = sheets(k);
        for i = s % Selection scenarios (S6_3)
            folder_name_2 = Scenarios(i-1);
            for c = cat % Selection flooding probability category (Iv)
                    folder_name_3 = Category(c);
            modeldir = [pwd filesep num2str(folder_name),...
                '\',num2str(folder_name_2),'\',num2str(folder_name_3), '\input'];
            count = count+1;
            modeldirs(count,1) = {modeldir};
            end
        end
    end
end


%% Create bat-file

%   --------------------------------------------------------------------
%   This code will create a bat-file which will be used to run xbeach
%   calculations on a HPW without matlab. This bat-file has information
%   about the calculations that need to be performed, the location of the
%   inputfiles and the location of xbeach.exe
%   --------------------------------------------------------------------

% Location of Xbeach program
dirModel = 'd:\Repositories\OET\matlab\applications\MorphAn\zss\example_xb\xbeach\netcdf_Release\';
xbeachExecutable = [dirModel,'\xbeach.exe'];    %   xbeachExecutable: direction of the Xbeach excecutable (char)

% Name of the file to run the xbeach calculations
filenameBat = 'run_xbeach';

nProc = 2 ;                     %   nProc: number of runs simultanoues
batchfilename = char(strcat(filenameBat,'.bat'));%   batchfilename: name of the batchfile (char)

generate_multiprocess_xbeach_runs(xbeachExecutable,modeldirs,nProc,batchfilename)