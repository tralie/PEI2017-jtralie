function [rclk] = rclkbias(PVTGeoFileName)
PVTGeoFileName = 'E:\Princeton\Sophomore\Internships\PEI\PVTSatCartesian\pton1900.17__SBF_PVTGeodetic2.txt';
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