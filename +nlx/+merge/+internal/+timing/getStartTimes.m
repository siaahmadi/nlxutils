function [startTimes, endTimes] = getStartTimes(Header)

idx = cellfun(@(header) find(~cellfun(@isempty, regexp(header, '^## Time Opened', 'match', 'once'))), Header, 'un', 0);
idx_closed = cellfun(@(header) find(~cellfun(@isempty, regexp(header, '^## Time Closed', 'match', 'once'))), Header, 'un', 0);

startTime = cellfun(@(header,i) regexp(header{i}, '\d*:\d*:\d*\.\d{1,3}$', 'match', 'once'), Header, idx, 'un', 0);
endTime = cellfun(@(header,i) regexp(header{i}, '\d*:\d*:\d*\.\d{1,3}$', 'match', 'once'), Header, idx_closed, 'un', 0);

startTimes = cellfun(@(st) datetime(st,'InputFormat','HH:mm:ss.SSS'), startTime, 'un', 0);
startTimes = cat(1, startTimes{:});
endTimes = cellfun(@(st) datetime(st,'InputFormat','HH:mm:ss.SSS'), endTime, 'un', 0);
endTimes = cat(1, endTimes{:});