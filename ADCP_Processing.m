%% ADCP_Processing General

%% Raw ADCP to a final QC variable
% Use rdradcp to go from ADCP binary to a mat file
% can use .000 file or .PD0 file
% If ADCP was recordeing waves you must process the raw files with waves-
% mon first, then use the resulting .PD0 file here

%must have the function rdradcp in the current working directory or addpath
%to it

%% Section 1
 %make sure you have rdradcp downloaded and the path is such that it is
 %usable

file_name = inputdlg('Enter the file name or pattern (e.g. Waves_newest.PD0 or Waves*)');
file_pattern = fullfile(file_name{1});
files = dir(file_pattern);

%rdradcp is used with the try catch command. This is done because sometimes
%the data at the end of the file is corrupted and rdradcp will give an
%error. the try catch command allows the error to be caught and another
%line of code to be ran instead of the error pausing the code. The first
%try attempt rdr on the entire file and then if an error is given more and
%more of the file is cut off at the end.
ct = 0;
for k = 1:length(files) 
    try
        [ADCP(k),CFG(k)] = rdradcp(files(k).name,1,-1)
    catch
        try
            [ADCP(k),CFG(k)] = rdradcp(files(k).name,1,[1 16000])
        catch
            try
               [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 15000])
            catch
                try
                    [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 14000])
                catch
                    try
                        [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 13000])
                    catch
                        try
                            [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 12000])
                        catch
                            try
                                [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 11000])
                            catch
                                try
                                    [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 10000])
                                catch
                                    try
                                        [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 9000])
                                    catch
                                        try
                                            [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 8500])
                                        catch
                                            try
                                                [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 8000])
                                            catch
                                                try
                                                    [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 7500])
                                                catch
                                                    try
                                                        [ADCP(k),CFG(k)]=rdradcp(files(k).name,1,[1 7000])  
                                                    catch
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    ct = ct+1
end

if isempty(ADCP) == 0
    msgbox('Section 1 complete')
else
end
%% Section 2, find the bad values at the end of deployments
% bad values will have an mtime = 0

ct=0;
for i = 1:length(ADCP)

    index = find(ADCP(i).mtime == 0);
    ADCP(i).mtime(index) = [];
    ADCP(i).number(index)=[];
    ADCP(i).pitch(index)=[];
    ADCP(i).roll(index)=[];
    ADCP(i).heading(index)=[];
    ADCP(i).pitch_std(index)=[];
    ADCP(i).roll_std(index)=[];
    ADCP(i).heading_std(index)=[];
    ADCP(i).depth(index)=[];
    ADCP(i).temperature(index)=[];
    ADCP(i).salinity(index)=[];
    ADCP(i).pressure(index)=[];
    ADCP(i).pressure_std(index)=[];
    ADCP(i).east_vel(:,index)=[];
    ADCP(i).north_vel(:,index)=[];
    ADCP(i).vert_vel(:,index)=[];
    ADCP(i).error_vel(:,index)=[];
    ADCP(i).corr(:,:,index)=[];
    ADCP(i).status(:,:,index)=[];
    ADCP(i).intens(:,:,index)=[];
    ADCP(i).bt_range(:,index)=[];
    ADCP(i).bt_vel(:,index)=[];
    ADCP(i).bt_corr(:,index)=[];
    ADCP(i).bt_ampl(:,index)=[];
    ADCP(i).bt_perc_good(:,index)=[];
    
    ct=ct+1;
end

msgbox('Section 2 complete')

%% section 3, finding the time the ADCP is in and out the water

% use depth field first to try and determine pre and post deployment data
exp_depth = inputdlg('What depth was the ADCP deployed?');

