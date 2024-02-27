function obj = BarometricPressureService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/BarometricPressure';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/barometricpressure/wsdl/BarometricPressure.wsdl';

obj = class(obj,'BarometricPressureService');

