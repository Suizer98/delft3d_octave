function obj = PredictionsService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/Predictions';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/predictions/wsdl/Predictions.wsdl';

obj = class(obj,'PredictionsService');

