function [ data ] = createDataBNet(database, startDate, endDate)

%  The function queries the database for collected
%  temperature,humidity,window,movement data
%
%   Parameter:
%   -database : name of database (database in 'database/until12_07_26.sqlite')
%   -startDate : initial date (earliest date: '2012-06-26 00:00:00')
%   -endDate:   final date (latest date: '2012-07-28 00:00:00')
%   Return
%     matrix of data

%database ='database/until12_07_26.sqlite';
%startDate = '2012-06-26 00:00:00';
%endDate = '2012-07-28 00:00:00';

disp('------------------------------------------------------------------------------------');
% EXTRACTING DATA
disp("[ 1/10] Extracting Data from 'WindowsOpen' sensor: when the window is open.");
windowOpen = extractWhenSensorOn(database, 2, startDate, endDate);
  
disp("[ 2/10] Extracting Data from 'Movement' sensor: when movement is detected.");
movement = extractWhenSensorOn(database, 9, startDate, endDate);

disp("[ 3/10] Extracting Data from 'Z-Plug' sensor: when Kettle, WaterDispenser, Microwave are On.");
[ kettle, waterDisp, microwave ] = queryZplug(database, startDate, endDate);

disp('------------------------------------------------------------------------------------');
% SNYC DATA

disp("[ 4/10] Synchronizing data between 'TemperatureDoor' and 'Humidity' sensors.");
tempWindHum = syncTempSmth(database, 12, 13, startDate, endDate);
tempWindHum = deleteDuplicateSensor(tempWindHum);

% the timeline is defined as the array of timestamps of the TemperatureDoor
timeline=tempWindHum(2,:);

disp("[ 5/10] Synchronizing data between 'TemperatureDoor' and 'TemperatureWindow' sensors.");
tempWindTempDoor=syncTempSmth(database, 12, 10, startDate, endDate);
tempWindTempDoor = deleteDuplicateSensor(tempWindTempDoor);


disp('------------------------------------------------------------------------------------');
% MATCHING DATA
disp("[ 6/10] Matching data: when 'Movement' sensor is On.");
data(1,:) = matchingSensorInterval(movement, timeline);
disp("[ 7/10] Matching data: when 'WindowOpen' sensor is On.");
data(2,:) = matchingSensorInterval(windowOpen, timeline);
disp("[ 8/10] Matching Data: when 'Kettle' is On.");
data(3,:) = matchingZplugInterval(kettle(3,:), timeline);
disp("[ 9/10] Matching Data: when 'WaterDispenser' is On.");
data(4,:) = matchingZplugInterval(waterDisp(3,:), timeline);
disp("[10/10] Matching Data: when 'Microwave' is On.");
data(5,:) = matchingZplugInterval(microwave(3,:), timeline);
 
data(6,:) = tempWindHum(1,:);
data(7,:) = tempWindHum(3,:);
data(8,:) = tempWindTempDoor(3,:);
disp('------------------------------------------------------------------------------------');

end
