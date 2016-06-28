use Mojo::Base -strict;

use Test::More;
use Mojo::Pg::Che;
use Scalar::Util 'refaddr';

my $class = 'Mojo::Pg::Che';
my $results_class = 'Mojo::Pg::Results';

# 1
my $pg = $class->connect("DBI:Pg:dbname=test;", "guest", undef, {pg_enable_utf8 => 1,})->on_connect(['set datestyle to "DMY, ISO";']);

my $result;
$result = $pg->query('select now() as now',);

isa_ok($result, $results_class);
like($result->hash->{now}, qr/\d{4}-\d{2}-\d{2}/, 'now query ok');

for (13..17) {
  $result = $pg->query('select ?::date as d', undef, ("$_/06/2016"));
  like($result->hash->{d}, qr/2016-06-$_/, 'date query ok');
}


{
  #~ my $db = $pg->db;
  my $sth = $pg->prepare('select ?::date as d');

  for (13..17) {
    $result = $pg->query($sth, undef, ("$_/06/2016"));
    like($result->hash->{d}, qr/2016-06-$_/, 'date sth ok');
  }
};


{
  my @results;
  my $cb = sub {
    #~ warn 'Non-block done';
    my ($db, $err, $results) = @_;
    die $err if $err;
    push @results, $results;
  };

  for (13..17) {
    $pg->query('select ?::date as d, pg_sleep(?::int)', {cached=>1,}, ("$_/06/2016", 2), $cb);
  }
  Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
  for (@results) {
    like($_->hash->{d}, qr/2016-06-\d+/, 'date sth ok');
  }
};


$result = undef;

my $cb = sub {
  #~ warn 'Non-block done';
  my ($db, $err, $results) = @_;
  die $err if $err;
  $result = $results;
};

$pg->db->query('select pg_sleep(?::int), now() as now' => 3, $cb);
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
like($result->hash->{now}, qr/\d{4}-\d{2}-\d{2}/, 'now non-block-query ok');

for (13..17) {
  my $result = $pg->query('select ?::date as d, pg_sleep(?::int)', {async=>1,}, ("$_/06/2016", 1), sub {die 'Will ignore';});
  like($result->hash->{d}, qr/2016-06-$_/, 'date async query ok');
}

done_testing();