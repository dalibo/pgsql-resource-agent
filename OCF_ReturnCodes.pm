#!/usr/bin/perl
# This program is open source, licensed under the PostgreSQL License.
# For license terms, see the LICENSE file.
#
# Copyright (C) 2015: Jehan-Guillaume de Rorthais and Mael Rimbault

=head1 OCF_ReturnCodes

OCF_ReturnCodes - Common varibales for the OCF Resource Agents supplied by
heartbeat.

This has been ported from the ocf-returncodes shell script.

=cut

package OCF_ReturnCodes;

use strict;
use warnings;
use 5.008;

BEGIN {
    use Exporter;

    our $VERSION   = 0.1;
    our @ISA       = ('Exporter');
    our @EXPORT    = qw(
        $OCF_SUCCESS
        $OCF_ERR_GENERIC
        $OCF_ERR_ARGS
        $OCF_ERR_UNIMPLEMENTED
        $OCF_ERR_PERM
        $OCF_ERR_INSTALLED
        $OCF_ERR_CONFIGURED
        $OCF_NOT_RUNNING
        $OCF_RUNNING_MASTER
        $OCF_FAILED_MASTER
    );
    our @EXPORT_OK = ( @EXPORT );
}

our $OCF_SUCCESS           = 0;
our $OCF_ERR_GENERIC       = 1;
our $OCF_ERR_ARGS          = 2;
our $OCF_ERR_UNIMPLEMENTED = 3;
our $OCF_ERR_PERM          = 4;
our $OCF_ERR_INSTALLED     = 5;
our $OCF_ERR_CONFIGURED    = 6;
our $OCF_NOT_RUNNING       = 7;
our $OCF_RUNNING_MASTER    = 8;
our $OCF_FAILED_MASTER     = 9;

1;
