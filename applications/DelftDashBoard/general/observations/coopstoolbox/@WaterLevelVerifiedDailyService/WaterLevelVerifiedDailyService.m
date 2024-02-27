function obj = WaterLevelVerifiedDailyService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelVerifiedDaily';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifieddaily/wsdl/WaterLevelVerifiedDaily.wsdl';

obj = class(obj,'WaterLevelVerifiedDailyService');