for i = 1:length(ADCP)
       clear bad_depth
       if length(unique(ADCP(i).depth))>2 && mean(ADCP(i).depth) > exp_depth-5 %Checking to make sure pressure sensor is recording and in the range of what we expect
           
           bad_depth = find(ADCP(i).depth < 5); %used to index values that are assumed to be above the surface. All values were depth is less than 5 are deleted if they meet the if statement above

           ADCP(i).mtime(bad_depth)=[];
           ADCP(i).pitch(bad_depth)=[];
           ADCP(i).roll(bad_depth)=[];
           ADCP(i).heading(bad_depth)=[];
           ADCP(i).depth(bad_depth)=[];
           ADCP(i).temperature(bad_depth)=[];
           ADCP(i).salinity(bad_depth)=[];
           ADCP(i).pressure(bad_depth)=[];
           ADCP(i).east_vel(:,bad_depth)=[];
           ADCP(i).north_vel(:,bad_depth)=[];
           ADCP(i).vert_vel(:,bad_depth)=[];
           ADCP(i).error_vel(:,bad_depth)=[];
           ADCP(i).corr(:,:,bad_depth)=[];
           ADCP(i).intens(:,:,bad_depth)=[];
           ADCP(i).perc_good(:,:,bad_depth)=[];
       else
       end
    clear bad_depth
end


%echo amplitude is now used to determine pre and post deployment data
%the echo amplitude (intensity) is expected to be lower in air than in
%water
%bin 25 is near the surface and has a high intensity, if it is low we
%assume that to mean the instrument is out of the water
exp_dist = inputdlg('How far is the surface from the transducer? (within ~2m)');
for i = 1:length(ADCP)
       clear bad_echo
       
           bad_echo = find(ADCP(i).intens(exp_dist,1,[1:15 end-15:end]) < 90); %used to index values above the surface. only looking in bin 25

           ADCP(i).mtime(bad_echo)=[];
           ADCP(i).pitch(bad_echo)=[];
           ADCP(i).roll(bad_echo)=[];
           ADCP(i).heading(bad_echo)=[];
           ADCP(i).depth(bad_echo)=[];
           ADCP(i).temperature(bad_echo)=[];
           ADCP(i).salinity(bad_echo)=[];
           ADCP(i).pressure(bad_echo)=[];
           ADCP(i).east_vel(:,bad_echo)=[];
           ADCP(i).north_vel(:,bad_echo)=[];
           ADCP(i).vert_vel(:,bad_echo)=[];
           ADCP(i).error_vel(:,bad_echo)=[];
           ADCP(i).corr(:,:,bad_echo)=[];
           ADCP(i).intens(:,:,bad_echo)=[];
           ADCP(i).perc_good(:,:,bad_echo)=[];
    
end

msgbox('Section 3 complete')
%% Section 4, Manual input to determine pre and post
%the instruments heading is plotted and the user will determine the moments
%for pre and post data

figure
for i = 1:length(ADCP)
    clear post_data pre_data samp_int xx yy
    
    subplot(2,1,1) %top plot is of the first 10 ensembles heading that remain after testing the depth and echo amplitude
    plot(ADCP(i).mtime,ADCP(i).heading,'Linewidth',2)
    ylim([0 360])
    xlim([ADCP(i).mtime(1) ADCP(i).mtime(10)])
    ylabel('degrees from north CW')
    title('Heading for First 10 Ensembles')
    xlabel('ensemble number')
    xticklabels({'1','2','3','4','5','6','7','8','9','10'})
    grid on

    
    subplot(2,1,2)% bottom plot is of the last 10 ensembles of deployment
    plot(ADCP(i).mtime,ADCP(i).heading,'Linewidth',2)
    ylim([0 360])
    xlim([ADCP(i).mtime(end-10) ADCP(i).mtime(end)])
    ylabel('degrees from north CW')
    title('Heading for Last 10 Ensembles')
    xlabel('ensemble number from end')
    xticklabels({'10','9','8','7','6','5','4','3','2','1'})
    grid on
    
    [xx,yy] = ginput(2); %first click needs to be on the top graph AFTER the heading becomes stable. second click is on the bottom graph BEFORE the heading becomes unstable
    %only the x coordinate will matter
    
    samp_int = ADCP(i).mtime(10)-ADCP(i).mtime(9); %determines the sample interval for the instruments deployment
    xx=[xx(1)+2*samp_int xx(2)-2*samp_int]; %takes the time determined from the user's input on heading graph and adds two sampling intervals before the first click and after the second click
    %the two sampling intervals are added to ensure the bad ensemble is
    %captured and deleted
    
    pre_data = find(ADCP(i).mtime < xx(1)); %pre deployment data 
    post_data = find(ADCP(i).mtime > xx(2)); %post deployment data
    
    %post deployment data is deleted first to not shift the indexes one
    %way. If the pre deployment data was deleted first the indexs for the
    %post deployment data would all be off
     ADCP(i).mtime(post_data)=[];
     ADCP(i).pitch(post_data)=[];
     ADCP(i).roll(post_data)=[];
     ADCP(i).heading(post_data)=[];
     ADCP(i).depth(post_data)=[];
     ADCP(i).temperature(post_data)=[];
     ADCP(i).salinity(post_data)=[];
     ADCP(i).pressure(post_data)=[];
     ADCP(i).east_vel(:,post_data)=[];
     ADCP(i).north_vel(:,post_data)=[];
     ADCP(i).vert_vel(:,post_data)=[];
     ADCP(i).error_vel(:,post_data)=[];
     ADCP(i).corr(:,:,post_data)=[];
     ADCP(i).intens(:,:,post_data)=[];
     ADCP(i).perc_good(:,:,post_data)=[];
    
     ADCP(i).mtime(pre_data)=[];
     ADCP(i).pitch(pre_data)=[];
     ADCP(i).roll(pre_data)=[];
     ADCP(i).heading(pre_data)=[];
     ADCP(i).depth(pre_data)=[];
     ADCP(i).temperature(pre_data)=[];
     ADCP(i).salinity(pre_data)=[];
     ADCP(i).pressure(pre_data)=[];
     ADCP(i).east_vel(:,pre_data)=[];
     ADCP(i).north_vel(:,pre_data)=[];
     ADCP(i).vert_vel(:,pre_data)=[];
     ADCP(i).error_vel(:,pre_data)=[];
     ADCP(i).corr(:,:,pre_data)=[];
     ADCP(i).intens(:,:,pre_data)=[];
     ADCP(i).perc_good(:,:,pre_data)=[];
     
