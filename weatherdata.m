function [time,Tas,Pas,Uas,Sms,Dms,Rcs,Hcs]=weatherdata(ASCIIIfiles)
% varargout = weatherplot(ASCIIIfiles,OutputFileName,Title)
% 
% Reads out the weather data and time values for given ASCIIIn files
% (which can be converted from SBF using a bin2asc conversion method).
% Also, the user needs the functions 'timeconv' and 'gnss_datevec' from my
% 'PEI2017-jtralie' github repository. 
%
% INPUT:
%
% ASCIIIfiles         The ASCIIIn files (containing weather data) outputted
%                     from a bin2asc conversion of SBF files. This function
%                     handles any number of ASCIIIn files. 
%                     
%                    
% OUTPUT:
% 
% time                The time of the data (in datetime values). If you
%                     will be plotting this data, you can use the datetick
%                     function to get the time into a readable date format.
%                     For example datetick('x','mm/dd') will change the
%                     time axis into month/day format. 
%
% Tas                 Temperature values (celsius)
%
% Pas                 Pressure values (bars)
%
% Uas                 Relative Humidity (%)
%
% Sms                 Wind speed (m/s)
%
% Dms                 Wind direction (degrees C) 
%
% Rcs                 Rain quantity (mm/sampling period)
%
% Hcs                 Hail quantity (hits/sampling period) 
%
% OTHER FUNCTIONS REQUIRED:
% This relies on 'timeconv' and 'gnss_datevec' (which are both located in my
% PEI-2017 github repository). 
% I have also included a sample weather
% file to demonstrate this function - it is located in my PEI-2017 github
% repository under the name 'pton2040.17__SBF_ASCIIIn.txt'. 
%
% Last modified by jtralie@princeton.edu on 08/04/2017

% Initialize variables.
wfiles = dir(ASCIIIfiles);
wcell = {wfiles.name};
delimiter = ',';

formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

Dms = [];
Sms = [];
Tas = [];
Uas = [];
Pas = [];
Rcs = [];
Hcs = [];
timeweeks = [];
weeknums = [];
es = [];

for i=1:length(wcell)
    %% Open the text file.
    fileID = fopen(wcell{i},'r');
    
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
    fclose(fileID);
    
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));
    
    for col=[1,2,3,4,5,6,7,8,9,10,11,12]
        % Converts text in the input cell array to numbers. Replaced non-numeric
        % text with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1)
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData(row), regexstr, 'names');
                numbers = result.numbers;
                
                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if numbers.contains(',')
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'))
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric text to numbers.
                if ~invalidThousandsSeparator
                    numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch
                raw{row, col} = rawData{row};
            end
        end
    end
    
    
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells
    
    pton = cell2mat(raw);
    diffpton = 1440 - length(pton);
    %need to make the arrays equal each other
    %there are several missing data points, so append NaNs to get files
    %equal to each other for cell2mat conversion. 
    if (diffpton > 0)
        pton(end+diffpton,:) = NaN;
        for j = 1:length(diffpton)
            pton(end-j,:) = NaN;
        end 
        timeweeks{i} = pton(:,1);
        weeknums{i} = pton(:,2); 
        
        Dms{i} = pton(:, 6); %wind direction (degrees)
        Sms{i} = pton(:, 7); %wind speed (m/s)
        Tas{i} = pton(:, 8); %temperature (degree C)
        Uas{i} = pton(:, 9); %humidity (percent)
        Pas{i} = pton(:, 10); %barometric pressure (bar)
        Rcs{i} = pton(:, 11); %rainfall (mm/sampling period)
        Hcs{i} = pton(:, 12); %hail (hits/sampling period)
    else 
        timeweeks{i} = pton(:,1); 
        weeknums{i} = pton(:,2);
        
        Dms{i} = pton(:, 6); %wind direction (degrees)
        Sms{i} = pton(:, 7); %wind speed (m/s)
        Tas{i} = pton(:, 8); %temperature (degree C)
        Uas{i} = pton(:, 9); %humidity (percent)
        Pas{i} = pton(:, 10); %barometric pressure (bar)
        Rcs{i} = pton(:, 11); %rainfall (mm/sampling period)
        Hcs{i} = pton(:, 12); %hail (hits/sampling period)
    end 

end 
%
%convert to doubles from cell arrays 
timeweeks = cell2mat(timeweeks);
weeknums = cell2mat(weeknums);
Dms = cell2mat(Dms);
Sms = cell2mat(Sms);
Tas = cell2mat(Tas);
Uas = cell2mat(Uas);
Pas = cell2mat(Pas);
Rcs = cell2mat(Rcs);
Hcs = cell2mat(Hcs);
[m,n] = size(Tas);

%time conversion
gnss = timeconv(weeknums,timeweeks);
datevec = gnss_datevec(gnss);
date = datenum(datevec); 
%flip time array to get it back into the same format as weather data files
timeflip = date';
time = reshape(timeflip,[1440,n]); 



