package Text::PageLayout;

use utf8;
use 5.010;
use strict;
use warnings;

=head1 NAME

Text::PageLayout - Assemble paragraphs onto pages.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Text::PageLayout::Page;
use Moo;
use Scalar::Util qw/reftype/;

with 'Text::PageLayout::PageElements';

has page_size  => (
    is          => 'rw',
    default     => sub { 67 },
);

has tolerance  => (
    is          => 'rw',
    default     => sub { 6 },
);

has split_paragraph => (
    is          => 'rw',
    default     => sub {
        sub {
            my %param  = @_;
            my @lines  = split /\n/, $param{paragaraph}, $param{max_lines} + 1;
            my $last = pop @lines;
            return  (
                join("", map "$_\n", @lines),
                $last,
            );
        };
    },
);

sub line_count {
    my ($self, $str) = @_;
    my $cnt = $str =~ tr/\n//;
    return $cnt;
}

sub pages {
    my $self = shift;
    my $pars = $self->paragraphs;

    my @pages;

    my $separator    = $self->separator;
    my $sep_lines    = $self->line_count($separator);
    my $tolerance    = $self->tolerance;
    my $goal         = $self->page_size;
    my $current_page = 1;
    my $header       = $self->_get_elem('header', $current_page);
    my $footer       = $self->_get_elem('footer', $current_page);
    my $lines_used   = $self->line_count($header) + $self->line_count($footer);
    my @current_pars;

    for my $idx (0..$#$pars) {
        my $paragraph = $pars->[$idx];
        my $l = $self->line_count($paragraph);

        my $start_new_page = 0;
        if ( $lines_used + $l + $sep_lines <= $goal ) {
            $lines_used += $l;
            $lines_used += $sep_lines if @current_pars;
            push @current_pars, $paragraph;
        }
        elsif ( $lines_used + $tolerance >= $goal) {
            $start_new_page = 1;
        }
        else {
            $start_new_page = 1;
            my ($c1, $c2) = $self->split_paragraph->(
                paragraph   => $paragraph,
                max_lines   => $goal - $lines_used - $sep_lines,
                page        => $current_page,
            );
            my $c1_lines = $self->line_count($c1);
            if ($c1_lines + $lines_used <= $goal) {
                # accept the split
                $lines_used += $c1_lines;
                $lines_used += $sep_lines if @current_pars;
                push @current_pars, $c1;
                $paragraph = $c2;
            }
        }
        if ($start_new_page) {
            push @pages, Text::PageLayout::Page->new(
                paragraphs          => [@current_pars],
                page_number         => $current_page,
                header              => $header,
                footer              => $footer,
                process_template    => $self->process_template,
                bottom_filler       => "\n" x ($goal - $lines_used),
                separator           => $separator,
            );
            $current_page++;
            @current_pars = ($paragraph);
            $header       = $self->_get_elem('header', $current_page);
            $footer       = $self->_get_elem('footer', $current_page);
            $lines_used   = $self->line_count($header) + $self->line_count($footer)
                            + $self->line_count($paragraph);
        }
    }
    if (@current_pars) {
        # final page
        push @pages, Text::PageLayout::Page->new(
            paragraphs          => [@current_pars],
            page_number         => $current_page,
            header              => $header,
            footer              => $footer,
            process_template    => $self->process_template,
            bottom_filler       => "\n" x ($goal - $lines_used),
        );
    }
    for my $p (@pages) {
        $p->total_pages($current_page);
    }
    return @pages;
}

sub _get_elem {
    my ($self, $elem, $page) = @_;
    my $e = $self->$elem();
    if (ref $e && reftype($e) eq 'CODE') {
        $e = $e->(page => $page);
    }
    return $e;
}


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Text::PageLayout;

    my $foo = Text::PageLayout->new();
    ...


=head1 METHODS

=head2 function1

=head1 AUTHOR

Moritz Lenz, C<< <moritz at faui2k3.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-pagelayout at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-PageLayout>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::PageLayout


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-PageLayout>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-PageLayout>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-PageLayout>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-PageLayout/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Moritz Lenz.
Written for L<noris network AG|http://www.noris.net/>.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Text::PageLayout
