-- sql/mysql_source_setup.sql

CREATE DATABASE IF NOT EXISTS hospital_source;
USE hospital_source;

DROP TABLE IF EXISTS patient_contact;

CREATE TABLE patient_contact (
    patient_nbr   BIGINT PRIMARY KEY,
    phone         VARCHAR(20),
    city          VARCHAR(50),
    country       VARCHAR(50)
);

INSERT INTO patient_contact (patient_nbr, phone, city, country) VALUES
(115014015, '+254700111222', 'Nairobi', 'Kenya'),
(80751879,   '+251911223344', 'Addis Ababa', 'Ethiopia'),
(23974596,   '+254701222333', 'Mombasa', 'Kenya'),
(24267006,   '+255711333444', 'Arusha', 'Tanzania'),
(23468526,   '+250788444555', 'Kigali', 'Rwanda');
