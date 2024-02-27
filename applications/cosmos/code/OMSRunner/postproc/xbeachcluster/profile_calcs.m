function profile_calcs(inputdir,outputdir,xmldir,mopid,tref)

fname=[outputdir mopid '.nc'];

% profile_calcs.m:  This program reads in the xbeach output netCDF file (xb####.nc) and
% calculates profile statistics.

%    usage:  profile_calcs(inputdir,outputdir,mopid);
%
%        where: inputdir - directory path where input data files are stored
%                       (ex: 'M:\Coastal_Hazards\Xbeach\post_xbeach\');
%               outputdir - directory path where netcdf output files are
%                       stored (ex: ''M:\Coastal_Hazards\Xbeach\post_xbeach\');
%               mopid - MOP profile ID which is used to read in the netcdf
%                       file (ex: 3401);

% JLE 9/29/09
% modified 11/19/09 for final xbeach bulk setup

%DEFINITION OF CONSTANTS
eps=0.01;% threshold depth for drying and flooding in params.txt
mhw=1.38; % mean high water for Socal to pick shoreline location
mhhw=1.6; % mean high high water for Socal, used for back beach estimate
%__________________________________________________________________________
%ITEMS CALCULATED FROM XBEACH OUTPUT
%  shoreline change (mhw contour)
%  back beach change (mhhw contour)
%  maximum runup height
%  flags for flooding hazard / inundation hazard 
%  duration of flooding
%  profile accretion (m2/m)
%  profile erosion (m2/m)
%  profile change - 0 to 1.6 m elevation range (m2/m)
%  maximum wave height applied at model boundary
%__________________________________________________________________________
% READ IN DATA

% Read in netcdf file for xbeach run (this includes all variables).
%ncload([outputdir,mopid,'.nc']);

%__________________________________________________________________________
% CALCULATE PARAMETERS FROM RUN
% Get location information.
% x2=x(:,1);
% y2=y(:,1);
% d=xc(:,1);

try
    
    % Generate the time variables from netcdf output of julian day and seconds
    x2=double(nc_varget(fname,'x'));
    y2=double(nc_varget(fname,'y'));
    d=double(nc_varget(fname,'xc'));
    
    dtglobal=nc_varget(fname,'tsglobal');
    dtmean=nc_varget(fname,'tsmean');
    dtrunup=nc_varget(fname,'tspoints');
    
    dtrunup=86400*(datenum(1970,1,1)+double(dtrunup)/86400-tref);
    
    zb=double(nc_varget(fname,'zb'));
    runup=double(nc_varget(fname,'runup'));
    runupx=nc_varget(fname,'runup_xw');
    runupy=nc_varget(fname,'runup_yw');
    Hmax=double(nc_varget(fname,'H_max'));
    zsmax=double(nc_varget(fname,'zs_max'));
    
    % Estimate alfa for profile from grid data.
    xdif = x2(end) - x2(1);
    ydif = y2(end) - y2(1);
    
    alfa=180*atan2(ydif,xdif)/pi;
    alfa=mod(alfa,360);
    %__________________________________________________________________________
    %CALCS FROM XBEACH OUTPUT
    % Find the pre and post MHW contour (1.38 m) and compare to look at
    % shoreline change along the profile
    % zbstart=zb(1,:,1)';
    % zbend=zb(end,:,1)';
    zbstart=squeeze(zb(1,1,:));
    zbend=squeeze(zb(end,1,:));
    [out,change] = shoreline_change(x2,y2,zbstart,zbend,d,mhw);
    
    shoreline0=out(1,4);
    
    % Find the back beach location (1.6 m MHHW), which should be the same before and
    % after the run unless there was major flooding.
    [bb_loc,bb_change] = shoreline_change(x2,y2,zbstart,zbend,d,mhhw);
    
    x_bb=bb_loc(1,1);
    y_bb=bb_loc(1,2);
    z_bb=bb_loc(1,3);
    d_bb=bb_loc(1,4);
    z_bb2=bb_loc(2,3);
    d_bb2=bb_loc(2,4);
    
    % Get closest model grid point to back beach location.
    for ii=1:length(d)
        p(ii)=abs(d(ii)-d_bb);
    end
    b_ind=find(p==min(p));
    
    % Estimate the profile erosion and accretion over the entire profile and
    % the net change in area between 0 and 1.6 m elevation (m2/m)
    [pchangeperm,perosionperm,pchangebeach] = profile_change(zbstart,zbend,d,d_bb,d_bb2);
    
    % Find the maximum runup height and associated time for the model run
    r_ind = find(runup==max(runup));
    max_r = runup(r_ind);
    max_r_time = dtrunup(r_ind);
    
    % Maximum run-up distance from origin
    max_runup_dist=max(sqrt( (runupx-x2(1)).^2 + (runupy-y2(1)).^2 ));
    
    % Read in the tidal forcing timeseries and find the difference between the
    % tidal forcing and maximum runup
    tide = load([inputdir 'tide.txt']);
    p=find(abs(max_r_time-tide(:,1))==min(abs(max_r_time-tide(:,1))),1,'first');
    WLdif=max_r-tide(p,2);
    
    % Find the maximum wave height at the offshore boundary for the model run.
    hmax=max(Hmax(:,1,1));
    hm_ind=find(Hmax(:,1,1)==max(Hmax(:,1,1)));
    
    % Initialize arrays for flooding and inundation flags
    nt=length(dtglobal);
    flood_flag1 = nan(nt,1);
    inund_flag1 = nan(nt,1);
    flood_dur=nan;
    
    % Find water level time series at back beach location by comparing z_max
    % over the timestep with zb for a point in time.  If the water level
    % reaches the back beach location (i.e. wl_bb is not NaN) then compare to
    % z_bb for flooding and inundation flags.
    for ii=1:length(dtmean)
        for jj=1:length(x2)
            if(zsmax(ii,1,jj)<=zb(ii+1,1,jj)+eps);
                zstemp(jj)=NaN;
                zsmax2(ii,jj,2)=NaN;
            else
                zstemp(jj)=zsmax(ii,1,jj);
                zsmax2(ii,jj,2)=zsmax(ii,1,jj);
            end
        end
        clear zstemp
    end
    
    for ii=1:length(dtmean)
        %    wl_bb(ii) = zsmax2(ii,b_ind,1);
        wl_bb(ii) = zsmax2(ii,b_ind,2);
    end
    
    p2=find(~isnan(wl_bb));
    if(isempty(p2)==0)
        % Flag times when there is flooding
        for ii=1:length(p2)
            if(wl_bb(p2(ii))>z_bb)
                flood_flag1(ii)=1;
            else
                flood_flag1(ii)=nan;
            end
        end
        % If flooding lasts more than one timestep, flag as inundation.
        for ii=2:length(flood_flag1)
            if(flood_flag1(ii)==1 && flood_flag1(ii-1)==1)
                %now check that the timesteps are consecutive
                if((dtmean(p2(ii))-dtmean(p2(ii-1)))==min(diff(dtmean)))
                    inund_flag1(ii)=1;
                else
                    inund_flag1(ii)=nan;
                end
            else
                inund_flag1(ii)=nan;
            end
        end
    end
    
    if(max(~isnan(flood_flag1))==1);
        flood_flag=1;
    else
        flood_flag=0;
    end
    
    if(max(~isnan(inund_flag1))==1);
        inund_flag=1;
    else
        inund_flag=0;
    end
    
    % Estimate duration of flooding/inundation in hours.
    p3=find(~isnan(flood_flag1));
    if(isempty(p3)==0)
        flood_dur=length(p3);
    else
        flood_dur=0;
    end
    
    % Write data to text file in output directory
    textout=[hmax,max_r,change,bb_change,pchangeperm,perosionperm,pchangebeach,flood_flag,inund_flag,flood_dur,WLdif];
    dum = fopen([outputdir,mopid,'_proc.txt'],'w');
    fprintf(dum,'hmax(m) max      shoreline      back beach       Profile         Profile       Profile      Flood Inundation Flood        WL Dif\n');
    fprintf(dum,'        runup(m) change, mhw(m) change, mhhw(m)  Accretion(m2/m) Erosion(m2/m) Change(m2/m) Flag  Flag       Duration(hr) maxr-tide(m)\n');
    fprintf(dum,'%5.2f %8.2f %10.2f %14.2f %15.2f %15.2f %12.2f %8d %5d %10.0f %14.2f\n',textout');
    fclose(dum);
    
    % Save a mat file of output data in output directory
    eval(['save ',outputdir,mopid,'_proc.mat x2 y2 d dtglobal dtmean dtrunup alfa zbstart zbend out change x_bb y_bb z_bb d_bb z_bb2 d_bb2 b_ind bb_change pchangeperm perosionperm pchangebeach max_r r_ind max_r_time WLdif hmax hm_ind wl_bb flood_flag inund_flag flood_dur']);
    %__________________________________________________________________________
    
    s.profile(1).name=mopid;
    s.profile(1).originx=num2str(x2(1),'%8.2f');
    s.profile(1).originy=num2str(y2(1),'%8.2f');
    s.profile(1).length=num2str(sqrt( (x2(end)-x2(1))^2 + (y2(end)-y2(1))^2 ),'%8.2f');
    s.profile(1).alpha=num2str(alfa,'%8.2f');
    s.profile(1).name=mopid;
    s.profile(1).proc.hmax=num2str(hmax,'%8.2f');
    s.profile(1).proc.max_runup=num2str(max_r,'%8.2f');
    s.profile(1).proc.max_runup_dist=num2str(max_runup_dist,'%8.2f');
    s.profile(1).proc.original_shoreline=num2str(shoreline0,'%8.2f');
    s.profile(1).proc.shoreline_change=num2str(change,'%8.2f');
    s.profile(1).proc.original_backbeach=num2str(d_bb,'%8.2f');
    s.profile(1).proc.backbeach_change=num2str(bb_change,'%8.2f');
    s.profile(1).proc.profile_accretion=num2str(pchangeperm,'%8.2f');
    s.profile(1).proc.profile_erosion=num2str(perosionperm,'%8.2f');
    s.profile(1).proc.beachprofile_change=num2str(pchangebeach,'%8.2f');
    s.profile(1).proc.flood_flag=flood_flag;
    s.profile(1).proc.inund_flag=inund_flag;
    s.profile(1).proc.flood_duration=num2str(flood_dur,'%8.2f');
    s.profile(1).proc.wl_diff=num2str(WLdif,'%8.2f');
    
    xml_save([xmldir mopid '.xml'],s,'off');
    
catch
    disp(['Something went wrong while determing hazards ' mopid ]);
end
