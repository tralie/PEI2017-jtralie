function varargout=weatherplot(ASCIIIfiles,OutputFileName,Title)
% varargout = weatherplot(ASCIIIfiles,OutputFileName,Title)
% 
% Plots a 5 subplot figure consisting of integrated water vapor,
% temperature, pressure, relative humidity, and rain. These plots are
% created from inputted ASCIIIn data (files outputted from a bin2asc
% conversion of SBF files). 
% Also, the user needs the functions 'timeconv' and 'gnss_datevec' from my
% 'PEI-2017' github repository. 
%
% INPUT:
%
% ASCIIIfiles         The ASCIIIn files (containing weather data) outputted
%                     from a bin2asc conversion of SBF files. This function
%                     handles any number of ASCIIIn files. 
%                     
% 
% OutputFileName     The name that will be given to the outputted file. 
%                    
%
% Title              The plot title
%                    
% OUTPUT:
%
% A plot of weather data from the ASCIIIn file(s). 
% Plots 5 subplots - IWV, temperature, pressure, relative humidity, and
% rainfall. The exported figure is a .pdf of all 5 subplots with the
% inputted title and under the inputted filename. 
%
% OTHER FUNCTIONS REQUIRED:
% This relies on 'timeconv' and 'gnss_datevec' (which are both located in my
% PEI-2017 github repository). In addition, this makes use of 
% Frederik J. Simons' title making function 'supertit' which is located
% in his Slepian github repository. I have also included a sample weather
% file to demonstrate this function - it is located in my PEI-2017 github
% repository under the name 'pton2040.17__SBF_ASCIIIn.txt'. 
%
% Last modified by jtralie@princeton.edu on 08/02/2017

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
%%
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

%% calculations
es = 6.11*10.^((7.5.*Tas)./(237.3+Tas)); 

lat_rad = 0.704167253126;

ZTD = 0.002277.*1000*Pas + 0.002277*(0.005 + (1255./(Tas + 273.15))).*es; % zenith total delay
ZHD = 0.0022765.*(1000*Pas)./(1-0.00266*cos(2*lat_rad)-.046692*2.8e-07); % zenith hydrostatic delay

ZWD = ZTD - ZHD; % zenith wet delay
Tm = 70.2 + Tas; % mean temperature
K = .0046151.*(((3.719*10^5)./Tm) + 16.4221); 

IWV = ZWD./K; % integrated water vapor 

%% plotting weather data for Princeton station
h = figure;
subplot(5,1,1); area(time,IWV*1000,'FaceColor',[0 0 1]); xlim([min(time(:,1)) max(time(:,end))]); datetick('x','mm/dd','keeplimits'); ylim([min(min(1000*IWV(:,:))) max(max(1000*IWV(:,:)))]); xtickangle(45); grid on; ylabel('IWV (mm)');
hAllAxes = findobj(gcf,'type','axes');
subplot(5,1,2); plot(time,Tas,'b.'); xlim([min(time(:,1)) max(time(:,end))]); datetick('x','mm/dd','keeplimits'); ylim([min(min(Tas(:,:))) max(max(Tas(:,:)))]); xtickangle(45); grid on; ylabel('Temp (c)'); %ylim([17 33.5]);
subplot(5,1,3); plot(time,Pas*1000,'b.'); xlim([min(time(:,1)) max(time(:,end))]); datetick('x','mm/dd','keeplimits'); ylim([min(min(1000*Pas(:,:))) max(max(1000*Pas(:,:)))]); xtickangle(45); grid on; ylabel('Pressure (mb)'); %ylim([998 1012]);
subplot(5,1,4); plot(time,Uas,'b.'); xlim([min(time(:,1)) max(time(:,end))]); datetick('x','mm/dd','keeplimits'); ylim([min(min(Uas(:,:))) max(max(Uas(:,:)))]); xtickangle(45); grid on; ylabel('Humidity (%)'); %ylim([32 100]); 
subplot(5,1,5); plot(time,Rcs,'b.'); xlim([min(time(:,1)) max(time(:,end))]); datetick('x','mm/dd','keeplimits'); ylim([min(min(Rcs(:,:))) max(max(Rcs(:,:)))]); xtickangle(45); grid on; ylabel('Rainfall (mm)'); ylim([0.001 1.5]);
supertit(hAllAxes,Title)
print(h,OutputFileName,'-dpdf','-fillpage','-r0')
