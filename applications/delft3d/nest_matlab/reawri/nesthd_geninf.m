      function [gen_inf] = nesthd_geninf(fileInp)

      % geninf: get general information from the history file
      %
      modelType                        = EHY_getModelType(fileInp);

      %% start with times
      [gen_inf.times,gen_inf.itdate]   = EHY_getmodeldata_getDatenumsFromOutputfile(fileInp);
      gen_inf.notims     = length(gen_inf.times);
      gen_inf.tstart     = (gen_inf.times(1)   - gen_inf.itdate)*1440.;    % in minutes
      gen_inf.tend       = (gen_inf.times(end) - gen_inf.itdate)*1440.;    % in minutes

      %% stations
      stations                          = EHY_getStationNames(fileInp,modelType);
      no_stat                           = length(stations);
      for i_stat = 1: no_stat
          gen_inf.list_stations(i_stat) = i_stat;
          gen_inf.names{i_stat}         = strtrim(stations{i_stat});
      end

      %% layer information
      gridInfo                          = EHY_getGridInfo(fileInp,{'Zcen' 'layer_model' 'no_layers'});
      gen_inf.kmax                      = gridInfo.no_layers;
      gen_inf.dps                       = -1.*gridInfo.Zcen;
      gen_inf.layer_model               = gridInfo.layer_model;
      if strcmpi (gridInfo.layer_model,'sigma-model')
          gridInfo                      = EHY_getGridInfo(fileInp,{'layer_perc'});
          gen_inf.thick                 = reshape(gridInfo.layer_perc,1,[]); % follow either d3d sigma or dhydro convention
      else
          gen_inf.thick(1:gen_inf.kmax) = NaN;
      end

      %% (temporary) alfas
      switch modelType
          case 'd3d'
              trih = vs_use(fileInp,'quiet');
              gen_inf.alfas   = vs_let(trih,'his-const','ALFAS','quiet');
          otherwise
              gen_inf.alfas(1:no_stat) = NaN;
      end

      %% Constituents
      gen_inf.namcon = EHY_getConstituentNames(fileInp);
      gen_inf.lstci = length(gen_inf.namcon);

