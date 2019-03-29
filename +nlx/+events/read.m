function [EventStrings, TimeStamps, Header] = read(pathToSession, evFileName)
%[EventStrings, TimeStamps, Header] = READ(pathToSession)

if ~exist('evFileName', 'var')
	evFileName = 'Events.nev';
end

[TimeStamps, EventStrings, Header] = Nlx2MatEV(fullfile(pathToSession, evFileName), [1 0 0 0 1 0], 1, 1, 0);

TimeStamps = TimeStamps(:) * 1e-6;