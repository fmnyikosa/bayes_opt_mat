% @author: favour@nyikosa.com 1/MAY/2017
% SENSOR DATA 

% GPS locations of sensors
loc_bramble      = [50.790167, -1.28583]; % bramble bank  - 50° 47'. 41N, 1° 17'.15W
loc_camber       = [50.797333,  -0.8995]; % cambermet - 50° 47'. 84N, 00° 53'. 97W 
loc_chi          = [50.7575,  -0.943167]; % chichester beacon - 50° 45'. 45N, 00° 56'. 59W 
loc_soton        = [50.8835,  -1.39433];  % Southampton Dock Head - 50 53.01N 1 23.66W

% qantities collected at sensor
bramble_atr_list = ['Day','Month','Year','Hour','Minute','WSPD','WD','GST','ATMP','WTMP','BARO','DEPTH','VIS'];
camber_atr_list  = ['Day','Month','Year','Hour','Minute','WSPD','WD','GST','ATMP','WTMP','BARO','DEPTH'];
chi_atr_list     = ['Day','Month','Year','Hour','Minute','WSPD','WD','GST','ATMP','WTMP','BARO','DEPTH','AWVHT','MWVHT','WVHT','APD'];
soton_atr_list   = ['Day','Month','Year','Hour','Minute','WSPD','WD','GST','ATMP','BARO','DEPTH'];