end

close
msgbox('Section 4 complete')

%% Section 5, Get rid of bad pressure
%a graph of pressure will be displayed and the user will be asked to input
%a 1 if the pressure is good or a 0 if the pressure is bad
%
%the y-axis is set between 24 and 30 decibars (~24m to 30m of depth)
%If the pressure reading is wacky it is deleted 
figure
for i = 1:length(ADCP)
    plot(ADCP(i).mtime,ADCP(i).pressure)
    datetick
    xlim([ADCP(i).mtime(1) ADCP(i).mtime(end)])
    ylim([2.4e4 3e4])
    yticks([2.4e4:1e4:3e4])
    yticklabels({'24000','25000','26000','27000','29000','30000'})
    ylabel('pressure (dBars)')
    xlabel('date')
    title('Time Series of Presure')
    grid on
    
    answer = inputdlg('Is Pressure Data Good? (1 for yes 0 for no)');

    if str2double(answer{1}) == 0
       ADCP(i).pressure = [];
    else
    end
end
close
msgbox('Section 5 complete')

%% Section 6, Test Images 
% creates images to make sure there are no obvious issues. For a stationary
% ADCP the heading should be a flat line after the pre and post deployment
% data are removed
figure
for j = 1:length(ADCP)
    
    subplot(4,2,1)
    imagesc(squeeze(ADCP(j).intens(:,1,[1:10])))
    title('Beam 1 EA')
    set(gca,'Ydir','normal')
    ylabel('bin number')
    grid on

    subplot(4,2,3)
    imagesc(squeeze(ADCP(j).intens(:,3,[1:10])))
    title('Beam 3 EA')
    set(gca,'Ydir','normal')
    ylabel('bin number')
    xlabel('first 10 ensembles')
    grid on
    
    subplot(4,2,2)
    imagesc(squeeze(ADCP(j).intens(:,1,[end-9:end])))
    title('Beam 1 EA')
    set(gca,'Ydir','normal')
    xticks([1:1:10])
    xticklabels({'10','9','8','7','6','5','4','3','2','1'})
    grid on

    subplot(4,2,4)
    imagesc(squeeze(ADCP(j).intens(:,3,[end-9:end])))
    title('Beam 3 EA')
    set(gca,'Ydir','normal')
    xlabel('last 10 ensembles')
    xticks([1:1:10])
    xticklabels({'10','9','8','7','6','5','4','3','2','1'})
    grid on
    
    if isempty(ADCP(j).pressure) == 0
        
        subplot(4,2,6)
        plot(ADCP(j).pressure(end-99:end))
        title('Pressure')
        xlabel('last 100 ensembles')
        ylim([23000 30000])
        grid on
        
    else
        subplot(4,2,6)
        plot([1:100],2.3e4,'r')
        title('Pressure')
        ylim([23000 30000]) 
        text(20,2.65e4,'no valid pressure data')
    end
    
    subplot(4,2,8)
    plot(ADCP(j).heading(end-99:end),'Linewidth',2)
    title('Heading')
    ylim([0 360])
    xlabel('last 100 ensembles')
    grid on
    
    
    if isempty(ADCP(j).pressure) == 0
        subplot(4,2,5)
        plot(ADCP(j).pressure(end-99:end))
        title('Pressure')
        ylabel('pressure (decibars)')
        ylim([23000 30000])
        grid on
    else
        subplot(4,2,5)
        plot([1:100],2.3e4,'r')
        title('Pressure')
        ylim([23000 30000]) 
        ylabel('pressure (decibars)')
        text(20,2.65e4,'no valid pressure data')
    end
    
    subplot(4,2,7)
    plot(ADCP(j).heading(1:100),'Linewidth',2)
    title('Heading')
    ylim([0 360])
    ylabel('degrees')
    xlabel('first 100 ensembles')
    grid on
    
    
