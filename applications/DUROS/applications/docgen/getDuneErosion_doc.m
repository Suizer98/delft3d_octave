%% DUROS(+) Dune Erosion routines
% The functions in this toolbox are designed for performing dune erosion
% calculations according to the <matlab:winopen(which('TRDA.pdf')) Dutch safety
% assessment rules>. This involves a couple of steps that are demonstrated
% in this document. 

%% General overview
% The calculation method can be subdivided into four steps:
%
% # Iteration of the (right location) of the erosion profile. This involves
%       routines to put together the correct erosion profile and routines
%       aimed at locating the erosion profile in such a way that the amount
%       of erosion equals the sedimentation (a closed sediment balance).
% # The second step is aimed at calculating the amount of eroded sediment
%       above the maximum storm surge level. This volume is needed in order
%       to calculate the additional erosion volume that has to be accounted
%       for in the third step.
% # Due to uncertainties of the relatively simple model an additional
%       erosion volume has to be taken into account to estimate the erosion
%       that is likely to occur during an extreme storm event.
% # Last step in the calculation is to insert a boundary profile in the
%       remaining dune profile that is designed to have enough strength to
%       be able to withstand higher water levels and waves in the period
%       after the storm when the dune is not yet recovered from the storm.
%
% A calculation including all the steps mentioned above can be conducted
% with the main function of the toolbox: _*getDuneErosion*_. An example of 
% a calculation with the reference profile is shown below:

% Initiate input variables
[xInitial, zInitial] = SimpleProfile;
Hs = 9;
Tp = 16;
WL = 5;
D50 = 225e-6;

% calculate the erosion profile, erosion volumes etc.
dresult = getDuneErosion(xInitial,zInitial,D50,WL,Hs,Tp);

% plot the results.
fig = figure(...
    'Position',[200 200 600 400],...
    'Color','w');
plotDuneErosion(dresult,fig);
    

%% The dune erosion profile
% First of all dune erosion is supposed to lead to an "equilibrium" erosion 
% profile after the storm. This profile consists of three parts. The middle
% part is a parabolic like shaped profile. The parabolic shape is described
% by:
%
% $$\left( {{{7,6} \over {H_{0s} }}} \right)y = 0,4714\left[ {\left( {{{7,6} \over {H_{0s} }}} \right)^{1,28} \left( {{{12} \over {T_p }}} \right)^{0,45} \left( {{w \over {0,0268}}} \right)^{0,56} x + 18} \right]^{0,5}  - 2,0$$
%
% The above equation describes the parabolic profile ranging from the 
% maximum storm surge level downwards. This parabolic shape is supposed to 
% have a maximum length/depth. Relative to the origin of the parabolic 
% profile (at storm surge level) this length is given by:
% 
% $$x_{\max }  = 250\left( {{{H_{0s} } \over {7,6}}} \right)^{1,28} \left( {{{0,0268} \over w}} \right)^{0,56}$$
% 
% The height of the parabolic profile corresponding with this length is:
%
% $$y_{\max }  = \left[ {0,4714\left\{ {250\left( {{{12} \over {T_p }}} \right)^{0,45}  + 18} \right\}^{0,5}  - 2,0} \right]\left( {{{H_{0s} } \over {7,6}}} \right)$$
%
% In these equations:
%
% * _H_ 0s = Significant wave height [m]
% * _T_ p  = Wave peak period [s]
% * _w_    = Fall velocity [m/s]
%
% The fall velocity can be calculated with the following equation:
%
% $$^{10} \log \left( {{1 \over w}} \right) = 0,476\left( {^{10} \log D_{50} } \right)^2  + 2,180^{10} \log D_{50}  + 3,226$$
%
% With:
%
% * _D_ 50 = Measure for the grain size diameter.
%
% Below the tip of the parabolic profile a linear profile is assumed with a
% steepness of 1:12,5. Above the maximum storm surge level collapsing of
% the dune front occurs. The resulting profile is schematized with a 1:1
% slope. 
%
% The following code shows an example of such a profile, based on the same
% reference profile.

% calculate the DUROS profile
result = getDUROSprofile(xInitial,zInitial,-60,Hs,Tp,WL,getFallVelocity(225e-6));

% create figure
figure(...
    'Position',[200 200 600 400],...
    'Color','w');
hold on
box on
grid on
ylim([-5 16]);
xlim([-100 300]);
xlabel('Cross-shore coordinate [m]');
ylabel('Height [m]');

