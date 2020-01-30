package Test::ProveRdeps;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;

use App::ProveRdeps;
use Data::Dmp;
use Test::Builder;

my $Test = Test::Builder->new;

sub import {
    my $self = shift;
    my $caller = caller;
    *{$caller.'::all_rdeps_ok'} = \&all_rdeps_ok;

    $Test->exported_to($caller);
    $Test->plan(@_);
}

sub all_rdeps_ok {
    my %opts = @_;
    my $res;
    my $ok = 1;

    {
        my $prres = App::ProveRdeps::prove_rdeps(%opts);
        unless ($prres->[0] == 200) {
            $Test->diag("Can't run prove_rdeps(): $prres->[0] - $prres->[1]");
            $Test->ok(0, "run prove_rdeps()");
            $ok = 0;
            last;
        }

        my $num_412 = 0;
        my $num_other_err = 0;
        for my $rec (@{ $prres->[2] }) {
            if ($rec->{status} == 412) {
                $num_412++;
            } elsif ($rec->{status} != 200) {
                $num_other_err++;
            }
        }

        if ($num_412 || $num_other_err) {
            $Test->diag("Some dependents cannot be tested or testing failed: ".dmp($prres->[2]));
        }

        if ($num_other_err) {
            $Test->ok(0, "prove_rdeps() result");
            $ok = 0;
            last;
        } else {
            $Test->ok(1, "prove_rdeps() result");
        }
    }

    $ok;
}

1;
# ABSTRACT: Test using App::ProveRdeps

=for Pod::Coverage ^()$

=head1 SYNOPSIS

 use Test::ProveRdeps tests=>1;
 all_rdeps_ok(
     modules => ["Foo::Bar"],
     # other options will be passed to App::ProveRdeps::prove_rdeps()
 );


=head1 DESCRIPTION

EXPERIMENTAL.


=head1 FUNCTIONS

=head2 all_rdeps_ok


=head1 SEE ALSO

L<App::ProveRdeps> and L<prove-rdeps>.

=cut
