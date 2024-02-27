function plot_mopspec(mopid,monthid)

% This program reads in the 2d spectral timeseries generated from the MOP
% spectral input for Xbeach and loops through to view the 2D spectra
% versus the inputs as a check.

%   Input:
%     mopid = mop station id (ex: 'VE338')
%     monthid = year and month of data (ex: '200904')

% JLE 9/27/09

% Read in the 2d spectral time series.
load([mopid,'_',monthid,'_2dspec.mat']);

% Now, loop through and plot the 2D spectra versus the first 
% moment mean directions as a check.
for ii=1:length(out1d.t)
    
    Splot=out2d.s(:,:,ii);
    
    %Define colormap based on max energy
    maxS = max(max(Splot));
    c = maxS;
    for kk=1:31
      c = [c(1)/2; c];
    end
    cmap = jet(length(c)-1); 
    cmap(1,:)= [1 1 1];
    
    figure
    set(gcf,'Position',[60 200 800 600])
    subplot(2,1,1)
    pcolor(out2d.f,out2d.d,Splot')
    colormap(cmap)
    shading interp
    colorbar
    grid on
    hold on
    plot(out1d.f,out1d.dmean(:,ii),'.k','MarkerSize',4)
    a=axis;
    axis([0 0.5 a(3) a(4)]);
    title(['2D Input Spectrum for MOP station VE 338 ',datestr(out1d.t(ii),0)]);
    xlabel('Frequency, Hz')
    ylabel('Direction, deg')
    clear a
    
    %Now, create 1d spec from 2d spec and plot to compare
    for jj=1:length(out1d.f)
        Espec(jj)=sum(Splot(jj,:));
    end
    % Now convert this to a 1D spectrum for the same time and plot
    subplot(2,1,2)
    plot(out1d.f,out1d.e(:,ii),'-b');
    xlabel('Frequency, Hz');
    ylabel('Energy Density, m^2/Hz');
    grid on
    hold on
    plot(out1d.f,Espec,'--r');
    legend('1d spectrum from CDIP','1d spectrum from 2d estimate');
    title(['Energy Density, m^2/Hz for MOP station VE 338',datestr(out1d.t(ii),0)]);
    text(out1d.f(25),(max(out1d.e(:,ii))/4)*3,['Hs = ',num2str(out1d.hs(ii))]);
    text(out1d.f(25),max(out1d.e(:,ii))/2,['Tp = ',num2str(out1d.tp(ii))]);
    text(out1d.f(25),max(out1d.e(:,ii))/4,['Dp = ',num2str(out1d.dp(ii))]);
    a=axis;
    axis([0 0.5 a(3) a(4)]);
    
    pause
    close
end