% ------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 BRAMBLEMET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load Bramblemet data
data_bram_1  = load('test_datasets/my_sensor_data/bramblemet/Bra26Mar2017.csv');
data_bram_2  = load('test_datasets/my_sensor_data/bramblemet/Bra27Mar2017.csv');
data_bram_3  = load('test_datasets/my_sensor_data/bramblemet/Bra28Mar2017.csv');
data_bram_4  = load('test_datasets/my_sensor_data/bramblemet/Bra29Mar2017.csv');
data_bram_5  = load('test_datasets/my_sensor_data/bramblemet/Bra30Mar2017.csv');
data_bram_6  = load('test_datasets/my_sensor_data/bramblemet/Bra31Mar2017.csv');
data_bram_7  = load('test_datasets/my_sensor_data/bramblemet/Bra01Apr2017.csv');
data_bram_8  = load('test_datasets/my_sensor_data/bramblemet/Bra02Apr2017.csv');
data_bram_9  = load('test_datasets/my_sensor_data/bramblemet/Bra03Apr2017.csv');
data_bram_10 = load('test_datasets/my_sensor_data/bramblemet/Bra04Apr2017.csv');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Training Data - Bramblemet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collate input traning data - March 26th to March 29th (4 days)
data_bramblemet_train  = [data_bram_1; data_bram_2; data_bram_3; data_bram_4];
% initilise location data
location_tag_x1        = loc_bramble(1) .* ones(size(data_bramblemet_train, 1), 1);
location_tag_x2        = loc_bramble(2) .* ones(size(data_bramblemet_train, 1), 1);
% append locations to input training dataset
full_bramblemet_train  = [location_tag_x1, location_tag_x2, data_bramblemet_train];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attribute list (with matlab indices): 
% 1.  long (longituvd) 
% 2.  lat (latitude)
% 3.  day 
% 4.  month 
% 5.  year 
% 6.  hour 
% 7.  minute 
% 8.  wspd (windspeed)
% 9.  wd (wind direction)
% 10. gst (maximum gust speed)
% 11. atmp (atmosperic temperature)
% 12. wtmp (water temperature)
% 13. baro (barmometric pressure)
% 14. depth (water depth)
% 15. visibility (visibility)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filtering out year and month attributes to reduce dimensionality, 
% since they are the same add no new information.
% format: {long, lat, day}, {hour, minute}, {key_quantity}
%         {1, 2, 3},        {6, 7},         {key_quantity}
% so,
% x = [ {1, 2, 3}, {6, 7} ], and
% y = [ {key_quantity} ]
%
first_set              = full_bramblemet_train(:,1:3);
second_set             = full_bramblemet_train(:,6:7);
xtr                    = [first_set, second_set];
% key quantity assignements and saves
key_quantity           = 8; % wspd
third_set              = full_bramblemet_train(:,key_quantity);
ytr                    = third_set;
save('bramblemet_wspd_train.mat', 'xtr', 'ytr', 'full_bramblemet_train')
% key quantity assignements and saves
key_quantity           = 11; % atmp
third_set              = full_bramblemet_train(:,key_quantity);
ytr                    = third_set;
save('bramblemet_atmp_train.mat', 'xtr', 'ytr', 'full_bramblemet_train')
% key quantity assignements and saves
key_quantity           = 12; % wtmp
third_set              = full_bramblemet_train(:,key_quantity);
ytr                    = third_set;
save('bramblemet_wtmp_train.mat', 'xtr', 'ytr', 'full_bramblemet_train')
% key quantity assignements and saves
key_quantity           = 13; % baro
third_set              = full_bramblemet_train(:,key_quantity);
ytr                    = third_set;
save('bramblemet_baro_train.mat', 'xtr', 'ytr', 'full_bramblemet_train')
% key quantity assignements and saves
key_quantity           = 14; % depth
third_set              = full_bramblemet_train(:,key_quantity);
ytr                    = third_set;
save('bramblemet_depth_train.mat', 'xtr', 'ytr', 'full_bramblemet_train')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Testing Data - Bramblemet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collate input traning data - March 30th to March 31th (2 days)
data_bramblemet_test   = [data_bram_5; data_bram_6];
% initilise location data
location_tag_x1        = loc_bramble(1) .* ones(size(data_bramblemet_test, 1), 1);
location_tag_x2        = loc_bramble(2) .* ones(size(data_bramblemet_test, 1), 1);
% append locations to the rest of the data
full_bramblemet_test   = [location_tag_x1, location_tag_x2, data_bramblemet_test];
% extract redundunt attributes
first_set              = full_bramblemet_test(:,1:3);
second_set             = full_bramblemet_test(:,6:7);
xte                    = [first_set, second_set];
% get interesting quantity and save
key_quantity           = 8; % wspd
third_set              = full_bramblemet_test(:,key_quantity);
yte                    = third_set;
save('bramblemet_wspd_test.mat', 'xte', 'yte', 'full_bramblemet_test');
% get interesting quantity and save
key_quantity           = 11; % atmp
third_set              = full_bramblemet_test(:,key_quantity); 
yte                    = third_set;
save('bramblemet_atmp_test.mat', 'xte', 'yte', 'full_bramblemet_test');
% get interesting quantity and save
key_quantity           = 12; % wtmp
third_set              = full_bramblemet_test(:,key_quantity); 
yte                    = third_set;
save('bramblemet_wtmp_test.mat', 'xte', 'yte', 'full_bramblemet_test');
% get interesting quantity and save
key_quantity           = 13; % baro
third_set              = full_bramblemet_test(:,key_quantity); 
yte                    = third_set;
save('bramblemet_baro_test.mat', 'xte', 'yte', 'full_bramblemet_test');
% get interesting quantity and save
key_quantity           = 14; % depth
third_set              = full_bramblemet_test(:,key_quantity); 
yte                    = third_set;
save('bramblemet_depth_test.mat', 'xte', 'yte', 'full_bramblemet_test');

