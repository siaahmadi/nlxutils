function [t, x, y] = readraw(pathToSession, trials)
%READRAW Read Raw Neuralynx Path Data
%
% [t, x, y] = READRAW(pathToSession, trials)

if ~exist('trials', 'var')
	trials = {''};
end

[t, x, y] = cellfun(@(tname) Nlx2MatVT(fullfile(pathToSession,tname,'VT1.nvt'),[1 1 1 0 0 0], 0, 1, 0), trials, 'un', 0);
t = cellfun(@(t) t*1e-6, t, 'un', 0);