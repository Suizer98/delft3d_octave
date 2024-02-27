function D = donar_dia_parse(D, varargin)
%DONAR_DIA_PARSE  Parses a DIA struct and tries to interpret the results
%
%   Parses a DIA struct resulting from the donar_dia_read function and
%   tries to interpret the results. It mainly tries to define some axes
%   corresponding to the data. Using these axes it also splits data (!) to
%   fit the axes. Of course, this is the wrong way around, but most likely
%   the file does not contain enough meta data to do it otherwise. It also
%   creates a lookup table to filter data more easily.
%
%   Syntax:
%   D = donar_dia_parse(D, varargin)
%
%   Input:
%   D         = Result structure from donar_dia_read function
%   varargin  = none
%
%   Output:
%   D         = Input structure with additional info on axes and look-up
%               table
%
%   Example
%   D = donar_dia_parse(D)
%
%   See also donar, donar_dia_read, donar_dia_view

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Apr 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: donar_dia_parse.m 9922 2013-12-30 15:55:16Z boer_g $
% $Date: 2013-12-30 23:55:16 +0800 (Mon, 30 Dec 2013) $
% $Author: boer_g $
% $Revision: 9922 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/donar_essence/donar_dia_parse.m $
% $Keywords: $

%% parse dia struct

for i = 1:length(D.data)

    d = D.data(i).value;

    % parse time
    try
        
        % convert time strings to date numbers
        TYD = xs_get(d,'RKS.TYD');
        
        switch TYD{6}
            case 'sec'
                f = 60*60*24;
            case 'min'
                f = 60*24;
        end
        
        xst = xs_set([],'time_from',datenum([TYD{1:2}],'yyyymmddhhMM'), ...
                        'time_to',  datenum([TYD{3:4}],'yyyymmddhhMM'), ...
                        'dt',       str2double(TYD{5})/f);
                    
        xst = xs_meta(xst,mfilename,'donar_time');
        
        D.data(i).value = xs_set(D.data(i).value,'time',xst);
    end
    
    % parse axes
    try
        xst = xs_get(D.data(i).value,'time');
        
        % build time axes
        xsa = xs_set([],'time',xs_get(xst,'time_from'):xs_get(xst,'dt'):xs_get(xst,'time_to'));
        xsa = xs_meta(xsa,mfilename,'donar_axes');
        
        D.data(i).value = xs_set(D.data(i).value,'axes',xsa);
        
        sz = size(xs_get(D.data(i).value,'WRD.data2'),2);
        
        if sz > 1
            
            % guess the frequency axis based on the number of frequency
            % bins
            switch sz
                case 50
                    f = .001.*[30:10:500];
                    s = [0 1 1];
                case 96
                    f = .001.*[30:10:500];
                    s = [0 0];
                case 101
                    f = .001.*[2.5 10:10:990];
                    s = [0 1];
            end

            D.data(i).value = split_frequency_data(D.data(i).value,f,s);
        end
    end
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function D = split_frequency_data(D,f,s)
    n = length(f);
                
    D = xs_set(D,'axes.frequency',f);
    
    data2 = xs_get(D,'WRD.data2');
    
    c = 0;
    for i = 1:length(s)
        if s(i) == 0; s(i) = n; end;
        
        D = xs_set(D,sprintf('WRD.data%d',i+1),data2(:,c+[1:s(i)]));
        
        c = c+s(i);
    end
end