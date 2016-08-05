package Mojo::Pg::Che;

use Mojo::Base 'Mojo::Pg';

=pod

=encoding utf-8

Доброго всем

=head1 Mojo::Pg::Che

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojo::Pg::Che - mix of parent Mojo::Pg and DBI.pm

=head1 VERSION

Version 0.052

=cut

our $VERSION = '0.052';


=head1 SYNOPSIS



    use Mojo::Pg::Che;

    my $pg = Mojo::Pg::Che->connect("dbname=test;", "postgres", 'pg-pwd', \%attrs);
    # or
    my $pg = Mojo::Pg::Che->new
      ->dsn("DBI:Pg:dbname=test;")
      ->username("postgres")
      ->password('pg--pw')
      ->options(\%attrs);

    # Bloking query
    my $result = $pg->query('select ...', undef, @bind);
    
    # Non-blocking query
    my $result = $pg->query('select ...', {Async => 1, ...}, @bind);
    
    # Cached query
    my $result = $pg->query('select ...', {Cached => 1, ...}, @bind);
    
    # prepare sth
    my $sth = $pg->prepare('select ...');
    
    # cached sth
    my $sth = $pg->prepare_cached('select ...');
    
    # Non-blocking query sth
    my $r = $pg->query($sth, undef, @bind, sub {my ($db, $err, $result) = @_; ...});
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
    
    # Result non-blocking query sth
    my $result = $pg->query($sth, {Async => 1,}, @bind,);
    
    # Mojo::Pg style
    my $now = $pg->db->query('select now() as now')->hash->{now};
    
    # DBI style
    my $now = $pg->selectrow_hashref('select now() as now')->{now};
    my $now = $pg->db->selectrow_hashref('select now() as now')->{now};
    
    my $now = $pg->selectrow_array('select now() as now');

=head2 Transaction syntax

  eval {
    my $tx = $pg->begin;
    $tx->query('insert into foo (name) values (?)', 'bar');
    $tx->do('insert into foo (name) values (?)', 'baz');
    $tx->commit;
  };
  die $@ if $@;
  
  my $tx = $pg->begin;
  $tx->do('insert into foo (name) values (?)', 'bazzzz');
  $tx->rollback;
  $tx->begin;
  $tx->query('insert into foo (name) values (?)', 'barrr');
  $tx->commit;

=head1 Non-blocking query cases

Depends on $attr->{Async} and callback:

1. $attr->{Async} set to 1. None $cb. Callback will create and Mojo::IOLoop will auto start. Method C<< ->query() >> will return result object. Methods C<<->select...()>> will return there perl structures.

2. $attr->{Async} not set. $cb defined. All ->query() and ->select...() methods will return reactor object and results pass to $cb. You need start Mojo::IOLoop:

  my @results;
  my $cb = sub {
    my ($db, $err, $results) = @_;
    die $err if $err;
    push @results, $results;
  };
  $pg->query('select ?::date as d, pg_sleep(?::int)', undef, ("2016-06-$_", 1), $cb)
    for 17..23;
  Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
  like($_->hash->{d}, qr/2016-06-\d+/, 'correct async query')
    for @results;


3. $attr->{Async} set to 1. $cb defined. Mojo::IOLoop will auto start. Results pass to $cb.


=head1 METHODS

All methods from parent module L<Mojo::Pg> are inherits and implements the following new ones.

=head2 connect

DBI-style of new object instance. See L<DBI#connect>

=head2 query

Like L<Mojo::Pg::Database#query> but input params - L<Mojo::Pg::Che#Params-for-quering-methods>

Blocking query without attr B<Async> or callback.

Non-blocking query with attr B<Async> or callback.

=head2 db

Overriden method of L<Mojo::Pg#db>. Because can first input param - DBI database handler (when prepared statement used).

=head2 prepare

Prepare and return DBI statement handler for query string.

=head2 prepare_cached

Prepare and return DBI cached statement handler for query string.

=head2 selectrow_array

DBI style quering. See L<DBI#selectrow_array>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 selectrow_arrayref

DBI style quering. See L<DBI#selectrow_arrayref>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 selectrow_hashref

DBI style quering. See L<DBI#selectrow_hashref>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 selectall_arrayref

DBI style quering. See L<DBI#selectall_arrayref>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 selectall_hashref

DBI style quering. See L<DBI#selectall_hashref>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 selectcol_arrayref

DBI style quering. See L<DBI#selectcol_arrayref>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 do

DBI style quering. See L<DBI#do>. Blocking|non-blocking, query string|statement handler. Input params - L<Mojo::Pg::Che#Params-for-quering-methods>.

=head2 begin

Start transaction and return new <Mojo::Pg::Che::Database> object which attr C< {tx} > is a <Mojo::Pg::Transaction> object. Sinonyms are: C<< ->tx >> and C<< ->begin_work >>.

=head1 Params for quering methods

The methods C<query>, C<select...>, C<do> has next input params:

=over 4

=item * String query | statement handler object

=item * Hashref attrs (optional)

=item * Array of bind values (optional)

=item * Callback non-blocking (optional)

=back

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=head1 BUGS / CONTRIBUTING

