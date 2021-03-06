#!/usr/bin/env perl

use strict;
use warnings;
use feature qw( say );

use lib './lib';
use MetaCPAN::Util qw( es );

my $scroller = es()->scroll_helper(
    search_type => 'scan',
    scroll      => '5m',
    index       => 'cpan',
    type        => 'author',
    size        => 100,
    body        => {
        query => {
            filtered => {
                filter => {
                    or => [
                        {
                            and => [
                                {
                                    term => {
                                        'profile.name' => 'twitter'
                                    }
                                },
                                { term => { 'country' => 'US' } }
                            ]
                        },
                        {
                            and => [
                                {
                                    term => { 'profile.name' => 'github' }
                                },
                                { term => { 'country' => 'CA' } }
                            ]
                        },
                    ],
                }
            },
        }
    },
);

while ( my $result = $scroller->next ) {
    my $author = $result->{_source};

    foreach my $profile ( @{ $author->{profile} } ) {
        if ( $author->{country} eq 'CA' ) {
            next unless $profile->{name} eq 'github';
        }
        else {
            next unless $profile->{name} eq 'twitter';
        }

        say sprintf(
            'author %s country %s %s %s',
            $author->{pauseid}, $author->{country},
            $profile->{name},   $profile->{id}
        );
        last;
    }
}

=pod

Demonstrates ANDs nested inside an OR.

=cut
