#-------------------------------------------------------------------------------
# This is an invidual section of a course.
#-------------------------------------------------------------------------------
package Data::Section;

use base 'Data';

__PACKAGE__->table('section');
__PACKAGE__->columns(Primary => 'rowid');
__PACKAGE__->columns(Essential => qw(name course));
__PACKAGE__->has_a(course => 'Data::Course');

1;
