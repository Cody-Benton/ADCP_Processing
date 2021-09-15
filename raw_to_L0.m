%% Raw ADCP to L0 
% Use rdradcp to go from ADCP binary to a mat file
% can use .000 file or .PD0 file
% If ADCP was recordeing waves you must process the raw files with waves-
% mon first, then use the resulting .PD0 file here

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

%% Section 3, saving the adcp data
%saves the ADCP data and the meta table created

save ADCP_L0_processing  ADCP  

msgbox('Section 3 complete')
clear