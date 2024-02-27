%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18209 $
%$Date: 2022-06-29 16:31:50 +0800 (Wed, 29 Jun 2022) $
%$Author: chavarri $
%$Id: D3D_bct_s.m 18209 2022-06-29 08:31:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bct_s.m $
%
%bct file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.bct.time = time at which the water levels are specified [s] [double(nt,1)] e.g. [0,3600,10000]
%   -simdef.bct.Q = constant discharge [m^3/s] [double(1,1)] e.g. [0.120]
%   -simdef.bct.etaw = water levels at the specified times [m] [double(nt,1)] e.g. [0.19,0.19,0.15]
%
%OUTPUT:
%   -a .bct compatible with D3D is created in file_name

function D3D_bct_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

time=simdef.bct.time;
Q=simdef.bct.Q;
dy=simdef.grd.dy;
B=simdef.grd.B;
etaw=simdef.bct.etaw;

Tunit=simdef.mdf.Tunit;
Tfact=simdef.mdf.Tfact;
Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt;

upstream_nodes=simdef.mor.upstream_nodes;

%round time
if time(end)<Tstop
    time(end)=(floor(Tstop/Dt)+1)*Dt;
    warning('The end time in bct is smaller than the end time of the simulation (maybe due to rounding issues). I have changed it.')
end

%other
nt=length(time);

if simdef.grd.K>1
    str_typeb='Logarithmic';
else
    str_typeb='Uniform';
end

%This is moved to <D3D_rework>!
% etaw=etaw-simdef.grd.dx/2*simdef.ini.s; %displacement of boundary condition to ghost node


%% FILE

%% upstream
kl=1;
for kn=1:upstream_nodes
    data{kl, 1}=sprintf('table-name           ''Boundary Section : %d''',kn); kl=kl+1;
    data{kl, 1}=sprintf('contents             ''%s           ''',str_typeb); kl=kl+1;
    data{kl, 1}=sprintf('location             ''Upstream_%02d       ''',kn); kl=kl+1;
    data{kl, 1}=        'time-function        ''non-equidistant'''; kl=kl+1;
    data{kl, 1}=        'reference-time       20000101'; kl=kl+1;
    switch Tunit
        case 'S'
    data{kl, 1}=        'time-unit            ''seconds'''; kl=kl+1;
        case 'M'
    data{kl, 1}=        'time-unit            ''minutes'''; kl=kl+1;
    end
    data{kl, 1}=        'interpolation        ''linear'''; kl=kl+1;
    switch Tunit
        case 'S'
    data{kl, 1}=        'parameter            ''time''                                     unit ''[sec]'''; kl=kl+1;
        case 'M'
    data{kl, 1}=        'parameter            ''time''                                     unit ''[min]'''; kl=kl+1;
    end
    switch upstream_nodes
        case 1
    data{kl, 1}='parameter            ''total discharge (t)  end A''               unit ''[m3/s]'''; kl=kl+1;
    data{kl, 1}='parameter            ''total discharge (t)  end B''               unit ''[m3/s]'''; kl=kl+1;
    data{kl, 1}=sprintf('records-in-table     %d',nt); kl=kl+1;
    for kt=1:nt
        data{kl,1}=sprintf(repmat('%0.7E \t',1,3),time(kt)*Tfact,Q(kt),Q(kt)); kl=kl+1;
    end
        otherwise
    data{kl, 1}='parameter            ''flux/discharge  (q)  end A''               unit ''[m3/s]'''; kl=kl+1;
    data{kl, 1}='parameter            ''flux/discharge  (q)  end B''               unit ''[m3/s]'''; kl=kl+1;
    data{kl, 1}=sprintf('records-in-table     %d',nt); kl=kl+1;
    for kt=1:nt
        data{kl,1}=sprintf(repmat('%0.7E \t',1,3),time(kt)*Tfact,Q(kt)*dy/B,Q(kt)*dy/B); kl=kl+1;
    end
    end
end %upstream_nodes

%% downstream
data{kl, 1}=sprintf('table-name           ''Boundary Section : %d''',kn+1); kl=kl+1;
data{kl, 1}=        'contents             ''Uniform             '''; kl=kl+1;
data{kl, 1}=        'location             ''Downstream          '''; kl=kl+1;
data{kl, 1}=        'time-function        ''non-equidistant'''; kl=kl+1;
data{kl, 1}=        'reference-time       20000101'; kl=kl+1;
switch Tunit
    case 'S'
data{kl, 1}=        'time-unit            ''seconds'''; kl=kl+1;
    case 'M'
data{kl, 1}=        'time-unit            ''minutes'''; kl=kl+1;
end
data{kl, 1}=        'interpolation        ''linear'''; kl=kl+1;
switch Tunit
    case 'S'
data{kl, 1}=        'parameter            ''time''                                    unit ''[sec]'''; kl=kl+1;
    case 'M'
data{kl, 1}=        'parameter            ''time''                                    unit ''[minutes]'''; kl=kl+1;
end
data{kl, 1}=        'parameter            ''water elevation (z)  end A''              unit ''[m]'''; kl=kl+1;
data{kl,1}=         'parameter            ''water elevation (z)  end B''              unit ''[m]'''; kl=kl+1;
data{kl,1}=sprintf('records-in-table     %d',nt); kl=kl+1;
for kt=1:nt
    %boundary at L+dx!
%     data{kl,1}=sprintf(repmat('%0.7E \t',1,3),time(kt)*Tfact,etaw(kt),etaw(kt)); kl=kl+1;
    %correct value of boundary
    data{kl,1}=sprintf(repmat('%0.7E \t',1,3),time(kt)*Tfact,etaw(kt),etaw(kt)); kl=kl+1;
end


%% WRITE

file_name=fullfile(dire_sim,'bct.bct');
writetxt(file_name,data)
