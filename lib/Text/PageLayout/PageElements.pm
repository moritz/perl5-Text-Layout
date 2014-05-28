package Text::PageLayout::PageElements;

use 5.010;
use strict;
use warnings;
use utf8;

use Moose::Role;

has paragraph_separator => (
    is      => 'rw',
    default => sub { "\n" },
);

has header => (
    is          => 'ro',
    default     => sub { '' },
);
has footer => (
    is          => 'rw',
    default     => sub { '' },
);
has paragraphs => (
    is          => 'rw',
    required    => 1,
);
has separator => (
    is          => 'rw',
    default     => sub { "\n" },
);
has process_template => (
    is          => 'rw',
    default     => sub { sub { my %param = @_; return $param{template} } },
);


1;
