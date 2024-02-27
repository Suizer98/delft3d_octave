# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import json
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
with open('../processes/wps_matlab_processes.json') as f:
    processes = json.load(f)

# <codecell>

import pywps

# <codecell>

geoformats =  [
               {'mimeType': 'text/plain', 'encoding': 'UTF-8'},
               {'mimeType': 'application/xml', 'schema': 'http://schemas.opengis.net/gml/2.1.2/feature.xsd', 'encoding': 'UTF-8'},
               {'mimeType': 'application/json'}
               ]

# <codecell>

class MatlabWPSProcess(pywps.Process.WPSProcess):
    def execute(self):
        logger.info("Passing everything to Matlab")
        logger.debug("Identifier: {}".format(self.identifier))
        for input in self.inputs:
            logger.debug("Input: {}=>{}".format(input, self.getInputValue(input)))

# <codecell>

wpsprocesses = []
for process in processes:
    wpsprocess = MatlabWPSProcess(identifier=process['identifier'])
    for key, value in process['inputs'].items():
        if value['type'] in ['point', 'linestring', 'polygon', 'geometrycollection', 'multilinestring', 'multipoint', 'multipolygon']:
            wpsprocess.addComplexInput(identifier=key, title=key, formats=geoformats)
        elif '/' in value['type']:
            wpsprocess.addComplexInput(identifier=key, title=key, formats=[{'mimeType': value['type']}])
        else:
            logger.warn('Unexpected type for process: {}, identifier: {}, type: {}'.format(process['identifier'], key, value['type']))
    for key, value in process['outputs'].items():
        if value['type'] in ['point', 'linestring', 'polygon', 'geometrycollection', 'multilinestring', 'multipoint', 'multipolygon']:
            wpsprocess.addComplexOutput(identifier=key, title=key, formats=geoformats)
        elif '/' in value['type']:
            wpsprocess.addComplexOutput(identifier=key, title=key, formats=[{'mimeType': value['type']}])
        else:
            logger.warn('Unexpected type for process: {}, identifier: {}, type: {}'.format(process['identifier'], key, value['type']))
    wpsprocesses.append(wpsprocess)
            

# <codecell>

p0 = wpsprocesses[0]

# <codecell>

location = p0.inputs['location']
location.format['mimetype']='text/plain'
location.setValue({'value': 'POINT(3 1)'})

# <codecell>

p0.execute()

# <codecell>

!ls

# <codecell>


