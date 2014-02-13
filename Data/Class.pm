package Data::Class;

use base 'Data';

Data::Class->table('class');
Data::Class->columns(Primary => 'id');
Data::Class->columns(Essential => qw(name active));
Data::Class->has_many(sections => 'Data::Section');

1;
