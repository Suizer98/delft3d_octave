%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 19:43:41 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_dimr_config.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_dimr_config.m $
%
%

function D3D_dimr_config(fpath_xml,fname_mdu)

fid=fopen(fpath_xml,'w');

fprintf(fid,'<?xml version="1.0" encoding="iso-8859-1"?>                                                                                                                                                                                        \r\n');
fprintf(fid,'<dimrConfig xmlns="http://schemas.deltares.nl/dimrConfig" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/dimrConfig http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">\r\n');
fprintf(fid,'    <documentation>                                                                                                                                                                                                                \r\n');
fprintf(fid,'        <fileVersion>1.00</fileVersion>                                                                                                                                                                                            \r\n');
fprintf(fid,'        <createdBy>V</createdBy>                                                                                                                                               \r\n');
fprintf(fid,'        <creationDate>%s</creationDate>                                                                                                                                                                              \r\n',datestr(datetime('now')));
fprintf(fid,'    </documentation>                                                                                                                                                                                                               \r\n');
fprintf(fid,'    <control>                                                                                                                                                                                                                      \r\n');
fprintf(fid,'        <start name="myNameDFlowFM"/>                                                                                                                                                                                              \r\n');
fprintf(fid,'    </control>                                                                                                                                                                                                                     \r\n');
fprintf(fid,'    <component name="myNameDFlowFM">                                                                                                                                                                                               \r\n');
fprintf(fid,'        <library>dflowfm</library>                                                                                                                                                                                                 \r\n');
fprintf(fid,'        <workingDir>.</workingDir>                                                                                                                                                                                                 \r\n');
fprintf(fid,'        <inputFile>%s</inputFile>                                                                                                                                                                                                  \r\n',fname_mdu);
fprintf(fid,'    </component>                                                                                                                                                                                                                   \r\n');
fprintf(fid,'</dimrConfig>                                                                                                                                                                                                                      \r\n');

fclose(fid);

end %xmlfile