package Data::Position;

use base 'Data';

__PACKAGE__->table('position');
__PACKAGE__->columns(Primary => 'rowid');
__PACKAGE__->columns(Essential => qw(name));

1;
