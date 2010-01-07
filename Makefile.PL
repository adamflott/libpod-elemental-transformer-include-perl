
use strict;
use warnings;



use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Pod-Elemental-Transformer-Include',
  NAME      => 'Pod::Elemental::Transformer::Include',
  AUTHOR    => "Adam\ Flott",
  ABSTRACT  => "include\ output\ via\ files\ and\ commands",
  VERSION   => '1.000',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "File::Slurp" => '0',
  },
  test => {TESTS => 't/*.t'}
);

