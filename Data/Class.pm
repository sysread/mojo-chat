package Data::Class;

use base 'Data';

__PACKAGE__->table('class');
__PACKAGE__->columns(Primary => 'rowid');
__PACKAGE__->columns(Essential => qw(active course section));
__PACKAGE__->has_a(course => 'Data::Course');
__PACKAGE__->has_a(section => 'Data::Section');

1;
