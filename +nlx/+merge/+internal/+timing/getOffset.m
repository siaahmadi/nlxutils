function timingData = getOffset(Header)

[startTimes, endTimes] = nlx.merge.internal.timing.getStartTimes(Header);
[~, earliest] = min(startTimes);
[~, latest] = max(endTimes);
offset = 1e3 * milliseconds(startTimes - startTimes(earliest)); % in micro seconds

timingData.offset = offset;
% timingData.offset(2) = 6e3*1e6; % for 2017-08-07 set this to 6000 seconds
timingData.earliest = earliest;
timingData.latest = latest;