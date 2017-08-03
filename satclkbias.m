function [satclkbias]=satclkbias(GPSNavFile,SVID)
% [satclkbias] = satclkbias(GPSNavFile,SVID)
% 
% Reads out the satellite clock bias for a given SVID in a specified
% GPSNav file (converted SBF to ASCII using bin2asc)
%
% INPUT:
%
% GPSNavFile          The GPSNav file returned from a bin2asc
%                     conversion of SBF files
% 
% SVID                The SVID for which the satellite clock bias will be
%                     obtained
% 
% OUTPUT:
%
% satlckbias          The satellite clock bias (s) for a given SVID 
%
% EXAMPLE:
% Complete a bin2asc conversion on an SBF file to retrieve a
% GPSNav. Below is an example file
% returned when I converted a file pton1900.17_ from SBF to ASCII using
% bin2asc: 
% GPSNav = 'pton1900.17__SBF_GPSNav.txt';
% I have included this file in my github repository 'PEI2017-jtralie' for use and
% demo purposes. 
% 
% Last modified by jtralie@princeton.edu on 08/03/2017
formatSpecGPS = '%s%s%C%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
fileID1 = fopen(GPSNavFile,'r');
delimiter = ',';
dataArray1 = textscan(fileID1, formatSpecGPS, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID1);
sv = dataArray1{:,3};
clockerr = dataArray1{:,17}; 
svind = sv == SVID; 
satclkbias = mean(str2num(char(clockerr(svind))));