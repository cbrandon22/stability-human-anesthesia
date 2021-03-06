% Downloads data from iEEG.org and saves in a structure
% Use iEEG portal to select a start and end time for saved segment
% Optional: Enter noisy channels noticed on iEEG into bad_channels array
% For description of saved variables, see last segment of code

%% Variables
% Machine/user variables
ieeg_pw_file = 'C:\Users\usr\Documents\MATLAB\stability\usr_ieeglogin.bin'; % directory of password file created by IEEGSession.createPwdFile
ieeg_user = 'USERNAME';
data_dir = 'D:\Libraries\Documents\Richardson Lab\Stability\data'; % save location for downloaded data

% Session variables
subject = 'HUP225'; % subject HUP###
session_type = 'Emergence'; % Induction or Emergence
session_title = 'HUP225_OR_implant_emergence';
start_seconds = 500; % manually selected start time
end_seconds = 1880; % manually selected end time
bad_channels = {'RA01','RA12', 'RB12','RE11','RE12','RG12','RI12'}; % Manually enter bad channels

%% Data download
% Start iEEG Session
ieeg_session = IEEGSession(session_title, ieeg_user, ieeg_pw_file);

% Build raw_data matrix (samples x chanels)
[~,num_channels] = size(ieeg_session.data.rawChannels);
start_useconds = start_seconds*1000000;
end_useconds = end_seconds*1000000;
raw_data = getvalues(ieeg_session.data,start_useconds,end_useconds-start_useconds,1); % getvalues(data, start microsec, duration, channel)
for i=2:num_channels
    raw_data(:,i) = getvalues(ieeg_session.data,start_useconds,end_useconds-start_useconds,i);
end
t = [0:size(raw_data,1)-1] / ieeg_session.data.sampleRate;

% Read Annotations, offset to match extracted data time
ieeg_annotations = getEvents(ieeg_session.data.annLayer, 0);
annotations = {ieeg_annotations(1,1).description,(ieeg_annotations(1,1).start- start_useconds)/1000000};
for i=2:length(ieeg_annotations)
    annotations = [annotations;{ieeg_annotations(1,i).description,(ieeg_annotations(1,i).start - start_useconds)/1000000}];
end

% Read targets from spreadsheet
if isfile(fullfile(data_dir,subject,strcat(subject, '_channels.xlsx')))
channel_labels = ieeg_session.data.channelLabels;
[~,~,sheet] = xlsread(fullfile(data_dir,subject,strcat(subject, '_channels.xlsx')));
else
    disp('No channel spreadsheet found. lead_targets will be left blank')
    sheet = {};
end

%% Build and save session structure
session.subject = subject;                                  % HUP### assigned to subject
session.type = session_type;                                % Emergence or Induction
session.sample_rate = ieeg_session.data.sampleRate;         % sample rate
session.start_us = start_useconds;                          % offset in milliseconds from start of recording
session.end_us = end_useconds;                              % milliseconds at end of downloaded segment
session.channel_labels = ieeg_session.data.channelLabels;   % labels for each lead/channel
session.data = raw_data;                                    % raw eeg data in microvolts
session.t = t;                                              % time in seconds for extracted data
session.annotations = annotations;                          % annotations typed during session
session.lead_targets = sheet;                               % anatomical target of each lead
session.bad_channels = bad_channels;                        % manually identified noise channels

save(fullfile(data_dir,subject,strcat(subject,'_', session_type, '.mat')),'session','-V7.3');
