% @author: favour@nyikosa.com 15/MAY/2017
% load data - PLAYSENSOR DATA

bram_a_list = ['Update Date and Time (ISO)','Update Duration (ms)',...
    'Reading Date and Time (ISO)','Air pressure (mb)','Air temperature (C)',...
    'Sea temperature (C)','Tide height (m)','Visibility (nm)',...
    'Wind direction (deg)','Wind gust speed (kn)','Wind speed (kn)'];

cam_a_list = ['Update Date and Time (ISO)','Update Duration (ms)',...
    'Reading Date and Time (ISO)','Tide height (m)','Wind direction (deg)',...
    'Wind gust speed (kn)','Wind speed (kn)'];

chi_a_list = ['Update Date and Time (ISO)','Update Duration (ms)',...
    'Reading Date and Time (ISO)','Air pressure (mb)','Air temperature (C)',...
    'Max wave height (m)','Mean wave height (m)','Sea temperature (C)',...
    'Tide height (m)','Wave periodicity (s)','Wind direction (deg)',...
    'Wind gust speed (kn)','Wind speed (kn)'];

soton_a_list = ['Update Date and Time (ISO)','Update Duration (ms)',...
    'Reading Date and Time (ISO)','Air pressure (mb)','Air temperature (C)',...
    'Tide height (m)','Wind direction (deg)','Wind gust speed (kn)',...
    'Wind speed (kn)'];

% GPS locations of sensors
loc_bramble     = [50.790167, -1.28583]; % bramble bank  - 50° 47'. 41N, 1° 17'.15W
loc_camber      = [50.797333,  -0.8995]; % cambermet - chichester chanel - 50° 47'. 84N, 00° 53'. 97W 
loc_chi         = [50.7575,  -0.943167]; % chichester beacon - 50° 45'. 45N, 00° 56'. 59W 
loc_soton       = [50.8835,  -1.39433];  % Southampton - Dock Head - 50 53.01N 1 23.66W


full sensor data - past
temp_data_bram  = load('test_datasets/sensor_data/bramblemet.csv'); % 11
temp_data_cam   = load('test_datasets/sensor_data/cambermet.csv');  % 7
temp_data_chi   = load('test_datasets/sensor_data/chimet.csv');     % 13
temp_data_soton = load('test_datasets/sensor_data/sotonmet.csv');   % 9

size(temp_data_bram)
size(temp_data_cam)
size(temp_data_chi)
size(temp_data_soton)