end

msgbox('Section 6 complete. If any of the graphs are not consistent, proceed to Section 7')

%% Section 7, Back up
% if test image shows something funky run this section
dep_num = inputdlg('Which deployment do you wish to trim? Enter 1 if there is only 1 deployment');
i = str2double(dep_num{1}); % make i equal to the deployment you wish to edit. If you are dealing with only 1 deployment i = 1.

beg_bad = inputdlg('How many ensembles need to be trimmed from begining of time series?');
end_bad = inputdlg('How many ensembles need to be trimmed from end of time series?');

beg_bad = str2double(beg_bad{1});
end_bad = str2double(end_bad{1});

if beg_bad ~= 0
    trim_start = [1:beg_bad]; %manually input the number of ensembles that appear to have bad data and they will be deleted from record.
    
    %the following if-else loop is used because if there is pressure data the
    %if statement is used to deleted the selected ensembles. 
    %%%
    % However, if there is no pressure data the else statement deleted the bad
    % ensembles. This is needed not to have an error since bad pressure data
    % was already deleted 
    if isempty(ADCP(i).pressure) == 0
    
     ADCP(i).mtime(trim_start)=[];
     ADCP(i).pitch(trim_start)=[];
     ADCP(i).roll(trim_start)=[];
     ADCP(i).heading(trim_start)=[];
     ADCP(i).depth(trim_start)=[];
     ADCP(i).temperature(trim_start)=[];
     ADCP(i).salinity(trim_start)=[];
     ADCP(i).pressure(trim_start)=[];
     ADCP(i).east_vel(:,trim_start)=[];
     ADCP(i).north_vel(:,trim_start)=[];
     ADCP(i).vert_vel(:,trim_start)=[];
     ADCP(i).error_vel(:,trim_start)=[];
     ADCP(i).corr(:,:,trim_start)=[];
     ADCP(i).intens(:,:,trim_start)=[];
     ADCP(i).perc_good(:,:,trim_start)=[];
    else
     ADCP(i).mtime(trim_start)=[];
     ADCP(i).pitch(trim_start)=[];
     ADCP(i).roll(trim_start)=[];
     ADCP(i).heading(trim_start)=[];
     ADCP(i).depth(trim_start)=[];
     ADCP(i).temperature(trim_start)=[];
     ADCP(i).salinity(trim_start)=[];
     ADCP(i).east_vel(:,trim_start)=[];
     ADCP(i).north_vel(:,trim_start)=[];
     ADCP(i).vert_vel(:,trim_start)=[];
     ADCP(i).error_vel(:,trim_start)=[];
     ADCP(i).corr(:,:,trim_start)=[];
     ADCP(i).intens(:,:,trim_start)=[];
     ADCP(i).perc_good(:,:,trim_start)=[];
    end
else
end

