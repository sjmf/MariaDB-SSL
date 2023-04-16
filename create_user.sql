-- Update the names for your database, user and password as needed:
CREATE SCHEMA arc_iasc;
CREATE USER 'arc_iasc'@'%' IDENTIFIED BY '1234' REQUIRE SSL;
GRANT ALL PRIVILEGES ON arc_iasc.* TO 'arc_iasc'@'%';
