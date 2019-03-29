function splitRootEventFileIntoSubsessions(pathToSession, newEvFileName)

[evt, ts, Header] = nlx.events.read(pathToSession);

subsessions = dir(pathToSession);
subsessions = subsessions([subsessions.isdir]);
subsessions = subsessions(3:end);
subsessions = {subsessions.name}';

evt_sub = cell(length(subsessions), 1);
ts_sub = evt_sub;
for iS = 1:length(subsessions)
	[evt_sub{iS}, ts_sub{iS}] = nlx.events.read(fullfile(pathToSession, subsessions{iS}));
	
	for iS_sub = 1:length(evt_sub{iS})
		[~, idx_b{iS_sub}] = intersect(evt, evt_sub{iS});
		idx_e{iS_sub} = idx_b{iS_sub} + 1;
	end
	idx_to_write = cat(1, idx_b{:}, idx_e{:});
	evt_to_write = evt(idx_to_write);
	ts_to_write = ts(idx_to_write);
	
	writeEvFile(fullfile(pathToSession, subsessions{iS}, newEvFileName), ts_to_write(:)', evt_to_write(:)');
end