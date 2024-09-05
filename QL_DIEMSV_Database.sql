create table BTL_QLDIEMSV

use BTL_QLDIEMSV

--tạo bảng môn học
create table MONHOC
(
	MAMH char(10) primary key,
	TENMH nvarchar(50),
	SOTIN int not null check ((SOTIN > 0) and (SOTIN <9))
)

--tạo bảng hệ đào tạo
create table HEDT
(
	MAHEDT char(10) primary key,
	TENHEDAOTAO nvarchar(50)
)

--tạo bảng khóa học
create table KHOAHOC
(
	MAKH char(10) primary key,
	TENKH nvarchar(50)
)

--tạo bảng khoa
create table KHOA
(
	MAKHOA char(10) primary key,
	TENKHOA nvarchar(50),
	DIACHI nvarchar(50),
	DIENTHOAI varchar(10)
)

--tạo bảng lớp
create table LOP
(
	MALOP char(10) primary key,
	TENLOP nvarchar(50),
	MAKHOA char(10) foreign key references KHOA(MAKHOA),
	MAHDT char(10) foreign key references HEDT(MAHEDT),
	MAKHOAHOC char(10) foreign key references KHOAHOC(MAKH)
)

--tạo bảng sinh viên
create table SINHVIEN
(
	MASV char(15) primary key,
	TENSV nvarchar(50),
	GIOITINH bit,
	NGAYSINH datetime,
	QUEQUAN nvarchar(50),
	MALOP char(10) foreign key references LOP(MALOP)
)

--tạo bảng điểm
create table DIEM
(
	MASV char(15) foreign key references SINHVIEN(MASV),
	MAMH char(10) foreign key references MONHOC(MAMH),
	HOCKY int check(HOCKY>0) not null,
	DIEMLAN1 char(5),
	DIEMLAN2 char(5)
)
