function handles=ddb_dnami_comp_Farea(handles)
%
% ------------------------------------------------------------------------------------
%
%
% Function:     ddb_dnami_comp_Farea.m
% Version:      Version 1.0, March 2007
% By:           Deepak Vatvani
% Summary:
%
% Copyright (c) WL|Delft Hydraulics 2007 FOR INTERNAL USE ONLY
%
% ------------------------------------------------------------------------------------
%
% Syntax:       output = function(input)
%
% With:
%               variable description
%
% Output:       Output description
%
% global Mw        lat_epi     lon_epi    fdtop     totflength fwidth   disloc    foption
% global dip       strike      slip       fdepth    userfaultL tolFlength
% global nseg      faultX      faultY     faultTotL xvrt       yvrt
% global mu        raddeg      degrad     rearth
% %
% fxn=[0 0 0 0 0 0]; fyn=[0 0 0 0 0 0];
% fig1 = findobj('name','Tsunami Toolkit');
% foption = get(findobj(fig1,'tag','SeismoOkada'),'string');



degrad=pi/180;

faultX=handles.toolbox.tsunami.FaultX;
faultY=handles.toolbox.tsunami.FaultY;
fwidth=handles.toolbox.tsunami.FaultWidth;
dip=handles.toolbox.tsunami.Dip;
strike=handles.toolbox.tsunami.Strike;
fdtop=handles.toolbox.tsunami.DepthFromTop;
nseg=handles.toolbox.tsunami.NrSegments;
userfaultL=handles.toolbox.tsunami.FaultLength;

if (handles.toolbox.tsunami.Magnitude > 0)
    %
    % Okada definition
    %
    if handles.toolbox.tsunami.RelatedToEpicentre==0
        fw = fwidth*cos(dip(1)*degrad);
        if (fdtop >0)
            fd = fdtop /sin(dip(1)*degrad);
            fd = min(fd,0.5*fw);
        else
            fd = 0;
        end
        [fxn(1),fyn(1)] = ddb_det_nxtvrtx(faultX(1)  , faultY(1)  , strike(1)+90.0, fd);
        for i=1:nseg
            [fxn(i+1),fyn(i+1)] = ddb_det_nxtvrtx(faultX(i+1)  , faultY(i+1)  , strike(i)+90.0, fd);
        end
        for i=1:nseg
            fw = fwidth*cos(dip(i)*degrad);
            xvrt(i,1) = fxn(i);
            yvrt(i,1) = fyn(i);
            xvrt(i,2) = fxn(i+1);
            yvrt(i,2) = fyn(i+1);
            [xvrt(i,3),yvrt(i,3)] = ddb_det_nxtvrtx(xvrt(i,2), yvrt(i,2), strike(i)+90., fw);
            [xvrt(i,4),yvrt(i,4)] = ddb_det_nxtvrtx(xvrt(i,3), yvrt(i,3), strike(i)+180., userfaultL(i));
            xvrt(i,5) = fxn(i);
            yvrt(i,5) = fyn(i);
        end
    else
        %
        % Seismological definition (EQ positioned at the centre of the Fault Area)
        %
        fw = fwidth*cos(dip(1)*degrad);
        [xvtc,yvtc]=ddb_det_nxtvrtx(handles.toolbox.tsunami.Longitude, handles.toolbox.tsunami.Latitude, strike(1)-90., fw/2);
        [xvrt(1,1),yvrt(1,1)]=ddb_det_nxtvrtx(xvtc, yvtc, strike(1)+180., userfaultL(1)/2);
        [xvrt(1,2),yvrt(1,2)]=ddb_det_nxtvrtx(xvrt(1,1), yvrt(1,1), strike(1), userfaultL(1));
        [xvrt(1,3),yvrt(1,3)]=ddb_det_nxtvrtx(xvrt(1,2), yvrt(1,2), strike(1)+90., fw);
        [xvrt(1,4),yvrt(1,4)]=ddb_det_nxtvrtx(xvrt(1,3), yvrt(1,3), strike(1)+180., userfaultL(1));
        xvrt(1,5) = xvrt(1,1);
        yvrt(1,5) = yvrt(1,1);
    end
    for i=nseg+1:5
        xvrt(i,1:5) = 0;
        yvrt(i,1:5) = 0;
    end
end

handles.toolbox.tsunami.VertexX=xvrt;
handles.toolbox.tsunami.VertexY=yvrt;