% plot the profiles
plot(xInitial,zInitial,'Color','k','DisplayName','Dune profile before a storm');
plot(result.xActive,result.z2Active,'Color','r','LineWidth',2,'DisplayName','Shape of the erosion profile');
addSlopeText(result.xActive(1:2),result.z2Active(1:2));warning('off','all');
addSlopeText(result.xActive(end-1:end),result.z2Active(end-1:end));warning('on','all');
plot([-100 300],[WL WL],'LineWidth',2,'LineStyle','--','Color','b','DisplayName','Maximum storm surge level');

% show legend
legend show

%% Optimization of the sediment balance
% The empirical erosion profile must be fit into the initial (pre storm)
% profile in such a way that the amount of erosion needed to achieve such
% an erosion profile equals the amount of deposition that would occur.
% 
% *Iteration boundaries*
%
% The toolbox uses the function _getIterationBoundaries_ to identify the
% boundaries between which the erosion profile can be moved. It is for
% example not possible to construct the erosion profile described above
% for which the origin of the erosion profile (point of the parabolic profile
% at maximum storm surge level) lies seaward of the most seaward crossing
% between the profile and the water level. Also no sediment balance can be
% calculated if there is no crossing between the parabolic profile and the
% initial profile (In that case the erosion profile is placed too far 
% landward).
%
% *Iterative determination of the correct location of the erosion profile*
%
% The function _optimiseDUROS_ performs iterations to find out the correct
% location of the erosion profile. Each iteration step it does the
% following:
%
% # Determine the erosion profile based on an x0 (origin of the erosion
%       profile).
% # Calculate the sediment balance of the solution under consideration with
%       the use of the function _getVolume_.
% # Determine whether the sediment balance is zero (or within a certain 
%       precision).
% # If the solution is not good enough, determine the x0  for the following 
%       iteration step
%
% *Landward transport*
%
% If it finds the correct x0 location the solution is checked for landward
% transport. The empirical model dictates that in the solution any landward
% transport of sediment must not taken into account. If this solution is
% out of balance because of this, the earlier results are corrected for
% landward transport as well and the iteration is continued with landward
% transport taken into account.
%
% *Channel slopes*
%
% It can happen that the initial profile contains parts with a steepness of
% more than 1:12,5 at the possible location of the toe of the erosion
% profile. In this case finding a solution becomes very difficult. A small
% movement of the solution in landward direction results in more erosion
% than deposition. A small movement of the erosion profile seaward includes
% the so-called "channel part" and will result in a large deposition volume
% compared to the erosion that would occur in that situation. This will
% result in the solution being moved from one side of the channel slope to
% the other without finding a closed sediment balance. For this case the
% assessment rules prescribe that the toe of the erosion profile should be
% placed exactly on the 1:12,5 point of the slope of the channel.
% 

% TODO create examples

%% Erosion volume above the maximum storm surge level
% With the DUROS erosion profile calculated in the previous step in mind, 
% the amount of eroded sediment above the maximum storm surge level (SSL)
% can be calculated with the function _getVolume_.

%% Additional erosion volume
% Three sources of uncertainty in this empirical method are described in
% the <matlab:winopen(which('TRDA.pdf')); Dutch safety assessment rules>:
%
% # Uncertainty of the input parameters (Measured profiles that are used as 
%       input do not necessarily represent the initial profile at the 
%       beginning of an extreme storm. Next to that also the exact valeues 
%       of the other input parameters is unknown).
% # There is no effect of the duration of the storm and variation of the
%       input parameters during a storm in this model. In practice this is
%       expected to have an influence on the final erosion profile.
% # This method account for a purely 2-dimensional redistribution of the
%       sediment whereas in reality some of the sediment is also
%       transported to other transects.
%
% To account for this uncertainty an additional erosion volume has to be
% taken into account. This volume is determined based on the erosion volume
% above SSL as calculated in the previous step:
%
% $$T = 0,25A$$
%
% In which:
% 
% * A = erosion volume above SSL [m3/m]
% * T = additional erosion volume [m3/m]
% 
% The T volume must be fitted in the remaining erosion profile above SSL. 
% Like the erosion profile also the additional erosion profile is assumed
% to have a slope of 1:1 of the dune face. A function similar to
% _optimiseDUROS_ (_getAdditionalErosion_)is used to calculate the exact 
% shape of the additional erosion volume.

% TODO: provide illuatration?

%% Boundary profile
%TODO: write section about boundary profile

%% 
%thisisthetempmainpage