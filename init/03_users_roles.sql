-- Membuat user dan role

-- membuat 3 user baru (password bebas, ini contoh)
create user backend_dev   with password 'backend123';
create user bi_dev        with password 'bi123';
create user data_engineer with password 'de123';

-- 1. backend_dev : CRUD semua table
grant usage on schema SALAM to backend_dev;
grant select, insert, update, delete on all tables in schema SALAM to backend_dev;

-- 2. bi_dev : hanya SELECT semua table/view
grant usage on schema SALAM to bi_dev;
grant select on all tables in schema SALAM to bi_dev;   

-- 3. data_engineer : CREATE, MODIFY, DROP semua objek + CRUD

-- pemilik objek boleh create/alter/drop objeknya sendiri,
-- jadi skema dan semua objek di dalamnya dipindahkan kepemilikannya
alter schema SALAM owner to data_engineer;
alter table SALAM.mahasiswas owner to data_engineer;
alter view SALAM.v_mahasiswa_aktif owner to data_engineer;
alter view SALAM.v_email_belum_diisi owner to data_engineer;
alter function SALAM.ubah_status_mahasiswa(varchar, boolean) owner to data_engineer;

-- Hak akses otomatis untuk objek yang dibuat data_engineer
alter default privileges for role data_engineer in schema SALAM
	grant select, insert, update, delete on tables to backend_dev;
alter default privileges for role data_engineer in schema SALAM
	grant select on tables to bi_dev;

-- Matriks hak akses
select
	r.rolname as nama_user,
	has_schema_privilege(r.rolname, 'salam', 'CREATE')                  as create_objek,
	has_table_privilege(r.rolname, 'SALAM.mahasiswas', 'SELECT')        as can_select,
	has_table_privilege(r.rolname, 'SALAM.mahasiswas', 'INSERT')        as can_insert,
	has_table_privilege(r.rolname, 'SALAM.mahasiswas', 'UPDATE')        as can_update,
	has_table_privilege(r.rolname, 'SALAM.mahasiswas', 'DELETE')        as can_delete,
	has_table_privilege(r.rolname, 'SALAM.v_mahasiswa_aktif', 'SELECT') as can_select_view
from pg_roles r
where r.rolname in ('backend_dev', 'bi_dev', 'data_engineer')
order by r.rolname;

-- PENGUJIAN a : backend_dev (CRUD, tanpa DDL)
set role backend_dev;
select current_user;   

select * from SALAM.mahasiswas;

insert into SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester)
values ('12475050001', 'Faishal', 'Teknik Informatika', 'Dosen A', 'uji@mail.com', 3);

update SALAM.mahasiswas set semester = 4 where nim = '12475050001';

delete from SALAM.mahasiswas where nim = '12475050001'; 

create table SALAM.coba_backend (id int);       
drop table SALAM.mahasiswas;                    
alter table SALAM.mahasiswas add column x int;  
reset role;

-- PENGUJIAN b : bi_dev (hanya SELECT)
set role bi_dev;
select current_user;    

select * from SALAM.mahasiswas;          
select * from SALAM.v_mahasiswa_aktif;    

insert into SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester)
values ('12475050014', 'Rifqi Alawi', 'Teknik Informatika', 'Dosen B', 'rifqi@mail.com', 3);

update SALAM.mahasiswas set semester = 5 where nim = '12475050014'; 

-- PENGUJIAN c : data_engineer (DDL penuh + CRUD)
set role data_engineer;
select current_user;  

-- CREATE
create table SALAM.coba_de (id int primary key, ket varchar(30));   
create view SALAM.v_coba_de as select * from SALAM.coba_de;        

-- MODIFY
alter table SALAM.coba_de add column waktu timestamp default now();

-- CRUD
insert into SALAM.coba_de (id, ket) values (1, 'tes');              
select * from SALAM.coba_de;                                        
update SALAM.coba_de set ket = 'ubah' where id = 1;                 
delete from SALAM.coba_de where id = 1; 

-- DROP
drop view SALAM.v_coba_de;                                
drop table SALAM.coba_de;  

-- CRUD pada tabel utama
select * from SALAM.mahasiswas;   
reset role
