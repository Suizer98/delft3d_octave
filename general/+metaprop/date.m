% DATE property for date in matlab datenums, has calender editor. Only for dates, not a date+time. 
%
% See also: metaprop.time, metaprop.example

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Thijs Damsma
%
%       Thijs.Damsma@VanOord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
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
% Created: 21 Feb 2014
% Created with Matlab version: 8.3.0.73043 (R2014a)

% $Id: date.m 10275 2014-02-24 15:42:52Z tda.x $
% $Date: 2014-02-24 23:42:52 +0800 (Mon, 24 Feb 2014) $
% $Author: tda.x $
% $Revision: 10275 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+metaprop/date.m $
% $Keywords: $

%%
classdef date < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.util.Date');
    end
    properties (SetAccess=immutable)    
        jEditor
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end    
    methods
        function self = date(varargin)
            self = self@metaprop.base(varargin{:});
            
            dateModel = com.jidesoft.combobox.DefaultDateModel;
            dateFormat = java.text.SimpleDateFormat('dd-MMM-yyyy');
            dateModel.setDateFormat(dateFormat);

            self.jEditor   = com.jidesoft.grid.DateCellEditor(dateModel, 1);

            % set specific restrictions
            self.DefaultAttributes = {'scalar','integer'};
            self.DefaultClasses    = {'double'};

            self.CheckDefault();
        end
    end
    methods (Static)
        function mValue = mValue(jValue)
            % conversion from java value to matlab value
            mValue = datenum(...
                jValue.getYear + 1900,...
                jValue.getMonth + 1,...
                jValue.getDate,...
                jValue.getHours,...
                jValue.getMinutes,...
                jValue.getSeconds);
        end
        function jValue = jValue(mValue)
            jValue = java.util.Date(datestr(mValue));
        end
    end
end