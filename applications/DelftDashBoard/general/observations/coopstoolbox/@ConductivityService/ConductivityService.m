function obj = ConductivityService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/Conductivity';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/conductivity/wsdl/Conductivity.wsdl';

obj = class(obj,'ConductivityService');

