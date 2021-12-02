%% Writing CSV file for Axiom to use


%%
%east values
for ii = 1:length(ADCP)
    T_east = datetime(ADCP(ii).mtime,'ConvertFrom','datenum');

    east(1,1:7) = -9999;

    for jj = 1:length(ADCP(ii).config.ranges)

    east(1,jj+7) = 30-abs(ADCP(ii).config.ranges(jj));
    end

    for jj = 1:length(T_east)
        east(jj+1,1) = year(T_east(jj));
        east(jj+1,2) = month(T_east(jj));
        east(jj+1,3) = day(T_east(jj));
        east(jj+1,4) = hour(T_east(jj));
        east(jj+1,5) = minute(T_east(jj));
        east(jj+1,6) = second(T_east(jj));

        if isempty(ADCP(ii).pressure) == 1
            east(jj+1,7) = -9999;
        else
            east(jj+1,7) = ADCP(ii).pressure(jj);
        end
    end


    for jj = 1:ADCP(ii).config.n_cells

        east(2:length(T_east)+1,jj+7) = ADCP(ii).east_vel(jj,:);
    end

    mask_e = isnan(east);
    east(mask_e) = -9999;

    T_east_str = datestr(T_east);

    dep_name_y_1 = T_east_str(1,8:11);
    dep_name_m_1 = T_east_str(1,4:6);
    dep_name_y_2 = T_east_str(end,8:11);
    dep_name_m_2 = T_east_str(end,4:6);

    dep_name_e = append('E_OB27_',dep_name_y_1,'_',dep_name_m_1,'_',dep_name_y_2,'_',dep_name_m_2,'.csv');

    writematrix(east,dep_name_e)

    %north values
    T_north = datetime(ADCP(ii).mtime,'ConvertFrom','datenum');

    north(1,1:7) = -9999;

    for jj = 1:length(ADCP(ii).config.ranges)

    north(1,jj+7) = 30-abs(ADCP(ii).config.ranges(jj));
    end

    for jj = 1:length(T_north)
        north(jj+1,1) = year(T_north(jj));
        north(jj+1,2) = month(T_north(jj));
        north(jj+1,3) = day(T_north(jj));
        north(jj+1,4) = hour(T_north(jj));
        north(jj+1,5) = minute(T_north(jj));
        north(jj+1,6) = second(T_north(jj));

        if isempty(ADCP(ii).pressure) == 1
            north(jj+1,7) = -9999;
        else
            north(jj+1,7) = ADCP(ii).pressure(jj);
        end
    end


    for jj = 1:ADCP(ii).config.n_cells

        north(2:length(T_north)+1,jj+7) = ADCP(ii).north_vel(jj,:);
    end

    mask_n = isnan(north);
    north(mask_n) = -9999;

    T_north_str = datestr(T_east);

    dep_name_y_1 = T_north_str(1,8:11);
    dep_name_m_1 = T_north_str(1,4:6);
    dep_name_y_2 = T_north_str(end,8:11);
    dep_name_m_2 = T_north_str(end,4:6);

    dep_name_n = append('N_OB27_',dep_name_y_1,'_',dep_name_m_1,'_',dep_name_y_2,'_',dep_name_m_2,'.csv');

    writematrix(north,dep_name_n)
    
    clear dep_name dep_name_e dep_name_n dep_name_m_1 dep_name_m_2 dep_name_y_1 dep_name_y_2 east north mask_e...
          mask_n T_east T_east_str T_north T_north_str
end
