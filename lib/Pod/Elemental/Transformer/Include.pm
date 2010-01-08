package Pod::Elemental::Transformer::Include;

use strict;
use warnings;

use 5.10.0;

our $VERSION = '1.0';

use Cwd;
use File::Spec::Functions;

use File::Slurp qw(slurp);

use Moose;

with 'Pod::Elemental::Transformer';

# ABSTRACT: include output via files and commands

sub transform_node {
    my ($self, $node) = @_;

    foreach my $child (@{$node->children}) {
        next unless ($child->content =~ /^include_/);

        my @output;
        my $action = $child->content;
        given ($action) {
            when (/^include_cmd:/) {
                my $cmd = $child->content;
                $cmd =~ /^include_cmd:(\s*)/;
                my $ws = $1 || '';
                $cmd =~ s/^include_cmd:\s*//;
                #say("cmd:$ws$cmd");
                $cmd = cwd() . '/' . $cmd;
                @output = qx($cmd);
                $child->content($ws . join($ws, @output));
            }
            when (/^include_file:/) {
                my $filename = $child->content;
                $filename =~ /^include_file:(\s*)/;
                my $ws = $1 || '';
                $filename =~ s/^include_file:\s*//;
                $filename = catfile(cwd(), $filename);
                #say("file:$ws$filename");
                my @output = slurp($filename, 'err_mode' => 'carp');
                $child->content($ws . join($ws, @output));
            }
        }
    }
}

1;

=head1 DESCRIPTION

A simple way to include files and output of commands in POD via L<Pod::Weaver>.

=head1 SYNOPSIS

    =head1 DIRECTORY LISTING

    include_file:header.txt

        include_cmd:ls

    include_cmd:blah

    include_file:footer.txt

=head1 USING

There are two supported identifiers C<include_file:> and C<include_cmd:>. They
must be placed at the beginning of the line optionally followed by white
space. When there is white space then the every line of output included will be
prefixed with that same amount of white space. For example,

    include_cmd:echo no white space

becomes,

    no white space

Where as,

    include_cmd:    echo 4 spaces

becomes,

        4 spaces

Errors are not fatal. But, you will see if something failed by prints to
standard output.

=over

=item * C<include_file:> - Replaces line with the file contents and does no
transformation on the data.

=item * C<include_cmd:> - Replaces the line with the command output and does no
transformation on the data.

=back

=head1 WARNING

Be careful what you execute with C<include_cmd:>.

=head1 SETUP

There may be another eloquent and preferred way, but I've gone with a
L<Pod::Weaver> PluginBundle in conjunction with L<Dist::Zilla>. A quick howto:

First setup a PluginBundle:

    package Pod::Weaver::PluginBundle::aflott;
    sub mvp_bundle_config {
      return (
        [ '@aflott/Default', 'Pod::Weaver::PluginBundle::Default', {} ],
        [ '@aflott/List',    'Pod::Weaver::Plugin::Transformer', { 'transformer' => 'List' } ],
        [ '@aflott/Include', 'Pod::Weaver::Plugin::Transformer', { 'transformer' => 'Include' } ],
      );
    }

Then insider your F<dist.ini>,

    [PodWeaver]
    config_plugin = @aflott

And now,

    $ dzil build
