%INSPECTABLE enables interactive (GUI) setting of custom object properties, similar to the matlab inspector
%
%   Relies on metaprop to descript the meta properties of the class
%   properties
%   
%   Example:
%      metaprop.example
% 
%See also oop, metaprop, setproperty

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

% $Id: inspectable.m 11108 2014-09-15 14:10:07Z gerben.deboer.x $
% $Date: 2014-09-15 22:10:07 +0800 (Mon, 15 Sep 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11108 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+oop/inspectable.m $
% $Keywords: $

%%
classdef (Abstract) inspectable < oop.setproperty
    properties (Hidden,Transient,SetAccess = immutable)
        metaprops % metaprops must be assigned by the constructor using the construct_metaprops functions
    end
    
    % object_metaprops = metaprop.Construct(mfilename('class'),{
    %     'Date',@metaprop.date,{
    %         'Description','Date field'}
    %     'Number',@metaprop.doubleScalar,{
    %         'Description','A single double precision number'
    %         'Attributes',{'>',1}}
    %     });
        
    properties (Hidden,Transient)
        % Stores the reason why the inspector was closed (e.g. 'ok' or 'cancel').
        Inspector_LastButtonPressed = ''
    end
    
    methods (Abstract,Hidden,Access = protected)
        % Each implementation must define a method to construct the metaprops. 
        % Usually this should be of the form 
        %     value = self.<class_name>_metaprops
        % In the case of subclasses, this can be expanded
        %     value = mergestructs(...
        %                self.<class_name>_metaprops,...
        %                construct_mp@<superclass_name>)
        value = construct_metaprops(self)
    end
    
    methods 
        function self = inspectable() % constructor
            % Constructor assigns value tp metaprops
            self.metaprops = self.construct_metaprops;
        end

        function inspector = inspect(self,varargin)
            % normally inspect will be called with it's metaprops, but it
            % is possible to inspect with only a subset of the metaprops
            inspector = metaprop.Inspect(self,self.metaprops,varargin{:});
        end
    end
end