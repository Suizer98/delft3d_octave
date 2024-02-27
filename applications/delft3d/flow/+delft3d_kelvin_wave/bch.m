function OK = bch(G, F, C,bndfile,bchfile,rieman2neuman)
%DELFT3D_KELVIN_WAVE.BCH  .
%
% OK = delft3d_kelvin_wave_bch(G, F, C,bndfile,bchfile)
%
%See also: delft3d_kelvin_wave_MAIN

rieman2zero = 1;

%% For Delft3d padd with dummy rows

   for ifreq=1:length(C.Tt)
      [ETA0(ifreq), VEL0(ifreq)] = delft3d_kelvin_wave_calculation(G, F, C,ifreq);
   end


%% Plot tidal results

   % delft3d_kelvin_wave_plot(G, ETA0, VEL0,C);
   % figure
   % delft3d_kelvin_wave_ampphase(G, ETA0, VEL0);
   % T.t = (0:0.5:12).*3600;
   % delft3d_kelvin_wave_tidalcycle(G, F, C, T, ETA0, VEL0);

%% Make harmonic boundary data

   BND = delft3d_io_bnd('read',bndfile,G.mmax,G.nmax);
   
   BCH.amplitudes  = zeros(2,BND.NTables,length(C.w));
   BCH.phases      = zeros(2,BND.NTables,length(C.w));
   
   % now add the constant offset
   BCH.frequencies = [360./C.Tt.*3600]; % [s] to [deg/hour]
   BCH.a0          = zeros(2,BND.NTables,1                      );
   
   for ifreq = 1:length(find(~(BCH.frequencies)==0))
   
      for i=1:BND.NTables
         
         if strcmp('Z',upper(BND.DATA(i).bndtype))
         
            BCH.amplitudes(1,i,ifreq)  =          ETA0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(ETA0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)));
            					                 
            BCH.amplitudes(2,i,ifreq)  =          ETA0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(ETA0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));
         
         elseif strcmp('R',upper(BND.DATA(i).bndtype)) & rieman2neuman
         
            BCH.amplitudes(1,i,ifreq)  =          ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2)));
            					          
            BCH.amplitudes(2,i,ifreq)  =          ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4)));
      
         elseif strcmp('R',upper(BND.DATA(i).bndtype)) & rieman2zero
      
            BCH.amplitudes(1,i,ifreq)  = 0.*      ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = 0.*     (ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2)));
            					          
            BCH.amplitudes(2,i,ifreq)  = 0.*      ETA0(ifreq).abs_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = 0.*     (ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(3),BND.DATA(i).mn(4)));
      
      
         elseif strcmp('R',upper(BND.DATA(i).bndtype))
         
            BCH.amplitudes(1,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)) + ...
                                  sqrt(C.g./G.D).*ETA0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  =      0.*(VEL0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2))) + ...
                                              0.*(ETA0(ifreq).arg_d_eta_d_y(BND.DATA(i).mn(1),BND.DATA(i).mn(2)));
            					              	        
            BCH.amplitudes(2,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)) + ...
                                  sqrt(C.g./G.D).*ETA0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  =      0.*(VEL0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4))) + ...
                                              0.*(ETA0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));
      
         elseif strcmp('C',upper(BND.DATA(i).bndtype)) & U.U0;
         
            BCH.amplitudes(1,i,ifreq)  = 0.*      VEL0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = 0.*     (VEL0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)));
            				                  
            BCH.amplitudes(2,i,ifreq)  = 0.*      VEL0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = 0.*     (VEL0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));
      
         elseif strcmp('C',upper(BND.DATA(i).bndtype))
         
            BCH.amplitudes(1,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(1),BND.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(VEL0(ifreq).arg          (BND.DATA(i).mn(1),BND.DATA(i).mn(2)));
            					                     
            BCH.amplitudes(2,i,ifreq)  =          VEL0(ifreq).abs          (BND.DATA(i).mn(3),BND.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(VEL0(ifreq).arg          (BND.DATA(i).mn(3),BND.DATA(i).mn(4)));
      
         end
         
      end % for i=1:BND.NTables
   
   end % for ifreq = length(BCH.frequencies)
   
   OK = delft3d_io_bch('write',bchfile,BCH);
   
   if nargout>0
      varargout = {OK};
   end
   
   %% EOF