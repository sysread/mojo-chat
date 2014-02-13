package Data::Section;

use base 'Data';

Data::Section->table('section');
Data::Section->columns(Primary => 'id');
Data::Section->columns(Essential => qw(name active class));
Data::Section->has_a(class => 'Data::Class');

1;
