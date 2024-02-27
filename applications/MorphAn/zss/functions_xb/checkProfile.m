function [d_start, slope, check] = checkProfile(Hm0, Tp, d_profile)

    %% Settings
    d_randvoorwaarde = 20;
    check = 0;
    
    % Hm0 = (maximum) significant wave height
    % Tp = maximum wave period
    % d_profile = starting depth of existing profile 
    %           Het is in deze BOI fase nog in twijfel of dit diepte is 
    %           tov NAP of tov NAP + max stormvloedpeil of NAP + min
    %           stormvloedpeil (de laatste gebruikte ik)
    
    %% compute Hm0,shoal
    [cg_BC, ~]                   = wavecelerity(Tp, d_randvoorwaarde);
    [cg_profile, n_profile]          = wavecelerity(Tp, d_profile);

    Hm0_shoal                       = Hm0 * sqrt(cg_BC/cg_profile);

    %% check

    if Hm0_shoal/d_profile<0.3 && n_profile<0.9
        d_start = d_profile;
        slope = 'NaN';
    else
        % --- compute d_start en Hm0,shoal iterative
        d_start = d_profile;
        d_start_previous =  2* d_profile;
        count = 1;
        % --- d_n: depth for which n=0.9
        d_n         = celerity_ratio_equals_09(Tp,d_start);

        while abs(d_start-d_start_previous)>0.05

            % ---
            d_start_previous            = d_start;
            % --- 
            d_start                     = max(3.33333*Hm0_shoal, d_n);
            % --- compute Hm0,shoal
            [cg, ~]           = wavecelerity(Tp, d_start);
            Hm0_shoal                   = Hm0 * sqrt(cg_BC/cg);

            count = count + 1;
            if count>20
                check = 1;
                break            
            end
        end
        % ---
        if Hm0_shoal/d_profile>0.3 && n_profile>0.9
            slope = 0.02;
        else
            slope = 0.1;
        end
    end
    
    %%
    function d = celerity_ratio_equals_09(Tp,d_start)
        d_dummy = d_start;
        count2   = 1;
        n       = 1;
        while n>0.9
            [cg, n] = wavecelerity(Tp, d_dummy);
            d_dummy = d_dummy + 0.05;
            count2 = count2+1;
            if count2>500
                check = 1;
                break 
            end
        end
        d = d_dummy;
    end


    function [cg, n] = wavecelerity(Tp, d)
        g = 9.81;
        k   = disper(2*pi./Tp, d, g);
        n   = .5*(1+2.*k.*d./sinh(2.*k.*d));
        c   = g.*Tp./(2*pi).*tanh(k.*d);
        cg  = n.*c;
    end
end

