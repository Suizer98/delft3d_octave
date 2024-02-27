function [Xq,Yq,Qq,tq] = ddb_NestingToolbox_XBeach_LISFLOOD_nest2a(xbeach, type)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Marc approach
if strcmp(type, 'berm')
    
    % Go to XBeach and read results
    cd(xbeach.path)
    
    % Get values
    try
    qx_mean     = nc_varget ('xboutput.nc','qx_mean');
    meantime    = nc_varget ('xboutput.nc','meantime');
    x           = nc_varget ('xboutput.nc','globalx');
    y           = nc_varget ('xboutput.nc','globaly');
    nx          = size(x,1);
    zb          = nc_varget ('xboutput.nc','zb');
    sedero      = nc_varget ('xboutput.nc','sedero');
    [berm]      = berm_location(zb,sedero,x,y);
    Xq          = berm(1); idx = find(berm(1) == x);
    Yq          = berm(2);
    Qq          = squeeze(qx_mean(:,:,idx));
    Qq1          = squeeze(qx_mean(:,:,nx-3));
    tq          = meantime;
    catch
    Qq          = NaN;
    tq          = NaN;
    Xq          = NaN;
    Yq          = NaN;
    end

%% Apply discharges from the back in XBeach in the model    
else
    
    % Go to XBeach and read results
    cd(xbeach.path)
    
    % Get values
    try
    qx_mean     = nc_varget ('xboutput.nc','qx_mean');
    meantime    = nc_varget ('xboutput.nc','meantime');
    x           = nc_varget ('xboutput.nc','globalx');
    y           = nc_varget ('xboutput.nc','globaly');
    zb          = nc_varget ('xboutput.nc','zb');
    nx          = size(x,1);
    
    % Find values
    Qq          = squeeze(qx_mean(:,:,nx-3));
    tq          = meantime;
    Xq          = x(nx-3);
    Yq          = y(nx-3);   
    catch
    Qq          = NaN;
    tq          = NaN;
    Xq          = NaN;
    Yq          = NaN;
    end
end

end

