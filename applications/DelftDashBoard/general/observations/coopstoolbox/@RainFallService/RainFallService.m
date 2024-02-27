function obj = RainFallService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/RainFall';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/rainfall/wsdl/RainFall.wsdl';

obj = class(obj,'RainFallService');

