function [pca]=cmgpca(u,v,varargin)%CMGPCA- function for principal component analysis.% % INPUTS:%   u, v = vectors of the two components of, e.g. currents.% % OUTPUS:%   Structure with the following fields:%       maazi - major axis azimuth (relative to EAST)%       mamag - major axis magnitude%       miazi - minor axis azimuth (relative to EAST)%       mimag - minor axis magnitude%% OPTIONS%    pca=cmgpca(u,v,'geo') - will rotate major and minor %       axis aziumths into geographic convention (NORTH up).%   % jpx @ usgs, 01-04-01% if nargin<1	help(mfilename);	return;elseif nargin<2	fprintf('\nAt least two input arguments are needed.\n');	return;endgflag=0;if any(strcmpi('geo',varargin));    gflag=1;endif any(size(u)-size(v))	fprintf('\nSizes of the first two arguments must agree.\n');elseif size(u,2)>1	fprintf('\nThe first two arguments cannot be matrices.\n');end;%timeplt_figure(12,1,'anything');indx=find(isnan(u)==0);u=u(indx);v=v(indx);indx=find(isnan(v)==0);u=u(indx);v=v(indx);covar=cov(u,v);[eigvec,eigval]=eig(covar);if eigval(2,2)>eigval(1,1)	cols=[2 1];else	cols=[1 2];end;majr=sqrt(eigval(cols(1),cols(1)));[junk,majaz]=cmguv2spd(eigvec(1,cols(1)),eigvec(2,cols(1)));minr=sqrt(eigval(cols(2),cols(2)));[junk,minaz]=cmguv2spd(eigvec(1,cols(2)),eigvec(2,cols(2)));if gflag    majaz=(360 - majaz) + 90;    majaz(majaz>360)=majaz(majaz>360)-360;        minaz=(360 - minaz) + 90;    minaz(minaz>360)=minaz(minaz>360)-360;endpca.maazi=majaz;pca.mamag=majr*2;pca.miazi=minaz;pca.mimag=minr*2;