function animate(t, x, y, t0, t1, speed, span)

idx = t0 <= t & t <= t1;
idx = find(idx(:)');

if ~exist('span', 'var')
	span = 1;
end
if ~exist('speed', 'var')
	speed = 1;
end

framerate = 30;

xlim([-100, 100]);
ylim([-100, 100]);
axis square;
axis manual;

spanidx = round(span*framerate);
% interpolate to handle non-integer `speed`:
iterateOver = interp1(1:length(idx)-spanidx+1, spanidx:length(idx), linspace(1, length(idx)-spanidx+1, round((length(idx)-spanidx+1)/speed)), 'nearest');
for i = idx(iterateOver)
	cla; hold on;
	plot(x(idx(1):i-spanidx+1), y(idx(1):i-spanidx+1), 'color', ones(1,3)*.65);
	plot(x(i-spanidx+1:i), y(i-spanidx+1:i), 'color', 'r');
	plot(x(i), y(i), '.', 'color', 'r', 'markersize', 20);
	
	title(sprintf('Time (%.2fx) = %.2f s', speed, t(i)));
	pause(.03);
end