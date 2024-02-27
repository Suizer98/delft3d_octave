function D = creategridstruct()
%VAKLODING_CREATEGRIDSTRUCT  Create an empty gridstructure for a vakloding
%
%   D = creategridstruct()
%
% See also

% $Id: vakloding_creategridstruct.m 774 2009-08-05 15:20:06Z boer_g $


% example struct
%  seq: 2015
%          datatypeinfo: 'Kaartblad Vaklodingen'
%              datatype: 1
%             datatheme: 'bathymetry'
%                  name: 'KB115.4140'
%                  year: '1999'
%            soundingID: '0414'
%             xllcorner: 41860
%             yllcorner: 425000
%              cellsize: 20
%               contour: [5x2 double]
%           contourunit: 'm'
%     contourprojection: 'Rijksdriehoek'
%      contourreference: 'origin'
%          ls_fielddata: 'parentSeq'
%             timestamp: 0
%             fielddata: [1x1 struct]
%                     X: [625x407 double]
%                     Y: [625x407 double]
%                     Z: [625x407 double]

D.seq               = 0;
D.datatypeinfo      = 'Kaartblad Vaklodingen';
D.datatheme         = 'bathymetry';
D.name              = '';
D.year              = '';
D.soundingID        = '';
D.xllcorner         = 0;
D.yllcorner         = 0;
D.cellsize          = 0;
D.contour           = zeros(5,2);
D.contourunit       = 'm';
D.contourprojection = 'Rijksdriehoek';
D.contourreference  = 'origin';
D.ls_fielddata      = 'parentSeq';
D.timestamp         = 0;
D.fielddata         = struct;
D.X                 = zeros(1,1)*NaN;
D.Y                 = zeros(1,1)*NaN;
D.Z                 = zeros(1,1)*NaN;

