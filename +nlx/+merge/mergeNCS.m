function timingData = mergeNCS(cscFileNumber, listOfMasterDirectories, outputDirectory, timingData)


cscFileNamePrefix = 'CSC';

if numel(cscFileNumber) > 1
	if exist('timingData', 'var')
		arrayfun(@(tt) nlx.merge.mergeNCS(tt, listOfMasterDirectories, outputDirectory, timingData), cscFileNumber);
	else
		arrayfun(@(tt) nlx.merge.mergeNCS(tt, listOfMasterDirectories, outputDirectory), cscFileNumber);
	end
	return;
end

cscFileName = [cscFileNamePrefix, num2str(cscFileNumber), '.ncs'];

for dirIdx = 1:length(listOfMasterDirectories)
	[TS{dirIdx}, Chn{dirIdx}, Freq{dirIdx}, nValid{dirIdx}, Sample{dirIdx}, Header{dirIdx}] = ...
		Nlx2MatCSC(fullfile(listOfMasterDirectories{dirIdx}, cscFileName), [1 1 1 1 1], 1, 1, 1);
end


%% Fix TS
if ~exist('timingData', 'var')
	warning('Timing data not provided. Due to the fact that not all Neuralynx headers are started at the same time this might introduce a discrepancy between the relative timing of events. Please beware!');
	timingData = nlx.merge.internal.timing.getOffset(Header);
end
offset = timingData.offset;
earliest = timingData.earliest;
latest = timingData.latest;

for dirIdx = 1:length(listOfMasterDirectories)
	TS{dirIdx} = TS{dirIdx} + offset(dirIdx);
end

[TS_sorted, I_ts] = sort(cat(2, TS{:}));

Chn_sorted = cat(2, Chn{:});
Chn_sorted = Chn_sorted(I_ts);

Freq_sorted = cat(2, Freq{:});
Freq_sorted = Freq_sorted(I_ts);

nValid_sorted = cat(2, nValid{:});
nValid_sorted = nValid_sorted(I_ts);

Sample_sorted = cat(2, Sample{:});
Sample_sorted = Sample_sorted(:, I_ts);


RefHeader = Header{earliest};
RefHeader{4} = Header{latest}{4};

%% Write Output

Mat2NlxCSC(fullfile(outputDirectory, cscFileName), 0, 1, 1, [1 1 1 1 1 1], TS_sorted, Chn_sorted, Freq_sorted, nValid_sorted, Sample_sorted, RefHeader);