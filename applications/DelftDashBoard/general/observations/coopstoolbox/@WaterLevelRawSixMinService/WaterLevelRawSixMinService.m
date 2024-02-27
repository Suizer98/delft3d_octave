function obj = WaterLevelRawSixMinService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelRawSixMin';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelrawsixmin/wsdl/WaterLevelRawSixMin.wsdl';

obj = class(obj,'WaterLevelRawSixMinService');

