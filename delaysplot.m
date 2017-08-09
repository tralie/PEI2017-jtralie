function varargout = delaysplot(PVTSatFileName,SVID,lat,lon,alt,OutputFileName)
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
% OutputFileName     The name that will be given to the outputted file. 
%                                     
% OUTPUT:
%
% A plot of the tropospheric and ionospheric delays for a given SV and
% a quiver plot of the SV
%
% OTHER FUNCTIONS REQUIRED:
% This relies on 'timeconv' and 'gnss_datevec' (which are both located in my
% PEI-2017 github repository). In addition, this makes use of 
% the earth_sphere function (available on the Mathworks website) and
% the defval function available from Frederik Simons' github repository. 
% I have also included a sample PVTSatCartesian
% file to demonstrate this function - it is located in my PEI-2017 github
% repository under the name 'pton1900.17__SBF_PVTSatCartesian.txt'. 
%
% Last modified by jtralie@princeton.edu on 08/09/2017
%
% data format setup/import 
defval('lat',40.345811675440125) % Guyot latitude
defval('lon',-74.654736944340939) % Guyot longitude
defval('alt',46.692) % Guyot altitude (meters)
delimiter = ',';
formatSpecSat = '%f%f%f%C%f%f%f%f%f%f%f%f%f%f%C%[^\n\r]';
startRow = 1;
fileID = fopen(PVTSatFileName,'r');
dataArray = textscan(fileID, formatSpecSat, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);


% Allocate imported array to column variable names
TOW = dataArray{:, 1}; % Time of week (seconds) since Sunday of week
WN = dataArray{:,2}; % week number since Jan 6, 1980 
SV = dataArray{:,4}; % Space vehicle I.D.
px = dataArray{:, 7}/1000; %convert positions to km
py = dataArray{:, 8}/1000; % to km
pz = dataArray{:, 9}/1000; % to km
vx = dataArray{:,10};
vy = dataArray{:,11};
vz = dataArray{:,12};
trop = dataArray{:, 13}; % tropospheric delay (m)
ion = dataArray{:, 14}; % ionospheric delay (m)

% Find parts of array that correspond to input SVID
tropfinal = trop(SV == SVID);
ionfinal = ion(SV == SVID); 
pxfinal = px(SV == SVID);
pyfinal = py(SV == SVID);
pzfinal = pz(SV == SVID);
vxfinal = vx(SV == SVID);
vyfinal = vy(SV == SVID);
vzfinal = vz(SV == SVID);
wnfinal = WN(SV == SVID); 
towfinal = TOW(SV == SVID);
time = timeconv(wnfinal,towfinal);
gnss = gnss_datevec(time);
time = datenum(gnss); 

% Convert latitude/longitude to radians for lla2ecef function
lat_rad = deg2rad(lat);
lon_rad = deg2rad(lon);
[rX, rY, rZ] = lla2ecef(lat_rad,lon_rad,alt); % convert from radians
% to degrees. This conversion requires the user have the function 'lla2ecef' 
rX=rX/1000; % convert to km 
rY=rY/1000; % km 
rZ=rZ/1000; % km

h = figure;
subplot(1,2,1)
xlim([min(TOW) max(TOW)])
title(['Tropospheric and Ionospheric Delay for ' SVID ' ' num2str(gnss(1,2)) '/' num2str(gnss(1,3))])
yyaxis left
plot(time,tropfinal,'b.')
ylabel('Tropospheric Delay (m)')
yyaxis right
plot(time,ionfinal,'r.')
ylabel('Ionospheric Delay (m)')
datetick('x','HH:MM')
grid on
subplot(1,2,2)
earth_sphere
hold on
quiver3(pxfinal,pyfinal,pzfinal,vxfinal,vyfinal,vzfinal)
hold on
plot3(rX,rY,rZ,'r*')
grid on
title(['Satellite Tracks for ' SVID])
text(pxfinal(1),pyfinal(1),pzfinal(1),'Start')
text(pxfinal(end),pyfinal(end),pzfinal(end),'End')
set(h,'PaperOrientation','landscape');
set(gcf,'Position',[500 300 900 340])
print(h,OutputFileName,'-bestfit','-dpdf','-r0')


    
