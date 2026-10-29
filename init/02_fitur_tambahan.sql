-- Membuat fitur tambahan

-- Fitur 1 : Soft delete (nonaktifkan, bukan hapus)

-- menambah kolom status pada tabel mahasiswas
alter table SALAM.mahasiswas
	add column if not exists status_aktif boolean not null default true,
	add column if not exists waktu_nonaktif timestamp;

-- membuat function untuk menonaktifkan / mengaktifkan kembali mahasiswa
CREATE OR REPLACE FUNCTION salam.ubah_status_mahasiswa(p_nim varchar, p_aktif boolean)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    jml int;
BEGIN
    UPDATE salam.mahasiswas
    SET status_aktif = p_aktif,
        waktu_nonaktif = CASE WHEN p_aktif THEN NULL ELSE CURRENT_TIMESTAMP END
    WHERE nim = p_nim;

    GET DIAGNOSTICS jml = ROW_COUNT;

    IF jml = 0 THEN
        RETURN 'NIM ' || p_nim || ' tidak ditemukan';
    END IF;

    RETURN 'NIM ' || p_nim || CASE WHEN p_aktif THEN ' diaktifkan kembali' ELSE ' dinonaktifkan' END;
END;
$$;

-- membuat view yang hanya menampilkan mahasiswa aktif
create view SALAM.v_mahasiswa_aktif as
select nim, nama, email, semester
from SALAM.mahasiswas
where status_aktif = true;

-- PENGUJIAN FITUR 1: SOFT DELETE

INSERT INTO SALAM.mahasiswas (nim, nama, jurusan, dosen_pembimbing, email, semester) 
VALUES
('12475050110', 'Naufal Ramadhan', 'Teknik Informatika', 'Deden Firdaus', 'naufal@gmail.com', 5);

select * from SALAM.mahasiswas

select SALAM.ubah_status_mahasiswa('12475050110', false);

-- hilang dari view aktif, tetapi datanya masih ada di tabel utama
select * from SALAM.v_mahasiswa_aktif where nim = '12475050110';
select nim, nama, status_aktif, waktu_nonaktif from SALAM.mahasiswas where nim = '12475050110';

-- diaktifkan kembali
select SALAM.ubah_status_mahasiswa('12475050110', true);

-- Fitur 2 : Daftar mahasiswa yang belum mengisi email

create view SALAM.v_email_belum_diisi as
select
	nim,
	nama,
	jurusan,
	dosen_pembimbing,
	'Email belum diisi' as email,
	semester
from SALAM.mahasiswas
where email is null or trim(email) = '';

-- PENGUJIAN FITUR 2: EMAIL BELUM DIISI

-- kosongkan email salah satu mahasiswa sebagai contoh
update SALAM.mahasiswas
set email =  null
where nim = '12475050110';

-- cek view
select * from SALAM.v_email_belum_diisi;

-- jumlah mahasiswa yang belum mengisi email
select count(*) as jumlah_belum_isi_email from SALAM.v_email_belum_diisi;

-- setelah email diisi lagi, datanya hilang dari view
update SALAM.mahasiswas
set email = 'naufal@gmail.com'
where nim = '12475050110';

select * from SALAM.v_email_belum_diisi;


