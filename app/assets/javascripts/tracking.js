
function pad(s) {
	return (s.toString().length < 2) ? "0" + s : s;
}

function time_period_string(period) {
	return pad(period.hours) + ':' + pad(period.minutes) + ':' + pad(period.seconds)
}
