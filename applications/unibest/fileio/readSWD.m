function [data] = readSWD(varargin)
%read SWD : Reads complete SWD-files
%It can also read newer SWD-files with 3 decimals. (version number = 4)
%   
%   Syntax:
%     function [data] = readSWD3(filenames,breakwater_length)
%   
%   Input:
%     filenames            (optional) specify a string or cell array with filenames including the path (if not sepcified the file can be selected)
%     breakwater_length    (optional) defined as the x_location of the breakwater tip relative to the MSL-shoreline
%                          (a positive value corresponds with a breakwater tip seaward of the MSL-shoreline)
%   
%   Output:
%     data                 structure with data from SWD file
%                          .waveindex        :  condition nr. (per condition) 
%                          .h0               :  water level (per condition) [m]
%                          .Hs_offshore      :  Hs_offshore (per condition) [m]
%                          .Hsig_dyn         :  Hs at dynamic boundary (per condition) [m]
%                          .T                :  Wave period (per condition) [s]
%                          .Wave_dir         :  Wave direction (per condition) [°N]
%                          .Cangle           :  Coast angle (per condition) [°N]
%                          .Cangle_dyn       :  Coast angle (per condition) [°N]
%                          .duration         :  Duration at dynamic boundary (per condition) [°N]
%                          .usmax            :  us_max (per condition) [m/s]
%                          .usmax_depth      :  depth aqt which us_max is located (per condition) [m]
%                          .Vmax             :  V_max (per condition) [m/s]
%                          .Vmax_depth       :  depth aqt which V_max is located (per condition) [m]
%                          .Qs_gross1        :  gross transports in m^3 per condition (in positive direction of grid)
%                          .Qs_gross2        :  gross transports in m^3 per condition (in negative direction of grid)
%                          .Qs_nett          :  nett transports in m^3 per condition
%                          .Qs_gross1_passed :  gross transports in m^3 per condition passing a structure ('breakwater_length').
%                          .Qs_gross2_passed :  gross transports in m^3 per condition passing a structure ('breakwater_length').
%                          .Qs_nett_passed   :  nett transports in m^3 per condition passing a structure ('breakwater_length').
%                          .nr               :  nr of cross-shore grid cells (cell array for each condition) [-]
%                          .x                :  x-position of cross-shore grid cells (cell array for each condition) [m]
%                          .z                :  z-position of cross-shore grid cells (cell array for each condition) [m]
%                          .Hsig             :  Hsig of cross-shore grid cells (cell array for each condition) [m]
%                          .a                :  a of cross-shore grid cells (cell array for each condition) [-]
%                          .V                :  V of cross-shore grid cells (cell array for each condition) [m/s]
%                          .us               :  us of cross-shore grid cells (cell array for each condition) [m/s]
%                          .Qs               :  Qs of cross-shore grid cells (cell array for each condition) [m3/m/condition] (multiply with dx to get .Qs_gross)
%                          .sQs              :  sum of Qs of cross-shore grid cells over all conditions up to the considered one (cell array for each condition) [m3/m/condition]
%   
%   Example:
%     data = readSWD3('test.SWD');
%     data = readSWD3('test.SWD',240);
%     GROSStransport1    = sum(data.Qs_gross1) [m3/yr]
%     GROSStransport2    = sum(data.Qs_gross2) [m3/yr]
%     NETtransport       = sum(data.Qs_nett) [m3/yr]
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readSWD.m 8631 2013-05-16 14:22:14Z heijer $
% $Date: 2013-05-16 22:22:14 +0800 (Thu, 16 May 2013) $
% $Author: heijer $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readSWD.m $
% $Keywords: $

print_percondition=0;
   
if nargin==2
    bw_length=-1*varargin{2};
end

clear data data2

if nargin==0
    [files, padn] = uigetfiles('*.SWD','SWD-files (*.swd)');
else
    filedata = varargin{1};
    if ~iscell(filedata)
        filedata={filedata};
    end
    files={};
    padn='';
    for ii=1:length(filedata)
        id = strfind(filedata{ii},filesep);
        id = [0,id];
        files{ii} = filedata{ii}(id(end)+1:end);
        padn  = filedata{ii}(1:id(end));
    end
end
% sort files
files2=files{1};for ii=1:length(files)-1;files{ii}=files{ii+1};end;files{length(files)}=files2;

