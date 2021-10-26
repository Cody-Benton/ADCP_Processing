# ADCP_Processing
Code processes binary ADCP data and incorporates some quality control (QC) measures. The QC measures follow recomendations made by IOOS's QARTOD standards. 

# Toolboxes and other codes needed
1) RDADCP by Rich Pawlowicz. The ADCP Processing script uses the function rdradcp which is contained in the RDADCP file. The file can be found at https://www.eoas.ubc.ca/~rich/#RDADCP. The function rdradcp reads the binary ADCP data.

# Instructions
This was prepared by Cody Benton as part of the 2021 SECOORA Buoy Data Challenge.
There are two matlab files used for processing the raw ADCP data, each with their own steps. The first matlab file turns the raw binary ADCP data into a matlab file, this is “raw_to_L0”. Next is “L0_to_L1” and this consists of some quality control measures (QC) which were guided by the QC standards of Quality Assurance/Control of Real Time Oceanographic Data (QARTOD) for real time ADCP measurements. ADCP_Processing was created for non real time moorings, so not all tests apply. 

L1 will result in a matlab structure with the following fields;

-config: has information on the configuration of the ADCP when it was deployed

-mtime: time in matlab date number format

-temperature: temperature in degrees celsius

 -pressure: pressure in decibars (if the pressure exists/is valid)

-east_vel: east-west velocity in m/s with positive being east and negative being west

-north_vel: north-south velocity in m/s with positive being north and negative being south

-mean_depth: the mean depth across the deployment calculated using pressure

-EA_avg: an average of the beam intensity across all four beams for each bin

-depth_ea: a conservative estimate of the depth using the difference in beam intensity between each bin. Useful for when there is no pressure data.



(1) Raw ADCP data to L0
L0 will result in a Matlab structure with numerous fields and no QC done. This code can be used to process multiple deployments or a single deployment. If processing multiple deployments, have all the raw ADCP files in a single folder with a naming convention that lists them chronologically. An example is currents_01, currents_02, currents_03,... etc. 
	This code will have four sections. Use the  “Run and Advance” button on the editor tab toolbar in Matlab. This button will run a section and advance you to the next step. At the end of each section a message saying it was completed will appear, if there is no message box something may have gone wrong. If the ADCP was set to measure only currents the .000 file can be used, however, if the ADCP was set to measure currents and waves then the .000 file must be processed with WavesMon. Running the .000 file through WavesMon will result in several file types, the .PD0 is the one we will use as it contains the current data. To process the raw data, the following steps must be followed while using the “raw_to_L1” code.

With the correct file, run the matlab script “raw_to_L0.m” using the “Run and Advance” button under the editor tab in the toolbar. The matlab function rdradcp is used to read the raw binary data and results in two structures, ADCP and CFG.
Some of the data will be bad. The next section of “raw_to_L0.m” finds and deletes these values. It does so by finding where the time = 0. At these points all data = 0. 
The ADCP data will be saved in section 3.

The ADCP data will be saved as “ADCP_L0_processing.mat” in whatever folder is your working directory when you run the code.

(2) L0 to L1
	L1 will result in ADCP current data that has been subjected to QC measures. The QC measures implemented include an error velocity test, correlation magnitude test and an echo intensity test. The QC tests were devised using guidance from QARTOD. More information about the QC tests and how they were applied can be found at the end of this document, under the “Methods” section. Before starting “L0_to_L1.m” make sure you have the ‘ADCP_L0_processing.mat’ file loaded into your workspace. Running the top header section should do this as long as your current folder is where it is saved. 

