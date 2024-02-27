%DELWAQ_DATENUM Read Delwaq files times.
%
%   TIMEOUT = DELWAQ_DATENUM(FILE)
%   Gives back the times in FILE
%
%   TIMEOUT = DELWAQ_DATENUM(STRUCTOUT)
%   Gives back the times in STRUCTOUT where:
%   Struct = DELWAQ('open','FileName')
%
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_DIFF, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function timeOut = delwaq_datenum(varargin)

if isstruct(varargin{1})
   S = varargin{1};    
else
  if exist(varargin{1},'file')==2;
     S = delwaq('open',varargin{1});
  end
end
timeOut = delwaq('read',S,1,1,0);