if end_bad ~= 0
    trim_end = [length(ADCP.mtime)-end_bad:length(ADCP.mtime)];
    
    %the following if-else loop is used because if there is pressure data the
    %if statement is used to deleted the selected ensembles. 
    %%%
    % However, if there is no pressure data the else statement deleted the bad
    % ensembles. This is needed not to have an error since bad pressure data
    % was already deleted 
    if isempty(ADCP(i).pressure) == 0
    
     ADCP(i).mtime(trim_end)=[];
     ADCP(i).pitch(trim_end)=[];
     ADCP(i).roll(trim_end)=[];
     ADCP(i).heading(trim_end)=[];
     ADCP(i).depth(trim_end)=[];
     ADCP(i).temperature(trim_end)=[];
     ADCP(i).salinity(trim_end)=[];
     ADCP(i).pressure(trim_end)=[];
     ADCP(i).east_vel(:,trim_end)=[];
     ADCP(i).north_vel(:,trim_end)=[];
     ADCP(i).vert_vel(:,trim_end)=[];
     ADCP(i).error_vel(:,trim_end)=[];
     ADCP(i).corr(:,:,trim_end)=[];
     ADCP(i).intens(:,:,trim_end)=[];
     ADCP(i).perc_good(:,:,trim_end)=[];
    else
     ADCP(i).mtime(trim_end)=[];
     ADCP(i).pitch(trim_end)=[];
     ADCP(i).roll(trim_end)=[];
     ADCP(i).heading(trim_end)=[];
     ADCP(i).depth(trim_end)=[];
     ADCP(i).temperature(trim_end)=[];
     ADCP(i).salinity(trim_end)=[];
     ADCP(i).east_vel(:,trim_end)=[];
     ADCP(i).north_vel(:,trim_end)=[];
     ADCP(i).vert_vel(:,trim_end)=[];
     ADCP(i).error_vel(:,trim_end)=[];
     ADCP(i).corr(:,:,trim_end)=[];
     ADCP(i).intens(:,:,trim_end)=[];
     ADCP(i).perc_good(:,:,trim_end)=[];
    end
else 
end

%the following if-else loop is used because if there is pressure data the
%if statement is used to deleted the selected ensembles. 
%%%
% However, if there is no pressure data the else statement deleted the bad
% ensembles. This is needed not to have an error since bad pressure data
% was already deleted    
msgbox('Section 7 complete')
%% Section 8, Applying QC procedures
% north values

error_thresh = inputdlg('Error velocity threshold input');
corr_thresh = inputdlg('Correlation Magnitude threshold input');
echo_amp_thresh = inputdlg('Echo intensity gradient threshold input');
for zz=1:length(ADCP)
    % velocity error test 
    clear col dif ind row xx yy 
    [row,col] = find(abs(ADCP(zz).error_vel)>=error_thresh); %indexes bin and ensemble for which the velocity error is above threshold

    for xx = 1:length(row)
           ADCP(zz).north_vel(row(xx),col(xx))=nan; %changes the indexed bin and ensemble to nan
    end

    %correlation magnitude test 
    for xx=1:length(ADCP(zz).mtime)
        [row,col] = find(ADCP(zz).corr(:,:,xx)<=corr_thresh); %indexes values that fail
         for yy= 1:length(row)
             ADCP(zz).north_vel(row(yy),xx) = nan; %changes values that failed to nan
         end
    end

    % Echo Amplitude test with a threshold of 10
    %the threshold of 10 referes to the difference in intensity (echo
    %amplitude) between adjacent bins 
    for xx=1:length(ADCP(zz).mtime)
        for ll = 1:4
            for yy=15:ADCP(zz).config.n_cells-1  %This test is only applied to bins above the 15th bin
                dif = ADCP(zz).intens(yy,ll,xx)-ADCP(zz).intens(yy+1,ll,xx);
                ind = find(abs(dif)>=echo_amp_thresh);

                if sum(ind) >= 1
                   ADCP(zz).north_vel(yy:end,xx)= nan;
                else
                end
            end
        end
    end
