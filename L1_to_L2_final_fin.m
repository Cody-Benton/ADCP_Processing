%% L2 to L3 binning
% L3 data will result in a mat file that has hourly binned velocity,
% temperature, depth and depth from echo intensity

addpath('C:\Users\codyb\Dropbox\matlab_tools')
load('ADCP_L2_4bm_eadepth.mat')
load('C:\Users\codyb\Dropbox\SECOORA\Mat Files\Finished Variables_Structures\diff_in_mag_var.mat')

%%
ADCP(3).east_vel = ADCP(3).east_vel(:,1:end-1);
ADCP(3).north_vel = ADCP(3).north_vel(:,1:end-1);
%% Correcting the mag_declination for deployments

for ii = 1:length(ADCP)
    [ADCP(ii).east_vel, ADCP(ii).north_vel] = vecrot(ADCP(ii).east_vel,ADCP(ii).north_vel,diff_in_mag(ii));
end
%% Section 1, Binning the north and east velocities plus depth and temperature

for zz = 1:length(ADCP)

    %north values
    data_north = [ADCP(zz).mtime; ADCP(zz).north_vel]';
    vnew3_north = bin(data_north,1,ceil(ADCP(zz).mtime(1)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'nanmean');
    vnew4_north = bin([ADCP(zz).mtime' isnan(ADCP(zz).north_vel)'],1,ceil(ADCP(zz).mtime(2)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'sum');

    vnew_north = vnew3_north(:,2:end); % Use the NaNmean ones
    sum_north = vnew4_north(:,2:end);
    
    samp_int = (ADCP(zz).mtime(2)-ADCP(zz).mtime(1))*24*60; %getting sampling interval in mins
    samps_in_hour = 60/samp_int; %determines how many samples are in 1 hour

    fracnan_north = sum_north./samps_in_hour; %determines the fraction of nan values in an hour
    bb = find(fracnan_north>=0.5); %if the fraction of nan values is => 0.5 the binned data is not included
    vnew_north(bb) = NaN;

    %east values
    data_east = [ADCP(zz).mtime; ADCP(zz).east_vel]';
    vnew3_east = bin(data_east,1,ceil(ADCP(zz).mtime(1)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'nanmean');
    vnew4_east = bin([ADCP(zz).mtime' isnan(ADCP(zz).east_vel)'],1,ceil(ADCP(zz).mtime(2)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'sum');

    vnew_east = vnew3_east(:,2:end); % Use the NaNmean ones
    sum_east = vnew4_east(:,2:end);

    fracnan_east = sum_east./samps_in_hour; % 60 because that is the number of observations that would go into an hour.
    cc = find(fracnan_east>=0.5);
    vnew_east(cc) = NaN;
    
    % Temperature
    data_temp = [ADCP(zz).mtime; ADCP(zz).temperature]';
    temp3 = bin(data_temp,1,ceil(ADCP(zz).mtime(1)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'nanmean');
    temp4 = bin([ADCP(zz).mtime' isnan(ADCP(zz).temperature)'],1,ceil(ADCP(zz).mtime(2)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'sum');

    t_new = temp3(:,2:end); % Use the NaNmean ones
    t_sum = temp4(:,2:end);

    fracnan_temp = t_sum./samps_in_hour; % 60 because that is the number of observations that would go into an hour.
    dd = find(fracnan_temp>=0.5);
    t_new(dd) = NaN;
    
    %Depth
    if isempty(ADCP(zz).new_depth) == 0
        data_depth = [ADCP(zz).mtime; ADCP(zz).new_depth]';
        depth3 = bin(data_depth,1,ceil(ADCP(zz).mtime(1)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'nanmean');
        depth4 = bin([ADCP(zz).mtime' isnan(ADCP(zz).new_depth)'],1,ceil(ADCP(zz).mtime(2)*24)/24,floor(ADCP(zz).mtime(end)*24)/24,1/24,'sum');

        depth_binned = depth3(:,2:end); % Use the NaNmean ones
        depth_sum = depth4(:,2:end);

        fracnan_depth = depth_sum./samps_in_hour; % 60 because that is the number of observations that would go into an hour.
        ee = find(fracnan_depth>=0.5);
        depth_binned(ee) = NaN;
    else
       depth_binned = nan(1,length(t_new));
       depth_binned = depth_binned';
    end
    

    %create new time
    timenew = vnew3_north(:,1);

    %Save binned data back into structure
    ADCP(zz).north_vel = vnew_north';
    ADCP(zz).east_vel = vnew_east';
    ADCP(zz).mtime = timenew';
    ADCP(zz).depth = depth_binned';
    ADCP(zz).temperature = t_new';
    ADCP(zz).depth_ea = mean(ADCP(zz).depth_ea); %ones(1,length(timenew))*ADCP(zz).depth_ea;
    
    clear vnew_north vnew_east timenew fracnan_north fracnan_east bb cc sum_north sum_east data_north data_east vnew3_east vnew3_north vnew4_east vnew4_north...
        dd ee data_depth data_temp depth3 depth4 depth_binned depth_sum fracnan_depth fracnan_temp t_new t_sum temp3 temp4 

end

%% Section 2, Removing extra fields 

fields = {'pressure','new_depth','EA_avg'};

ADCP = rmfield(ADCP,fields);


%% Section 3, concatinating all deployment times
if length(ADCP) > 1
    time_L3 = ADCP(1).mtime;
    east_L3 = ADCP(1).east_vel(1:25,:);
    north_L3 = ADCP(1).north_vel(1:25,:);
    depth_L3 = ADCP(1).depth;
    temp_L3 = ADCP(1).temperature;
    depth_ea_L3 = ADCP(1).depth_ea;
    
    for ii = 2:length(ADCP)
        time_L3 = horzcat(time_L3,ADCP(ii).mtime);
        east_L3 = horzcat(east_L3,ADCP(ii).east_vel(1:25,:));
        north_L3 = horzcat(north_L3,ADCP(ii).north_vel(1:25,:));
        depth_L3 = horzcat(depth_L3,ADCP(ii).depth);
        temp_L3 = horzcat(temp_L3,ADCP(ii).temperature);
        depth_ea_L3 = horzcat(depth_ea_L3,ADCP(ii).depth_ea);
    end
else
    time_L3 = ADCP.mtime;
    east_L3 = ADCP.east_vel(1:25,:);
    north_L3 = ADCP.north_vel(1:25,:);
    depth_L3 = ADCP.depth;
    temp_L3 = ADCP.temperature;
    depth_ea_L3 = ADCP.depth_ea;
end


%% Section 4, using the blank nan method 

time_test = [time_L3(1):(time_L3(2)-time_L3(1)):time_L3(end)];
T = linspace(ceil(time_L3(1)*24)/24,floor(time_L3(end)*24)/24,length(time_test));
blank = nan(25,length(T));

blank_north = blank;
blank_east = blank;
blank_temp = blank;
blank_depth = blank;
blank_depth_ea = blank;

for zz = 1:length(time_L3)
    time_L3(zz) = round(time_L3(zz),9);
end

for zz = 1: length(T)
    T(zz) = round(T(zz),9);
end


C = ismember(T,time_L3);
blank_east(:,C) = east_L3;
blank_north(:,C) = north_L3;
blank_temp(1,C) = temp_L3;
blank_depth(1,C) = depth_L3;
blank_depth_ea = mean(depth_ea_L3);

%% Section 5, saving fields
ADCP_L3.time = T;
ADCP_L3.east = blank_east;
ADCP_L3.north = blank_north;
ADCP_L3.temp = blank_temp(1,:);
ADCP_L3.depth = blank_depth(1,:);
ADCP_L3.depth_ea = blank_depth_ea(1,:);
