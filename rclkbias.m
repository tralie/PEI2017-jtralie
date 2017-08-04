function [rclk] = rclkbias(PVTGeoFileName)
% [rclk] = rclkbias(PVTGeoFileName)
% 
% Reads out the receiver clock bias at 1 hour increments in a specified
% PVTGeodetic2 file (converted SBF to ASCII using bin2asc)
%
% INPUT:
%
% PVTGeoFileName      The PVTGeodetic2 file returned from a bin2asc
%                     conversion of SBF files
%
% OUTPUT:
%
% rclk                The receiver clock bias (s) for a given PVTGeodetic2 file 
%
% EXAMPLE:
% Complete a bin2asc conversion on an SBF file to retrieve a
% PVTGeodetic2 file. Below is an example file
% returned when I converted a file pton1900.17_ from SBF to ASCII using
% bin2asc: 
% PVTGeoFileName = 'pton1900.17__SBF_PVTGeodetic2.txt';
% I have included this file in my github repository 'PEI2017-jtralie' for use and
% demo purposes. 
% 
% Last modified by jtralie@princeton.edu on 08/04/2017
delimiter = ',';
formatSpec = '%f%s%s%s%s%s%s%s%s%s%s%s%s%s%f%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(PVTGeoFileName,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
tow = dataArray{:,1};
recclk = dataArray{:,15}/1000; % convert ms to s
tdat = linspace(tow(1),tow(end)-3585,24);
for i = 1:length(tdat)
    towindex = tow == tdat(i); 
    rclk(i) = recclk(towindex); 
end