function getdefaults(varargin)
%GETDEFAULTS  checks all input and sets predefined defaults
%
%This function can be called within another function. It checks
%for the existance of input variables. When a variable is not found
%it is set to default. A message can be displayed and is stored using
%writemessage.
%
%syntax:
%   getdefaults on
%   getdefaults off
%   getdefaults(variables,default_values,display_ind);
%   getdefaults(var_1,def_1,disp_1,var_2,def_2,disp_2,...);
%   getdefaults(...,'quiet',...);
%   getdefaults(variables,default_values,'quiet');
%
%input:
%   'quiet'     -   suppresses all display messages
%   variables   -   cell containing all variables that need to be checked
%                   as char-arrays.
%   default_values- cell with the same size as variables containing all
%                   defaults for the variables specified in 'variables'.
%   display_ind -   double with same size as variables denoting whether a
%                   message has to be displayed if default value is set 
%                   (using 1 or 0).
%   var_1       -   individual variable name given as a character array.
%                   This variable has to be given in paires together with
%                   def_1 and disp_1.
%   def_1       -   default for variable specified in var_1.
%   disp_1      -   1 or 0 for displaying message when altering var_1.
%
%See also writemessage, assignin

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: getdefaults.m 1995 2009-11-27 13:50:27Z heijer $
% $Date: 2009-11-27 21:50:27 +0800 (Fri, 27 Nov 2009) $
% $Author: heijer $
% $Revision: 1995 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_defaults/getdefaults.m $
% $Keywords: $

%% Process input

% recall stop criterion
persistent stop

% check if stopcriterion is given or number of input arguments is ok
if nargin<3
    if nargin==1 && (strcmp(varargin,'on') || strcmp(varargin,'off'))
        if strcmp(varargin,'on')
            stop=0;
        else
            stop=1;
        end
    else
        display('This function needs at least 3 input arguments');
        return
    end
end

% if stop is on, quit
if stop
    return
end

% filter 'quiet' from input
quiet=0;
if any(strcmp(varargin,'quiet'))
    varargin(:,strcmp(varargin,'quiet'))=[];
    quiet=1;
end

ST = dbstack;
CallerFileName = [];
for i = 2:length(ST)
    CallerFileName = [ST(i).name ' -> ' CallerFileName]; %#ok<AGROW>
end
if isempty(CallerFileName)
    CallerFileName = 'Base';
end

%% Retrieve vars and defaults from input

if iscell(varargin{1})
    vars=varargin{1};
    defaults=varargin{2};
    try
        disptexttemp=varargin{3};
    catch
        disptexttemp=ones(size(vars));
    end
else
    vars={varargin{1:3:end}};
    defaults={varargin{2:3:end}};
    disptexttemp=[varargin{3:3:end}];
end

disptext=ones(size(vars));
disptext(1:length(disptexttemp))=disptexttemp;

if length(vars) ~= length(defaults)
    display('Input arguments are not processed correctly. Check your input.');
    return
end

%% In case of quiet call, set all indicators to 0

if quiet
    disptext=zeros(size(vars));
end

%% Check all input variables

for i=1:length(vars)
    exst = evalin('caller',['exist(''' vars{i} ''',''var'')']);
    if ~exst
        default= defaults{i};
        s=size(default);
        sz=[num2str(s(1)) 'x' num2str(s(2))];
        if ischar(default)
            deftext=['"' default '"'];
        elseif isnumeric(default) && ~any(s>1)
            deftext=num2str(default);
        else
            deftext=['<' sz ' ' class(default) '>'];
        end
        msg = [CallerFileName ': variable: "' vars{i} '" set to default: ' deftext];
        assignin('caller', vars{i},default);
        writemessage(0,msg);
        if disptext(i)
            disp(msg);
        end
    end
end