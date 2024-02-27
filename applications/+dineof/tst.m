%function OK = tst(varargin)
%TST test for DINEOF
%
%  dineof.tst(<keyword,value>) tst for DINEOF
%
%See als0: DINEOF
close all
clear all

OPT.plot = 1;

%OPT = setproperty(OPT,varargin);

%% X x T
    nt      = 11; T    = [1:nt];
    nx      = 13;
    x       = linspace(-3,3,nx)';
    z       = peaks(x,0);
    mask    = rand(size(z)) < 1.1;
    
    mask2 = double(mask);
    mask2(~mask) = nan;
 
    for it=1:nt
      noise  = 0.*rand(size(z));
      cloudiness = 0.4;
      clouds = double(rand(size(z)) > cloudiness);
      clouds(clouds==0)=nan;
      D(:,it) =       z.*cos(1.0.*pi.*it./nt).*x + ...
                      noise.*mask2.*clouds;
    end
    
    [F,E] = dineof.run(D, T, mask, 'nev',5,'ncv',10,'plot',OPT.plot,'export',0,'cleanup',0);
 
%%    
       N = sum(~isnan(D(:)));
       for i=1:E.P
          M = zeros([size(D)]);
          for it=1:size(E.rghvec,1)
           M(:,it) = permute(E.lftvec(:,i)*E.vlsng(i)*E.rghvec(it,i),[3 1 2]);
          end
          E.mode_var_aut(i) = sum(M(~isnan(D(:))).^2)./N;      % This works only for EOF fits
          E.mode_var_cor(i) = sum(M(~isnan(D(:))).*...
                                 (D(~isnan(D(:)))-E.mean))./N; % This also works for other fits, e.g. harmonic 
       end
    
       R.var        = sum((D(~isnan(D(:)))-nanmean(D(:))).^2)./N;
       E.var        = sum((F(~isnan(D(:)))-       E.mean).^2)./N;

       E.modeEx_aut    = 100.*E.mode_var_aut./R.var;
       E.modeEx_cor    = 100.*E.mode_var_cor./R.var;
    
       for i=1:E.P
       E.modeLab_aut{i} = ['Mode ',num2str(i,'%d'),' = ',num2str(E.modeEx_aut(i),'%0.1f'),' %'];
       E.modeLab_cor{i} = ['Mode ',num2str(i,'%d'),' = ',num2str(E.modeEx_cor(i),'%0.1f'),' %'];
       end

       E.varLab       % ?? when clouds
       E.modeLab_aut' % OK when clouds       
       E.modeLab_cor' % OK when clouds

    OK(1) = isequal(size(D),size(F));clear data

%% 1 x X x T

    nt      = 14;time    = [1:nt];
    nx      = 50;
    x       = linspace(-3,3,nx)';
    z       = peaks(x,0);
    mask    = rand(size(z)) < 1;
 
    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(2) = isequal(size(data),size(dataf));clear data
    
%% 1 x X x T

    nt      = 14;time    = [1:nt];
    nx      = 50;
    x       = linspace(-3,3,nx);
    z       = peaks(x,0);
    mask    = rand(size(z)) < 1;
 
    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(3) = isequal(size(data),size(dataf));clear data

%% X x Y x T

    nt      = 14;time    = [1:nt];
    ny      = 20;
    nx      = 21;
   [y,x]    = meshgrid(linspace(-3,3,ny),linspace(-3,3,nx));
    z       = peaks(x,y);
    mask    = rand(size(z)) < 1;
    mask(1:5,1:5) = 0; % land

    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(4) = isequal(size(data),size(dataf));clear data
    
%%

OK = all(OK);
    