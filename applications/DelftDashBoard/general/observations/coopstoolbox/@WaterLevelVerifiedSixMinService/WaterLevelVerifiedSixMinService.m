function obj = WaterLevelVerifiedSixMinService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelVerifiedSixMin';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedsixmin/wsdl/WaterLevelVerifiedSixMin.wsdl';

obj = class(obj,'WaterLevelVerifiedSixMinService');

