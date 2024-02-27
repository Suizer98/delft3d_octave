      function [argout]  = saco_convert (argin, formula, varargin)

      % convert : contains all conversion functions from slinity to density chlorinity etc for SACO
      %
      % This function converts to and from salinity, density, chlorinity and conductivity
      % It is based on the fortran program of Kees Kuijper (SaCo; Salinity conversions; Bulletin Kuijpe_k
      %
      % If temperature is needed for the conversion that should be the 3th argument in the function call
      % If temperature is not needed for the conversion 2 arguments are sufficient
      %
      % Pre-assumed units are:
      % Salinity     [ psu ]
      % Density      [kg/m3]
      % Chlorinity   [  -  ]
      % Conductivity [mS/cm]
      %
      % Formulae supported are
      % Formula  1: calculation     salinity       --->      density; equation according to millero/delft hydraulics       (NaCl)
      % Formula  2: calculation     salinity       --->      density; equation according to millero/delft hydraulics       (NaCl)
      % Formula  3: calculation     salinity       --->      density; equation according to UNESCO (millero-poisson) 1981  (Seawater)
      % Formula  4: calculation     salinity       --->      density; eckart (1958): salt formula in Delft3D-Flow          (Seawater)
      % Formula  5: calculation     salinity       --->      density; engineering approximation
      % Formula  6: calculation   chlorinity       --->      density; equation according to millero/delft hydraulics       (NaCl)
      % Formula  7: calculation   chlorinity       --->      density; equation according to franks/lo surdo                (NaCl)
      % Formula  8: calculation   chlorinity       --->      density; equation according to UNESCO                         (seawater)
      % Formula  9: calculation conductivity       --->     salinity; equation according to Labrique/Kohlrausch            (NaCl)
      % Formula 10: calculation conductivity       --->     salinity; equation NaCl 94                                     (NaCl)
      % Formula 11: calculation conductivity       --->     salinity; fit head (1983) based on chiu data (1968)            (NaCl)
      % Formula 12: calculation conductivity       --->     salinity; hewitt (1960)                                        (NaCl)
      % Formula 13: calculation conductivity       --->     salinity; UNESCO                                               (Seawater)
      % Formula 14: calculation     salinity       ---> conductivity; Labrique/Kohlrausch                                  (NaCl)
      % Formula 15: calculation     salinity       ---> conductivity; NaCl94                                               (NaCl)
      % Formula 16: calculation     salinity       ---> conductivity; hewitt (1960)                                        (NaCl)
      % Formula 17: calculation     salinity       ---> conductivity; UNESCO                                               (seawater)
      % Formula 18: calculation conductivity       --->   chlorinity; Labrique/Kohlrausch                                  (NaCl)
      % Formula 19: calculation conductivity       --->   chlorinity; NaCl94                                               (NaCl)
      % Formula 20: calculation conductivity       --->   chlorinity; UNESCO                                               (Seawater)
      % Formula 21: calculation chlorinity         ---> conductivity; Labrique/Kohlrausch                                  (NaCl)
      % Formula 22: calculation chlorinity         ---> conductivity; NaCl94                                               (NaCl)
      % Formula 23: calculation chlorinity         ---> conductivity; UNESCO                                               (Seawater)
      % Formula 24: calculation conductivity       --->      density; Labr/Kohlr/Mill/Delft                                (Nacl)
      % Formula 25: calculation conductivity       --->      density; UNESCO                                               (Seawater)
      % Formula 26: calculation     salinity       --->   chlorinity;                                                      (NaCl)
      % Formula 27: calculation     salinity       --->   chlorinity;                                                      (Seawater)
      % Formula 28: calculation   chlorinity       --->     salinity;                                                      (NaCl)
      % Formula 29: calculation   chlorinity       --->     salinity;                                                      (Seawater)
      % Formula 30: calculation conductivity       ---> Cl-concent. ; RWS (NDB)                                            (Seawater)
      % Formula 31: NOAA                                                                                                   (Seawater)
      % Formula 32: calculation conductivity       ---> Cl-concent. ; EVIDES (Brielse Meer)
      % Formula 33: calculation salinity, CO2, CH4 ---> Density     ; Schmid (Lake Kivu)
      %             From: "How hazardous is the gas accumulation in Lake Kivu?
      %                    Arguments for a risk assessment in light of the Nyiragongo Volcano"
      %                    Acta Vulcanologica Vol 14 (1-2),2002 15 (1-2), 2003: 115 - 122
      %
      % Example: to convert salinity to density according to UNESCO Formulations your function call should be something like:
      % [dens] = convert(salinity,3,temperature);
      %

      switch (formula)

      case   (1)
         %
         % Formula  1: calculation     salinity --->      density; equation according to millero/delft hydraulics       (NaCl)
         % out:      Density; in:     Salinity and Temperature
         %
         argout = conversion_01 (argin, varargin{1});
      case   (2)
         %
         % Formula  2: calculation     salinity --->      density; equation according to millero/delft hydraulics       (NaCl)
         % out:      Density; in:     Salinity and Temperature
         %
         argout = conversion_02 (argin, varargin{1});
      case   (3)
         %
         % Formula  3: calculation     salinity --->      density; equation according to unesco (millero-poisson) 1981  (Seawater)
         % out:      Density; in:     Salinity and Temperature
         %
         argout = conversion_03 (argin, varargin{1});
      case   (4)
         %
         % Formula  4: calculation     salinity --->      density; eckart (1958): salt formula in Delft3D-Flow          (Seawater)
         % out:      Density; in:     Salinity and Temperature
         %
         argout = conversion_04 (argin, varargin{1});
      case   (5)
         %
         % Formula  5: calculation     salinity --->      density; engineering approximation
         % out:      Density; in:     Salinity and Temperature
         %
         argout = conversion_05 (argin, varargin{1});
      case   (6)
         %
         % Formula  6: calculation   chlorinity --->      density; equation according to millero/delft hydraulics       (NaCl)
         % out:      Density; in:   Chlorinity and Temperature
         %
         argout = conversion_06 (argin, varargin{1});
      case   (7)
         %
         % Formula  7: calculation   chlorinity --->      density; equation according to franks/lo surdo                (NaCl)
         % out:      Density; in:   Chlorinity and Temperature
         %
         argout = conversion_07 (argin, varargin{1});
      case   (8)
         %
         % Formula  8: calculation   chlorinity --->      density; equation according to UNESCO                         (seawater)
         % out:      Density; in:   Chlorinity and Temperature
         %
         argout = conversion_08 (argin, varargin{1});
      case   (9)
         %
         % Formula  9: calculation conductivity --->     salinity; equation according to Labrique/Kohlrausch            (NaCl)
         % out:     Salinity; in: Conductivity and Temperature
         %
         argout = conversion_09 (argin, varargin{1});
      case   (10)
         %
         % Formula 10: calculation conductivity --->     salinity; equation NaCl 94                                     (NaCl)
         % out:     Salinity; in: Conductivity and Temperature
         %
         argout = conversion_10 (argin, varargin{1});
      case   (11)
         %
         % Formula 11: calculation conductivity --->     salinity; fit head (1983) based on chiu data (1968)            (NaCl)
         % out:     Salinity; in: Conductivity and Temperature
         %
         argout = conversion_11 (argin, varargin{1});
      case   (12)
         %
         % Formula 12: calculation conductivity --->     salinity; hewitt (1960)                                        (NaCl)
         % out:     Salinity; in: Conductivity and Temperature
         %
         argout = conversion_12 (argin, varargin{1});
      case   (13)
         %
         % Formula 13: calculation conductivity --->     salinity; Unesco                                               (Seawater)
         % out:     Salinity; in: Conductivity and Temperature
         %
         argout = conversion_13 (argin, varargin{1});
      case   (14)
         %
         % Formula 14: calculation     salinity ---> conductivity; Labrique/Kohlrausch                                  (NaCl)
         % out: Conductivity; in:     Salinity and Temperature
         %
         argout = conversion_14 (argin, varargin{1});
      case   (15)
         %
         % Formula 15: calculation     salinity ---> conductivity; NaCl94                                               (NaCl)
         % out: Conductivity; in:     Salinity and Temperature
         %
         argout = conversion_15 (argin, varargin{1});
      case   (16)
         %
         % Formula 16: calculation     salinity ---> conductivity; hewitt (1960)                                        (NaCl)
         % out: Conductivity; in:     Salinity and Temperature
         %
         argout = conversion_16 (argin, varargin{1});
      case   (17)
         %
         % Formula 17: calculation     salinity ---> conductivity; Unesco                                               (seawater)
         % out: Conductivity; in:     Salinity and Temperature
         %
         argout = conversion_17 (argin, varargin{1});
      case   (18)
         %
         % Formula 18: calculation conductivity --->   chlorinity; Labrique/Kohlrausch                                  (NaCl)
         % out:   Chlorinity; in: Conductivity and Temperature
         %
         argout = conversion_18 (argin, varargin{1});
      case   (19)
         %
         % Formula 19: calculation conductivity --->   chlorinity; NaCl94                                               (NaCl)
         % out:   Chlorinity; in: Conductivity and Temperature
         %
         argout = conversion_19 (argin, varargin{1});
      case   (20)
         %
         % Formula 20: calculation conductivity --->   chlorinity; Unesco                                               (Seawater)
         % out:   Chlorinity; in: Conductivity and Temperature
         %
         argout = conversion_20 (argin, varargin{1});
      case   (21)
         %
         % Formula 21: calculation chlorinity   ---> conductivity; Labrique/Kohlrausch                                  (NaCl)
         % out: Conductivity; in:   Chlorinity and Temperature
         %
         argout = conversion_21 (argin, varargin{1});
      case   (22)
         %
         % Formula 22: calculation chlorinity   ---> conductivity; NaCl94                                               (NaCl)
         % out: Conductivity; in:   Chlorinity and Temperature
         %
         argout = conversion_22 (argin, varargin{1});
      case   (23)
         %
         % Formula 23: calculation chlorinity   ---> conductivity; Unesco                                               (Seawater)
         % out: Conductivity; in:   Chlorinity and Temperature
         %
         argout = conversion_23 (argin, varargin{1});
      case   (24)
         %
         % Formula 24: calculation conductivity --->      density; Labr/Kohlr/Mill/Delft                                (Nacl)
         % out:      Density; in: Conductivity and Temperature
         %
         argout = conversion_24 (argin, varargin{1});
      case   (25)
         %
         % Formula 25: calculation conductivity --->      density; Unesco                                               (Seawater)
         % out:      Density; in: Conductivity and Temperature
         %
         argout = conversion_25 (argin, varargin{1});
      case   (26)
         %
         % Formula 26: calculation     salinity --->   chlorinity;                                                      (NaCl)
         % out:   Chlorinity; in:     Salinity and Temperature
         %
         argout = conversion_26 (argin);
      case   (27)
         %
         % Formula 27: calculation     salinity --->   chlorinity;                                                      (Seawater)
         % out:   Chlorinity; in:     Salinity and Temperature
         %
         argout = conversion_27 (argin);
      case   (28)
         %
         % Formula 28: calculation   chlorinity --->     salinity;                                                      (NaCl)
         % out:     Salinity; in:   Chlorinity and Temperature
         %
         argout = conversion_28 (argin);
      case   (29)
         %
         % Formula 29: calculation   chlorinity --->     salinity;                                                      (Seawater)
         % out:   Chlorinity; in:     Salinity and Temperature
         %
         argout = conversion_29 (argin);
      case   (30)
         %
         % Formula 30: calculation conductivity ---> cl-concentration RWS(NDB)                                          (Seawater)
         % out:   Cl- conc  ; in: Conductivity and Temperature
         %
         argout = conversion_30 (argin,varargin{1});
      case   (31)
         %
         % Formula 31: Salinity to density NOAA (Seawater)
         % out:   density  ; in: Salinity and Temperature
         %
         argout = conversion_31 (argin,varargin{1});
      case   (32)
         %
         % Formula 30: calculation conductivity ---> cl-concentration RWS(NDB)                                          (Seawater)
         % out:   Cl- conc  ; in: Conductivity and Temperature
         %
         argout = conversion_32 (argin,varargin{1});
      case   (33)
         %
         % Formula 33: calculation salinity, temperature, CO2 CH4 --> density                                            (Lake Kivu)
         % out:   density     in: Salinity, Temperature, CO2, CH4
         %
         argout = conversion_33 (argin,varargin{1},varargin{2}, varargin{3});
      end

      function [dens] = conversion_01 (sal,temp)
      %
      % CALCULATION SALINITY ---> DENSITY
      % EQUATION ACCORDING TO MILLERO/DELFT HYDRAULICS
      % NACL SOLUTION
      %
      dens  = 999.904            + 4.8292E-2*temp - 7.2312E-3*temp^2 + ...
              2.9963E-5*temp^3   + 7.6427E-1*sal  -                    ...
              3.1490E-3*sal*temp + 3.1273E-5*sal*temp^2;

      function [dens] = conversion_02 (sal,temp)

      A    = [-0.2341    , 3.4128E-3   ,-2.7030E-5 ,1.4037E-7   ;
               5.3956E-2 ,-6.2635E-4   , 0.        ,0.          ;
              -9.5653E-4 , 5.2829E-5   , 0.        ,0.          ];
      B    = [ 45.5655   , -1.8527     ,-1.6368    , 0.2274     ];
      C    = [999.8396   , 18.224944   ,-7.92221E-3,-55.44846E-6,      ...
              149.7562E-9,-393.2952E-12];
      D    =  18.159725E-3;


      %  CALCULATE DENSITY RHOPUR OF PURE WATER, STILL DEPENDENT  ON TEMPERATURE
      %  REFERENCE: FRANKS, FELIX (ED.) (1972), "WATER, A COMPREHENSIVE TREATISE
      %  VOL. 1. THE PHYSICAL CHEMISTRY OF WATER", PLENUM. PRESS.

      tmp      = 1.;
      term1    = C(1);
      for i = 2: 6
         tmp   = tmp*temp;
         term1 = term1+C(i)*tmp;
      end

      term2    = 1.+D*temp;
      rhopur   = term1/term2;

      % INCREASE DENSITY DUE TO NACL
      % REF: LO SURDO, A., ET AL (1982) J. CHEM. THERMODYNAMICS,
      % VOL. 14, PP 649-662

      % SM(1) IS THE MOLAR CONCENTRATION OF NACL
      % CONVERSION G/KG TO KG/KG NACL

      sal  = sal/1000.;

      sm(1) = (sal/(1.-sal))/0.058443;
      sm(2) = sm(1)*sqrt(abs(sm(1)));
      sm(3) = sm(1)*sm(1);
      sm(4) = sm(1)*sm(2);

      term2 = 0.;
      for i = 1: 4
         term2 = term2 + B(i)*sm(i);
      end

      term1 = 0.;
      tmp   = 1.;
      for j = 1: 4
         tmp = tmp * temp ;
         for i = 1: 3
            term1 = term1+A(i,j)*tmp*sm(i);
         end
      end

      dens = rhopur + term1 + term2;

      function [dens] = conversion_03 (sal,temp)

      % CALCULATION SALINITY ---> DENSITY
      % EQUATION ACCORDING TO UNESCO (MILLERO-POISSON) 1981
      % EXTENDED BY UNESCO EQUATION (POISSON ET AL) 1991
      % SEAWATER
      % TEMPERATURE RANGE:  0 - 40 dgr C AND SALINITY RANGE: 0.5 - 43
      % OR
      % TEMPERATURE RANGE: 15 - 30 dgr C AND SALINITY RANGE: 43  - 50

      rhoref= 999.842594          + 6.793952E-2*temp    - 9.095290E-3*temp.^2 + ...
              1.001685E-4*temp.^3 - 1.120083E-6*temp.^4 + 6.536332E-9*temp.^5 ;

      if sal < 43
         %
         % Unesco 1981
         %
         A     = 8.24493E-1        - 4.0899E-3 * temp  + 7.6438E-5*temp.^2 - ...
                 8.2467E-7*temp.^3 + 5.3875E-9*temp.^4 ;
         B     = -5.72466E-3       + 1.0227E-4*temp    - 1.6546E-6*temp.^2 ;
         C     = 4.8314E-4;

         dens  = rhoref + A*sal + B*sal.^1.5 + C*sal.^2;
      else
         %
         % Unesco 1991
         %
         dens  = sal .*                                      ...
                 ( 0.824427                                  ...
                 - 0.52753E-2   * temp                       ...
                 - 0.51175E-3   * sal                        ...
                 + 0.4026E-4    * temp.^2                    ...
                 + 0.1151146E-3 * temp   .* sal              ...
                 - 0.1479E-4    * sal.^2                     ...
                 + 0.67901E-6   * temp.^3                    ...
                 - 0.15886E-5   * temp.^2.* sal              ...
                 - 0.52228E-6   * temp   .* sal.^2           ...
                 + 0.2075E-6    * sal.^3 );

         dens  = rhoref + dens;

      end

      function [dens] = conversion_04 (sal,temp)

      % CALCULATION SALINITY ---> DENSITY
      % ECKART (1958): SALT FORMULA IN TRISULA
      % SEAWATER:
      % TEMPERATURE RANGE: 0 - 40 dgr Celsius
      % SALINITY RANGE: 0 - 40

      alpho = 0.698;
      rhom  = 0.;
      cpo   = 5890. + 38.*temp-0.375*temp^2;
      clam  = 1779.5 + 11.25*temp-0.0745*temp^2;
      clamo = 3.8 + 0.01*temp;
      cp1   = cpo + 3.*sal;
      clam1 = clam - clamo*sal;
      dens  = 1000.*cp1/(alpho*cp1+clam1)-rhom;


      function [dens] = conversion_05 (sal,temp)

      % CALCULATION SALINITY ---> DENSITY
      % ENGINEERING APPROXIMATION
      % SEAWATER
      % TEMPERATURE RANGE: 1.0 - 20 dgr C
      % SALINITY RANGE: 1 - 30

      dens  = 1000. + 0.8054*sal - 0.0065*(temp - 4. + 0.2214*sal)^2;

      function [dens] = conversion_06 (clr,temp)
      %
      % CALCULATION CHLORINITY ---> DENSITY
      % FIRST CHLORINITY IS CONVERTED INTO SALINITY
      % EQUATION ACCORDING TO MILLERO/DELFT HYDRAULICS
      % NACL SOLUTION
      %
      sal = 1.64846 * clr;
      dens = conversion_01(sal,temp);

      function [dens] = conversion_07 (clr,temp)
      %
      % CALCULATION CHLORINITY ---> DENSITY
      % FIRST CHLORINITY IS CONVERTED INTO SALINITY
      % EQUATION ACCORDING TO FRANKS/LO SURDO
      % NACL SOLUTION
      %
      sal = 1.64846 * clr;
      dens = conversion_02(sal,temp);

      function [dens] = conversion_08 (clr,temp)
      % CALCULATION CHLORINITY ---> DENSITY
      % FIRST CHLORINITY IS CONVERTED INTO SALINITY
      % Unesco
      % Seawater

      sal  = 1.80655 * clr;
      dens = conversion_03(sal,temp);

      function [sal] = conversion_09 (kst,temp)
      %
      % Conductivity to salinity according to Labrique/Kohlrausch (NaCl)
      %
      mt     = 1./((0.008018*temp + 1.0609)^2 -0.5911);
      k25    = mt*kst;

      sal    = (k25/2.134)^(1./0.92);

      function [sal] = conversion_10 (kst,temp)
      %
      % Conductivity to salinity (NaCl 94)
      %
      %----------------------------------------------------------------+
      % CALCULATION CONDUCTIVITY ---> SALINITY                         |
      % NACL94                                                         |
      % NACL SOLUTION                                                  |
      % TEMPERATURE RANGE: -2 - 35 dgr C                               |
      % SALINITY RANGE: .06 - 56                                       |
      %----------------------------------------------------------------+

      rsmt  = 0.6766097         + 2.00564E-02*temp + 1.104259E-04*temp^2      ...
             -6.9698E-07*temp^3 + 1.00310E-09*temp^4;
      m     = 1.2365374 / rsmt;
      k25   = m * kst;
      sal   = 0.018 * k25 * ( (abs(k25))^0.5 + 27.176 );

      function [sal] = conversion_11 (kst,temp)

      %----------------------------------------------------------------+
      % CALCULATION CONDUCTIVITY ---> SALINITY                         |
      % FIT HEAD (1983) BASED ON CHIU DATA (1968)                      |
      % NACL SOLUTION                                                  |
      % TEMPERATURE RANGE: -2.0 - 35 dgr C                             |
      % SALINITY RANGE: 4 - 59                                         |
      %----------------------------------------------------------------+

      %  CONVERSION OF CONDUCTIVITY KST AT TEMPERATURE T TO CONDUCT.
      %  K25 AT TEMPERATURE OF 25 DGR. C USING THE ADAPTED UNESCO EQ.
      %  (THE UNESCO EQ. CONVERTS TO A REFERENCE TEMP. OF 15 DGR.
      %  CELSIUS BUT THIS CAN BE REWRITTEN TO 25 DRG. C, THUS:
      %  RSMT = KST/K15 BECOMES:
      %  RT = R25 (KST/K25) WITH R25 = 1.2365374)

      rsmt  = 0.6766097          + 2.00564E-02*temp + 1.104259E-04*temp^2    ...
             -6.9698E-07*temp^3 + 1.0031E-09*temp^4;

      k25   = 1.2365374 * ( kst / rsmt );

      %  CALCULATION OF SALINITY SAL FROM K25 USING FIT BY HEAD (1983, PAGE 159).
      %  COEFF. a5 BY HEAD SHOULD BE: 0.000006269 !!!

      sal   = 0.01498478            - 0.01458078 * k25^0.5 + 0.05185288 * k25 +       ...
              0.00206994  * k25^1.5 - 0.00010365 * k25^2.0 +                          ...
              0.000006269 * k25^2.5;

      % CONVERSION FROM weight% TO salinity
      sal   = sal * 10.0;

      function [sal] = conversion_12 (kst,temp)

      % Rather crude, use inverse routine

      difmin = 1.0e37;

      for ss = 0.0: 0.001: 100.0
         kcmp = conversion_16(ss,temp);
         diff = abs(kcmp - kst);
         if diff < difmin
            difmin = diff;
            sal_estimate = ss;
         end
      end

      sal   = sal_estimate;


      function [sal] = conversion_13 (kst,temp)
      %
      % Conductivity to salinity according to Unesco 1981 (Seawater)
      %
      kref15 = 42.910;

      rsmt   = 0.6766097 + 2.00564E-02*temp + 1.104259E-04*temp^2 ...
              -6.9698E-07*temp^3 + 1.0031E-09*temp^4;
      kreft  = rsmt * kref15;
      rgrt   = kst / kreft;

      sal    = 0.0080 - 0.1692*rgrt^0.5 + 25.3851*rgrt +14.0941*rgrt^1.5 - 7.0261*rgrt^2 + 2.7081*rgrt^2.5;
      corrs  = ((temp-15.)/(1.+0.0162*(temp-15.))) * (0.0005 - 0.0056*rgrt^0.5 - 0.0066*rgrt -  ...
                0.0375*rgrt^1.5 + 0.0636*rgrt^2 - 0.0144*rgrt^2.5);
      sal    = sal  + corrs;


      function [kst] = conversion_14 (sal,temp)

      % LABRIQUE

      m     = 1./((0.008018 * temp + 1.0609)^2 - 0.5911);

      % INVERSE KOHLRAUSCH
      kst   = (2.134 * sal^0.92) / m;

      function [kst] = conversion_15 (sal,temp)

      diff   = 1.0e36;
      k25old = 2.134 * sal^0.92;

      %  START OF ITERATION BY RE-SUBSTITUTION

      while diff > 1.0e-6

         k25   = sal / (0.018 * (sqrt(abs(k25old)) + 27.176));

         % TEST IF NEW AND OLD VALUE FOR CONDUCTIVITY AT 25 DGR. DIFFER
         % MORE THAN 1E-06

         diff = abs ( k25 - k25old );

         if  diff > 1E-06
            k25old = k25;
         end
      end

      rsmt  = 0.6766097         + 2.00564E-02*temp + 1.104259E-04*temp^2 ...
             -6.9698E-07*temp^3 + 1.0031E-09*temp^4;

      m     = 1.2365374 / rsmt;

      kst   = k25 / m;

      function [kst] = conversion_16 (sal,temp)

      %----------------------------------------------------------------+
      % CALCULATION SALINITY ---> CONDUCTIVITY                         |
      % HEWITT (1960), SEE ALSO HEAD (1983), PAGE 158                  |
      % NACL SOLUTION                                                  |
      % TEMPERATURE RANGE: -2.0 - 35 dgr C                             |
      % SALINITY RANGE: 0.1 - 260 (= SATURATION)                       |
      %----------------------------------------------------------------+

      kst = NaN;

      %  CONVERSION FROM [g/kg] TO wgt%
      sal2  = sal / 10.;

      if sal2 < 0.1
      %     NO FIT EXISTS IN THIS RANGE
         kst = -9999.99;
      elseif 0.1 <= sal2 && sal2 < 1.0
         x   = 53.6508          + 17.7272 * sal2^0.5 - 6.9940 * sal2 -    ...
                2.0216*sal2^1.5 + 3.0262 * sal2^2.0;
      elseif 1.0 <= sal2 && sal2 < 10.
         slg = log (sal2);
         x   = 65.3068 + 7.0523 * slg - 3.1346 * slg^2 +                  ...
                1.4293 * slg^3;
      elseif 10.0 <= sal2 && sal2 < 26.
         slg = log (sal2);
         x   = -923.8866         + 1241.9749 * slg - 546.7730 * slg^2 +   ...
                 96.6712 * slg^3 -    4.8034 * slg^4;
      else
         x = sal2 / -9999.99;
      end

      if isnan(kst)
         k18   = sal2 / x;

         %  CONVERSION OF CONDUCTIVITY K18 AT 18 DGR. C TO CONDUCTIVITY
         %  KST AT TEMPERATURE T USING THE ADAPTED UNESCO EQUATION
         %  (THE UNESCO EQ. CONVERTS TO A REFERENCE TEMPERATURE OF 15 DGR.
         %  CELSIUS BUT THIS CAN BE REWRITTEN TO 18 DRG. C, THUS:
         %  RSMT = KST/K15 BECOMES KST = RSMT * K18 / R18,
         %  WITH R18 = 1.0694434)

         rsmt  = 0.6766097         + 2.00564E-02*temp  + 1.104259E-04*temp^2  ...
                -6.9698E-07*temp^3 + 1.0031E-09*temp^4;

         kst   = rsmt * k18 / 1.0694434;

         %  CONVERSION FROM S/cm TO mS/cm

         kst   = kst * 1000.;

      end

      function [kst] = conversion_17 (sal,temp)

      % From salinity to conductivity
      % Uneso 1981 sea water
      % use inverse formulation (rather crude)

      difmin = 1.0e37;

      for kk = 0:0.01:100
         sal_estimate = conversion_13(kk,temp);
         diff = abs(sal-sal_estimate);
         if diff < difmin
            difmin = diff;
            kst    = kk;
         end
      end

      function [cl] = conversion_18 (kst,temp)

      sal = conversion_09(kst,temp);
      cl  = sal/1.64846;

      function [cl] = conversion_19 (kst,temp)

      sal = conversion_10(kst,temp);
      cl  = sal/1.64846;

      function [cl] = conversion_20 (kst,temp)

      sal = conversion_13(kst,temp);
      cl  = sal/1.80655;

      function [kst] = conversion_21 (cl,temp)

      kst = conversion_14(cl*1.64846,temp);

      function [kst] = conversion_22 (cl,temp)

      kst = conversion_15(cl*1.64846,temp);

      function [kst] = conversion_23 (cl,temp)

      kst = conversion_17(cl*1.80655,temp);

      function [dens] = conversion_24 (kst,temp)

      sal  = conversion_09(kst,temp);
      dens = conversion_01(sal,temp);

      function [dens] = conversion_25 (kst,temp)

      sal  = conversion_13(kst,temp);
      dens = conversion_03(sal,temp);

      function [cl] = conversion_26 (sal)
      %
      % salinity to chlorinity (NaCl)
      %
      cl   = sal/1.64846;

      function [cl] = conversion_27 (sal)
      %
      % salinity to chlorinity (Seawater)
      %
      cl   = sal/1.80655;

      function [sal] = conversion_28 (cl)
      %
      % Chlorinity to Salinity (NaCl)
      %
      sal   = cl*1.64846;

      function [sal] = conversion_29 (cl)
      %
      % Chlorinity to Salinity (Seawater)
      %
      sal   = cl*1.80655;

      function [cl_ion] = conversion_30 (kst,temp)
      %
      % CALCULATION CONDUCTIVITY ---> CHLORIDE-ION CONCENTRATION      |
      % RIJKSWATERSTAAT                                               |
      % NDB LINE '80 - '81                                            |
      % TEMPERATURE RANGE: 0 - 24.5 dgr C                             |
      % CONDUCTIVITY RANGE: 0.1 - 50 mS/cm                            |


      kref15 = 42.910;
      kref18 = 45.890;
      a      = [-0.95646E-9,66.3405E-9,-2.18091E-6,0.1227E-3,0.0200402,0.676518];

      % LOWER AND UPPER BOUNDARIES FOR TEMPERATURE (LLT AND ULT) AND
      % CONDUCTIVITY AT 18 dgr (LLK AND ULK)
      % LLK AND ULK ARE IN muS/cm !!!

      kst   = kst * 1000.;


      kreft = kref15 *(((((a(1)*temp+a(2))*temp+a(3))*temp+a(4))*temp  ...
              +a(5))*temp+a(6));
      ks18  = ( kref18 / kreft ) * kst;

      if ks18 > 200. && ks18 <= 1200.
         cl_ion = 0.0000958 * ks18*ks18 + 0.139 * ks18 - 16.;
      elseif ks18 > 1200. && ks18 <= 2500.
         cl_ion = 0.0000051 * ks18*ks18 + 0.345 * ks18 - 137.;
      elseif ks18 > 2500. && ks18 <= 12500.
         cl_ion = 0.0000030 * ks18*ks18 + 0.345 * ks18 - 140.;
      elseif ks18 > 12500. && ks18 <= 19000.
         cl_ion = 0.0000014 * ks18*ks18 + 0.380 * ks18 - 330.;
      elseif ks18 > 19000. && ks18 <= 19275.
         cl_ion = 0.0000014 * ks18*ks18 + 0.380 * ks18 - 340.;
      elseif ks18 > 19275. && ks18 <= 33000.
         cl_ion = 0.0000014 * ks18*ks18 + 0.380 * ks18 - 350.;
      elseif ks18 > 33000. && ks18 <= 50000.
         cl_ion = 0.475 * ks18 - 1960.;
      else
         cl_ion = NaN;
      end

      cl_ion = cl_ion/1000.;

      function [dens] = conversion_31 (conc,temp)

      %
      % Formula form NOAA; copied from http://www.csgnetwork.com/h2odenscalc.html
      %

      rho  = 1000*(1.0-(temp+288.9414)/(508929.2*(temp+68.12963))*((temp-3.9863)^2));

      A    =   0.824493 - 0.0040899*temp  + 0.000076438*temp^2 - 0.00000082467*temp^3 + 0.0000000053675*temp^4;
      B    =  -0.005724 + 0.00010227*temp - 0.0000016546*temp^2;
      dens = rho + A*conc + B*conc^(3/2) + 0.00048314*conc^2;

      function [cl_ion] = conversion_32 (kst,temp)

      %
      % CALCULATION CONDUCTIVITY ---> CHLORIDE-ION CONCENTRATION      |
      % Evides Brielse meer                                          |
      %

      %
      % Omrekenenen geleidendheid naar geleidendeheid bij 25 oC
      % neem correctiecoefficient alpha van 2% aan
      %

      alpha = 0.02;
      kst25 = kst/(1 + alpha*(temp - 25));

      %
      % Chloride in mg/l
      %

      cl_ion = 270.5*kst25 - 85.92;

      %
      % In kg/m3
      %

      cl_ion = cl_ion/1000;

      function [dens] = conversion_33 (sal,temp,co2,ch4)
          
      % Lake Kivu; Schmid 2002
      beta_sal =  0.750e-3;
      beta_co2 =  0.284e-6;
      beta_ch4 = -1.250e-6;
      
      % Multiplication factor from delft3d-flow, dens.f90
      fact(1:max(length(sal),length(temp)),1) = 1.0;
      if ~isempty(sal) fact = 1.0  + beta_sal        *sal; end
      if ~isempty(co2) fact = fact + beta_co2*44.0099*co2; end
      if ~isempty(ch4) fact = fact + beta_ch4*16.04  *ch4; end % TODO: Check origin of 44.0099 and 16.04
      
      % Density (based upon unesco with a salinity equal to zero)
      dens = saco_convert(0.0,3,temp).*fact;
      
      

