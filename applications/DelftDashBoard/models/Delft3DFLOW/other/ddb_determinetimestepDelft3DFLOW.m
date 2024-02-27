function timestep = ddb_determinetimestepDelft3DFLOW(x,y,z)

%% Valid for projected grids
dxx=diff(x,1,1);
dxy=diff(x,1,2);
dyx=diff(y,1,1);
dyy=diff(y,1,2);
distx=sqrt(dxx.^2+dyx.^2);
disty=sqrt(dxy.^2+dyy.^2);
%mindelta=min(distx(:,2:end),disty(2:end,:)); % Is this correct? Or perhaps new Matlab version?
mindelta=min(min(min(distx)),min(min(disty)));
dep=z(2:end,2:end);
dep(dep>0)=NaN;
dep = dep*-1;

% Criteria 1: stability flooding
timestep1 = min(min(2*mindelta/5))/60;

% Criteria 2: barotropic mode
% Easy
timestep2a = min(min(5*mindelta./sqrt(dep*9.81)))/60;

% Hard
dxdyterm = power(distx(:,2:end),-2) + power(disty(2:end,:),-2);
term2 = power((9.81.*dep.*dxdyterm),0.5);
timesteps = 5./ term2;
timestep2b = min(min(timesteps)) / 60;

% Check
% figure; pcolor(courantnumbers); caxis([0 10]); colormap(jet); shading flat;
% courantnumbers = 2*120*term2;
% ;

% Output
out = min(timestep1, timestep2b);

% Find the largest time step
suggested_timesteps=[1e-9 0.001 0.002 0.0025 0.005 0.01 0.02 0.025 0.05 0.1 0.2 0.25 0.5 1 2 2.5 5 10 100000];
ilast=find(suggested_timesteps<=out,1,'last');
timestep=suggested_timesteps(ilast);

% timestep = round(out,0);
% if timestep < 1
% timestep = round(out,1);
% end
    

