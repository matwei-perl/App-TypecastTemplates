package App::TypecastTemplates;

use 5.006;
use strict;
use warnings;

use Template;
use Text::CSV;

=head1 NAME

App::TypecastTemplates - Format records with different templates.

=head1 VERSION

Version v0.1.0

=cut

our $VERSION = 'v0.1.0';

=head1 SYNOPSIS

This module allows to print records from a table using different templates.
The template to be used for a record is chosen by the value of the column
named "type" for that record.
The table is expected to be CSV formatted.

The module can be used without any script using the following command line:

    perl -M App::TypecastTemplates -e tt_run

It expects the table in CSV format at STDIN and prints the formatted records
to STDOUT.

=head1 EXPORT

This module exports the function C<< run >>, that does the formatting.

=cut

our @EXPORT = qw( tt_run );
use Exporter;
our @ISA = qw( Exporter );

=head1 SUBROUTINES/METHODS

=head2 tt_run

=cut

sub tt_run {
	my $tmpl = _read_templates(\*DATA);
	my $tt = new Template();
	my $csv = Text::CSV->new({
			binary => 1,
			auto_diag => 1,
			sep_char => ',',
		});
	my $fn = $main::ARGS[0] || '-';
	open(my $handle, '<' . $fn)
		or die "can't open credentials file '$fn'";
	my @cols = $csv->getline( $handle );
	$csv->column_names( @cols );
	while (my $r = $csv->getline_hr( $handle )) {
		if (exists $tmpl->{$r->{type}}) {
			my $template = $tmpl->{$r->{type}};
			$tt->process(\$template, $r);
		}
		else {
			die "No template for type '$r->{type}'";
		}
	}
} # tt_run()

#--- internal functions only ---

sub _read_templates {
	my ($fh) = @_;
	my $templates = {};

	while (my $tl = <$fh>) {
		my ($type,$line) = split /:/, $tl, 2;
		if (exists $templates->{$type}) {
			$templates->{$type} .= $line;
		}
		else {
			$templates->{$type} = $line;
		}
	}
	return $templates;
} # _read_templates

=head1 AUTHOR

Mathias Weidner, C<< <mamawe at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-typecasttemplates at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-TypecastTemplates>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TypecastTemplates


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=App-TypecastTemplates>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-TypecastTemplates>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/App-TypecastTemplates>

=item * Search CPAN

L<https://metacpan.org/release/App-TypecastTemplates>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2021 by Mathias Weidner.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of App::TypecastTemplates

__DATA__
cisco:
cisco:### [% name %] (cisco) ###
cisco:add method [% name %] {ssh}
cisco:add user [% name %] {[% user %]}
cisco:add password [% name %] {[% password %]} {[% enablepw %]}
mikrotik:
mikrotik:### [% name %] (mikrotik) ###
mikrotik:add method [% name %] {ssh}
mikrotik:add user [% name %] {[% user %]}
mikrotik:add password [% name %] {[% password %]}
