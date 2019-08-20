% Gets Beijing air quality data. 
%
% See: https://www.microsoft.com/en-us/research/publication/u-air-when-urban-air-quality-inference-meets-big-data/
%
% Usage:
%
% data = getAirQualityDataBeijing()
%
%       data:     air quaity data
%       
% data has the following atributes (with matlab indices):
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
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-18

function data  = getAirQualityDataBeijing()
    data_   = load('beijing_data.mat', 'beijing_data');
    data    = data_.beijing_data;
end