Delete the pre and post-deployment data. The pre and post data is determined by looking at the echo intensity of the 25th bin, which should be near the surface and have a high echo intensity. If the echo intensity is below 90 decibels we assume it to be pinging out of the water. The pressure is also checked, if the pressure is <5 dBars it is assumed the ADCP is out of the water. 
Section 2 deletes pre and post-deployment data. A two panel plot of the instruments heading will be displayed. The top plot is only the first 10 ensembles and the bottom is the last 10 ensembles. Examine the data and click where the heading becomes stable, indicating the instrument is properly deployed. The FIRST click needs to be in the top plot to the RIGHT of the bad data. The SECOND click is in the bottom plot to the LEFT of the bad data. The input will be used to trim the pre and post deployment data.
A plot of the pressure over the entire deployment will be displayed. Then the user will be asked to put a 1 if pressure appears good or a 0 if pressure appears bad. Signs of bad pressure would be a drifting pressure value, a flat line, or no data at all. For all of these cases enter a 0.
These panels provide the user a quick way to check if all the pre and post-deployment data was properly removed. If there is anything funky, such as a peak echo intensity that isn't consistent or an unstable heading, at the beginning or end of the time series proceed to section five.
Run the fifth section only if the test image showed bad data at the start or end of the time series, otherwise proceed to section six. 
Run the sixth section to apply QC measures to the north values. Three QC tests are applied here;
-error velocity test with a threshold of 0.05 m/s
-correlation magnitude test with a threshold of 110
-echo intensity test which screens bins that have an increase of 10 or more decibels. This test is not applied to the bottom 15 bins
More information on threshold values and the QC process can be found in the methods.
The seventh section applies the same QC measures to the east values. After section six and seven all data corresponding to north and east velocity values that failed QC tests will be screened and represented as Matlab's nan (not a number).
Calculate depth from pressure.
Calculate the four-beam average beam intensity. Then a method is used to determine a conservative estimate of sea surface in the case of no pressure data. This is done by finding the depth at which the echo intensity QC test is failed for each ensemble.
 Remove fields and trim the data set down.
All values that appear above the sea surface (as determined by pressure or in section nine) are turned into nan.

 (3) Deployment Report
	The deployment report is used to create a PDF for documentation and future reference. The report includes metadata, the name of who prepared the report and when it was prepared. This code is run differently than the others. Instead of using the “Run and Advance” button, the user should go to the publish tab in Matlab. The following are the steps needed to produce the report.

Go to the publish tab 
Under the “Publish button” press the black arrow then “Edit Publishing Options…”
Under “Output Settings” select PDF and the folder you wish to save it to
Under “Code Settings” make sure the “Include Code” is set to “false”
Press “publish”
When asked to enter your full name, enter your name
You will be asked to enter the deployment name, enter the deployment name following the naming convention “OB27_mm_mm_yyyy” (e.g. OB27_02_05_2021 for a deployment that spans February 2021 to May 2021. If the deployment crosses years, like November to January then OB27_11_1_2020_2021)
A PDF of the report should be created and ready to print or save



Methods for processing and applying QC for OB27 ADCP

Processing and Quality Control (QC) of OB27 current data was done in two stages. The processing resulted in two tiers of data L0 and L1. The following are the methods used to achieve each tier as well as an explanation of the tier.

L0
The first tier is L0. L0 consists of data with no QC and may contain data from both pre-deployment and post-deployment. To get to L0 the raw binary ADCP data is imported to Matlab and the matlab function “rdradcp” written by R. Pawlowicz is used. In order to use rdradcp the raw binary data must not include wave measurements. If the ADCP was set to measure waves then RDI’s WavesMon software must be used before importing the data to Matlab.
WavesMon will process the .000 file and result in several file types. The current data will be in the .PD0 file. Rdradcp will be used on either a .000 file containing only currents, or a .PDO file. This will result in a matlab structure titled ADCP with the fields 

config: configuration of instrument at time of deployment
mtime: time in Matlab’s datenum
number: ensemble number
pitch: instruments pitch
roll: instruments roll
heading: instruments heading 
pitch_std: the standard deviation of the pitch
roll_std: the standard deviation of the roll
heading_std: the standard deviation of the heading
depth: the depth of the instrument
temperature: the temperature at the instrument 
salinity: salinity measured at the instrument  
pressure: pressure in decibars
pressure_std: the standard deviation of the pressure
coords: coordinate system used by the instrument
east_vel: east/west component of velocity with east being positive
north_vel: north/south component of velocity with north being positive
vert_vel: vertical velocity 
error_vel: error velocity 
corr: the correlation magnitude between beams
status: the status of the instrument
intens: the echo intensity for each beam in each bin (also called echo amplitude)
bt_range: bottom tracking range
bt_vel: bottom tracking velocity
bt_corr: bottom tracking correlation
bt_ampl: bottom tracking amplitude
bt_perc_good: bottom tracking percent of good measurements
perc_good: percent of good measurements

Some of these fields are completely irrelevant depending on the type of deployment. For example, all the bottom tracking information is irrelevant for OB27 as it is an upward facing deployment. No fields are removed at the L0 level. If there are multiple deployments where N is the number of deployments, then the resulting structure will be named ADCP and have a size of 1xN where N is the nth deployment. 
The resulting data will have some bad data, typically at the end of the data. This is found by looking for when time = 0. The time field is in Matlab’s datenum and a time = 0 indicates that all the data at that index is 0 as well. These are found and deleted. The result is the L0 tier of data.
	
