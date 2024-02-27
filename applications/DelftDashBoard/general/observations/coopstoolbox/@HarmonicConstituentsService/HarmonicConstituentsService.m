function obj = HarmonicConstituentsService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/HarmonicConstituents';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/harmonicconstituents/wsdl/HarmonicConstituents.wsdl';

obj = class(obj,'HarmonicConstituentsService');