% ------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 CAMBERMET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cambermet data
data_camber_1  = load('test_datasets/my_sensor_data/cambermet/Cam26Mar2017.csv');
data_camber_2  = load('test_datasets/my_sensor_data/cambermet/Cam27Mar2017.csv');
data_camber_3  = load('test_datasets/my_sensor_data/cambermet/Cam28Mar2017.csv');
data_camber_4  = load('test_datasets/my_sensor_data/cambermet/Cam29Mar2017.csv');
data_camber_5  = load('test_datasets/my_sensor_data/cambermet/Cam30Mar2017.csv');
data_camber_6  = load('test_datasets/my_sensor_data/cambermet/Cam31Mar2017.csv');
data_camber_7  = load('test_datasets/my_sensor_data/cambermet/Cam01Apr2017.csv');
data_camber_8  = load('test_datasets/my_sensor_data/cambermet/Cam02Apr2017.csv');
data_camber_9  = load('test_datasets/my_sensor_data/cambermet/Cam03Apr2017.csv');
data_camber_10 = load('test_datasets/my_sensor_data/cambermet/Cam04Apr2017.csv');
% collate input training data - March 26th to March 29th (4 days)
data_cambermet_train  = [data_camber_1; data_camber_2; data_camber_3; data_camber_4];
% initilise location data
location_tag_x1        = loc_camber(1) .* ones(size(data_cambermet_train, 1), 1);
location_tag_x2        = loc_camber(2) .* ones(size(data_cambermet_train, 1), 1);
% append locations to input training dataset
full_cambermet_train  = [location_tag_x1, location_tag_x2, data_cambermet_train];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attribute list (with matlab indices): 
% 1.  long (longituvd) 
% 2.  lat (latitude)
% 3.  day 
% 4.  month 
% 5.  year 
% 6.  hour 
% 7.  minute 
% 8.  wspd (windspeed)
% 9.  wd (wind direction)
% 10. gst (maximum gust speed)
% 11. atmp (atmosperic temperature)
% 12. wtmp (water temperature)
% 13. baro (barmometric pressure)
% 14. depth (water depth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filtering out year and month attributes to reduce dimensionality, 
% since they are the same add no new information.
% format: {long, lat, day}, {hour, minute}, {key_quantity}
%         {1, 2, 3},        {6, 7},         {key_quantity}
% so,
% x = [ {1, 2, 3}, {6, 7} ], and
% y = [ {key_quantity} ]
%
first_set              = full_cambermet_train(:,1:3);
second_set             = full_cambermet_train(:,6:7);
xtr                    = [first_set, second_set];
% key quantity assignements and saves
key_quantity           = 8; % wspd
third_set              = full_cambermet_train(:,key_quantity);
ytr                    = third_set;
save('cambermet_wspd_train.mat', 'xtr', 'ytr', 'full_cambermet_train')
% key quantity assignements and saves
key_quantity           = 11; % atmp
third_set              = full_cambermet_train(:,key_quantity);
ytr                    = third_set;
save('cambermet_atmp_train.mat', 'xtr', 'ytr', 'full_cambermet_train')
% key quantity assignements and saves
key_quantity           = 12; % wtmp
third_set              = full_cambermet_train(:,key_quantity);
ytr                    = third_set;
save('cambermet_wtmp_train.mat', 'xtr', 'ytr', 'full_cambermet_train')
% key quantity assignements and saves
key_quantity           = 13; % baro
third_set              = full_cambermet_train(:,key_quantity);
ytr                    = third_set;
save('cambermet_baro_train.mat', 'xtr', 'ytr', 'full_cambermet_train')
% key quantity assignements and saves
key_quantity           = 14; % depth
third_set              = full_cambermet_train(:,key_quantity);
ytr                    = third_set;
save('cambermet_depth_train.mat', 'xtr', 'ytr', 'full_cambermet_train')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Testing Data - Cambermet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collate input traning data - March 30th to March 31th (2 days)
data_cambermet_test   = [data_camber_5; data_camber_6];
% initilise location data
location_tag_x1        = loc_camber(1) .* ones(size(data_cambermet_test, 1), 1);
location_tag_x2        = loc_camber(2) .* ones(size(data_cambermet_test, 1), 1);
% append locations to the rest of the data
full_cambermet_test   = [location_tag_x1, location_tag_x2, data_cambermet_test];
% extract redundunt attributes
first_set              = full_cambermet_test(:,1:3);
second_set             = full_cambermet_test(:,6:7);
xte                    = [first_set, second_set];
% get interesting quantity and save
key_quantity           = 8; % wspd
third_set              = full_cambermet_test(:,key_quantity);
yte                    = third_set;
save('cambermet_wspd_test.mat', 'xte', 'yte', 'full_cambermet_test');
% get interesting quantity and save
key_quantity           = 11; % atmp
third_set              = full_cambermet_test(:,key_quantity); 
yte                    = third_set;
save('cambermet_atmp_test.mat', 'xte', 'yte', 'full_cambermet_test');
% get interesting quantity and save
key_quantity           = 12; % wtmp
third_set              = full_cambermet_test(:,key_quantity) ;
yte                    = third_set;
save('cambermet_wtmp_test.mat', 'xte', 'yte', 'full_cambermet_test');
% get interesting quantity and save
key_quantity           = 13; % baro
third_set              = full_cambermet_test(:,key_quantity); 
yte                    = third_set;
save('cambermet_baro_test.mat', 'xte', 'yte', 'full_cambermet_test');
% get interesting quantity and save
key_quantity           = 14; % depth
third_set              = full_cambermet_test(:,key_quantity) ;
yte                    = third_set;
save('cambermet_depth_test.mat', 'xte', 'yte', 'full_cambermet_test');

% ------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  CHIMET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% chimet data
data_chi_1  = load('test_datasets/my_sensor_data/chimet/Chi26Mar2017.csv');
data_chi_2  = load('test_datasets/my_sensor_data/chimet/Chi27Mar2017.csv');
data_chi_3  = load('test_datasets/my_sensor_data/chimet/Chi28Mar2017.csv');
data_chi_4  = load('test_datasets/my_sensor_data/chimet/Chi29Mar2017.csv');
data_chi_5  = load('test_datasets/my_sensor_data/chimet/Chi30Mar2017.csv');
data_chi_6  = load('test_datasets/my_sensor_data/chimet/Chi31Mar2017.csv');
data_chi_7  = load('test_datasets/my_sensor_data/chimet/Chi01Apr2017.csv');
data_chi_8  = load('test_datasets/my_sensor_data/chimet/Chi02Apr2017.csv');
data_chi_9  = load('test_datasets/my_sensor_data/chimet/Chi03Apr2017.csv');
data_chi_10 = load('test_datasets/my_sensor_data/chimet/Chi04Apr2017.csv');
% collate input training data - March 26th to March 29th (4 days)
data_chimet_train  = [data_chi_1; data_chi_2; data_chi_3; data_chi_4];
% initilise location data
location_tag_x1    = loc_chi(1) .* ones(size(data_chimet_train, 1), 1);
location_tag_x2    = loc_chi(2) .* ones(size(data_chimet_train, 1), 1);
% append locations to input training dataset
full_chimet_train  = [location_tag_x1, location_tag_x2, data_chimet_train];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attribute list (with matlab indices): 
% 1.  long (longituvd) 
% 2.  lat (latitude)
% 3.  day 
% 4.  month 
% 5.  year 
% 6.  hour 
% 7.  minute 
% 8.  wspd (windspeed)
% 9.  wd (wind direction)
% 10. gst (maximum gust speed)
% 11. atmp (atmosperic temperature)
% 12. wtmp (water temperature)
% 13. baro (barmometric pressure)
% 14. depth (water depth)
% 15. visibility (visibility)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filtering out year and month attributes to reduce dimensionality, 
% since they are the same add no new information.
% format: {long, lat, day}, {hour, minute}, {key_quantity}
%         {1, 2, 3},        {6, 7},         {key_quantity}
% so,
% x = [ {1, 2, 3}, {6, 7} ], and
% y = [ {key_quantity} ]
%
first_set              = full_chimet_train(:,1:3);
second_set             = full_chimet_train(:,6:7);
xtr                    = [first_set, second_set];
% key quantity assignements and saves
key_quantity           = 8; % wspd
third_set              = full_chimet_train(:,key_quantity);
ytr                    = third_set;
save('chimet_wspd_train.mat', 'xtr', 'ytr', 'full_chimet_train');
% key quantity assignements and saves
key_quantity           = 11; % atmp
third_set              = full_chimet_train(:,key_quantity);
ytr                    = third_set;
save('chimet_atmp_train.mat', 'xtr', 'ytr', 'full_chimet_train');
% key quantity assignements and saves
key_quantity           = 12; % wtmp
third_set              = full_chimet_train(:,key_quantity);
ytr                    = third_set;
save('chimet_wtmp_train.mat', 'xtr', 'ytr', 'full_chimet_train');
% key quantity assignements and saves
key_quantity           = 13; % baro
third_set              = full_chimet_train(:,key_quantity);
ytr                    = third_set;
save('chimet_baro_train.mat', 'xtr', 'ytr', 'full_chimet_train');
% key quantity assignements and saves
key_quantity           = 14; % depth
third_set              = full_chimet_train(:,key_quantity);
ytr                    = third_set;
save('chimet_depth_train.mat', 'xtr', 'ytr', 'full_chimet_train')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Testing Data - Chimet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collate input traning data - March 30th to March 31th (2 days)
data_chimet_test   = [data_chi_5; data_chi_6];
% initilise location data
location_tag_x1        = loc_chi(1) .* ones(size(data_chimet_test, 1), 1);
location_tag_x2        = loc_chi(2) .* ones(size(data_chimet_test, 1), 1);
% append locations to the rest of the data
full_chimet_test   = [location_tag_x1, location_tag_x2, data_chimet_test];
% extract redundunt attributes
first_set              = full_chimet_test(:,1:3);
second_set             = full_chimet_test(:,6:7);
xte                    = [first_set, second_set];
% get interesting quantity and save
key_quantity           = 8; % wspd
third_set              = full_chimet_test(:,key_quantity); 
yte                    = third_set;
save('chimet_wspd_test.mat', 'xte', 'yte', 'full_chimet_test');
% get interesting quantity and save
key_quantity           = 11; % atmp
third_set              = full_chimet_test(:,key_quantity); 
yte                    = third_set;
save('chimet_atmp_test.mat', 'xte', 'yte', 'full_chimet_test');
% get interesting quantity and save
key_quantity           = 12; % wtmp
third_set              = full_chimet_test(:,key_quantity); 
yte                    = third_set;
save('chimet_wtmp_test.mat', 'xte', 'yte', 'full_chimet_test');
% get interesting quantity and save
key_quantity           = 13; % baro
third_set              = full_chimet_test(:,key_quantity); 
yte                    = third_set;
save('chimet_baro_test.mat', 'xte', 'yte', 'full_chimet_test');
% get interesting quantity and save
key_quantity           = 14; % depth
third_set              = full_chimet_test(:,key_quantity);
yte                    = third_set;
save('chimet_depth_test.mat', 'xte', 'yte', 'full_chimet_test');

% ------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 SOTONMET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sotonmet data
data_soton_1  = load('test_datasets/my_sensor_data/sotonmet/Sot26Mar2017.csv');
data_soton_2  = load('test_datasets/my_sensor_data/sotonmet/Sot27Mar2017.csv');
data_soton_3  = load('test_datasets/my_sensor_data/sotonmet/Sot28Mar2017.csv');
data_soton_4  = load('test_datasets/my_sensor_data/sotonmet/Sot29Mar2017.csv');
data_soton_5  = load('test_datasets/my_sensor_data/sotonmet/Sot30Mar2017.csv');
data_soton_6  = load('test_datasets/my_sensor_data/sotonmet/Sot31Mar2017.csv');
data_soton_7  = load('test_datasets/my_sensor_data/sotonmet/Sot01Apr2017.csv');
data_soton_8  = load('test_datasets/my_sensor_data/sotonmet/Sot02Apr2017.csv');
data_soton_9  = load('test_datasets/my_sensor_data/sotonmet/Sot03Apr2017.csv');
data_soton_10 = load('test_datasets/my_sensor_data/sotonmet/Sot04Apr2017.csv');
% collate input training data - March 26th to March 29th (4 days)
data_sotonmet_train  = [data_soton_1; data_soton_2; data_soton_3; data_soton_4];
% initilise location data
location_tag_x1      = loc_soton(1) .* ones(size(data_sotonmet_train, 1), 1);
location_tag_x2      = loc_soton(2) .* ones(size(data_sotonmet_train, 1), 1);
% append locations to input training dataset
full_sotonmet_train  = [location_tag_x1, location_tag_x2, data_sotonmet_train];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attribute list (with matlab indices): 
% 1.  long (longituvd) 
% 2.  lat (latitude)
% 3.  day 
% 4.  month 
% 5.  year 
% 6.  hour 
% 7.  minute 
% 8.  wspd (windspeed)
% 9.  wd (wind direction)
% 10. gst (maximum gust speed)
% 11. atmp (atmosperic temperature)
% 12. baro (barmometric pressure)
% 13. depth (water depth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filtering out year and month attributes to reduce dimensionality, 
% since they are the same add no new information.
% format: {long, lat, day}, {hour, minute}, {key_quantity}
%         {1, 2, 3},        {6, 7},         {key_quantity}
% so,
% x = [ {1, 2, 3}, {6, 7} ], and
% y = [ {key_quantity} ]
%
first_set              = full_sotonmet_train(:,1:3);
second_set             = full_sotonmet_train(:,6:7);
xtr                    = [first_set, second_set];
% key quantity assignements and saves
key_quantity           = 8; % wspd
third_set              = full_sotonmet_train(:,key_quantity);
ytr                    = third_set;
save('sotonmet_wspd_train.mat', 'xtr', 'ytr', 'full_sotonmet_train')
% key quantity assignements and saves
key_quantity           = 11; % atmp
third_set              = full_sotonmet_train(:,key_quantity);
ytr                    = third_set;
save('sotonmet_atmp_train.mat', 'xtr', 'ytr', 'full_sotonmet_train')
% key quantity assignements and saves
%key_quantity           = 12; % wtmp
%third_set              = full_sotonmet_train(:,key_quantity);
%ytr                    = third_set;
%save('sotonmet_wtmp_train.mat', 'xtr', 'ytr', 'full_sotonmet_train')
% key quantity assignements and saves
key_quantity           = 12; % baro
third_set              = full_sotonmet_train(:,key_quantity);
ytr                    = third_set;
save('sotonmet_baro_train.mat', 'xtr', 'ytr', 'full_sotonmet_train')
% key quantity assignements and saves
key_quantity           = 13; % depth
third_set              = full_sotonmet_train(:,key_quantity);
ytr                    = third_set;
save('sotonmet_depth_train.mat', 'xtr', 'ytr', 'full_sotonmet_train')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Testing Data - Sotonmet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collate input traning data - March 30th to March 31th (2 days)
data_sotonmet_test     = [data_soton_5; data_soton_6];
% initilise location data
location_tag_x1        = loc_soton(1) .* ones(size(data_sotonmet_test, 1), 1);
location_tag_x2        = loc_soton(2) .* ones(size(data_sotonmet_test, 1), 1);
% append locations to the rest of the data
full_sotonmet_test     = [location_tag_x1, location_tag_x2, data_sotonmet_test];
% extract redundunt attributes
first_set              = full_sotonmet_test(:,1:3);
second_set             = full_sotonmet_test(:,6:7);
xte                    = [first_set, second_set];
% get interesting quantity and save
key_quantity           = 8; % wspd
third_set              = full_sotonmet_test(:,key_quantity); 
yte                    = third_set;
save('sotonmet_wspd_test.mat', 'xte', 'yte', 'full_sotonmet_test');
% get interesting quantity and save
key_quantity           = 11; % atmp
third_set              = full_sotonmet_test(:,key_quantity); 
yte                    = third_set;
save('sotonmet_atmp_test.mat', 'xte', 'yte', 'full_sotonmet_test');
% get interesting quantity and save
% key_quantity           = 12; % wtmp
% third_set              = full_sotonmet_test(:,key_quantity) 
% ytr                    = third_set;
% save('sotonmet_wtmp_test.mat', 'xte', 'yte', 'full_sotonmet_test');
% get interesting quantity and save
key_quantity           = 12; % baro
third_set              = full_sotonmet_test(:,key_quantity); 
yte                    = third_set;
save('sotonmet_baro_test.mat', 'xte', 'yte', 'full_sotonmet_test');
% get interesting quantity and save
key_quantity           = 13; % depth
third_set              = full_sotonmet_test(:,key_quantity); 
yte                    = third_set;
save('sotonmet_depth_test.mat', 'xte', 'yte', 'full_sotonmet_test');

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
