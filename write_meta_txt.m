function write_meta_txt(num)
%
% make_init_file_fft(num,amp,Ly)
% 
% num has got to be run number. amp has got to be ampfile name. This was
% done for the wavemaker tests with different dfs.
%
eval(sprintf('filname = ''meta_OB27_%1d.txt'';',num));

load('ADCP_L1.mat')

str_date = datestr(ADCP(1).mtime(1));
end_date = datestr(ADCP(1).mtime(end));
samp_int = round((ADCP.mtime(2)-ADCP.mtime(1))*24*60*60);

l1 = 'Organization: CORMP';
l2 = 'Region: U.S. East Coast, North Carolina, Onslow Bay';
eval(sprintf('l3 = ''Deployment dates: %s to %s'';',str_date(1:11),end_date(1:11))); 
l4 = 'Instrument: RDI Workhorse 600kHz ADCP';
eval(sprintf('l5 = ''Sampling rate: %d seconds'';',samp_int));
l6 = 'Latitude: -77.353 degrees';
l7 = 'Longitude: 33.993 degrees';
l8 = 'Depth: 30m';
l9 = 'Altitude above sea floor: 2m';
eval(sprintf('l10 = ''Bin 1 distance: %dm'';',round(ADCP.config.bin1_dist),2));
eval(sprintf('l11 = ''Bin size: %dm'';',ADCP.config.cell_size));
eval(sprintf('l12 = ''Correlation threshold: %d'';',ADCP.config.corr_threshold));
eval(sprintf('l13 = ''Magnetic Declination Input: %d'';',ADCP.config.magnetic_var));
eval(sprintf('l14 = ''Number of bins: %d'';',ADCP.config.n_cells));
eval(sprintf('l15 = ''Pings per ensemble: %d'';',ADCP.config.pings_per_ensemble));
eval(sprintf('l16 = ''Instrument serial num: %d'';',ADCP.config.remus_serialnum));
l17 = 'Unit for currents: m/s';
l18 = 'Column 1-6 is the time in UTC in this order, yyyy,mm,dd,hh,mm,ss';
l19 = 'Column 7 is the instrument-measured pressure in dbars';
l20 = 'column 8 is the first velocity bin. Subsequent columns are velocity bins with increasing distance from sea bed.';
l21 = 'The top row is estimated water depth (m) of the corresponding bin. Columns 1-7 are -9999';
l22 = 'Data flagged as bad, or non-existant values are indicated by -9999';



fileID = fopen(filname,'wt');
formatSpec = '%s\n';
% Actually write the file. Add number of lines if we increase the amount of
% stuff we are saving.
for xx = 1:22                           
eval(sprintf('fprintf(fileID,formatSpec,l%s);',num2str(xx)));
end
fclose(fileID);

