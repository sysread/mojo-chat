DROP TABLE IF EXISTS position;
CREATE TABLE position (
    name        TEXT NOT NULL
);

DROP TABLE IF EXISTS person;
CREATE TABLE person (
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    position    INT NOT NULL,
    FOREIGN KEY(position) REFERENCES position(rowid)
);

DROP TABLE IF EXISTS course;
CREATE TABLE course (
    name        TEXT UNIQUE NOT NULL
);

DROP TABLE IF EXISTS section;
CREATE TABLE section (
    name        TEXT NOT NULL,
    course      INT NOT NULL,
    FOREIGN KEY(course) REFERENCES course(rowid)
);

DROP TABLE IF EXISTS class;
CREATE TABLE class (
    active      INT,
    course      INT NOT NULL,
    section     INT NOT NULL,
    instructor  INT NOT NULL,
    FOREIGN KEY(course)     REFERENCES course(rowid),
    FOREIGN KEY(section)    REFERENCES section(rowid),
    FOREIGN KEY(instructor) REFERENCES person(rowid)
);
