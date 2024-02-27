function out = getHm0_2D(s)
%% Process data

% df      = (1-0.05)/24;
% frintf  = df/24;
% integrate action density spectrum
% Etot = squeeze(sum(sum(ac2,1),2));
% Etot = tot(1:end-1);
% Etot2D = reshape(tot,fliplr(size(XCGRID)));
% also OLD
% Etot_dsig = squeeze(sum(s.ac2,1))'*(s.spcsig.^2)*frintf*s.ddir;
% Etot      = sum(Etot_dsig);
% Etot      = Etot + Etot_dsig(24)*s.pwtail(6)/frintf;
% if Etot > exp(-20)
%     out.hs = 4*sqrt(Etot);
% end

frintf = 0.3744665;     % Just for now; read from SWAN debug
MDC = length(s.ac2(:,1,1));
MSC = length(s.ac2(1,:,1));

for ids = 1:length(s.ac2(1,1,:));                   % loop over space
    Etot_dsig = squeeze(sum(s.ac2(:,:,ids),1))'.*(s.spcsig.^2).*frintf*s.ddir;
    Etot      = sum(Etot_dsig);
    Etot      = Etot + Etot_dsig(MSC)*s.pwtail(6)/frintf;
    if Etot > exp(-20)
        out.hs(ids) = 4*sqrt(Etot);
    else
%         out.hs(ids) = 0;
    end
end


% based on SUBROUTINE SINTGRL in swancom1.for; +/-4890; Called in SUBROUTINE SWOMPU
% !     Calculate total spectral energy
% !
%       FRINTF_X_DDIR = FRINTF * DDIR
%       ETOT_DSIG(:)  = SUM(AC2(:,:,KCGRD(1)),DIM=1) * SIGPOW(:,2) *
%      &                FRINTF_X_DDIR
%       ETOT          = SUM(ETOT_DSIG)
% !
% !     *** add high frequency tail ***
% !
%       ETOT = ETOT + ETOT_DSIG(MSC) * PWTAIL(6) / FRINTF
% ...
% IF ( ETOT .GT. 1.E-20 ) THEN
%     HS       = 4. * SQRT (ETOT)
% END IF
% 
%
% !             ETOT    : Total wave energy density
% !             AC2     : Action density as function
% !             DDIR    : width of directional band
% !             FRINTF  : frequency integration factor df/f
% !             SIGPOW  : contains powers of relative frequencies
% !                       second dimension indicates power of sigma
%                         SIGPOW(:,2) = SPCSIG**2
% !             SPCSIG	: Relative frequencies in computational domain in sigma-space


% compute Hs
tic
for ids = 1:length(s.ac2(1,1,:));                   % loop over space
    acloc = squeeze(s.ac2(:,:,ids));                    % ! local action density spectrum
    
    eftail = 1/(s.pwtail(1)-1);
    Etot = 0;
    % trapezoidal rule is applied
    for ii = 1:MDC           % loop over directions
        for jj = 2:MSC       % loop over frequencies
            ds = s.spcsig(jj) - s.spcsig(jj-1);
            ead = 0.5*(s.spcsig(jj)*acloc(ii,jj) + ...
                s.spcsig(jj-1)*acloc(ii,jj-1)*ds*s.ddir);
            Etot = Etot + ead;
        end
        if MSC > 3
            % contribution of tail to total energy density
            ehfr = acloc(ii,MSC)*s.spcsig(MSC);
            Etot = Etot + s.ddir*ehfr*s.spcsig(MSC)*eftail;
        end
    end
    if Etot > 0
        Hm0(ids,:) = 4*sqrt(Etot);
    else
        Hm0(ids,:) = 0;
    end
    out.Etot(ids,:) = Etot;
    if ids == 5000      % temp
        ids
    end
end
toc

Hm0 = Hm0(1:end-1);
out.Hm0_2D = reshape(Hm0,fliplr(size(s.XCGRID)));

% and based on SUBROUTINE SWOEXA in swanout1.for
% 
%         EFTAIL = 1. / (PWTAIL(1) - 1.)
% 
% !       significant wave height
% !
%         IVTYPE = 10
%         IF (OQPROC(IVTYPE)) THEN
%           IF (OUTPAR(6).EQ.0.) THEN                                       40.87
% !            integration over [0,inf]                                     40.87
%              ETOT = 0.
% !            trapezoidal rule is applied
%              DO ID=1, MDC
%                DO IS=2,MSC
%                  DS=SPCSIG(IS)-SPCSIG(IS-1)                               30.72
%                  EAD = 0.5*(SPCSIG(IS)*ACLOC(ID,IS)+                      30.72
%      &                      SPCSIG(IS-1)*ACLOC(ID,IS-1))*DS*DDIR          30.72
%                  ETOT = ETOT + EAD
%                ENDDO
%                IF (MSC .GT. 3) THEN                                       10.20
% !                contribution of tail to total energy density
%                  EHFR = ACLOC(ID,MSC) * SPCSIG(MSC)                       30.72
%                  ETOT = ETOT + DDIR * EHFR * SPCSIG(MSC) * EFTAIL         30.72
%                ENDIF
%              ENDDO
%           ELSE                                                            40.87
% !            integration over [fmin,fmax]                                 40.87
%              FMIN = PI2*OUTPAR(21)                                        40.87
%              FMAX = PI2*OUTPAR(36)                                        40.87
%              ECS  = 1.                                                    40.87
%              ETOT = SwanIntgratSpc(0. , FMIN, FMAX, SPCSIG, SPCDIR(1,1),  40.87
%      &                             WK , ECS , 0.  , 0.    , ACLOC      ,  40.87
%      &                             1  )                                   40.87
%           ENDIF                                                           40.87
%           IF (ETOT .GE. 0.) THEN                                          30.00
%             VOQ(IP,VOQR(IVTYPE)) = 4.*SQRT(ETOT)
%           ELSE
%             VOQ(IP,VOQR(IVTYPE)) = 0.                                     40.86
%           ENDIF
%           IF (ITEST.GE.100) THEN                                          40.00
%             WRITE(PRINTF, 222) IP, OVSNAM(IVTYPE), VOQ(IP,VOQR(IVTYPE))   40.00
%           ENDIF
%         ENDIF