Please report any bugs or feature requests at L<https://github.com/mche/Mojo-Pg-Che/issues>. Pull requests also welcome.

=head1 COPYRIGHT

Copyright 2016 Mikhail Che.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Carp qw(croak);

has db_class => sub {
  require Mojo::Pg::Che::Database;
  'Mojo::Pg::Che::Database';
};

has options => sub {
  {AutoCommit => 1, AutoInactiveDestroy => 1, PrintError => 0, RaiseError => 1, ShowErrorStatement => 1, pg_enable_utf8 => 1,};
};

has [qw(debug)];

sub connect {
  my $self = shift->SUPER::new;
  map $self->$_(shift), qw(dsn username password);
  if (my $attrs = shift) {
    my $options = $self->options;
    @$options{ keys %$attrs } = values %$attrs;
  }
  $self->dsn('DBI:Pg:'.$self->dsn)
    unless $self->dsn =~ /^DBI:Pg:/;
  return $self;
}

sub query {
  my $self = shift;
  #~ my ($query, $attrs, @bind) = @_;
  my ($sth, $query) = ref $_[0] ? (shift, undef) : (undef, shift);
  
  my $attrs = shift;
  my $async = delete $attrs->{Async} || delete $attrs->{pg_async};
  
  my $cb = ref $_[-1] eq 'CODE' ? pop : undef;
  my $result;
  $cb ||= sub {
    my ($db, $err) = map shift, 1..2;
    croak "Error on non-blocking query: ",$err
      if $err;
    $result = shift;
    
  } if $async;
  
  my @bind = @_;
  
  #~ $sth ||= $self->prepare($query, $attrs, 3); ?????
  
  if ($sth) {$result = $self->db($sth->{Database})->execute_sth($sth, @bind, $cb ? ($cb) : ());}
  else {$result = $self->db->execute_string($query, $attrs, @bind, $cb ? ($cb) : (),);}
  
  Mojo::IOLoop->start if $async && not(Mojo::IOLoop->is_running);

  return $result;
  
}

sub db {
  my ($self, $dbh) = (shift, shift);

  # Fork-safety
  delete @$self{qw(pid queue)} unless ($self->{pid} //= $$) eq $$;
  
  $dbh ||= $self->_dequeue;

  return $self->db_class->new(dbh => $dbh, pg => $self);
}

sub prepare { shift->db->prepare(@_); }
sub prepare_cached { shift->db->prepare_cached(@_); }

sub _db_sth {shift->db(ref $_[0] && $_[0]->{Database})}

sub selectrow_array { shift->_db_sth(@_)->selectrow_array(@_) }
sub selectrow_arrayref { shift->_db_sth(@_)->selectrow_arrayref(@_) }
sub selectrow_hashref { shift->_db_sth(@_)->selectrow_hashref(@_) }
sub selectall_arrayref { shift->_db_sth(@_)->selectall_arrayref(@_) }
sub selectall_hashref { shift->_db_sth(@_)->selectall_hashref(@_) }
sub selectcol_arrayref { shift->_db_sth(@_)->selectcol_arrayref(@_) }
sub do { shift->_db_sth(@_)->do(@_) }

#~ sub begin_work {croak 'Use $pg->db->tx | $pg->db->begin';}
sub tx {shift->begin}
sub begin_work {shift->begin}
sub begin {
  my $self = shift;
  my $db = $self->db;
  $db->begin;
  return $db;
}

sub commit {croak 'Use: $tx = $pg->begin; $tx->do(...); $tx->commit;';}
sub rollback {croak 'Use: $tx = $pg->begin; $tx->do(...); $tx->rollback;';}

# Patch parent Mojo::Pg::_dequeue
sub _dequeue {
  my $self = shift;

  #~ while (my $dbh = shift @{$self->{queue} || []}) { return $dbh if $dbh->ping }
  
  my $queue = $self->{queue} ||= [];
  
  while (my ($i, $dbh) = each @$queue) {
  #~ for my $i (0..$#$queue) {
    
    #~ my $dbh = $queue->[$i];
    
    delete $queue->[$i]
      and next
      unless $dbh->ping;
    
    #~ say STDERR "DBH [$dbh] из пула" and
    return delete $queue->[$i]
    #~ say STDERR "Async: $dbh->{pg_async_status}";
     #~ return $dbh #(splice(@$queue, $i, 1))[0]
      unless $dbh->{pg_async_status} > 0;
  }
  
  my $dbh = DBI->connect(map { $self->$_ } qw(dsn username password options));
  #~ say STDERR "НОвое [$dbh] соединение";
  

  #~ if (my $path = $self->search_path) {
    #~ my $search_path = join ', ', map { $dbh->quote_identifier($_) } @$path;
    #~ $dbh->do("set search_path to $search_path");
  #~ }
  
  #~ ++$self->{migrated} and $self->migrations->migrate
    #~ if !$self->{migrated} && $self->auto_migrate;
  $self->emit(connection => $dbh);

  return $dbh;
}

sub _enqueue {
  my ($self, $dbh) = @_;
  my $queue = $self->{queue} ||= [];
  push @$queue, $dbh
    if $dbh->{Active} && @$queue < $self->max_connections;
  #~ shift @$queue while @$queue > $self->max_connections;
}

1;


