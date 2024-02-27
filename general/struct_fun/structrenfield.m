function s = structrenfield(s, orgfieldname , newfieldname, varargin)
%STRUCTRENFIELD  Renames field(s) in the structure
%
%   Renaming function because Matlab doesn't support this directly.
%
%   Syntax:
%       s = structrenfield(s, oldfieldname , newfieldname)
%
%   Input:  s  = structure
%           orgfieldname = original field name(s), string or cellstring 
%           newfieldname = new field name(s), string or cellstring 
%
%       $varargin  =
%
%   where the following <keyword,value> pairs have been implemented (values indicated are the current default settings):
%   	'orderfields'    , 0   = Flag for ordering fields so that the output is the same
%
%   Output: s  = structure
%
%   Example
%       s = struct('first',1,'second',2,'thirt',3);
%       s = structrenfield(s, 'first' , 'First')
%
%       s = struct('first',1,'second',2,'thirt',3);
%       s = structrenfield(s, 'first' , 'First', 'orderfields', 1)
%
%       s = structrenfield(s, {'second' 'thirt' 'tmp'} , {'Second' 'Thirt' 'tmp'}, 'orderfields', 1)
%
%   See also rmfield fieldnames

%% settings
% defaults
OPT.orderfields = 0 ; % Flag for ordering fields so that the output is the same

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin);

% Checks
if ischar(orgfieldname) ; orgfieldname = cellstr(orgfieldname); end
if ischar(newfieldname) ; newfieldname = cellstr(newfieldname); end

assert(numel(orgfieldname) == numel(newfieldname), 'Input fieldnames not equal!')

% Inits
if OPT.orderfields ; fields = fieldnames(s); end

% Rename
for nf = 1:numel(orgfieldname)    
    if isfield(s,orgfieldname{nf})
        s.(newfieldname{nf}) = s.(orgfieldname{nf}) ;
        s = rmfield(s, orgfieldname{nf});
    else
        sprintf('Not a valid field: %s\n',orgfieldname{nf})
    end
end

% Order fields
if OPT.orderfields
    idx  = ismember(fields, orgfieldname(:) );
    idx2 = ismember(orgfieldname(:),fields);
    fields(idx) = newfieldname(idx2) ;
    s = orderfields(s , fields) ;
end

%   --------------------------------------------------------------------
%   Copyright (C) 2016 Van Oord, RHO@vanoord.com
%
%   This library is copyrighted Van Oord software intended for internal
%   use only: you cannot redistribute it outside of Van Oord.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. In case of
%   errors or suggestions, refer to the central HeadURL address below.
% --------------------------------------------------------------------
%   $Id: structrenfield.m 12719 2016-05-11 09:01:13Z rho.x $
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/struct_fun/structrenfield.m $
%   $Keywords:
% --------------------------------------------------------------------
