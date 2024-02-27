function [tout,dout]=cmgidgaps(t1,data1,t2,data2)
% Function to concatenate two timeseries.
% Any gap between the separate timeseries is filled with NaNs.
%
% Usage: [tjoin,datajoin]=cmgjoin(t1,data1,t2,data2)
%
% Input: Series1 t1     (vector (n1,1))
%                data1  (matrix (n1,m))
%        Series2 t2     (vector (n2,1))
%                data2  (matrix (n2,m))

%
% Written by GL 7 March 2003
%
% check consistency of input arrays and matrices
[nn1,mm1]=size(t1);
[nn2,mm1]=size(data1);
if nn1==nn2
    n1=nn1;
else
    error('Series 1 time and data arrays different lengths')
end
[nn1,mm2]=size(t2);
[nn2,mm2]=size(data2);
if nn1==nn2
    n2=nn1;
else
    error('Series 2 time and data arrays different lengths')
end
if mm1==mm2
    m=mm1;
else
    error('Series 1 and 2 have different numbers of data fields')
end
sig=1e-6;
if abs((t1(2)-t1(1))-(t1(end)-t1(1))/(n1-1))<sig
    dt1=t1(2)-t1(1);
else
    error('Series 1 dt error')
end
if abs((t2(2)-t2(1))-(t2(end)-t2(1))/(n2-1))<sig
    dt2=t2(2)-t2(1);
else
    error('Series 2 dt error')
end
if dt1==dt2
    dt=dt1;
else
    error('Series 1 dt different from Series 2 dt')
end
tgap=(t2(1)-t1(end));
if tgap > dt
    if mod(tgap,dt)>sig
        error('Gap between series not a multiple of dt')
    end
else
    error('Series 2 starts before end of Series 1')
end
%
% OK, now can get on with it
%
nout=round((t2(end)-t1(1))/dt + 1);
tout=[t1(1):dt:t2(end)]';
dout(1:nout,1:m)=NaN;
dout(1:n1,:)=data1;
dout(end-n2+1:end,:)=data2;
