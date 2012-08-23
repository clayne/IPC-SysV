################################################################################
#
#  $Revision: 12 $
#  $Author: mhx $
#  $Date: 2007/10/13 04:13:17 +0100 $
#
################################################################################
#
#  Version 2.x, Copyright (C) 2007, Marcus Holland-Moritz <mhx@cpan.org>.
#  Version 1.x, Copyright (C) 1999, Graham Barr <gbarr@pobox.com>.
#
#  This program is free software; you can redistribute it and/or
#  modify it under the same terms as Perl itself.
#
################################################################################

require 5.004_05;

use strict;
use ExtUtils::MakeMaker;

unless ($ENV{'PERL_CORE'}) {
  $ENV{'PERL_CORE'} = 1 if grep { $_ eq 'PERL_CORE=1' } @ARGV;
}

WriteMakefile(
  NAME         => 'IPC::SysV',
  VERSION_FROM => 'lib/IPC/SysV.pm',
  PREREQ_PM    => {
                    'Test::More' => 0.45,
                  },
  CONFIGURE    => \&configure,
);

sub configure
{
  my @moreopts;
  my %depend;

  if (eval $ExtUtils::MakeMaker::VERSION >= 6) {
    push @moreopts, AUTHOR => 'Marcus Holland-Moritz <mhx@cpan.org>',
                    ABSTRACT_FROM => 'lib/IPC/SysV.pm';
  }

  if (eval $ExtUtils::MakeMaker::VERSION >= 6.30_01) {
    print "Setting license tag...\n";
    push @moreopts, LICENSE => 'perl';
  }

  if ($ENV{'PERL_CORE'}) {
    # Pods will be built by installman.
    push @moreopts, MAN3PODS => {};
  }
  else {
    # IPC::SysV is in the core since 5.005
    push @moreopts, INSTALLDIRS => ($] >= 5.005 ? 'perl' : 'site');
  }

  $depend{'SysV.xs'} = 'const-c.inc const-xs.inc';

  return {
    depend => \%depend,
    @moreopts
  };
}


#--- MY package

sub MY::libscan
{
 my($self, $path) = @_;
 return '' if $path =~ m! /(RCS|CVS|SCCS)/ | [~%]$ | \.(orig|rej)$ !x;
 $path;
}

sub MY::postamble
{
  package MY;
  my $post = shift->SUPER::postamble(@_);
  $post .= <<'POSTAMBLE';

purge_all: realclean
	@$(RM_F) const-c.inc const-xs.inc

regen:
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) regen.pl

const-c.inc: lib/IPC/SysV.pm regen.pl
	@$(MAKE) regen

const-xs.inc: lib/IPC/SysV.pm regen.pl
	@$(MAKE) regen

POSTAMBLE
  return $post;
}
