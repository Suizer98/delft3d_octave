function output = spatialRange_write(varargin);
%SPATIALRANGE_WRITE
%
%   string = spatialRange_write(<keyword,value>)
%
% where keywords are 
% * 'start'/'stop'/'size'  2 our of 3 required or 'limits'
% * 'limits'               required if not 'start'/'stop'/'size'
% * 'resolution'           optional
% * 'units'                required if not spherical degrees
%
% Example:
% spatialRange_write('limits',[50 51])
% spatialRange_write('start' ,50     ,'stop',51)
% spatialRange_write('start' ,50     ,'size', 1)
%
%See also: OPENDAP

%% geospatialCoverage Element
% 
% <xsd:element name="geospatialCoverage">
%  <xsd:complexType>
%   <xsd:sequence>
%     <xsd:element name="northsouth" type="spatialRange"         minOccurs="0" />
%     <xsd:element name="eastwest"   type="spatialRange"         minOccurs="0" />
%     <xsd:element name="updown"     type="spatialRange"         minOccurs="0" />
%     <xsd:element name="name"       type="controlledVocabulary" minOccurs="0" maxOccurs="unbounded"/>
%   </xsd:sequence>
%     
%   <xsd:attribute name="zpositive" type="upOrDown" default="up"/>
%  </xsd:complexType>
% </xsd:element>
% 
% <xsd:complexType name="spatialRange">
%  <xsd:sequence>
%    <xsd:element name="start"      type="xsd:double" />
%    <xsd:element name="size"       type="xsd:double" />
%    <xsd:element name="resolution" type="xsd:double" minOccurs="0" />
%    <xsd:element name="units"      type="xsd:string" minOccurs="0" />
%  </xsd:sequence>
% </xsd:complexType>
% 
% <xsd:simpleType name="upOrDown">
%  <xsd:restriction base="xsd:token">
%    <xsd:enumeration value="up"/>
%    <xsd:enumeration value="down"/>
%  </xsd:restriction>
% </xsd:simpleType>

OPT.start      = [];
OPT.stop       = [];
OPT.size       = [];
OPT.limits     = [];
OPT.resolution = [];
OPT.units      = [];
OPT.indent     = '';

OPT = setproperty(OPT,varargin);

if ~(isempty(OPT.limits) | isnan(OPT.limits))
   OPT.start = OPT.limits(1);
   OPT.size  = OPT.limits(2) - OPT.limits(1);
end

if isempty(OPT.size) & ~isempty(OPT.stop) & ~isempty(OPT.start)
   OPT.size = OPT.stop - OPT.start;
end

if isempty(OPT.start) & ~isempty(OPT.stop) & ~isempty(OPT.size)
   OPT.size = OPT.stop - OPT.size;
end

if ~isempty(OPT.resolution)
    output = sprintf([...
'%s<start>\n%f</start>',...
'%s<size>\n%f</size>',...
'%s<resolution>\n%s</resolution>',...
'%s<units>%s</units>'],...
	OPT.indent,OPT.start,OPT.indent,OPT.size,OPT.indent,OPT.resolution,OPT.indent,OPT.units);
else
    output = sprintf([...
'%s<start>\n%f</start>',...
'%s<size>\n%f</size>',...
'%s<units>%s</units>'],...
	OPT.indent,OPT.start,OPT.indent,OPT.size,OPT.indent,OPT.units);
end
