function varargout = godin_filter(time,data)
%GODIN   GODIN low-pass tide filter for time series
%
% godin(time,data)
%
% where time is in days
%
%See also: THOMPSON1983, T_TIDE, fft_filter, godin_filter

% equidistant time function

dthour = 24*(time(2) - time(1)); % hours

n_24   = round(24/dthour) ; % 144 with 10 minute times eries
n_25   = round(25/dthour) ; % 150 with 10 minute times eries

ones24 = ones(n_24,1);
ones25 = ones(n_25,1);

%plot(time,data,'k')
%hold on
%pausedisp

rm1      = filter(ones24,n_24,data);
rm1      = rm1   (n_24:end); % skip n_24 -1, so start at n_24
time1    = filter(ones24,n_24,time);
time1    = time1 (n_24:end);

%plot(time1,rm1,'r')
%pausedisp

rm2      = filter(ones24,n_24,rm1);clear rm1;
rm2      = rm2   (n_24:end);
time2    = filter(ones24,n_24,time1);clear time1;
time2    = time2 (n_24:end);

%plot(time2,rm2,'g')
%pausedisp

rm3      = filter(ones25,n_25,rm2);clear rm2;
rm3      = rm3   (n_25:end);
time3    = filter(ones25,n_25,time2);clear time2;
time3    = time3 (n_25:end);

%plot(time3,rm3,'b')
%pausedisp



    if nargout==1
    
    varargout = {rm3};
    
elseif nargout==2


   varargout = {rm3,time3};
   
end


% http://ferret.pmel.noaa.gov/Ferret/Mail_Archives/fu_2000/msg00464.html
% > I am wanting to pass hourly current data through a Godin filter.  That is,
% > perform 3 UNWEIGHTED running means - 24, 24, 25 - but am not having much
% > luck.  Does anyone our there have an existing journal file or alternatively
% > some ideas on how to do it?  
% 
% You can use @SBX to make running averages, including those with an even
% number of points, but I assume you knew that. If the problem is that 
% @SBX:24 weights the endpoints by 1/2 (in order to keep the running mean 
% on the original gridpoints), then you can construct such a mean by hand. 
% Since you will be doing the even-n1umbered running mean twice, the result 
% will still end up on the original gridpoints:
% 
% let rm1=(var[l=@shf:-12]+var[l=@shf:-11]+ ... +[var[l=@shf:11])/24
% let rm2=(rm1[l=@shf:-11]+rm1[l=@shf:-10]+ ... +[rm1[l=@shf:12])/24
% let godin=rm2[l=@sbx:25]
% 
% In this example, the result of the first calculation (rm1) will be placed
% "incorrectly", in that the first value will be found at point 13, whereas
% a true 24-point running mean would be centered at point 12.5. But then the
% second calculation (rm2) will place its first result at gridpoint 24 (note
% that the arguments to @SHF are different in each case), which is correct.
% Then then final filter (godin) is a straightforward @SBX, which will place 
% the first value at gridpoint 36.
% 
% You will probably run into line-length problems with the specification of
% rm1 and rm2. In that case break the calculation into a few segments.
% 
% I'm curious if the result of this is significantly different than what you
% would get by simply doing:
% 
% let check1=var[l=@sbx:24]
% let check2=check1[l=@sbx:24]
% let check3=check2[l=@sbx:25]
% 
% ????
% 
% Billy K


