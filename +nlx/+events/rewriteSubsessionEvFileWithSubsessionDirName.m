function rewriteSubsessionEvFileWithSubsessionDirName(pathToSession, newEvFileName)

subsessions = dir(pathToSession);
subsessions = subsessions([subsessions.isdir]);
subsessions = subsessions(3:end);
subsessions = {subsessions.name}';

for iS = 1:length(subsessions)
	[evt_sub, ts_sub] = nlx.events.read(fullfile(pathToSession, subsessions{iS}), 'Events_split.nev');
	
	if length(evt_sub) ~= 2
		error('Fix Event File?');
	end
	evt_sub{1} = strcat('begin', subsessions{iS});
	evt_sub{2} = strcat('end', subsessions{iS});
	
	writeEvFile(fullfile(pathToSession, subsessions{iS}, newEvFileName), ts_sub(:)', evt_sub(:)');
end