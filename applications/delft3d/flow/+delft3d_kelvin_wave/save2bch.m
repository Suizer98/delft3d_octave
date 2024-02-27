function save2bch(OPT,G,ETA0,VEL0,C)
%SAVE2BCH save harmonic boundary data in Delft3D format
%
%  save2bch(OPT,G,ETA0,VEL0,C)
%
%See also: delft3d_kelvin_wave

   BCH.amplitudes  = zeros(2,G.bnd.NTables,length(ETA0));
   BCH.phases      = zeros(2,G.bnd.NTables,length(ETA0));

   % now add the constant offset
   BCH.frequencies = [360./C.Tt.*3600]; % [s] to [deg/hour]
   BCH.a0          = zeros(2,G.bnd.NTables,1); % a0 separate, so not in frequencies: no 3D amplitudes and phases required

   for ifreq = 1:length(find(~(BCH.frequencies)==0))

      for i=1:G.bnd.NTables

         if strcmp('Z',upper(G.bnd.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          ETA0(ifreq).abs          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(ETA0(ifreq).arg          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          ETA0(ifreq).abs          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(ETA0(ifreq).arg          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)));

         elseif strcmp('N',upper(G.bnd.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          ETA0(ifreq).abs_d_eta_d_y(G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(ETA0(ifreq).arg_d_eta_d_y(G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          ETA0(ifreq).abs_d_eta_d_y(G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(ETA0(ifreq).arg_d_eta_d_y(G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)));

         elseif strcmp('R',upper(G.bnd.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  = 0.*      ETA0(ifreq).abs_d_eta_d_y(G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = 0.*     (ETA0(ifreq).arg_d_eta_d_y(G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  = 0.*      ETA0(ifreq).abs_d_eta_d_y(G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = 0.*     (ETA0(ifreq).arg_d_eta_d_y(G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)));


         elseif strcmp('R',upper(G.bnd.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          VEL0(ifreq).abs          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)) + ...
                                  sqrt(C.g./G.D).*ETA0(ifreq).abs          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  =      0.*(VEL0(ifreq).arg          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2))) + ...
                                              0.*(ETA0(ifreq).arg_d_eta_d_y(G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          VEL0(ifreq).abs          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)) + ...
                                  sqrt(C.g./G.D).*ETA0(ifreq).abs          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  =      0.*(VEL0(ifreq).arg          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4))) + ...
                                              0.*(ETA0(ifreq).arg          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)));

         elseif strcmp('C',upper(G.bnd.DATA(i).bndtype)) & U.U0;

            BCH.amplitudes(1,i,ifreq)  = 0.*      VEL0(ifreq).abs          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = 0.*     (VEL0(ifreq).arg          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  = 0.*      VEL0(ifreq).abs          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = 0.*     (VEL0(ifreq).arg          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)));

         elseif strcmp('C',upper(G.bnd.DATA(i).bndtype))

            BCH.amplitudes(1,i,ifreq)  =          VEL0(ifreq).abs          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2));
            BCH.phases    (1,i,ifreq)  = -rad2deg(VEL0(ifreq).arg          (G.bnd.DATA(i).mn(1),G.bnd.DATA(i).mn(2)));

            BCH.amplitudes(2,i,ifreq)  =          VEL0(ifreq).abs          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4));
            BCH.phases    (2,i,ifreq)  = -rad2deg(VEL0(ifreq).arg          (G.bnd.DATA(i).mn(3),G.bnd.DATA(i).mn(4)));

         end

      end % for i=1:G.bnd.NTables

   end % for ifreq = length(BCH.frequencies)
   
   if ~isempty(OPT.bch)

     %OPT.bch         = [OPT.workdir,'depth_',num2str(OPT.d_sea),'_ks_',num2str(C.Ks),'_amplitudes_',num2str(F.eta0),'.bch'];
   
      delft3d_io_bch('write',OPT.bch,BCH);
      
      G.mdf.keywords.filbch = filenameext(OPT.bch);
      
      G.mdf = delft3d_io_mdf('write',OPT.mdf,G.mdf.keywords);

   end

   % DOES NOT WORK, ADD ALL SPECTRAL COMPONENTS FIRST
   %if U.writeini
   %ok=delft3d_io_ini('write',[U.workdir,'kelvin',num2str(G.D,'%.3i'),'.ini'],addrowcol(real      (ETA0.complex ),0),...
   %                                                                          addrowcol(zeros(size(ETA0.complex)),0),...
   %                                                                          addrowcol(real      (VEL0.complex ),0));
   %end                                                                  
