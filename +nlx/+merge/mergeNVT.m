function timingData = mergeNVT(nvtFileName, listOfMasterDirectories, outputDirectory, timingData)


for dirIdx = 1:length(listOfMasterDirectories)
	[TS{dirIdx}, X{dirIdx}, Y{dirIdx}, Angle{dirIdx}, Targets{dirIdx}, Points{dirIdx}, Header{dirIdx}] = ...
		Nlx2MatVT(fullfile(listOfMasterDirectories{dirIdx}, nvtFileName), [1 1 1 1 1 1], 1, 1, 1);
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

X_sorted = cat(2, X{:});
X_sorted = X_sorted(I_ts);

Y_sorted = cat(2, Y{:});
Y_sorted = Y_sorted(I_ts);

Angle_sorted = cat(2, Angle{:});
Angle_sorted = Angle_sorted(I_ts);

Targets_sorted = cat(2, Targets{:});
Targets_sorted = Targets_sorted(:, I_ts);

Points_sorted = cat(2, Points{:});
Points_sorted = Points_sorted(:, I_ts);


RefHeader = Header{earliest};
RefHeader{4} = Header{latest}{4};


Mat2NlxVT(fullfile(outputDirectory, nvtFileName), 0, 1, 1, [1 1 1 1 1 1], TS_sorted, X_sorted, Y_sorted, Angle_sorted, Targets_sorted, Points_sorted, RefHeader);