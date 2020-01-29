package Test::ProveDeps;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;

use App::ProveDeps;
use Data::Dmp;

my $Test = Test::Builder->new;

sub all_dependents_ok {
    my %opts   = (@_ && (ref $_[0] eq "HASH")) ? %{(shift)} : ();
    my $res;
    my $ok = 1;

    {
        my $pdres = App::ProveDeps::prove_deps(%opts);
        unless ($pdres->[0] == 200) {
            $Test->diag("Can't run prove_deps(): $pdres->[0] - $pdres->[1]");
            $Test->ok(0, "run prove_deps()");
            $ok = 0;
            last;
        }

        my $num_412 = 0;
        my $num_other_err = 0;
        for my $rec (@{ $pdres->[2] }) {
            if ($rec->{status} == 412) {
                $num_412++;
            } elsif ($rec->{status} != 200) {
                $num_other_err++;
            }
        }

        if ($num_412 || $num_other_err) {
            $Test->diag("Some dependents cannot be tested or testing failed: ".dmp($pdres->[2]));
        }

        if ($num_other_err) {
            $Test->ok(0, "prove_deps() result");
            $ok = 0;
            last;
        } else {
            $Test->ok(1, "prove_deps() result");
        }
    }

    $ok;
}

1;
# ABSTRACT: Test using App::ProveDeps

=for Pod::Coverage ^()$

=head1 SYNOPSIS

 use Test::ProveDeps tests=>1;
 all_dependents_ok(
     modules => ["Foo::Bar"],
     # other options will be passed to App::ProveDeps::prove_deps()
 );


=head1 DESCRIPTION


=head1 SEE ALSO

L<App::ProveDeps> and L<prove-deps>.

=cut