L1
	The L1 tier of data has had pre and post-deployment data, faulty pressure measurements and extra fields removed from the data set. QC has also been applied to the data and a depth field and four-beam averaged beam intensity fields have been added. L1 data will include fields

config: configuration settings of ADCP 
mttime: time in matlab datenumber 
temperature: temperature in degrees celsius 
pressure: pressure in decibars 
east_vel: east velocity in m/s with a flow to the east being positive
north_vel: north velocity in m/s with a flow to the north being positive
mean_depth: mean depth of ADCP in meters calculated from the pressure 
EA_avg: the four beam average echo intensity (or echo amplitude) in decibels
depth_ea: a conservative estimate of the sea-surface using the echo intensity

The pre and post-deployment data are found and removed using several methods. The first method is by looking for depth less than 5m but whose mean depth is greater than 23m. This would correspond to the data while the ADCP is being deployed or while it is being retrieved. These intervals vary, but for OB27, tend to be every 3 months. The mean must be greater than 23m because a failing pressure sensor could read any value as it drifts over time. That means the entire data set would be thrown out if say the sensor was reading 3m the whole time. So we check that the pressure sensor is recording a depth that is somewhat close to the actual depth before screening the values that correspond to a less than 5m depth. The second method for finding the pre and post-deployment data is looking for an echo intensity less than 90 in the 25th bin. The 25th bin is used as it is centered near 27m distance from the sea floor, which is roughly where the sea surface is expected to be and will result in the highest values for echo intensity. A low echo intensity here most likely indicates the ADCP is pinging in air and not water, and the echo intensity will be lower in air than water. 90 decibels  was chosen as a threshold as this is significantly below the average for the 25th bin.
The next step is to manually determine the pre and post deployment data. This is done by manually looking at some data. Section 2 of the L0 to L1 processing code will create an image with the instruments heading for the first 10 ensembles and last 10 ensembles. If the heading appears to be unstable near the beginning or end of the time series the data is screened. The echo intensity is also screened in a similar manner for the beginning and end of the time series.
Although we screened some pressure at the beginning, there could still be erroneous pressure data due to a failing or compromised pressure sensor. The pressure data is plotted and checked for validity, if the pressure data appears to be wrong or drifting over a deployment, it will be deleted from the L1 data set. After this step the pre and post deployment data should be completely screened and we are now ready to apply the QC measures.
Three QC tests are applied to the data. These QC tests are a velocity error test, a correlation magnitude test and an echo intensity test. These tests were recommended by documentation provided by Quality Assurance/Control of Real Time Oceanographic Data (QARTOD). Since OB27 is not a real time mooring, not all tests are applicable. A presentation on QC of ADCP by Australia’s Commonwealth Scientific and Industrial Research Organization (CSIRO) was also helpful in developing these QC tests. The thresholds for these tests will vary depending on the region the ADCP is deployed, the following thresholds are appropriate for the Onslow Bay region off the coast of North Carolina.
The velocity error test screens any data that has an error velocity greater than 0.05m/s. This value was selected as it would keep the majority of values in the water column and above the surface it screened ~75% of the values, which we know are bad. Because multiple QC tests were being implemented we could use a less stringent threshold and try to keep as many good values as possible. The second test was a correlation magnitude test. The threshold used for the correlation magnitude test was 110, this threshold screened about 80% at the surface boundary and approshed 100% the farther above the surface you go. The final QC test used the echo intensity. The echo intensity for each beam was used and the difference between bins was determined. If the echo intensity increases by more than 10 decibels between bins we consider all the data above that point to be bad and it is screened. This resulted in nearly 100% of the data being screened at the surface and above. This test is not applied to the bottom 15 bins. This is to prevent good data near the bottom from being screened. Sediment in the lower level of the water column can cause a sudden increase in echo amplitude. When all three tests are applied we get a good data set with erroneous data removed.



A new field is added to the L1 data, this field is depth_ea. This field is a conservative estimate of the surface. It is determined by finding the mean depth at which the 10 decibels increase happens across the time series. We found this approach to be 1-2m below the surface as determined by pressure. The depth-ea field is useful for when the pressure data (thus the depth data) is non-existent or faulty. The mean depth from pressure or echo intensity is used in the final step to screen any values above the surface that may have passed by the QC tests.
Some other fields are added to the L1 tier of data. These include depth calculated from the pressure using h = pressure*10/(1026*9.81). A four beam average of the echo intensity is also calculated and added to L1.











