function xls_xmp
%xls_xmp exampel how to compare xls files

      %
      % Defenitions:
      %

      Filinp = 'testje_testje';
      Filout = 'testje';

      stations_wat = {'Culvert_Waddenzee_2';
                      'Culvert_IJsselmeer'};
      stations_dis = {'Culvert_Wadden'    };

      %
      % Open en read input file
      %

      File   = qpfopen(['trih-' Filinp '.dat']);
      Fields = qpread (File);

      % Sediment concentrations

      Fieldnames = transpose ({Fields.Name});

      % water levels

      quantity    = 'water level';
      index_field = find   (strcmp(quantity,Fieldnames) == 1);
      stations    = qpread (File,Fieldnames{index_field},'stations');
      times       = qpread (File,Fieldnames{index_field},'times');

      for i_stat = 1: length(stations_wat)
         station_name = stations_wat{i_stat};
         index_stat   = find   (strcmp(station_name,stations) == 1);
         Data         = qpread (File,Fieldnames{index_field},'Data',1:length(times),index_stat);
         cell_arr{1,1} = 'Date';
         cell_arr{1,2} = 'Waddenzee';
         cell_arr{1,3} = 'IJsselmeer';
         for i_time = 1: length(times)
            cell_arr{i_time + 1,1}          = datestr(times(i_time),'yyyy-mm-dd  HH:MM:SS');
            cell_arr{i_time + 1,i_stat + 1} = Data.Val(i_time);
         end
      end

      filename = [Filout '.xls'];
      xlswrite_report(filename,cell_arr,quantity);

      % Discharges

      clear cell_arr

      quantity    = 'instantaneous discharge';
      index_field = find   (strcmp(quantity,Fieldnames) == 1);
      stations    = qpread (File,Fieldnames{index_field},'stations');
      times       = qpread (File,Fieldnames{index_field},'times');

      for i_stat = 1: length(stations_dis)
         station_name = stations_dis{i_stat};
         index_stat   = find   (strcmp(station_name,stations) == 1);
         Data         = qpread (File,Fieldnames{index_field},'Data',1:length(times),index_stat);
         cell_arr{1,1} = 'Date';
         cell_arr{1,2} = 'Debiet Culvert';
         for i_time = 1: length(times)
            cell_arr{i_time + 1,1}          = datestr(times(i_time),'yyyy-mm-dd  HH:MM:SS');
            cell_arr{i_time + 1,i_stat + 1} = Data.Val(i_time);
         end
      end

      xlswrite_report(filename,cell_arr,quantity,'format','.0','colwidth',[20 15]);
