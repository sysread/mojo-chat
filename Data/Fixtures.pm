package Data::Fixtures;

use strict;
use warnings;

use Data::Dumper;

use Data::Position;
use Data::Person;
use Data::Course;
use Data::Section;
use Data::Class;


my @POSITIONS = (
    { name => 'Instructor' },
    { name => 'Student' },
);

my @PEOPLE    = (
    { first_name => 'Joe',    last_name => 'Stevens', position => 'Student' },
    { first_name => 'Jane',   last_name => 'Smith',   position => 'Student' },
    { first_name => 'Bob',    last_name => 'Ross',    position => 'Student' },
    { first_name => 'Martha', last_name => 'Ericson', position => 'Instructor' },
);

my @COURSES  = qw(Reading Writing Arithmetic);
my @SECTIONS = qw(001 002);


sub generate {
    # Add pretend postions
    Data::Position->find_or_create($_) foreach @POSITIONS;

    # Add pretend people
    Data::Person->find_or_create($_) foreach @PEOPLE;

    # Add pretend courses
    my @instructors = Data::Person->search({position => 'Instructor'});
    my $instructor  = $instructors[0];

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
                instructor => $instructor,
                active     => 1,
            });
        }
    }
}

1;
