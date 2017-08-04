function varargout=errormeshplot(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,SVID,lat,lon,height,spacing,delta,az,el,OutputFile)
% varargout = weatherplot(PVTSatFile,MeasEpochFile,HGTFile,SVID,lat,lon,height,spacing,delta,OutputFile)
%  
% Generates a mesh plot of spacing by spacing dimensions of the simulated
% uncorrected pseudorange error at different lat/lon values around the 
% fixed lat/lon value given on input (this will be the top mesh plot).
% In addition, it also plots a corrected pseudorange plot (corrected for
% clock bias, tropospheric and ionospheric delays). This will be the
% lower mesh plot. 
% 
% The user needs the 'defval' function from Frederik J. Simons' Slepian
% github repository, and the 'lla2ecef' function to convert from lat, lon, 
% and altitude to earth-centered, earth fixed (ECEF) cartesian coordinates.
% Also, the user needs the functions 'timeconv' and 'gnss_datevec' from my
% 'PEI2017-jtralie' github repository. This is to generate a title that 
% includes the date. Lastly, the user needs the plot_google_map function
% available on the MathWorks website from Zohar Bar-Yehuda. This plots
% a map from Google Earth of the region on the xy-plane of the figure. 
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
% az                 Defines the azimuth viewing angle
%
% el                 Defines the elevation viewing angle 
%
% OutputFile         The outputted filename
%
% OUTPUT:
%
% A mesh plot of simulated uncorrected and corrected error at different 
% latitudes and longitudes for the pseudorange of an inputted satellite. 
%
%
%
% Last modified by jtralie@princeton.edu on 08/04/2017

% default values for the function 
defval('lat',40.345811675440125); % Guyot Hall fixed latitude (degrees)
defval('lon',-74.654736944340939); % Guyot Hall fixed longitude (degrees) 
defval('height',46.692); % Guyot Hall fixed height (meters)
defval('spacing',5); 
defval('az',-43);
defval('el',38);

% setup a meshgrid spaced at the given delta value that is spacing by
% spacing in dimension 
[latvalues,lonvalues] = meshgrid(linspace(lat - delta,lat + delta,spacing),linspace(lon-delta,lon+delta,spacing));
formatSpec = '%f%f%f%C%f%f%f%f%f%f%f%f%f%f%C%[^\n\r]';
fileID = fopen(PVTSatFile,'r');
delimiter = ','; 
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
TOW = dataArray{:, 1};
WN = dataArray{:, 2};
gnss = timeconv(WN,TOW);
gnssdatevec = gnss_datevec(gnss);

% send data to the prerror function to calculate err and corerr
err = [];
[a,b] = size(latvalues);
index = a*b; 
for i = 1:index  
    [err{i},corerr{i}] = prerror(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,SVID,latvalues(i),lonvalues(i),height);
end

% obtain the average values for error and corrected error 
for j = 1:length(err)
    error = err{j};
    corerror = corerr{j};
    ind = isnan(error);
    ind = ind ~= 1;
    avgerr(j) = mean(error(ind));
    avgcor(j) = mean(corerror(ind)); 
end

% plotting
f = figure; 
pointsize = 15; 
lonout = lonvalues(:)';
latout = latvalues(:)';
%a = scatter(lonout,latout,pointsize,avgerr,'filled')
v = griddata(lonout,latout,avgerr,lonvalues,latvalues);
w = griddata(lonout,latout,avgcor,lonvalues,latvalues); 
a=mesh(lonvalues,latvalues,v);
set(a,'facecolor','none') 
hold on
plot3(lonout,latout,avgerr,'.')
hold on
plot(lon,lat,'r*')
hold on
b=mesh(lonvalues,latvalues,w);
set(b,'facecolor','none')
hold on
plot3(lonout,latout,avgcor,'.')
hold on
plot_google_map
hold off 
text(lon,lat,'(Fixed)')
h = colorbar;
ylabel(h,'Pseudorange Error (%)')
xlabel('Longitude (Degrees)')
ylabel('Latitude (Degrees)')
zlabel('Pseudorange Error (%)')
xlim([(lon-delta) (lon+delta)])
ylim([(lat-delta) (lat+delta)])
zlim([0 1])
title([SVID ' Uncorrected/Corrected Pseudorange Error for Varying Lat/Lon - ' num2str(gnssdatevec(1,2)) '/' num2str(gnssdatevec(1,3))])
colormap('hot')
caxis([0 1]) 
view(az,el)
hold off
grid on
print(f,OutputFile,'-dpdf','-fillpage','-r0')