end
msgbox('Section 8 complete')
%% Section 9, East values
% same as the above procedures only now the east velocity values are
% screened
for zz=1:length(ADCP)
    clear col dif ind row xx yy 
    [row,col] = find(abs(ADCP(zz).error_vel)>=error_thresh);

    for xx = 1:length(row)
           ADCP(zz).east_vel(row(xx),col(xx))=nan; 
    end

    %correlation magnitude test
    for xx=1:length(ADCP(zz).mtime)
        [row,col] = find(ADCP(zz).corr(:,:,xx)<=corr_thresh);
         for yy= 1:length(row)
             ADCP(zz).east_vel(row(yy),xx) = nan;
         end
    end

    % Echo Amplitude test
     for xx=1:length(ADCP(zz).mtime)
        for ll = 1:4
            for yy=15:ADCP(zz).config.n_cells-1
                dif = ADCP(zz).intens(yy,ll,xx)-ADCP(zz).intens(yy+1,ll,xx);
                ind = find(abs(dif)>=echo_amp_thresh);

                if sum(ind) >= 1
                   ADCP(zz).east_vel(yy:end,xx)= nan;
                else
                end
            end
        end
    end
end
msgbox('Section 9 complete')
%% Section 10, Calculating depth from pressure data
%the provided depth values are discrete so here we calculate our own depth
%field and call it "new_depth"
for ii = 1:length(ADCP)
    if isempty(ADCP(ii).pressure) == 0
        for jj = 1:length(ADCP(ii).mtime)
            ADCP(ii).mean_depth(jj) = nanmean((ADCP(ii).pressure(jj))*10/(1026*9.81)); %recorded pressure is in decibars so we use density of water to be 1026 and g to be 9.81
        end
    else
        ADCP(ii).mean_depth = []; %if there was no valid pressure data the field is empty
    end
end

msgbox('Section 10 complete')
%% Section 11, calculating 4 beam average EA
%Here we average the beam intensity (echo amplitude)
%then we determine a conservative estimate for the sea surface using the
%averaged echo amplitude

for gg = 1:length(ADCP)
    for  hh = 1:length(ADCP(gg).mtime)
         ADCP(gg).EA_avg(:,hh) = mean(ADCP(gg).intens(:,:,hh),2); %averaging across the 4 beams
    end
end

%here we use the same procedure as the echo amplitude QC test. A difference
%of 10 is found between two adjacent bins, except this time the 4 beam
%average echo intensity is used
for zz = 1:length(ADCP)

    for xx=1:length(ADCP(zz).mtime)
        for yy= round(exp_depth/2):ADCP(zz).config.n_cells-1 %only bins above the halfway
            dif(xx,yy) = ADCP(zz).EA_avg(yy,xx)-ADCP(zz).EA_avg(yy+1,xx);
            if isempty(min(find(abs(dif(xx,:))>echo_amp_thresh))) == 0
                c(xx) = min(find(abs(dif(xx,:))>echo_amp_thresh));
            else
                c(xx) = 25;
            end
        end
    end
%the config ranges is used to go from bin number to distance from ADCP
%(depth). then a mean across the entire deployment is taken
    ADCP(zz).depth_ea = mean(abs(ADCP(zz).config.ranges(c))); 

end
msgbox('Section 11 complete')
%% Section 12, Remove fields that are not needed for L1

fields = {'number','pitch','roll','heading','pitch_std','roll_std','heading_std','depth','salinity','vert_vel','error_vel','corr','status','intens','bt_range','bt_vel',...
    'bt_corr','bt_ampl','bt_perc_good','perc_good','pressure_std','coords'};

ADCP = rmfield(ADCP,fields);
msgbox('Section 12 complete')
%% Section 13, Removing values that are above Sea surface 
%last resort QC procedure
%anything above the sea surface as determined by depth is turned into an
%nan
%%%%
%if there is no depth field the sea surface determined by the echo
%amplitude is used as a conservative cut off

for ii=1:length(ADCP)
    if isempty(ADCP.mean_depth) == 0

        surface_press = find(abs(ADCP.config.ranges) > ADCP.mean_depth);
        surface_cut_press = min(surface_press);

        ADCP.east_vel(surface_cut_press:end,:) = nan;
        ADCP.north_vel(surface_cut_press:end,:) = nan;

    else
        surface_ea = find(abs(ADCP.config.ranges) > ADCP.depth_ea);
        surface_cut_ea = min(surface_ea);

        ADCP.east_vel(surface_cut_ea:end,:) = nan;
        ADCP.north_vel(surface_cut_ea:end,:) = nan;
    end
end

save ADCP_L1 ADCP
msgbox('Section 12 complete. You have successfully processed the ADCP data')
clear