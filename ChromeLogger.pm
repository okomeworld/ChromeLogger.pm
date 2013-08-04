package ChromeLogger;

use strict;
use warnings;

use JSON::XS;
use MIME::Base64;

my $VERSION = 4.1.0;

my $HEADER_NAME = 'X-ChromeLogger-Data';

my $TYPE = +{
	INFO => 'info',
	WARN => 'warn',
	ERROR => 'error',
	DEBUG => 'debug',
	LOG	=> 'log',
	GROUP => 'group',
	GROUP_END => 'groupEnd',
	GROUP_COLLAPSED => 'groupCollapsed',
	TABLE => 'table',
};

my $data_format = +{
	version => $VERSION,
	columns => +['log', 'backtrace', 'type'],
	rows => +[],
};

my $rows = +[];

sub log($) {
	my $data = shift;
	_log($TYPE->{LOG},$data);
}

sub warn($) {
	my $data = shift;
	_log($TYPE->{WARN},$data);
}

sub error($) {
	my $data = shift;
	_log($TYPE->{ERROR},$data);
}

sub info($) {
	my $data = shift;
	_log($TYPE->{INFO},$data);
}

sub table($) {
	my $data = shift;
	_log($TYPE->{TABLE},$data);
}

sub group($) {
	my $data = shift;
	_log($TYPE->{GROUP},$data);
}

sub group_end($) {
	my $data = shift;
	_log($TYPE->{GROUP_END},$data);
}

sub group_collapsed($) {
	my $data = shift;
	_log($TYPE->{GROUP_COLLAPSED},$data);
}

sub _log($$) {
	my ($type,$data) = @_;
	$type ||= '';

	my $logs = +[
		+[+{
			___class_name => _backtrace(),
			log => $data,
		}],
		_backtrace(),
		$type,
	];

	push @$rows, $logs;
}

sub _backtrace {
	my ($package,$filename,$line) = caller(2);
	return "$filename:$line";
}

sub get_header_name {
	return $HEADER_NAME;
}

sub _convert_log {
	my $res = $data_format;
	$res->{rows} = $rows;
	return $res;
}

sub get_log_data {
	my $res = _convert_log();
	$res = encode_base64(encode_json($data_format));
	$res =~ s/\n//g;
	return $res;
}

sub output_header {
	my $header_name = get_header_name();
	my $data = get_log_data();

	return "$header_name:$data";
}

1;
