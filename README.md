# ADCP_Processing
Code processes binary ADCP data and incorporates some quality control (QC) measures. The QC measures follow recomendations made by IOOS's QARTOD standards. Works for upward facing ADCPs in 5m or more of water depth.

This was prepared by Cody Benton as part of the 2021 SECOORA Buoy Data Challenge.
ADCP_Processing consists of some quality control measures (QC) which were guided by the QC standards of Quality Assurance/Control of Real Time Oceanographic Data (QARTOD) for real time ADCP measurements. ADCP_Processing was created for non real time moorings, so not all tests apply. 

The result will be a matlab structure with the following fields;

-config: has information on the configuration of the ADCP when it was deployed

-mtime: time in matlab date number format

-temperature: temperature in degrees celsius

-pressure: pressure in decibars (if the pressure exists/is valid)

-east_vel: east-west velocity in m/s with positive being east and negative being west

-north_vel: north-south velocity in m/s with positive being north and negative being south

-mean_depth: the mean depth across the deployment calculated using pressure

-EA_avg: an average of the beam intensity across all four beams for each bin

-depth_ea: a conservative estimate of the depth using the difference in beam intensity between each bin. Useful for when there is no pressure data.

Use the  “Run and Advance” button on the editor tab toolbar in Matlab. This button will run a section and advance you to the next step. At the end of each section a message saying it was completed will appear, if there is no message box something may have gone wrong. If the ADCP was set to measure only currents the .000 file can be used, however, if the ADCP was set to measure currents and waves then the .000 file must be processed with WavesMon. Running the .000 file through WavesMon will result in several file types, the .PD0 is the one we will use as it contains the current data. To process the raw data, the following steps must be followed.

# Toolboxes, codes and other software needed
1) RDADCP by Rich Pawlowicz. The ADCP Processing script uses the function rdradcp which is contained in the RDADCP file. The file can be found at https://www.eoas.ubc.ca/~rich/#RDADCP. The function rdradcp reads the binary ADCP data.
2) WavesMon from RDI (contact RDI).

# Instructions
Make sure the function rdradcp is installed and in the working directory, or the path is accessible. The following instructions will correspond to each seaction (i.e. step 1 is for section 1).

1) Make sure the binary ADCP data is in the working directory. When prompted to input name pattern, type the complete name of the file including the exstention OR type enough so that no other file could be confused for it and finish with a '\*'. If processing several ADCP deployments in one go, you can name the raw files with a convention that lists them chronologically. For Example, "Currents_01, currents_02, Currents_03.... so on" then use the file patterns input "Currents\*". This will process all the deployments and the result will be a structure named ADCP with N rows, each row being a deployment.
2) No input needed from user.
3) Input the approximate depth that the ADCP was deployed. Then, input how far the surface is from the transducer. Both of these can be aproximate. The distance of the surface must take into account the elevation of the ADCP above the sea floor. 
4) An image will appear with the heading plotted for the first 10 ensembles and last 10 ensembles. The user must FIRST click to the RIGHT of when the heading becomes stable. THEN click to the LEFT of when the heading becomes unstable. IF the heading appears stable for all 10 ensembles click the begining or end of the time series.
5) A plot of the pressure data will appear. The user will be asked to enter 1 if the data is good, or 0 if the data is bad. Bad pressure data can consist of no pressure, or a drifting pressure reading.
6) A figure will appear of several fields plotted for the first 100 ensembles and the last 100 ensembles. If any of the fields appear to be inconsistent mark the ensembles where it becomes consistent again.
7) You will be asked which deployment you wish to trim the time series for. If you are processing a singles deployment enter "1". Then eneter the number of ensembles you want to trim from the begining and end.
8) Section 8 applies the QC tests. These tests include an error velocity test, correlation magnitude test and and echo intensity test. Thresholds for these tests will vary by location. you will be asked to input the thresholds you wish to apply to the data.
9) Requires no input from user.
10) requires no input from user.
11) requires no input from user.
12) requires no input from user.
13) requires no input from user.

Processing as been complet and the data has been saved in the current working directory as ADCP_L1.

# Methods for processing and applying QC 

Processing and Quality Control (QC) of ADCP current data was done using QARTOD Recomendations. The following are the methods used to achieve the final, processed result.

The raw binary ADCP data is imported to Matlab and the matlab function “rdradcp” written by R. Pawlowicz is used. In order to use rdradcp the raw binary data must not include wave measurements. If the ADCP was set to measure waves then RDI’s WavesMon software must be used before importing the data to Matlab.
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

Some of these fields are completely irrelevant depending on the type of deployment. For example, all the bottom tracking information is irrelevant for an upward facing ADCP. No fields are removed at this point. If there are multiple deployments where N is the number of deployments, then the resulting structure will be named ADCP and have a size of 1xN where N is the nth deployment.

