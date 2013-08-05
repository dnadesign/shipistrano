DROP DATABASE IF EXISTS `shipistrano_test_db`;
DROP DATABASE IF EXISTS `shipistrano_test_db_uploaded`;
DROP DATABASE IF EXISTS `shipistrano_test_db_uploaded_alt`;

CREATE DATABASE `shipistrano_test_db`;
USE `shipistrano_test_db`;

CREATE TABLE `test` (
  `message` text,
  `test` varchar(20)
);