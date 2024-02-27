function obj = highlowtidepredService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/highlowtidepred';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/highlowtidepred/wsdl/HighLowTidePred.wsdl';

obj = class(obj,'highlowtidepredService');

