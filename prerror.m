function [err,corerr] = prerror(PVTSatFileName,MeasEpochFileName,GPSNavFileName,SVID,lat,lon,alt)
% [err] = prerror(PVTSatFileName,MeasEpochFileName,GPSNavFileName,SVID,lat,lon,alt)
% 
% Calculation of the error between the pseudorange and the geometric
% distance of a satellite to a fixed reference point.
% Requires the function 'lla2ecef' to convert from lat, lon, and altitude
% to earth-centered, earth fixed (ECEF) cartesian coordinates. Also,
% the user needs the function 'defval' from Frederik J. Simons' slepian
% github repository. 
%
% INPUT:
%
% PVTSatFileName     The PVTSatCartesian file returned from a bin2asc
%                     conversion of SBF files
% 
% MeasEpochFileName  The MeasEpoch2 file returned from a bin2asc conversion
%                    of SBF files
%
% GPSNavFileName      The GPSNav file returned from a bin2asc
%                     conversion of SBF files
%
% SVID               The Space Vehicle Identification of the satellite
%                    for which the error will be calculated. 
%
% lat                The fixed latitude coordinate (degrees)
%
% lon                The fixed longitude coordinate (degrees)
%
% alt                The fixed altitude coordinate (meters)
%
% OUTPUT:
%
% err                The uncorrected 
%                    pseudorange error for each hour of the day. At some
%                    hours, the satellite may not be visible to the receiver. 
%                    In this case, that error element will be 'NaN'. 
%
% corerr             The corrected (for just satellite clock bias)
%                    pseudorange error for each hour of the day. At some
%                    hours, the satellite may not be visible to the
%                    receiver. In this case, that error element will be
%                    'NaN'. 
%
%
% EXAMPLE:
% Complete a bin2asc conversion on an SBF file to retrieve a
% PVTSatCartesian and MeasEpoch2 file. Below are two examples files
% returned when I converted a file pton1900.17_ from SBF to ASCII using
% bin2asc: 
% PVTSatFileName = 'pton1900.17__SBF_PVTSatCartesian.txt';
% MeasEpochFileName = 'pton1900.17__SBF_MeasEpoch2.txt';
% GPSNavFileName = 'pton1900.17__SBF_GPSNav.txt';
%
% These files can be given to the prerror function along with a 
% SVID # for the satellite you wish to calculate the pseudorange error for.
% 
% Let's choose GPS satellite, 'G05'. 
% Using the above file parameters:
% 
% [err,corerr] = prerror(PVTSatFileName,MeasEpochFileName,GPSNavFileName,'G05',[],[],[])
%
% RETURNS:
% 24 column matrix consisting of the calculated error when the satellite
% is visible. For this example, columns 1:4 and 22:24 contain values for 
% the pseudorange error (thus, satellite 'G05' would be visible to the
% receiver at these hours). For all other columns, prerror returns 'NaN'
% since the satellite is not visible to the receiver. 
% It also returns a 24 column matrix consisting of the corrected error
% which follows a similar behavior to the above mentioned error matrix. 
% 
% Last modified by jtralie@princeton.edu on 08/03/2017

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
formatSpecMeas = '%f%f%C%C%C%C%C%C%f%C%f%C%C%f%C%C%C%f%f%f%f%[^\n\r]';
fileID1 = fopen(MeasEpochFileName,'r');
dataArray1 = textscan(fileID1, formatSpecMeas, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID1);

% Allocate imported array to column variable names
TOW = dataArray{:, 1}; % Time of week (seconds) since Sunday of week
SV = dataArray{:,4}; % Space vehicle I.D.
px = dataArray{:, 7}/1000; %convert positions to km
py = dataArray{:, 8}/1000; % to km
pz = dataArray{:, 9}/1000; % to km
trop = dataArray{:, 13}; % tropospheric delay (m)
ion = dataArray{:, 14}; % ionospheric delay (m)

TOWs_Meas = dataArray1{:, 1}; % TOW for the MeasEpoch file
SVID_Meas = dataArray1{:,10}; % SVID for MeasEpoch file
PR_mm = dataArray1{:, 19}/1000; % Pseudorange (converted from m to km)

c = 299792458; % speed of light in a vacuum (m/s)

