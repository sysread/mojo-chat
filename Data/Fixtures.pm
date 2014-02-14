#-------------------------------------------------------------------------------
# This module provides some fake data to populate the chat rooms.
#-------------------------------------------------------------------------------
package Data::Fixtures;

use strict;
use warnings;

use Data::Dumper;

use Data::Course;
use Data::Section;
use Data::Class;


my @COURSES  = qw(Reading Writing Arithmetic);
my @SECTIONS = qw(001 002);


sub generate {
    foreach my $course_name (@COURSES) {
        my $course = Data::Course->find_or_create({
            name => $course_name,
        });

        # Add pretend sections
        foreach my $section_name (@SECTIONS) {
            my $section = Data::Section->find_or_create({
                name   => $section_name,
                course => $course,
            });

            # Add pretend classes
            my $class = Data::Class->find_or_create({
                course     => $course,
                section    => $section,
                active     => 1,
            });
        }
    }
}

1;
