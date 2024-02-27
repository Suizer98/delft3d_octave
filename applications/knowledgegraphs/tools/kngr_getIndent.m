function [indentation] = getIndent (level_previous)
% GETINDENT gets a new indent for the interpret-text of a graph
%
% Syntax:
% [indentation] = getIndent (level_previous)
%
% Input:
% level_previous = 
%
% Output:
% indentation    = a string containing a number of spaces
%
% See also: getNextLayers
 
%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2007  FOR INTERNAL USE ONLY
% Version:  Version 1.0, December 2007 (Version 1.0, December 2007)
% By:      <Mark van Koningsveld (email:mark.vankoningsveld@deltares.nl)>
%--------------------------------------------------------------------------------
 
indentation = [];
for i = 1 : level_previous
    indentation = [indentation '   ']; %#ok<AGROW> if possible pre-allocate ... for now ok
end
