-- Buat skema SALAM
create schema SALAM;

-- Buat tabel mahasiswas
create table SALAM.mahasiswas(
	nim VARCHAR(15) primary key,
	nama VARCHAR(50) not null,
	jurusan VARCHAR(50) not null,
	dosen_pembimbing VARCHAR(50) not null,
	email VARCHAR(50) unique,
	semester INT CHECK (semester BETWEEN 1 AND 14)
);

INSERT INTO SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester) 
VALUES 
('12475050075', 'Raihan Dwiyuga Fadilah', 'Teknik Informatika', 'Wildan Budiawan Zulfikar', 'raihan@gmail.com', 5),
('12475050006', 'Raihan Khoirul Aziz', 'Teknik Informatika', 'Cepy Slamet', 'raihankhoirul@gmail.com', 5),

-- Uji Constraint

-- 1. Uji NIM
INSERT INTO SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester) 
VALUES 
('12475050075', 'Naufal Faishal', 'Teknik Informatika', 'Agung Wahana', 'raihan@gmail.com', 5);

-- 2. Uji email
INSERT INTO SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester) 
VALUES 
('124750500045', 'Naufal Faishal', 'Teknik Informatika', 'Agung Wahana', 'raihankhoirul@gmail.com', 5);

-- 3. Uji semester
INSERT INTO SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester) 
VALUES 
('124750500045', 'Naufal Faishal', 'Teknik Informatika', 'Agung Wahana', 'faishal@gmail.com', 20);
