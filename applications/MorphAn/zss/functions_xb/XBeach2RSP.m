function [x] = XBeach2RSP(x_xb, x_Jrk)
% input
% - x_xb: x-axis of x-values XBeach
% - x_Jrk: x-axis of x-values from JarKus measurement. 
% 		x_Jrk(1) is most landward value where min(x_Jrk) == x_Jrk(1)

    % reverse x values XBeach
    x = (x_xb - max(x_xb)) .* -1;

    % transform the x-grid of XBeach to RSP
    RSPdiff = x_Jrk(1);
    x = x + RSPdiff;

end