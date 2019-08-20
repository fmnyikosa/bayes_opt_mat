% AIR QUALITY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 BEIJING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% stations attributes:
% 1.station_id 2.station_name 3.latitude 4.longtitude
%
% sensor attributes:
% 1.  long 
% 2.  lat 
% 3.  day 
% 4.  month 
% 5.  year 
% 6.  hour 
% 7.  minute 
% 8.  sec 
% 9.  PM25_AQI_value 
% 10. PM10_AQI_value 
% 11. NO2_AQI_value 
% 12. temperature 
% 13. pressure 
% 14. humidity 
% 15. wind 
% 16. weather


beijing_data = load('test_datasets/air_quality_data/beijing/BeijingData.csv');
save('beijing_data.mat', 'beijing_data');
[n_rows_beijing, n_cols_beijing] = size(beijing_data);

shanghai_data = load('test_datasets/air_quality_data/shanghai/ShanghaiData.csv');
save('shanghai_data.mat', 'shanghai_data');
[n_rows_shanghai, n_cols_shanghai] = size(shanghai_data);
