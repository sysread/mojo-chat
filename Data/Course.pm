#-------------------------------------------------------------------------------
# This is an individual course of study. It stores data shared between all
# sections of a course.
#-------------------------------------------------------------------------------
package Data::Course;

use base 'Data';

__PACKAGE__->table('course');
__PACKAGE__->columns(Primary => 'rowid');
__PACKAGE__->columns(Essential => qw(name));
__PACKAGE__->has_many(sections => 'Data::Section');
__PACKAGE__->has_many(classes => 'Data::Class');

1;
