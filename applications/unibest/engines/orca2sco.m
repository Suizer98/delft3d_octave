function orca2sco(varargin)
%orca2sco : Write orca data to sco
%
%   Syntax:
%     function orca2sco(orca struct, sco_filename, duration, waterlevel, numberofdays)
% 
%   Input:
%     s             :  orcastruct 
%     sco_filename  :  output filename ('') (If output sco-file is not specified 'orca2sco.sco' will be the output file)
%     duration      :  [Nx1] matrix of durations
%     waterlevel    :  [Nx1] matrix of still water levels
%     numberofdays  :  total number of days
%
%   Output:
%     .sco file
%   
%   Example:
%     orca2sco(s, 'output.sco');  or  orca2sco(s, 'output.sco', duration); etc	  
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

% $Id: orca2sco.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/SCOextract/orca2sco.m $
% $Keywords: $

err_value=0;

if nargin==0
    fprintf('\n-------------------------------------------\n  please specify at least the orca struct\n-------------------------------------------\n\n');
    err_value=1;
elseif nargin==1
    sco_output   = 'orca2sco.sco';
    scn          = varargin{1};
elseif nargin>1
    sco_output   = varargin{2};
    scn          = varargin{1};
end
input_dataname={'H0','Hs','Tp','Dir','duration'};
data_num=[1 2 3 4 5];
output_data={[],[],[],[],[]};

if exist('scn')
    for ii=1:length(input_dataname)
        i = strcmpi({scn.parameter.name},input_dataname{ii});
        if any(i)
            output_data{data_num(ii)}=scn.parameter(i).data;
        end
%         for i=1:length(scn.parameter)
%             if strcmp(scn.parameter(i).name,input_dataname{ii})
%                 output_data{data_num(ii)}=scn.parameter(i).data;
%             end
%         end
    end
    % if no duration than scn.parameter(6).data
    if isempty(output_data{5})
        output_data{5}=scn.parameter(6).data;
    end
    % if no wave height than scn.parameter(1).data
    if isempty(output_data{2})    
        output_data{2}=scn.parameter(1).data;    
    end    
    % if no wave period than scn.parameter(2).data
    if isempty(output_data{3})
        output_data{3}=scn.parameter(2).data;    
    end    
    % if no wave direction than scn.parameter(3).data
    if isempty(output_data{4})
        output_data{4}=scn.parameter(3).data;    
    end    
    % no waterlevels in scn then zeros
    if isempty(output_data{1})    
        output_data{1}=zeros(length(scn.parameter(1).data),1);        
    end        
end
numberofdays    = 365;

if nargin==3   
    output_data{5}  = varargin{3};
elseif nargin==4     
    output_data{5}  = varargin{3};
    output_data{1}  = varargin{4};   
elseif nargin==5     
    output_data{5}  = varargin{3};
    output_data{1}  = varargin{4};   
    numberofdays    = varargin{5};   
elseif nargin>5
    err_value=1;
end


if isfield(scn, 'location')
    output_data2(1)=scn.location.coordinates(1);
    output_data2(2)=scn.location.coordinates(2);
else
    output_data2=[0 0];
end

if err_value~=1
    writeSCO(sco_output,...
         output_data{1},...              %waterlevel
         output_data{2},...              %waveheight,...
         output_data{3},...              %waveperiod,...
         output_data{4},...              %direction,...
         output_data{5},...              %duration,...
         output_data2(1),...             %X,...
         output_data2(2),...             %Y
         numberofdays);                  %numOfDays
end