% Convert latitude/longitude to radians for lla2ecef function
lat_rad = deg2rad(lat);
lon_rad = deg2rad(lon);

[rX, rY, rZ] = lla2ecef(lat_rad,lon_rad,alt); % convert from radians
% to degrees. This conversion requires the user have the function 'lla2ecef' 
rX=rX/1000; % convert to km 
rY=rY/1000; % km 
rZ=rZ/1000; % km

% geometric distance calculation
% direct distance between satellite and (rX,rY,rZ)
r = sqrt((px-rX).^2 + (py-rY).^2 + (pz-rZ).^2);
tdat = linspace(TOW(1),TOW(end)-3585,24); % space times at 1 hour increments

% find values that occur at each hour on the hour
pxc=[];pyc=[];pzc=[];
for i=1:length(tdat)
    T = TOW == tdat(i);
    for j = 1:length(T)
        if T(j) == 1
            pxc(j) = px(j);
            pyc(j) = py(j);
            pzc(j) = pz(j);
            rc(j) = r(j);
            tropc(j) = trop(j);
            ionc(j) = ion(j);
            svidc(j) = SV(j);
        end
    end
end

for i =1:length(tdat)
    in1 = find(pxc ~= 0,1,'first');
    in2 = find(pxc == 0,1,'first');
    if i == 24
        svr{24} = svidc(in1:end);
        rfinal{24} = rc(in1:end);
        tropfinal{24} = tropc(in1:end);
        ionfinal{24} = ionc(in1:end);
    else
        svr{i} = svidc(in1:in2-1);
        rfinal{i} = rc(in1:in2-1);
        tropfinal{i} = tropc(in1:in2-1);
        ionfinal{i} = ionc(in1:in2-1);
    end
    pxc = pxc(:,in2:end);
    rc = rc(in2:end);
    tropc = tropc(in2:end);
    ionc = ionc(in2:end);
    svidc = svidc(in2:end);
    in3 = find(pxc ~= 0,1,'first');
    rc = rc(in3:end);
    tropc = tropc(in3:end);
    ionc = ionc(in3:end);
    svidc = svidc(in3:end);
    pxc = pxc(:,in3:end);
end

% pseudorange importing/assignment
for i=1:length(tdat)
    T = TOWs_Meas == tdat(i);
    for j = 1:length(T)
        if T(j) == 1
            PRc(j) = PR_mm(j);
            SVID_Measc(j) = SVID_Meas(j);
        end
    end
end

%clean the PR and SVID arrays to separate hourly cells
for i =1:length(tdat)
    in1 = find(PRc ~= 0,1,'first');
    in2 = find(PRc == 0,1,'first');
    if i == 24
        PRfinal{24} = PRc(in1:end);
        SVIDfinal{24} = SVID_Measc(in1:end);
    else
        PRfinal{i} = PRc(in1:in2-1);
        SVIDfinal{i} = SVID_Measc(in1:in2-1);
    end
    PRc = PRc(in2:end);
    SVID_Measc = SVID_Measc(in2:end);
    in3 = find(PRc ~= 0,1,'first');
    PRc = PRc(in3:end);
    SVID_Measc = SVID_Measc(in3:end);
end

% pseudorange/position matching up
rad1 = [];
prg1 = [];
trop1 = [];
for j = 1:length(tdat)
    SVID1 = SVIDfinal{j};
    PR1 = PRfinal{j};
    svr1 = svr{j}; 
    r1 = rfinal{j};
    tropo = tropfinal{j};
    for i = 1:length(SVID1)
        prg1{j} = mean(PR1(SVID1==SVID));
    end
    for i = 1:length(svr1) 
        trop1{j} = tropo(svr1==SVID);
        rad1{j} = mean(r1(svr1==SVID));
    end
end

satclk = satclkbias(GPSNavFileName,SVID); 
% absolute value error calculation 
err = abs(100*(cell2mat(prg1) - cell2mat(rad1))./cell2mat(rad1));
corerr = abs(100*((cell2mat(prg1)*1000) - (cell2mat(rad1)*1000) + c*(satclk))./(cell2mat(rad1)*1000));
% Clear temporary variables
clearvars PVTSat delimiter formatSpec fileID dataArray ans;