#oodist: *** DO NOT USE THIS VERSION FOR PRODUCTION ***
#oodist: This file contains OODoc-style documentation which will get stripped
#oodist: during its release in the distribution.  You can use this file for
#oodist: testing, however the code of this development version may be broken!

package Dancer2::Plugin::LogReport::Message;
use parent 'Log::Report::Message';

use strict;
use warnings;

use Log::Report   'dancer2-plugin-logreport';

#--------------------
=chapter NAME

Dancer2::Plugin::LogReport::Message - extended Log::Report::Message class

=chapter SYNOPSIS

  In your template:

  [% FOR message IN messages %]
    <div class="alert alert-[% message.bootstrapColor %]">
      [% message.toString | html_entity %]
    </div>
  [% END %]

=chapter DESCRIPTION

[This Dancer2 plugin was contributed by Andrew Beverley]

This class is an extension of L<Log::Report::Message>, with functions
specifically designed for Dancer applications. Minimal functions are
provided (currently only aimed at Bootstrap), but ideas for new ones are
welcome.

=chapter METHODS

=section Constructors

=c_method new %options
=option  reason $reason
=default reason undef
The $reason reflects the exception level which is attached to message,
often derived from a caught exception.
=cut

sub init($)
{	my ($self, $args) = @_;
	$self->SUPER::init($args);
	$self->{reason} = $args->{reason};
	$self;
}

#----------------
=section Attributes

=method reason [$reason]
Get or set the reason of a message.
=cut

sub reason
{	my $self = shift;
	$self->{reason} = $_[0] if exists $_[0];
	$self->{reason};
}

=method bootstrapColor
[2.03] Get a suitable bootstrap context color for the message. This can be
used as per the SYNOPSIS.

CSS class C<success> is used for M<Dancer2::Plugin::LogReport::success()>
messages, C<info> colors are used for messages C<notice> and below,
C<warning> is used for C<warning> and C<mistake>, C<danger> is used for
all other messages.
=cut

my %reason2color = (
	TRACE   => 'info',
	ASSERT  => 'info',
	INFO    => 'info',
	NOTICE  => 'info',
	WARNING => 'warning',
	MISTAKE => 'warning',
);

sub bootstrapColor()
{	my $self = shift;
	$self->taggedWith('success') ? 'success' : ($reason2color{$self->reason} || 'danger');
}

=method bootstrap_color
Deprecated.  See M<bootstrapColor()>.
=cut

*bootstrap_color = \&bootstrapColor;

#-----------------
=section Serialization

[2.03] Log messages are/can be stored in the Session object.  The Session
object may be cached in a file, in various formats.  To be able to save
and restore these message objects from this session serialization, we
need to freeze and thaw the object at the right moment.  This happens
transparently.

=subsection JSON::XS serialization

For session serialization in the database, put this in your
configuration:

  engines:
    session:
      DBIC:
        serializer: JSON
        serialize_options:
          allow_tags: 1
        deserialize_options:
          allow_tags: 1

=method FREEZE $serializer
=error unsupported serializer '$s' for message FREEZE.
=cut

sub FREEZE($)
{	my ($self, $ser) = @_;
	$ser eq 'JSON'
		or error __x"unsupported serializer '{s UNKNOWN}' for message FREEZE.", s => $ser;

	$self->freeze;
}

=c_method THAW $serializer, $msg
=error unsupported serializer '$s' for message THAW.
=cut

sub THAW($@)
{	my ($class, $ser, $msg) = @_;
	$ser eq 'JSON'
		or error __x"unsupported serializer '{s UNKNOWN}' for message THAW.", s => $ser;

	$class->thaw($msg);
}

1;
