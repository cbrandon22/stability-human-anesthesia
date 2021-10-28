load('D:\Libraries\Documents\Richardson Lab\Stability\data\HUP223\HUP223_Emergence.mat');

% select channel/event/time window
channel = 2;
event_number = 13;
duration_secs = 10;

%Plot event
[~,evi] = min(abs(session.t - session.annotations{event_number,2}));
starti = evi - ceil(duration_secs*session.sample_rate/2);
endi = starti + duration_secs*session.sample_rate;
plot(session.t(starti:endi),session.data(starti:endi,channel)); hold on
xline(session.annotations{event_number,2});
title([session.channel_labels{channel}, ' - ', session.annotations{event_number,1}])
xlabel('Seconds');
ylabel('µV');