fprintf('\n reading:\n');
for run_id=1:length(files)
    
    %_______________INPUT_______________
    data(run_id).filename=files{run_id};
    data(run_id).pathname=padn;
    fprintf(['  - ' files{run_id} '\n']);
    UB_outputfile=[padn files{run_id}];
    
    %______________Inlezen______________

    fid = fopen(UB_outputfile,'r');
    for ii=1:2
        tline = fgetl(fid);   
    end
    [swd1 swd2 swd3 swd4] = strread(tline,'%f%f%f%f');
    Qs_hulp2{1,1} = [swd1 swd2 swd3 swd4];
    n_grid = swd3;
    n_fixed = 11; %fixed number of lines between tables
    
    % read x and Qs values from file and store in arrays Qs_hulp and x_hulp
    teller1 = 2;
    teller2 = 2;
    while 1
        tline = fgetl(fid);
        teller1 = teller1 +1;
    % inputUB(teller1) = tline; 
        if mod(teller1-1,n_grid+n_fixed)>n_fixed-1
            try
                [swd1 swd2 swd3 swd4 swd5 swd6 swd7 swd8 swd9] = strread(tline,'%f%f%f%f%f%f%f%f%f');
                Qs_hulp(teller1,:) = [swd1 swd2 swd3 swd4 swd5 swd6 swd7 swd8 swd9];
            catch
                Qs_hulp(teller1,:) = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            end 
        else
            Qs_hulp(teller1,:) = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
            
            if mod(mod(teller1-1,n_grid+n_fixed),2)==1
                A = strread(tline);
                Qs_hulp2{mod(teller1,n_grid+n_fixed)/2,ceil(teller2/5)} = A;
                teller2=teller2+1;
            end
        end
        if ~ischar(tline), break, end
    end
    fclose(fid);
        
    % calculate the number of conditions;
    % this value has to be equal to the number of wave bins*number of
    % directions
    N_conditions = round(teller1/(n_grid+n_fixed));
    
    % read needed values in Qs_hulp and x_hulp and store them in Qs-array
    % which has as many rows as grid points and as many columns as conditions
    for k = 1:N_conditions
        % this tells the position in the long Qs-array
        position1 = n_fixed + (k-1) * (n_fixed+n_grid)+1;
        position2 = n_fixed + (k-1) * (n_fixed+n_grid)+n_grid;

        %fprintf(' %5.0f\t%5.0f\n',jj,k);
        data(run_id).nr{k}   = Qs_hulp(position1:position2,1);
        data(run_id).x{k}    = Qs_hulp(position1:position2,2);
        data(run_id).z{k}    = Qs_hulp(position1:position2,3);
        data(run_id).Hsig{k} = Qs_hulp(position1:position2,4);
        data(run_id).a{k}    = Qs_hulp(position1:position2,5);
        data(run_id).V{k}    = Qs_hulp(position1:position2,6);
        data(run_id).us{k}   = Qs_hulp(position1:position2,7);
        data(run_id).Qs{k}   = Qs_hulp(position1:position2,8);
        data(run_id).sQs{k}  = Qs_hulp(position1:position2,9);
        if k==1
        data(run_id).sQs_gross1 = zeros(size(data(run_id).sQs{k}));
        data(run_id).sQs_gross2 = zeros(size(data(run_id).sQs{k}));
        end
        
        data(run_id).Cangle(k)     = Qs_hulp2{1,k}(4);
        data(run_id).Hsig_dyn(k)   = Qs_hulp2{2,k}(1); % at truncation point / where transport starts to be computed
        data(run_id).Cangle_dyn(k) = Qs_hulp2{2,k}(2); % at truncation point / where transport starts to be computed
        data(run_id).waveindex(k)  = Qs_hulp2{3,k}(1);
        data(run_id).h0(k)         = Qs_hulp2{4,k}(1);
        data(run_id).T(k)          = Qs_hulp2{4,k}(3);
        data(run_id).Wave_dir(k)   = Qs_hulp2{4,k}(4);
        data(run_id).duration(k)   = Qs_hulp2{5,k}(2);

        % Find maximum and at water depth of 1 meter
        data(run_id).usmax_1m(k) = interp1q(data(run_id).z{k},data(run_id).us{k},-1);
        data(run_id).Vmax_1m(k)  = interp1q(data(run_id).z{k},data(run_id).V{k},-1);
        
        % velocity of the waves at bottom
        id1=find(abs(data(run_id).us{k})==max(abs(data(run_id).us{k})));
        data(run_id).usmax(k)    = data(run_id).us{k}(id1(1));
        data(run_id).usmax_depth(k)   = data(run_id).z{k}(id1(1));
        
        % wave-induced longshore current
        id2=find(abs(data(run_id).V{k})==max(abs(data(run_id).V{k})));
        data(run_id).Vmax(k)     = data(run_id).V{k}(id2(1));
        data(run_id).Vmax_depth(k)    = data(run_id).z{k}(id2(1));
        
        % Hs offshore
        data(run_id).Hs_offshore(k)=data(run_id).Hsig{k}(1);
        
        % Tp offshore
        
        
        % Nett and Gross transport per condition
        Qs  = data(run_id).Qs{k};
        x   = data(run_id).x{k};
        dx  = (x(2:end)-x(1:end-1));
        dx2 = [dx(1) ; (dx(1:end-1)+dx(2:end))/2; dx(end)];
        gross1=Qs;              gross2=gross1;
        gross1(gross1<0)=0;     gross2(gross2>0)=0;
        data(run_id).Qs_gross1(k) = sum(gross1.*dx2);
        data(run_id).Qs_gross2(k) = sum(gross2.*dx2);
        data(run_id).Qs_nett(k)   = sum(Qs.*dx2);
        
        % Total gross transports
        data(run_id).dx=dx2;
        data(run_id).sQs_gross1 = data(run_id).sQs_gross1+gross1;%.*dx2;
        data(run_id).sQs_gross2 = data(run_id).sQs_gross2+gross2;%.*dx2;
        
        % Nett and Gross transports passing structure
        if nargin>1
            gross1(data(run_id).x{k}>bw_length)=0;
            gross2(data(run_id).x{k}>bw_length)=0;
            data(run_id).Qs_gross1_passing(k) = sum(gross1.*dx2);
            data(run_id).Qs_gross2_passing(k) = sum(gross2.*dx2);
            data(run_id).Qs_nett_passing(k)   = data(run_id).Qs_gross1_passing(k)+data(run_id).Qs_gross2_passing(k);
        else
            data(run_id).Qs_gross1_passing(k) = nan;
            data(run_id).Qs_gross2_passing(k) = nan;
            data(run_id).Qs_nett_passing(k)   = nan;
        end
        
    end
    clear data0 Qs_hulp

    % print table
    if print_percondition==1
        if nargin==0
            fprintf('\n  Hs_offshore\t  Tp  \t Qs\n');
            fprintf('\t    [m]    \t  [s]  \t[m3/yr]\n');
            fprintf('\t%8.2f\t%8.2f\t%8.1f\n',[data(run_id).Hs_offshore;data(run_id).T;data(run_id).Qs_nett]);
        elseif nargin==1
            fprintf('\n  Hs_offshore\t  Tp  \t Qs_nett  Qs_passing\n');
            fprintf('\t    [m]    \t  [s]  \t [m3/yr]\t [m3/yr]\n');
            fprintf('\t%8.2f\t%8.2f\t%8.1f\t%8.1f\n',[data(run_id).Hs_offshore;data(run_id).T;data(run_id).Qs_nett;data(run_id).Qs_nett_passing]);
            fprintf('  summed: [m3]\n');
            if max(sum(abs(data(run_id).Qs_gross1_passing))>sum(abs(data(run_id).Qs_gross2_passing)))
                summed_Qs_gross_passing = sum(data(run_id).Qs_gross1_passing);
            else
                summed_Qs_gross_passing = sum(data(run_id).Qs_gross2_passing);
            end
            fprintf('\t     \t     \t%8.1f\t%8.1f\n',[sum(data(run_id).Qs_nett);summed_Qs_gross_passing]);
        end
    elseif run_id==length(files)
        fprintf('\n--------------------------------------------------------------------\n');
        fprintf('     filename         \t gross1\t gross1\t nett\n');
        fprintf('                      \t [m3/yr]\t [m3/yr]\t [m3/yr]\n');
        for ii=1:length(data)
            fprintf(' %s\t', [data(ii).filename, repmat(' ',[1 22 - length(data(ii).filename)])]);
            fprintf('%10.0f\t' , sum(data(ii).Qs_gross1));
            fprintf('%10.0f\t' , sum(data(ii).Qs_gross2));
            fprintf('%10.0f\n' , sum(data(ii).Qs_nett));
        end
    end
end
fprintf('\n SWD_read finished correctly \n');
