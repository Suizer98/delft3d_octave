function DESettings = defaultDESettings

DESettings = struct(...
    'Flags',[],...                                   % for logical values that can be used to turn on / off various processes in the dune erosion calculation
    'Constants',[],...                               % for constants during the calculation
    'ParabolicProfile',[],...
    'Other',struct ...                               % for all other (temporary) variables that are needed during calculation
    );

DESettings.Flags = struct(...
    'AdditionalErosionMax',true,...                  % can be used to turn on / off boundary limitation of the additional erosion to 15 meters
    'ChannelSlopes',true,...                         % can be used to turn on / off boundary limitation due to steep (channel) slopes
    'PreventLandwardTransport',true,...              % can be used to turn on / off volume correction for landward directed sediment transport
    'AutoStrengthening',false,...                    % can be used to turn on / off automated strengthening of a landward profile part
    'DuneBreachCalculation',true ...                 % can be used to turn on / off secondary calculations after a first dune row has been breached
    );

DESettings.Constants = struct(...
    'a',0.476,...                                    % first constant used in calculation of the fall velocity of sediment
    'b',2.18,...                                     % second constant used in calculation of the fall velocity of sediment
    'c',3.226,...                                    % third constant used in calculation of the fall velocity of sediment
    'rho',1024,...                                   % specific gravity of salt water
    'g',9.81...                                      % fall acceleration
    );

DESettings.Other = struct(...
    'AdditionalVolume','min([-20,.25*Volume])',...   % formulation to use to determine the target volume
    'TP12slimiter',true,...                          % Switch TP limiter at 12s on/off (true/false)
    'Plus','-plus',...                               % DUROS-plus method (including Tp, as opposed to DUROS)
    'Period','TP',...                                % Type of period measure that is used (either TP or TMM10)
    'n_d',1, ...                                     % scale factor
    'Bend',0, ...                                    % Coastal Bend
    'ProfileFluct',0, ...                            % Profile fluctuation
    'maxRetreat',15,...                              % Limitation of additional erosion length
    'maxiter', 50, ...                               % Maximum number of iterations
    'verbosemessages',[45,1,3,60,61,-4,-5,-6],...    % Messages that have to be displayed whem verbose is set to true
    'FallVelocity', {{@getFallVelocity ...           % Fall velocity function
        'a' 0.476 ...                                % Fall velocity input arguments; these arguments will be passed through to the fall velocity function together with the D50
        'b' 2.18 ...
        'c' 3.226 ...
        'D50'}}, ...                                 % Since getFallVelocity uses propertyname propertyvalue pairs for all variables, the last arguments is therefore the propertyname (!) D50, since the property value of D50 is included during the process
    'd',20 ...                                       % Gives the depth contour (relative to z=0) at which the hydraulic conditions are given.
    );

DESettings.ParabolicProfile = struct(...
    'c_1',0.4714,...                                 % DUROS/DUROS+ coefficient c1 : used for definition of erosion profile
    'c_2',18,...                                     % DUROS/DUROS+ coefficient c2 : used for definition of erosion profile
    'c_1plusplus',0.6,...                            % D++ coefficient c1 : used for definition of erosion profile
    'c_2plusplus',50,...                             % D++ coefficient c2 : used for definition of erosion profile
    'c_hs',7.6,...                                   % reference wave height
    'cp_hs',1.28,...                                 % power of wave height component
    'c_tp',12,...                                    % Reference wave period for D+
    'cp_tp',0.45,...                                 % power of wave period component in D+ equation...
    'c_w',0.0268,...                                 % reference fall velocity
    'cp_w',0.56,...                                  % power of fall velocity component
    'xref',250,...                                   % reference length of erosion profile (for Hs=7.6m, Tp=12s, ws=0.0268, d=NAP-20m)
    'xrefplusplus',270,...                           % D++ value for reference length of erosion profile (for Hs=7.6m, Tp=12s, ws=0.0268, d=NAP-20m)
    'gammaplusplus',0.4,...                          % D++ value for gamma, which is used for the wave breaking model (0.4 works well for ENDEC/ 0.5 for SWAN without wind / 0.6 for SWAN with wind / 0.7 for Xbeach) 
    'thetaplusplus',0.06,...                         % D++ value for deltagamma, which is used for smooth transition to cfdepth correction factor (0.06 works well for steep profiles/reference profile) 
    'ParabolicProfileFcn', @getParabolicProfile, ... % Parabolic profile function
    'ParabolicProfileFcnInput',{{...
        '#PARWL_T',...
        '#PARHS_T',...                               % Input arguments for the parabolic profile function
        '#PARTP_T',...                               % #PARHS_T #PARTP_T #PARW #PARX0 #PARX #PARD
        '#PARW',...                                 
        '#PARX0',...                                
        '#PARX'}},...                                
    'rcParabolicProfileFcn', @getRcParabolicProfile, ... % Function that calculates the rc of the parabolic profile excactly
    'rcParabolicProfileFcnInput',{{...
        '#PARWL_T',...                               % Input arguments fot the rcDetermination:
        '#PARHS_T',...                               %  #PARWL_T #PARHS_T #PARTP_T #PARW #PARZ #PARD
        '#PARTP_T',...
        '#PARW',...
        '#PARZ'}},...
    'invParabolicProfileFcn', @invParabolicProfile,...
    'invParabolicProfileFcnInput',{{...
        '#PARWL_T',...                               % Input arguments fot the rcDetermination:
        '#PARHS_T',...                               %  #PARWL_T #PARHS_T #PARTP_T #PARW #PARZ #PARD
        '#PARTP_T',...
        '#PARW',...
        '#PARZ'}}...
    );                                              

%    Possible parameters:
%       * #PARHS_T - Is replaced by the significant wave height
%       * #PARTP_T - Is replaced by the peak period
%       * #PARW    - Is replaced by the calculated fall velocity
%       * #PARX0   - Is replaced by the x0 position (shift of the profile) during iterations.
%       * #PARX    - Is replaced by the xgrid during the iteration process
%       * #PARD    - Is replaced by the depth (d) that is stored in the DuneErosionSettings.Other.d
%       * #PARZ    - Is replaced by the z value during a call to getRcParabolicProfile or a replacement of that function
%       * #PARWL_T - Is replaced by the storm surge level

DESettings.Actions = struct(...
    'Verbose',true, ...                              % Display important messages at the end of the calculation
    'DUROS',true, ...                                % can be used to turn on / off DUROS(-plus) calculation
    'AdditionalErosion',true, ...                    % can be used to turn on / off additional erosion calculation
    'BoundaryProfile',true ...                       % can be used to turn on / off boundary profile fitting
    );
