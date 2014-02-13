package Data;

use base 'Class::DBI';

Data->connection('dbi:SQLite:data.db', '', '');

1;