The resulting data will have some bad data, typically at the end of the data. This is found by looking for when time = 0. The time field is in Matlab’s datenum and a time = 0 indicates that all the data at that index is 0 as well. These are found and deleted. The result is the L0 tier of data.
	
The final data has had pre and post-deployment data, faulty pressure measurements and extra fields removed from the data set. QC has also been applied to the data and a depth field and four-beam averaged beam intensity fields have been added. L1 data will include fields

config: configuration settings of ADCP 
mttime: time in matlab datenumber 
temperature: temperature in degrees celsius 
pressure: pressure in decibars 
east_vel: east velocity in m/s with a flow to the east being positive
north_vel: north velocity in m/s with a flow to the north being positive
mean_depth: mean depth of ADCP in meters calculated from the pressure 
EA_avg: the four beam average echo intensity (or echo amplitude) in decibels
depth_ea: a conservative estimate of the sea-surface using the echo intensity

The pre and post-deployment data are found and removed using several methods. The first method is by looking for depth less than 5m but whose mean depth is greater than the deployed depth-5m. This would correspond to the data while the ADCP is being deployed or while it is being retrieved. These intervals vary but tend to be every few months. The mean must be greater than the deployed depth-5m because a failing pressure sensor could read any value as it drifts over time. That means the entire data set would be thrown out if say the sensor was reading 3m the whole time. So we check that the pressure sensor is recording a depth that is somewhat close to the actual depth before screening the values that correspond to a less than 5m depth. The second method for finding the pre and post-deployment data is looking for an echo intensity less than 90 at the surface. The surface is determined by the user’s input of expected sea surface distance from the transducer. The sea surface  will result in the highest values for echo intensity. A low echo intensity here most likely indicates the ADCP is pinging in air and not water, and the echo intensity will be lower in air than water. 90 decibels  was chosen as a threshold as this is significantly below the average for the surface.
The next step is to manually determine the pre and post deployment data. This is done by manually looking at some data. Section 4 of the ADCP_Processing code will create an image with the instruments heading for the first 10 ensembles and last 10 ensembles. If the heading appears to be unstable near the beginning or end of the time series the data is screened. The echo intensity is also screened in a similar manner for the beginning and end of the time series.
Although we screened some pressure at the beginning, there could still be erroneous pressure data due to a failing or compromised pressure sensor. The pressure data is plotted and checked for validity, if the pressure data appears to be wrong or drifting over a deployment, it will be deleted from the data set. After this step the pre and post deployment data should be completely screened and we are now ready to apply the QC measures.
Three QC tests are applied to the data. These QC tests are a velocity error test, a correlation magnitude test and an echo intensity test. These tests were recommended by documentation provided by Quality Assurance/Control of Real Time Oceanographic Data (QARTOD). Since ADCP_Processing was created for  non real time moorings, not all tests are applicable. A presentation on QC of ADCP by Australia’s Commonwealth Scientific and Industrial Research Organization (CSIRO) was also helpful in developing these QC tests. The thresholds for these tests will vary depending on the region the ADCP is deployed.
The velocity error test screens any data that has an error velocity greater than the threshold the user inputs. This value should keep the majority of values in the water column and screen ~75% of the values above the surface, which we know are bad. Because multiple QC tests were being implemented we could use a less stringent threshold and try to keep as many good values as possible. The second test is a correlation magnitude test. The threshold used for the correlation magnitude test is determined by the user. This threshold should screen about 80% at the surface boundary and approach 100% the farther above the surface you go. The final QC test uses echo intensity. The echo intensity for each beam is used and the difference between bins is determined. If the echo intensity increases by more than the user-determined threshold  between bins, all the data above that point is screened. This dhpi;d result in nearly 100% of the data being screened at the surface and above. This test is not applied to the bottom half of the water column. This is to prevent good data near the bottom from being screened. Sediment in the lower level of the water column can cause a sudden increase in echo amplitude. When all three tests are applied we get a good data set with erroneous data removed.



A new field called ‘depth_ea’ is calculated. This field is a conservative estimate of the surface. It is determined by finding the mean depth at which the echo intensity threshold increase happens across the time series. We found this approach to be 1-2m below the surface as determined by pressure. The depth-ea field is useful for when the pressure data (thus the depth data) is non-existent or faulty. The mean depth from pressure or echo intensity is used in the final step to screen any values above the surface that may have passed by the QC tests.
Some other fields are added to the data. These include depth calculated from the pressure using h = pressure*10/(1026*9.81). A four beam average of the echo intensity is also calculated and added.
