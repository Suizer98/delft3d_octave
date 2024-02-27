function obj = DataInventoryService

obj.endpoint = 'http://opendap.co-ops.nos.noaa.gov/axis/services/DataInventory';
obj.wsdl = 'http://opendap.co-ops.nos.noaa.gov/axis/webservices/datainventory/wsdl/DataInventory.wsdl';

obj = class(obj,'DataInventoryService');

