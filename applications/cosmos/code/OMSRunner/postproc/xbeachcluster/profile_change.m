function [pchangeperm,perosionperm,pchangebeach] = profile_change(zstart,zend,d,d_bb,d_bb2)
% Estimates the profile change  between the input and final bathymetry 
% for the xbeach run.

%   Input:
%     zstart = initial bathymetry from xbeach run
%     zend = final bathymetry from xbeach run
%     d = distance along profile
%     d_bb = distance corresponding to the back beach of the initial profile
%     d_bb2 = distance corresponding to the back beach of the final
%     profile
%   Output:
%     pchangeperm = profile area change for xbeach run in m2/m (area of
%     fill/length of profile)
%     perosionperm = profile area change for xbeach run in m2/m (area of
%     cut/length of profile)
%     pchangebeach = profile area change for xbeach run in m2/m (cumulative
%     area of change between 0 and 1.6m elevation / length of section)

% JLE 11/24/09

% Sum the areas where the end profile has higher z values,
% using the trapezoidal mehtod and a backward difference method to 
% estimate the dx.

csum=0;
%Case 1: Both zend values are greater than zstart
for kk=2:length(d)
    if(zend(kk)>zstart(kk) && zend(kk-1)>zstart(kk-1))
        % Use trapezoidal method to estimate area
        z1=[zend(kk-1) zend(kk)]';
        d1=[d(kk-1) d(kk)]';
        z2=[zstart(kk-1) zstart(kk)]';
        area=trapz(d1,z1)-trapz(d1,z2);
        % Add to total sum
        csum=csum+area;
        clear z1 d1 z2 area
        %plot(d(kk),zend(kk),'*m');
    end
end
        
% Sum the areas where the start profile has higher z values,
% using a backward difference method to determine dx
csumneg=0;
% Case 2: Both zstart values are greater than zend
for kk=2:length(d)
    if(zstart(kk)>zend(kk) && zstart(kk-1)>zend(kk-1))
        % Use trapezoidal method to estimate area
        z1=[zstart(kk-1) zstart(kk)]';
        d1=[d(kk-1) d(kk)]';
        z2=[zend(kk-1) zend(kk)]';
        area=trapz(d1,z1)-trapz(d1,z2);
        % Add to total sum
        csumneg=csumneg+area;
        clear z1 d1 z2 area
        %plot(d(kk),zstart(kk),'*g');
    end
end

% Sum the areas that cross between start and end elevation being greater.  Choose
% whichever area is greater and include with that estimate.

% Case 3: one zstart value and one zend value are greater
for kk=2:length(d)
    if(zstart(kk)>zend(kk) && zend(kk-1)>zstart(kk-1))
        % Use trapezoidal method to estimate area
        z1=[zend(kk-1) zend(kk)]';
        d1=[d(kk-1) d(kk)]';
        z2=[zstart(kk-1) zstart(kk)]';
        area=trapz(d1,z1)-trapz(d1,z2);
        if(area>0)
            csum=csum+area;
            %plot(d(kk),zstart(kk),'*b');
        elseif(area<0)
            csumneg=csumneg+abs(area);
            %plot(d(kk),zstart(kk),'*y');
        end
        clear z1 d1 z2 area
    elseif(zend(kk)>zstart(kk) && zstart(kk-1)>zend(kk-1))
        % Use trapezoidal method to estimate area
        z1=[zstart(kk-1) zstart(kk)]';
        d1=[d(kk-1) d(kk)]';
        z2=[zend(kk-1) zend(kk)]';
        area=trapz(d1,z1)-trapz(d1,z2);
        if(area>0)
            csumneg=csumneg+area;
            %plot(d(kk),zstart(kk),'*y');
        elseif(area<0)
            csum=csum+abs(area);
            %plot(d(kk),zstart(kk),'*b');
        end
        clear z1 d1 z2 area 
    end
end

% xlabel('Distance Along Profile, m');
% ylabel('Elevation NAVD88, m');
profchange=csum;
proferosion=csumneg;
xwidth=d(end)-d(1);
pchangeperm=csum/xwidth;
perosionperm=csumneg/xwidth;

%__________________________________________________________________________
% Calculate the change in area along the transect seaward of the back beach
% reference point and landward of the 0 m contour.

%pick range of data between 0 and 1.6m elevation from starting profile
p1=find(d<=d_bb);
zstart2=zstart(p1);
d2=d(p1);
p2=find(zstart2>0);
zstart3=zstart2(p2);
d3=d2(p2);
%Interpolate starting profile data to 0 and bb locations and combine with
%range between to estimate area.
y2=[0 1.6];
df=interp1q(zstart,d,y2');
if(isempty(d3)==0)
    yp1=[0 zstart3' 1.6];
    df1=[df(1) d3' df(end)];
else
    yp1=y2;
    df1=df;
end
area1=trapz(df1,yp1);
%plot(df1,yp1,'ob');

%pick range of data between 0 and 1.6m elevation from ending profile
p3=find(d<=d_bb2);
zend2=zend(p3);
db2=d(p3);
p4=find(zend2>0);
zend3=zend2(p4);
db3=db2(p4);
%Interpolate ending profile data to 0 and bb locations and combine with
%range between to estimate area.
dfb=interp1q(zend,d,y2');
if(isempty(db3)==0)
    yp2=[0 zend3' 1.6];
    df2=[dfb(1) db3' dfb(end)];
else
    yp2=y2;
    df2=dfb;
end
area2=trapz(df2,yp2);
%plot(df2,yp2,'om');

% If back beach location does not change
if(d_bb==d_bb2)
    pchangebeach=(area2-area1)/(df1(end)-df1(1));
% If final back beach location is greater than initial bb location
elseif(d_bb2>d_bb)
    area1fix=area1+((d_bb2-d_bb)*1.6);
    if(df1(1)<df2(1))
        dmin=df1(1);
    else
        dmin=df2(1);
    end
    pchangebeach=(area2-area1fix)/(d_bb2-dmin);
% If initial back beach location is greater than final bb location
elseif(d_bb2<d_bb)
    area2fix=area2+((d_bb-d_bb2)*1.6);
    if(df1(1)<df2(1))
        dmin=df1(1);
    else
        dmin=df2(1);
    end
    pchangebeach=(area2fix-area1)/(d_bb-dmin);
end
