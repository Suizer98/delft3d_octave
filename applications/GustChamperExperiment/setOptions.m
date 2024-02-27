function varargout = setOptions(varargin)
%UNTITLED  Set Gust Champer experiment settings below;
%
%   More detailed description goes here.
%
%   Syntax:
%   OPT = setOptions(varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   varargin  =
%         diameter            = diameter in mm.
%         slope_calibration   = slope calibration equation
%         shear               = Shear Pa
%         V               	= Voltage responding to shear
%         perc                = pump percentage
%         discharge           = pump discharge in ml/min
%         dt                  = 0.1;
% 
% 
%         %% Multiple files
%         dir                 = directory which contains subdirectory with files
%         contains            = Only use the folders which contain this
%         params              = name of the params file which is given in every folder.
% 
%         %% Single files
%         % raw data files
%         usef                = Use raw data files or not (true/false) 
%         fdir                = raw data file directory
%         fext                = raw data file extension 
%         ffilter             = filter, used if included in the file.
% 
%         % xls data files
%         usexls              = Use excel files or not (true/false)
%         xlsdir              = Excel file directory
%         xlsext              = Excel file extension
%         xlsfilter           = Excel files included if the name includes this.
%         xlssheet            = Excel sheet name;
%         xlsrange            = Excel range;
%
%   Output:
%   varargout = OPT;
%
%   Example
%   OPT = setOptions('fdir','D:/kpru')
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 <COMPANY>
%       Kees Pruis
%
%       kees.pruis@boskalis.com	
%
%       +31 78 696 8470
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
% Created: 09 Sep 2014
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% INPUT

% Information about the experiment
OPT.diameter            = 92; % diameter in mm.
OPT.slope_calibration   = 5.2;


OPT.shear               = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8]; %0.88];       %Shear Pa
OPT.V               	= [2.3 3.5 4.5 5.5 6.4 7.5 8.6 10.9]; %10.9];      %Voltage responding to shear
OPT.perc                = [11 14 16 17 18 19 19 19]; %19];                 %pump percentage
OPT.discharge           = [124 156 192 209 220 226 230 232]; %232];        %pump discharge in ml/min
OPT.dt                  = 0.1;

% Uberdir
OPT.dir                 = 'd:\Projects\ShortQuestions\Chatham\Tests\';
OPT.contains            = 'Test *';                                       %Use folder which contain this
OPT.params              = 'params.txt';


% raw data files
OPT.usef                = true;
OPT.fdir                = 'd:\Projects\ShortQuestions\Chatham\Tests\12_hour';
OPT.fext                = 'raw';
OPT.ffilter             = OPT.fext;

% xls data files
OPT.usexls              = false;
OPT.xlsdir              = 'd:\Projects\ShortQuestions\Chatham\XLS';
OPT.xlsext              = 'xls';
OPT.xlsfilter           = 'Shear';
OPT.xlssheet            = 'Sheet1';
OPT.xlsrange            = 'B1:B10800';

% return defaults (aka introspection)
if nargin==0;
   varargout = {OPT};
   return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
varargout = {OPT};
