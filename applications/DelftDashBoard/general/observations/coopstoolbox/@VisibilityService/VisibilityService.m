function obj = VisibilityService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/Visibility';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/visibility/wsdl/Visibility.wsdl';

obj = class(obj,'VisibilityService');

