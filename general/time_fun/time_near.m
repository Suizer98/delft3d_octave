%TIME_NEAR Find the nearest time within a certain time windows.
%   [iT1,iT2] = TIME_NEAR(T1,T2,dt,type)returns index vectors iT1 and iT2
%   such that T1(iT1) There is a near time
%             T2(iT2) This is the nearest time to T1(iT1)
%   <dt>   in the time windows in seconds. 
%   <type> is one of
%         'middle'   - T2 in the interval [(T1-dt/2)  (T1+dt/2))
%         'forward'  - T2 in the interval [T1 (TI+dt))
%         'backward' - T2 in the interval [(T1-dt) T1)
%         If no argument then type = 'middle' 
%   NOTE: If <dt> and <type> are not providen then TIME_NEAR find the nearest
%         time (in T2) to T1.
%         'nearest'  - Nearest point to T1
%
% See also TIME_FLOOR, TIME_CEIL.

%   Copyright: Deltares, the Netherlands
%        http://www.delftsoftware.com
%        Date: 05.06.2009
%      Author: S. Gaytan Aguilar
%--------------------------------------------------------------------------
function [it1 it2]  = time_near(t1,t2,dt,type,onerecord)

if nargin<5
   onerecord = 1;
end

if ~issorted(t1) || ~issorted(t2)
   error('Vector T1 and T2 must be sorted in time')
end

% If no argument then dt = 3600

if nargin ==2
   type = 'nearest';
elseif nargin ==3;
   type = 'middle';
end

dt = dt/(60*60*24);
switch type
    case 'middle'
        tlow = t1-(dt/2);
        tup  = t1+(dt/2);
        [it1 it2] = find_time_in_interval(t1,t2,tlow,tup,onerecord);
    case 'forward'        
        tlow = t1;
        tup  = t1+dt;
        [it1 it2] = find_time_in_interval(t1,t2,tlow,tup,onerecord);
    case 'backward'        
        tlow = t1-dt;
        tup  = t1;   
        [it1 it2] = find_time_in_interval(t1,t2,tlow,tup,onerecord);
    case 'nearest'        
        it2 = interp1(t2,1:length(t2),t1,'nearest','extrap');
        it1 = 1:length(t1);
end

function [it1 it2] = find_time_in_interval(t1,t2,tlow,tup,onerecord)
it1 = [];
it2 = [];
k=0;
for it = 1:length(t1)
    inear = find((t2 >= tlow(it) & t2< tup(it)));
    if ~isempty(inear)
        if length(inear)>1 && onerecord
           tdiff = abs(t1(it)-t2(inear));
           inearest = tdiff==min(tdiff);
           if length(inear)>1
              inearest = find(inearest,1,'last');
           end
           inear = inear(inearest);
        end
       for j = 1:length(inear)
           k = k+1;
           it1(k,1) = it;        %#ok<AGROW>
           it2(k,1) = inear(j);  %#ok<AGROW>
       end
    end
end
