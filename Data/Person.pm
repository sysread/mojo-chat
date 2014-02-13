package Data::Person;

use base 'Data';

__PACKAGE__->table('person');
__PACKAGE__->columns(Primary => 'rowid');
__PACKAGE__->columns(Essential => qw(
    first_name
    last_name
    position
));

__PACKAGE__->has_a(position => 'Data::Position');
__PACKAGE__->has_many(classes => 'Data::Class');

1;
