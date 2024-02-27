function segArea = delwaq_seg_area(lgaFile)
%DELWAQ_XYSEGMENT Read Delwaq LGA files and returns the area of the segments 
%    
%   GRIDSTRUCT = DELWAQ_SEG_AREA(LGAFILE)Returns the area of the segment
%                specified by the vertices in the vectors X and Y in the
%                LGAFILE
% 
%   See also: DELWAQ, DELWAQ_XYSEGMENT, DELWAQ_CONC, DELWAQ_RES, 
%             DELWAQ_DATENUM, DELWAQ_STAT, DELWAQ_INTERSECT

%   Copyright 2012 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2012-Apr-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

% Read the center and the corner of each segment
gridStruct = delwaq_xysegment(lgaFile);
X = [gridStruct.cor.x(:,1) gridStruct.cor.x(:,3) gridStruct.cor.x(:,4) gridStruct.cor.x(:,2) gridStruct.cor.x(:,1)];
Y = [gridStruct.cor.y(:,1) gridStruct.cor.y(:,3) gridStruct.cor.y(:,4) gridStruct.cor.y(:,2) gridStruct.cor.y(:,1)];

% Returns the area of the polygon specified by the vertices in the vectors X and Y
segArea = polyarea(X',Y');
segArea = segArea(:);