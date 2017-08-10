function [correctederror,minlat,minlon,time]=errormesh(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,SVID,lat,lon,height,spacing,delta)
% varargout = weatherplot(PVTSatFile,MeasEpochFile,HGTFile,SVID,lat,lon,height,spacing,delta,OutputFile)
%  
% Finds the minimum latitude/longitude of
% a mesh plot of spacing by spacing dimensions of the simulated
% uncorrected pseudorange error at different lat/lon values around the 
% fixed lat/lon value given on input.

% The user needs the 'defval' function from Frederik J. Simons' Slepian
% github repository, and the 'lla2ecef' function to convert from lat, lon, 
% and altitude to earth-centered, earth fixed (ECEF) cartesian coordinates.
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
%
% OUTPUT:
%
% Finds the latitude and longitude where the error of a mesh of simulated 
% corrected error at different latitudes and longitudes for the pseudorange 
% of an inputted satellite is minimized.  
%
%
% Last modified by jtralie@princeton.edu on 08/10/2017
defval('lat',40.345811675440125); % Guyot Hall fixed latitude (degrees)
defval('lon',-74.654736944340939); % Guyot Hall fixed longitude (degrees) 
defval('height',46.692); % Guyot Hall fixed height (meters)
defval('spacing',5); 

[latvalues,lonvalues] = meshgrid(linspace(lat - delta,lat + delta,spacing),linspace(lon-delta,lon+delta,spacing));
formatSpec = '%f%f%f%C%f%f%f%f%f%f%f%f%f%f%C%[^\n\r]';
fileID = fopen(PVTSatFile,'r');
delimiter = ','; 
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
TOW = dataArray{:, 1};
WN = dataArray{:, 2};
gnss = timeconv(WN,TOW);
time = gnss_datevec(gnss);

err = [];
[a,b] = size(latvalues);
index = a*b; 
for i = 1:index  
    [err{i},corerr{i}] = prerror(PVTSatFile,MeasEpochFile,GPSNavFile,PVTGeoFile,SVID,latvalues(i),lonvalues(i),height);
end

%
for j = 1:length(err)
    error = err{j};
    corerror = corerr{j};
    ind = isnan(error);
    ind = ind ~= 1;
    avgcor(j) = mean(corerror(ind)); 
end

lonout = lonvalues(:)';
latout = latvalues(:)';
correctederror = griddata(lonout,latout,avgcor,lonvalues,latvalues); 
correctederror = correctederror(:);
[M,I] = min(correctederror);
latitude = latvalues(:);
longitude = lonvalues(:);
minlat = latitude(I);
minlon = longitude(I); 
