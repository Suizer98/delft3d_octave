function [it1,it2,tfrac1,tfrac2]=find_time_indices_and_factors(times,t)

itime=find(abs(times-t)<1/864000, 1, 'first');

if ~isempty(itime)
    % Exact time found
    it1=itime;
    it2=0;
    tfrac1=1;
    tfrac2=0;
elseif t>times(end)
    it1=0;
    it2=0;
    tfrac1=0;
    tfrac2=0;
elseif t<times(1)
    it1=0;
    it2=0;
    tfrac1=0;
    tfrac2=0;
else    
    % Averaging between surrounding times
    it1=find(times<t,1,'last');
    it2=find(times>t,1,'first');    
    t1=times(it1);
    t2=times(it2);    
    dt=t2-t1;
    tfrac2=(t-t1)/dt;
    tfrac1=1-tfrac2;
end
