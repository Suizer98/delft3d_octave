function obj = WaterLevelVerifiedHourlyService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/WaterLevelVerifiedHourly';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/waterlevelverifiedhourly/wsdl/WaterLevelVerifiedHourly.wsdl';

obj = class(obj,'WaterLevelVerifiedHourlyService');

