function rmax=rmax_knaff_and_zehr_2007(vsrm,lat)

% Computes Rmax based on Knaff et al 2007
% Storm relative intensity given in knots (or should we use Vmax ???)
% rmax given in km

rmax=66.785 - 0.09102*vsrm + 1.0619*(abs(lat)-25); % Knaff and Zehr 2007 (in kilometers)

% % Convert to NM
% rmax=rmax/1.852;
