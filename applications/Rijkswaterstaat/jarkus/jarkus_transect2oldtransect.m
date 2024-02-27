function transect = jarkus_transect2oldtransect
%JARKUS_TRANSECT2OLDTRANSECT converts Jarkus transect struct
%
%    transect = jarkus_transect2oldtransect()
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

transect.areacode          = 0;
transect.areaname          = '';
transect.year              = 0;
transect.metre             = 0;
transect.dateTopo          = 0;
transect.dateBathy         = 0;
transect.n                 = 0;
% this is jarkus specific.... should be moved to another entity 
% Origin of the data (and combine 1,3 and 5):
% id=1 non-overlap beach data
% id=2 overlap beach data
% id=3 interpolation data (between beach and off shore)
% id=4 overlap off shore data
% id=5 non-overlap off shore data
transect.origin            = []; % vector of origin codes 
% Seaward distance from pole;
transect.seawardDistance   = [];
% Height
transect.height            = [];
transect.id                = 0;

transect.seq               = 0;
transect.datatypeinfo      = 'Jarkus Data';
transect.datatype          = 1;
transect.datatheme         = '';
transect.area              = transect.areaname;
transect.areacode          = num2str(transect.areacode);
transect.transectID        = num2str(transect.metre, '%05d');
transect.year              = year(transect.time); %'1965'
vecTopo                    = datevec(transect.timeTopo);
transect.dateTopo          = sprintf('%02d%02d', vecTopo(3),vecTopo(2)); % '3008'
vecBathy                    = datevec(transect.timeBathy);
transect.dateBathy         = sprintf('%02d%02d', vecBathy(3),vecBathy(2)); % '1708'
transect.soundingID        = num2str(transect.year); % '1965'
transect.xRD               = 0; %in EPSG:28992
transect.yRD               = 0; %in EPSG:28992
transect.GRAD              = 0; % 0 - 360
transect.contour           = []; %[2x2 double]
transect.contourunit       = 'm';
transect.contourprojection = 'Amersfoort / RD New';
transect.contourreference  = 'origin';
transect.ls_fielddata      = 'parentSeq';
timestamp                  = 0; %1.1933e+009;?
transect.fielddata         = []; %[1x1 struct]
transect.MLW               = 0; % -0.8000
transect.MHW               = 0; %0.8000
transect.xi                = 0; %[1264x1 double]
transect.zi                = 0; %[1264x1 double]
transect.xe                = 0; %[1264x1 double]
transect.ze                = 0; %[1264x1 double]

%                   seq: 25178
%          datatypeinfo: 'Jarkus Data'
%              datatype: 1
%             datatheme: ''
%                  area: 'Noord-Holland'
%              areacode: '7'
%            transectID: '03800'
%                  year: '1965'
%              dateTopo: '3008'
%             dateBathy: '1708'
%            soundingID: '1965'
%                   xRD: 103011
%                   yRD: 514782
%                  GRAD: 278
%               contour: [2x2 double]
%           contourunit: 'm'
%     contourprojection: 'Rijksdriehoek'
%      contourreference: 'origin'
%          ls_fielddata: 'parentSeq'
%             timestamp: 1.1933e+009
%             fielddata: [1x1 struct]
%                   MLW: -0.8000
%                   MHW: 0.8000
%                    xi: [1264x1 double]
%                    zi: [1264x1 double]
%                    xe: [1264x1 double]
%                    ze: [1264x1 double]

end % end function jarkus_transect2oldtransect