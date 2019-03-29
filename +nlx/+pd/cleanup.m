function [x, y] = cleanup(x, y, maxSpeed, mzCenter, mzScale)
%[x, y] = CLEANUP(x, y, maxSpeed, mzCenter, mzScale)

if ~exist('maxSpeed', 'var') || isempty(maxSpeed)
	maxSpeed = 100; % cm/s
end
if ~exist('mzCenter', 'var') || isempty(mzCenter)
	mzCenter = [364; 231];
end
if ~exist('mzScale', 'var') || isempty(mzScale)
	mzScale = [.42, -.45];
end

smoothingKernelSize = 7;
boxcar = ones(smoothingKernelSize, 1) / smoothingKernelSize;

[x, y] = cellfun(@(x,y) fixVideoReflections(x, y, abs(maxSpeed / mzScale(1))), x, y, 'un', 0);

x = cellfun(@(z) interpnan(substituteNansForZeros(z)), x, 'un', 0);
y = cellfun(@(z) interpnan(substituteNansForZeros(z)), y, 'un', 0);

x = cellfun(@(z) xpad(z, floor(smoothingKernelSize/2)), x, 'un', 0);
y = cellfun(@(z) xpad(z, floor(smoothingKernelSize/2)), y, 'un', 0);

[x, y] = cellfun(@(x,y) deal(conv(mzScale(1)*(substituteNansForZeros(x)-mzCenter(1)), boxcar, 'same'), ...
	conv(mzScale(2)*(substituteNansForZeros(y)-mzCenter(2)), boxcar, 'same')), x, y, 'un', 0);

x = cellfun(@(z) unpad(z, floor(smoothingKernelSize/2)), x, 'un', 0);
y = cellfun(@(z) unpad(z, floor(smoothingKernelSize/2)), y, 'un', 0);


function x = substituteNansForZeros(x)
x(x==0) = NaN;

function [x, y] = fixVideoReflections(x, y, maxSpeed)
jumps = eucldist(x(1:end-1), y(1:end-1), x(2:end), y(2:end));
oo = lau.rt(jumps > maxSpeed);
iNaN = find(oo(:));
for i = 1:2:length(iNaN)
	x(iNaN(i):iNaN(i+1)) = NaN;
	y(iNaN(i):iNaN(i+1)) = NaN;
end

function x = xpad(x, by)
x = [repmat(x(1), by, 1); x(:); repmat(x(end), by, 1)];

function x = unpad(x, by)
x = x(by+1:end-by);