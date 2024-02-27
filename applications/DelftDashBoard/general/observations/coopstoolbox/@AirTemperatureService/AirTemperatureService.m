function obj = AirTemperatureService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/AirTemperature';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/airtemperature/wsdl/AirTemperature.wsdl';

obj = class(obj,'AirTemperatureService');

