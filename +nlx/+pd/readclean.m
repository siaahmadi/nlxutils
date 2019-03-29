function [t, x, y, v] = readclean(pathToSession, trials, options)
%READCLEAN Read Neuralynx Path Data and Preprocess to Remove the Artifacts
%
% [t, x, y, v] = READCLEAN(pathToSession, trials, maxSpeed)

if ~exist('options', 'var')
	options = struct();
end
if ~isfield(options, 'maxSpeed')
	options.maxSpeed = 100; % cm/s
end
if ~isfield(options, 'mzCenter')
	options.mzCenter = [364; 231];
end
if ~isfield(options, 'mzScale')
	options.mzScale = [.42, -.45];
end

if ~exist('trials', 'var')
	trials = {''};
end

[t, x, y] = nlx.pd.readraw(pathToSession, trials);

[x, y] = nlx.pd.cleanup(x, y, options.maxSpeed, options.mzCenter, options.mzScale);

if nargout > 3
	v = cellfun(@nlx.pd.estimateVelocity, t, x, y, 'un', 0);
end