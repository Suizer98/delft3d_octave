function [out,change] = shoreline_change(x,y,zstart,zend,d,contour)

% Estimates the shoreline position and shoreline change between the input
% and final bathymetry for the xbeach run.

% modified from contourdiffs.m (DJH 20090423) code by JLE 10/5/09 to find the MLLW
% contour and shoreline change for individual xbeach output profile.

% For the shoreline location (positive z), preference always is given
% to the first occurrence moving inland from the offshore reference point or most
% seaward point in the dataset. After shoreline positions are estimated for each line the 
% values are subtracted to get the shoreline change.

%   Input:
%     x = x-coordinates for profile
%     y = y-coordinates for profile
%     zstart = initial bathymetry from xbeach run
%     zend = final bathymetry from xbeach run
%     d = distance along profile
%     contour = shoreline contour (ex: 1.38 m)
%   Output:
%     out = [xloc,yloc,zloc,d] with location of the shoreline along the
%     profile.
%     out(1,:) - starting shoreline location
%     out(2,:) - ending shoreline location
%     change = shoreline change for xbeach run (change in d, positive means
%              ending shoreline is seaward and accretion, negative means
%              ending shoreline is landward and erosion has occurred).

%bathy contours to find - change as desired.
nt=1;

for nt = 1:2 
    %loop through for the starting and ending bathymetry
    if nt==1
        data=[x,y,zstart,d]; %Consolidate x,y,z,d into single variable
    else
        data=[x,y,zend,d];
    end
    datasortd=sortrows(data,4); %Sort by d, ascending (offshore %to onshore)

    n=numel(d); % Number of points along line

    if n>=2; %Make sure there's enough data to find anything!
    
        contoursfound=0; %Initialize counter for row to write to in 
                                 %contour output file
        contourz=contour; %specify depth being searched for
        i=1; %row index for loop through each line looking for each depth

        while i<n; %
            %use product of successive points (shifted by contour
            %depth) to see if contour crossed between points
            product=(datasortd(i,3)-contourz)*(datasortd(i+1,3)-contourz);

            if product<=0; %contour is on or between points, 
            %but possible that both depths equal and on contour

                if datasortd(i,3)~=datasortd(i+1,3); %points 
                    %are not equal depth, contour is between or on one point

                    %get contour location as fractionaldistance between depths 
                    %at row i and i+1 and use to compute interpolated x,y,d.

                    delzpoints=datasortd(i+1,3)-datasortd(i,3);
                    delzcontour=contourz-datasortd(i,3);
                    interpfrac=delzcontour/delzpoints;
                                
                    %interpolated x, y, and d
                    contx=datasortd(i,1)+interpfrac*(datasortd(i+1,1)-datasortd(i,1));
                    conty=datasortd(i,2)+interpfrac*(datasortd(i+1,2)-datasortd(i,2));
                    contd=datasortd(i,4)+interpfrac*(datasortd(i+1,4)-datasortd(i,4));

                    contoursfound=contoursfound+1;
                    contoursout(contoursfound,:)=[contx,conty,contourz,contd];

                    %check if second point on contour, then need to
                    %skip in next pass

                    if datasortd(i+1,3)==contourz;
                        i=i+1;
                    else
                    end

                else %points are equal and at contour depth, save both

                    contoursfound=contoursfound+1; %increment and save first point
                    contoursout(contoursfound,:)=datasortd(i,:);
                    contoursfound=contoursfound+1; %increment and save second point
                    contoursout(contoursfound,:)=datasortd(i+1,:);
                    i=i+1; %skip extra point as both are on contour, don't want to count twice

                end
            end
            i=i+1;
        end
                
        %save data for start and end profile for each contour, 
        %columns, x, y, z, d
        if nt==1
            cdatas = contoursout;
            clear contoursout;
        else
            cdatae = contoursout;
            clear contoursout
        end  
    end

    clear conty product ans search contd data datasortd fnameout ...
        contoursfound delzcontour i delzpoints interpfrac contourz n contx;
    nt=nt+1;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save x,y,z of best shoreline position for start and end profile

cdata1sort=sortrows(cdatas,-4); %sort by d from monument, descending since 
%monument is offshore endpoint
clear x y z d;

out(1:2,1:4)=NaN; %create empty array to 
%collect "best" contour locations for start and end profile. For shoreline
% choose the most seaward location.
bestrow=find(cdata1sort(:,3)==contour,1,'last');

if isempty(bestrow)==0; %if bestrow exists record contour d
    out(1,:)=cdata1sort(bestrow,:);
else
end
clear bestrow*

% Now, do the same for the post-xbeach profile

cdata2sort=sortrows(cdatae,-4); %sort by d from monument, descending
clear x y z d;

bestrow=find(cdata2sort(:,3)==contour,1,'last');

if isempty(bestrow)==0; %if bestrow exists record contour d
    out(2,:)=cdata2sort(bestrow,:);
else
end
clear bestrow*
                    
%subtract contour distances and save in output array
change =out(1,4)-out(2,4);

