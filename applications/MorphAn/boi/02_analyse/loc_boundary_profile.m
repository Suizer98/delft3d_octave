function X11 = loc_boundary_profile(znat,xnat,x,zb0,maxwl)
%% input
% --- upper limit boundary profile (zswetmax+1.5m)
z_max_grensprofiel = znat+1.5;
% --- lower limit boundary profile (Rekenpeil)
z_min_grensprofiel = maxwl;
% --- length boundary profile
length_boundary_profile_top     = 3;
length_boundary_profile_bottom  = 7.5;


helling1 = 1; % left slope 1/1
helling2 = 2; % right slope 1/2

% --- plot profile

figure
plot(x,zb0,'.-');
hold on
plot(x, x*0+z_max_grensprofiel)
plot(x, x*0+z_min_grensprofiel)
plot(xnat,z_max_grensprofiel-1.5,'*')

%% find crossings
update_lower        = true;
upward_crossing     = true;
count1              = 1;
count2              = 1;
crossing_l = [NaN]; % - crossing left side
crossing_r = [NaN]; % - crossing right side


assert( z_max_grensprofiel>z_min_grensprofiel , 'kan geen grensprofiel inpassen' ) 



% --- find crossings
for ii=1:length(zb0)
    
    if zb0(ii)> z_min_grensprofiel & update_lower & upward_crossing & zb0(ii)<z_max_grensprofiel & x(ii)>=xnat
        crossing_l(count1)   = ii;

        update_lower         = false;
        upward_crossing      = true;

        count1 = count1 +1;
        plot(x(ii),zb0(ii),'o')
    end
    
    if zb0(ii)> z_max_grensprofiel & ~update_lower & upward_crossing  & x(ii)>=xnat
        crossing_l(count1)  = ii;
        
        update_lower        = false;
        upward_crossing     = false;

        count1 = count1 +1;
        plot(x(ii),zb0(ii),'o')
    end

    if zb0(ii)< z_max_grensprofiel & ~update_lower & ~upward_crossing & zb0(ii)>z_min_grensprofiel  & x(ii)>=xnat
        crossing_r(count2)  = ii;
        
        update_lower        = true;
        upward_crossing     = false;

        count2 = count2 +1;
        plot(x(ii),zb0(ii),'o')
    end
    
    if zb0(ii)< z_min_grensprofiel & update_lower & ~upward_crossing & x(ii)>=xnat
        crossing_r(count2)  = ii;
        
        update_lower        = true;
        upward_crossing     = true;

        count2 = count2 +1;
        plot(x(ii),zb0(ii),'o')
    end
    
end

% --- remove last value if length is odd
if mod(length(crossing_l),2)==1 & length(crossing_l)>1
    crossing_l(end) = [];
end
if mod(length(crossing_r),2)==1 & length(crossing_r)>1
    crossing_r(end) = [];
end

% --- plot crossings
if ~isnan(crossing_l(1))
plot(x(crossing_l),squeeze(zb0(crossing_l)),'ro');
end
if ~isnan(crossing_r(1)) 
plot(x(crossing_r),zb0(crossing_r),'bo');
end

% --- find location boundary profile
if isnan(crossing_l(1))
    disp('kan geen grensprofiel inpassen');
    X11 = NaN;
elseif length(crossing_l)==2 & length(crossing_r)==1
    N                   = crossing_l(2)-crossing_l(1);
    [X11 X12 Z11 Z12]   = inpassen_links(N, crossing_l(1), helling1, z_max_grensprofiel, z_min_grensprofiel,zb0,x);
    
    plot([X11 X12],[Z11 Z12],'k-')
    grensprofiel_x      = X11;    
    
    plot(X11,znat,'<')
else
    found_sol = false;

    for jj=1:2:length(crossing_l)
        
        N                   = crossing_l(jj+1)-crossing_l(jj);
        [X11 X12 Z11 Z12]   = inpassen_links(N, crossing_l(jj), helling1, z_max_grensprofiel, z_min_grensprofiel,zb0,x);

        plot([X11 X12],[Z11 Z12],'k-')

        % ---
        if length(crossing_r) < jj
            grensprofiel_x  = X11;
            found_sol       = true;
            break
        end
        
        N = crossing_r(jj+1)-crossing_r(jj);
        [X21 X22 Z21 Z22] = inpassen_rechts(N, crossing_r(jj), helling2, z_max_grensprofiel, z_min_grensprofiel,zb0,x)
        
        plot([X21 X22],[Z21 Z22],'k-')   

        if X22-X12> length_boundary_profile_top & X21-X11 > length_boundary_profile_bottom
            grensprofiel_x  = X11;
            found_sol       = true;
            break
        end
        
    end
    if ~found_sol
        disp('kan geen grensprofiel inpassen');
        X11 = Nan;
    else
        plot(X11,znat,'<')
    end
end


%%
function [X11 X12 Z11 Z12] = inpassen_links(N, crossing1, helling, z_max_grensprofiel, z_min_grensprofiel,zb0,x)
    x_list_dummy1 = nan(1,N);
    for ii=1:N
        z_dummy             = zb0(crossing1 + ii -1) - z_min_grensprofiel;
        x_dummy             = x(crossing1 + ii -1) - z_dummy * helling;

        x_list_dummy1(ii)   = x_dummy;

    end
    index = find( max(x_list_dummy1)==x_list_dummy1);
    
    X11 = x_list_dummy1(index);
    Z11 = z_min_grensprofiel;
    X12 = x_list_dummy1(index)+(z_max_grensprofiel-z_min_grensprofiel)*helling;
    Z12 = z_max_grensprofiel;
end

function [X21 X22 Z21 Z22] = inpassen_rechts(N, crossing2, helling2, z_max_grensprofiel, z_min_grensprofiel,zb0,x)
    x_list_dummy2 = nan(1,N);
    for ii=1:N
        z_dummy = zb0(crossing2 + ii -1) - z_min_grensprofiel;
        x_dummy = x(crossing2 + ii -1) + z_dummy * helling2;
        x_list_dummy2(ii)   = x_dummy;

    end
    index = find( min(x_list_dummy2)==x_list_dummy2);
    
    X21 = x_list_dummy2(index)-helling2*(z_max_grensprofiel-z_min_grensprofiel);
    Z21 = z_max_grensprofiel;
    X22 = x_list_dummy2(index);
    Z22 = z_min_grensprofiel;
end

end