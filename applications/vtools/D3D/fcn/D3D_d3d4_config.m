%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18070 $
%$Date: 2022-05-21 00:33:29 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: D3D_d3d4_config.m 18070 2022-05-20 16:33:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_d3d4_config.m $
%
%

function D3D_d3d4_config(fpath_xml,fname_mdu)

fid=fopen(fpath_xml,'w');

fprintf(fid,'<?xml version="1.0" encoding="iso-8859-1"?>\r\n');
fprintf(fid,'<deltaresHydro xmlns="http://schemas.deltares.nl/deltaresHydro" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/deltaresHydro http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">\r\n');
fprintf(fid,'    <documentation>\r\n');
fprintf(fid,'        File created by    : V\r\n');
fprintf(fid,'        File creation date : %s\r\n',datestr(datetime('now')));
fprintf(fid,'        File version       : 1.00\r\n');
fprintf(fid,'    </documentation>\r\n');
fprintf(fid,'    <control>\r\n');
fprintf(fid,'        <sequence>\r\n');
fprintf(fid,'            <start>myNameFlow</start>\r\n');
fprintf(fid,'        </sequence>\r\n');
fprintf(fid,'    </control>\r\n');
fprintf(fid,'    <flow2D3D name="myNameFlow">\r\n');
fprintf(fid,'        <library>flow2d3d</library>\r\n');
fprintf(fid,'        <mdfFile>%s</mdfFile>\r\n',fname_mdu);
fprintf(fid,'        <!--\r\n');
fprintf(fid,'            Note: exactly one mdfFile (single domain) or ddbFile (domain decomposition)\r\n');
fprintf(fid,'            element must be present.\r\n');
fprintf(fid,'        -->\r\n');
fprintf(fid,'        <!--\r\n');
fprintf(fid,'            Options/alternatives:\r\n');
fprintf(fid,'            1) DomainDecomposition: replace <mdfFile>f34.mdf</mdfFile> with:\r\n');
fprintf(fid,'                <ddbFile>vlissingen.ddb</ddbFile>\r\n');
fprintf(fid,'            2) Specification of dll/so to use:\r\n');
fprintf(fid,'                <library>/opt/delft3d/lnx64/flow2d3d/bin/libflow2d3d.so</library>\r\n');
fprintf(fid,'            3) Single precision:\r\n');
fprintf(fid,'                <library>flow2d3d_sp</library>\r\n');
fprintf(fid,'            4) Documentation:\r\n');
fprintf(fid,'                <documentation>\r\n');
fprintf(fid,'                    Basic tutorial testcase.\r\n');
fprintf(fid,'                </documentation>\r\n');
fprintf(fid,'            5) More output to screen (silent, error, info, trace. default: error):\r\n');
fprintf(fid,'                <verbosity>trace</verbosity>\r\n');
fprintf(fid,'            6) Debugging by attaching to running processes (parallel run):\r\n');
fprintf(fid,'                <waitFile>debug.txt</waitFile>\r\n');
fprintf(fid,'            7) Force stack trace to be written (Linux only):\r\n');
fprintf(fid,'                <crashOnAbort>true</crashOnAbort>\r\n');
fprintf(fid,'        -->\r\n');
fprintf(fid,'    </flow2D3D>\r\n');
fprintf(fid,'    <delftOnline>\r\n');
fprintf(fid,'        <enabled>false</enabled>\r\n');
fprintf(fid,'        <urlFile>zzz.url</urlFile>\r\n');
fprintf(fid,'        <waitOnStart>false</waitOnStart>\r\n');
fprintf(fid,'        <clientControl>true</clientControl>    <!-- client allowed to start, step, stop, terminate -->\r\n');
fprintf(fid,'        <clientWrite>false</clientWrite>    <!-- client allowed to modify data -->\r\n');
fprintf(fid,'        <!--\r\n');
fprintf(fid,'            Options/alternatives:\r\n');
fprintf(fid,'            1) Change port range:\r\n');
fprintf(fid,'                <tcpPortRange start="51001" end="51099"/>\r\n');
fprintf(fid,'            2) More output to screen (silent, error, info, trace. default: error):\r\n');
fprintf(fid,'                <verbosity>trace</verbosity>\r\n');
fprintf(fid,'            3) Force stack trace to be written (Linux only):\r\n');
fprintf(fid,'                <crashOnAbort>true</crashOnAbort>\r\n');
fprintf(fid,'        -->\r\n');
fprintf(fid,'    </delftOnline>\r\n');
fprintf(fid,'</deltaresHydro>\r\n');                                                                                                                                                                                                                

fclose(fid);

end %xmlfile