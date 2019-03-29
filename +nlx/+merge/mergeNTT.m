function timingData = mergeNTT(nttFileNumber, listOfMasterDirectories, outputDirectory, timingData)


cscFileNamePrefix = 'TT';

if numel(nttFileNumber) > 1
	if exist('timingData', 'var')
		arrayfun(@(tt) nlx.merge.mergeNTT(tt, listOfMasterDirectories, outputDirectory, timingData), nttFileNumber);
	else
		arrayfun(@(tt) nlx.merge.mergeNTT(tt, listOfMasterDirectories, outputDirectory), nttFileNumber);
	end
	return;
end

nttFileName = [cscFileNamePrefix, num2str(nttFileNumber), '.ntt'];

for dirIdx = 1:length(listOfMasterDirectories)
	[TS{dirIdx}, ScNum{dirIdx}, CellNum{dirIdx}, FeaturesAD{dirIdx}, AmplitudeAD{dirIdx}, Header{dirIdx}] = ...
		Nlx2MatSpike(fullfile(listOfMasterDirectories{dirIdx}, nttFileName), [1 1 1 1 1], 1, 1, 1);
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

%% Fix Amplitude
[bitvolts, adbitvoltidx] = getBitVolt(Header);
[refbitvolt, refHeader] = max(bitvolts); % the highest coefficient indicates highest maximum in Cheetah (to understand, think in terms of the fact that AmplitudeAD is expressed as "numerator of percentages" while the denominator is determined as peak at recording). We will scale everything according to this and use its Header as the output header.
coeff = bitvolts ./ repmat(refbitvolt, size(bitvolts, 1), 1);

for dirIdx = 1:length(listOfMasterDirectories)
	AmplitudeAD{dirIdx}(:, 1, :) = round(AmplitudeAD{dirIdx}(:, 1, :) * coeff(dirIdx, 1)); % channel 1
	AmplitudeAD{dirIdx}(:, 2, :) = round(AmplitudeAD{dirIdx}(:, 2, :) * coeff(dirIdx, 2)); % channel 2
	AmplitudeAD{dirIdx}(:, 3, :) = round(AmplitudeAD{dirIdx}(:, 3, :) * coeff(dirIdx, 3)); % channel 3
	AmplitudeAD{dirIdx}(:, 4, :) = round(AmplitudeAD{dirIdx}(:, 4, :) * coeff(dirIdx, 4)); % channel 4
	
	FeaturesAD{dirIdx}(1, :) = round(FeaturesAD{dirIdx}(1, :) * coeff(dirIdx, 1)); % peak 1
	FeaturesAD{dirIdx}(2, :) = round(FeaturesAD{dirIdx}(2, :) * coeff(dirIdx, 2)); % peak 2
	FeaturesAD{dirIdx}(3, :) = round(FeaturesAD{dirIdx}(3, :) * coeff(dirIdx, 3)); % peak 3
	FeaturesAD{dirIdx}(4, :) = round(FeaturesAD{dirIdx}(4, :) * coeff(dirIdx, 4)); % peak 4
	FeaturesAD{dirIdx}(5, :) = round(FeaturesAD{dirIdx}(5, :) * coeff(dirIdx, 1)); % trough 1
	FeaturesAD{dirIdx}(6, :) = round(FeaturesAD{dirIdx}(6, :) * coeff(dirIdx, 2)); % trough 2
	FeaturesAD{dirIdx}(7, :) = round(FeaturesAD{dirIdx}(7, :) * coeff(dirIdx, 3)); % trough 3
	FeaturesAD{dirIdx}(8, :) = round(FeaturesAD{dirIdx}(8, :) * coeff(dirIdx, 4)); % trough 4
end

refbitvoltString = ['-ADBitVolts ', strjoin(arrayfun(@(ad) num2str(ad, '%0.24f'), refbitvolt, 'un', 0), ' ')];

RefHeader = Header{earliest};
RefHeader{adbitvoltidx{earliest}} = refbitvoltString;
RefHeader{4} = Header{latest}{4};

% TODO: RefHeader -InputRange

%% Concat all
[TS_all, order_evt] = sort(cat(2, TS{:}));
AmplitudeAD_all = cat(3, AmplitudeAD{:});
AmplitudeAD_all = AmplitudeAD_all(:, :, order_evt);
ScNum_all = cat(2, ScNum{:});
ScNum_all = ScNum_all(order_evt);
CellNum_all = cat(2, CellNum{:});
CellNum_all = CellNum_all(order_evt);
FeaturesAD_all = cat(2, FeaturesAD{:});
FeaturesAD_all = FeaturesAD_all(:, order_evt);
%% Write Output

Mat2NlxSpike(fullfile(outputDirectory, nttFileName), 0, 1, 1, [1 1 1 1 1 1], TS_all, ScNum_all, CellNum_all, FeaturesAD_all, AmplitudeAD_all, RefHeader);


function [bitvolts, adbitvoltidx] = getBitVolt(Header)

adbitvoltidx = cellfun(@(header) find(~cellfun(@isempty, regexp(header, '^-ADBitVolts', 'match', 'once'))), Header, 'un', 0);

bitvolts = cellfun(@(header,i) extractBitVolt(header{i}), Header, adbitvoltidx, 'un', 0);
bitvolts = cat(1, bitvolts{:});

function bitvolts = extractBitVolt(adbitvolt)

bitvolts = regexp(adbitvolt, '(\d\.\d*) (\d\.\d*) (\d\.\d*) (\d\.\d*)', 'tokens');
bitvolts = cellfun(@str2double, bitvolts{1});
