function [d_start, slope] = check_profile(Hm0, Tp, d_profile, varargin)

    %% Settings
    d_randvoorwaarde = 20;
    
    %Hm0 = (maximum) significant wave height
    %Tp = maximum wave period
    % d_profile = starting depth of existing profile 
    
    %varargin:
    % - 'figures'
    % - 'info' 
    
    %% compute Hm0,shoal
    [cg_BC dummy]                   = wavecelerity(Tp, d_randvoorwaarde);
    [cg_profile n_profile]          = wavecelerity(Tp, d_profile);
    
    disp(['n = ' num2str(n_profile)])
    
    Hm0_shoal                       = Hm0 * sqrt(cg_BC/cg_profile);

    %% check

    if Hm0_shoal/d_profile<0.3 & n_profile<0.9
        disp('no changes required')
        if sum(strcmp(varargin(:),'info'))>0
            fprintf('Hm0,shoal=%2.2f\n',Hm0_shoal)
            fprintf('d_{start}=d_{profile}=%2.2f\n',d_profile)
            fprintf('Hm0,shoal/d=%2.2f\n',Hm0_shoal/d_profile)
            fprintf('n=%2.2f\n',n_profile)
        end
        d_start = d_profile;
        slope = 'NaN';
    else
        % --- compute d_start en Hm0,shoal iterative
        d_start = d_profile;
        d_start_previous =  2* d_profile;
        count = 1;
        % --- d_n: depth for which n=0.9
        d_n         = celerity_ratio_equals_09(Tp,d_start);
        if sum(strcmp(varargin(:),'figures'))>0 ; figure(); end
        while abs(d_start-d_start_previous)>0.05

            % ---
            d_start_previous            = d_start;
            % --- 
            d_start                     = max(3.33333*Hm0_shoal, d_n);
            % --- compute Hm0,shoal
            [cg n_startdepth]           = wavecelerity(Tp, d_start);
            Hm0_shoal                   = Hm0 * sqrt(cg_BC/cg);
            if sum(strcmp(varargin(:),'figures'))>0
                subplot(2,1,1)
                plot(count,Hm0_shoal,'ro'); hold on
                subplot(2,1,2)
                plot(count,d_start,'ro'); hold on
                plot(count,d_start,'bo'); hold on
            end
            count = count + 1;
            if count>20
                disp('error')
                break            
            end
        end
        % ---
        if Hm0_shoal/d_profile>0.3 & n_profile>0.9
            slope = 0.02;
            disp('Artificial slope of 1:50')
        else
            slope = 0.1;
            disp('Artificial slope of 1:10')
        end
        if sum(strcmp(varargin(:),'info'))>0
            fprintf('Hm0,shoal=%2.2f\n',Hm0_shoal)
            fprintf('d_{start}=%2.2f\n',d_start)
            fprintf('Hm0,shoal/d_{slope}=%2.2f\n',Hm0_shoal/d_profile)
            fprintf('Hm0,shoal/d_{start}=%2.2f\n',Hm0_shoal/d_start)
            fprintf('n(d_{slope})=%2.2f\n',n_profile)
            fprintf('n(d_{start})=%2.2f\n',n_startdepth)
        end
    end
    
    if sum(strcmp(varargin(:),'figures'))>0
        figure;
        fill([0 0.3 0.3 0],[0 0 0.9 0.9],'r','facealpha',0.2)
        hold on
        fill([0.3 1 1 0.3],[0 0 0.9 0.9],'b','facealpha',0.2)
        fill([0 0.3 0.3 0],[0.9 0.9 1 1],'m','facealpha',0.2)
        fill([0.3 1 1 0.3],[0.9 0.9 1 1],'y','facealpha',0.2)
        plot([0 1],[0.9 0.9],'r--','linewidth',2)
        plot([0.3 0.3],[0.5 1],'r--','linewidth',2)
        plot(Hm0_shoal/d_start,n_startdepth,'o')
        hold on
        plot(Hm0_shoal/d_profile,n_profile,'o')
        ylim([0.5 1])
        xlabel('H_{m0,shoal0/d}')
        ylabel('n=c_g/c')
    end

    
    %%
    function d = celerity_ratio_equals_09(Tp,d_start)
        d_dummy = d_start;
        count2   = 1;
        n       = 1;
        while n>0.9
            [cg n] = wavecelerity(Tp, d_dummy);
            d_dummy = d_dummy + 0.05;
            count2 = count2+1;
            if count2>500
                disp('error')
                break 
            end
        end
        d = d_dummy;
    end


    function [cg n] = wavecelerity(Tp, d)
        g = 9.81;
        k   = disper(2*pi./Tp, d, g);
        n   = .5*(1+2.*k.*d./sinh(2.*k.*d));
        c   = g.*Tp./(2*pi).*tanh(k.*d);
        cg  = n.*c;
    end
end

