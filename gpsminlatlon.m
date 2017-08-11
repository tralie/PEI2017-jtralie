function [latmin,lonmin,distance] = gpsminlatlon(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,lat,lon,height,spacing,delta,OutputFileName) 
% varargout = weatherplot(ASCIIIfiles,OutputFileName,Title)
% 
% Plots a 5 subplot figure consisting of integrated water vapor,
% temperature, pressure, relative humidity, and rain. These plots are
% created from inputted ASCIIIn data (files outputted from a bin2asc
% conversion of SBF files). 
% Also, the user needs the functions 'timeconv' and 'gnss_datevec' from my
% 'PEI2017-jtralie' github repository. 
%
% INPUT:
%
% PVTSatFileName     The PVTSatCartesian file returned from a bin2asc
%                     conversion of SBF files
%
% MeasEpochFile      The MeasEpoch2 file returned from a bin2asc conversion
%                    of SBF files
%
% GPSNavFile          The GPSNav file returned from a bin2asc
%                     conversion of SBF files
%
% PVTGeoFile         The PVTGeodetic2 file returned from a bin2asc
%                    conversion
%         
% SVID               The Space Vehicle Identification of the satellite
%                    for which the error mesh plot will be generated.  
%
% lat                The fixed latitude about which other
%                    latitudes will be simulated 
%
% lon                The fixed longitude about which other longitudes will
%                    will be simulated
% 
% height             The fixed height used in the prerror calculation.
%
% spacing            The outputted mesh will have dimensions
%                    spacing*spacing. For example, if the user inputs 5, 
%                    the resultant mesh will have 25 points and be a 5 by 5
%                    square.
%
% delta              The distance between points (in degrees)
%
% OutputFileName     The name that will be given to the outputted file. 
%                                     
% OUTPUT:
%
% A plot of the fixed lat and lon position and of the average minimum
% lat and lon position (with a line connecting the two that displays the
% distance in degrees between the two points). This function also returns
% the minimum lat and lon coordinates as well as the distance of offset
% between the average min lat/lon and the fixed lat/lon
%
% OTHER FUNCTIONS REQUIRED:
% This relies on 'timeconv' and 'gnss_datevec' (which are both located in my
% PEI-2017 github repository). 
% I have also included a sample PVTSatCartesian
% file to demonstrate this function - it is located in my PEI-2017 github
% repository under the name 'pton1900.17__SBF_PVTSatCartesian.txt'. 
%
% Last modified by jtralie@princeton.edu on 08/10/2017
%
% data format setup/import 

defval('lat',40.345811675440125); % Guyot Hall fixed latitude (degrees)
defval('lon',-74.654736944340939); % Guyot Hall fixed longitude (degrees) 
defval('height',46.692); % Guyot Hall fixed height (meters)
defval('spacing',3); 
defval('delta',.000001);

[correctedg1,lat1,lon1,time1]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G01',lat,lon,height,spacing,delta);
[correctedg2,lat2,lon2,time2]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G02',lat,lon,height,spacing,delta);
[correctedg3,lat3,lon3,time3]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G03',lat,lon,height,spacing,delta);
[correctedg4,lat4,lon4,time4]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G04',lat,lon,height,spacing,delta);
[correctedg5,lat5,lon5,time5]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G05',lat,lon,height,spacing,delta);
[correctedg6,lat6,lon6,time6]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G06',lat,lon,height,spacing,delta);
[correctedg7,lat7,lon7,time7]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G07',lat,lon,height,spacing,delta);
[correctedg8,lat8,lon8,time8]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G08',lat,lon,height,spacing,delta);
[correctedg9,lat9,lon9,time9]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G09',lat,lon,height,spacing,delta);
[correctedg10,lat10,lon10,time10]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G10',lat,lon,height,spacing,delta);
[correctedg11,lat11,lon11,time11]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G11',lat,lon,height,spacing,delta);
[correctedg12,lat12,lon12,time12]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G12',lat,lon,height,spacing,delta);
[correctedg13,lat13,lon13,time13]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G13',lat,lon,height,spacing,delta);
[correctedg14,lat14,lon14,time14]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G14',lat,lon,height,spacing,delta);
[correctedg15,lat15,lon15,time15]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G15',lat,lon,height,spacing,delta);
[correctedg16,lat16,lon16,time16]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G16',lat,lon,height,spacing,delta);
[correctedg17,lat17,lon17,time17]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G17',lat,lon,height,spacing,delta);
[correctedg18,lat18,lon18,time18]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G18',lat,lon,height,spacing,delta);
[correctedg19,lat19,lon19,time19]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G19',lat,lon,height,spacing,delta);
[correctedg20,lat20,lon20,time20]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G20',lat,lon,height,spacing,delta);
[correctedg21,lat21,lon21,time21]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G21',lat,lon,height,spacing,delta);
[correctedg22,lat22,lon22,time22]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G22',lat,lon,height,spacing,delta);
[correctedg23,lat23,lon23,time23]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G23',lat,lon,height,spacing,delta);
[correctedg24,lat24,lon24,time24]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G24',lat,lon,height,spacing,delta);
[correctedg25,lat25,lon25,time25]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G25',lat,lon,height,spacing,delta);
[correctedg26,lat26,lon26,time26]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G26',lat,lon,height,spacing,delta);
[correctedg27,lat27,lon27,time27]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G27',lat,lon,height,spacing,delta);
[correctedg28,lat28,lon28,time28]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G28',lat,lon,height,spacing,delta);
[correctedg29,lat29,lon29,time29]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G29',lat,lon,height,spacing,delta);
[correctedg30,lat30,lon30,time30]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,'G30',lat,lon,height,spacing,delta);
lats = [lat1 lat2 lat3 lat4 lat5 lat6 lat7 lat8 lat9 lat10 lat11 lat12 lat13 lat14 lat15 lat16 lat17 lat18 lat19 lat20 lat21 lat22 lat23 lat24 lat25 lat26 lat27 lat28 lat29 lat30];
lons = [lon1 lon2 lon3 lon4 lon5 lon6 lon7 lon8 lon9 lon10 lon11 lon12 lon13 lon14 lon15 lon16 lon17 lon18 lon19 lon20 lon21 lon22 lon23 lon24 lon25 lon26 lon27 lon28 lon29 lon30];
latmin = mean(lats);
lonmin = mean(lons);
distance = sqrt((lonmin-lon)^2 + (latmin-lat)^2); 
% plotting
h=figure;
plot(lonmin,latmin,'b*'); hold on; plot(lon,lat,'r*'); 
hold on; line([lonmin lon],[latmin lat]);
text(lonmin,latmin,['Distance = ' num2str(sqrt((lonmin-lon)^2 + (latmin-lat)^2))])
xlim([(lon - delta-delta/2) (lon + delta+delta/2)])
ylim([(lat - delta-delta/2) (lat + delta+delta/2)])
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)') 
grid on; 
text(lon,lat,'Fixed')
title(['Min Lat: ' num2str(latmin) ' Min Lon: ' num2str(lonmin) ' on ' num2str(time1(1,2)) '/' num2str(time1(1,3))])
print(h,OutputFileName,'-bestfit','-dpdf','-r0')

