use BTL_QLDIEMSV

--thêm trường niên khóa cho bảng khóa học
alter table KHOAHOC
add NIENKHOA nvarchar(50);

--CHÈN DỮ LIỆU VÀO CÁC BẢNG GHI

-- Chèn bản ghi vào bảng KHOAHOC (Khóa học) với tên khóa và niên khóa tương ứng
INSERT INTO KHOAHOC (MAKH, TENKH, NIENKHOA)
VALUES 
('KH2018', 'Khóa 60', '2018-2022'),
('KH2019', 'Khóa 61', '2019-2023'),
('KH2020', 'Khóa 62', '2020-2024'),
('KH2021', 'Khóa 63', '2021-2025');


-- Chèn bản ghi vào bảng MONHOC (Môn học) - Mã môn học giữ nguyên
INSERT INTO MONHOC (MAMH, TENMH, SOTIN)
VALUES 
('MH_TOAN01', 'Toán cao cấp', 4),
('MH_LTC02', 'Lập trình C', 3),
('MH_MMT03', 'Mạng máy tính', 3);

-- Chèn bản ghi vào bảng HEDT (Hệ đào tạo) - Mã hệ đào tạo giữ nguyên
INSERT INTO HEDT (MAHEDT, TENHEDAOTAO)
VALUES 
('HDT_DHCQ', 'Đại học chính quy'),
('HDT_LT', 'Liên thông'),
('HDT_DTTX', 'Đào tạo từ xa');

-- Chèn bản ghi vào bảng KHOA (Khoa) với địa chỉ tại Hà Nội
INSERT INTO KHOA (MAKHOA, TENKHOA, DIACHI, DIENTHOAI)
VALUES 
('IT01', 'Công nghệ thông tin', 'Số 1, Đại Cồ Việt, Hai Bà Trưng, Hà Nội', '0123456789'),
('EE01', 'Kỹ thuật điện tử', 'Số 2, Xuân Thủy, Cầu Giấy, Hà Nội', '0987654321');

-- Chèn bản ghi vào bảng LOP (Lớp) - Mã lớp kết hợp mã khoa và khóa học
INSERT INTO LOP (MALOP, TENLOP, MAKHOA, MAHDT, MAKHOAHOC)
VALUES 
('IT2018A', 'CNTT Khóa 2018', 'IT01', 'HDT_DHCQ', 'KH2018'),
('IT2019A', 'CNTT Khóa 2019', 'IT01', 'HDT_DHCQ', 'KH2019');

-- Chèn bản ghi vào bảng SINHVIEN (Sinh viên) - Mã sinh viên giữ nguyên
INSERT INTO SINHVIEN (MASV, TENSV, GIOITINH, NGAYSINH, QUEQUAN, MALOP)
VALUES 
('IT2018A01', N'Nguyễn Văn A ', 1, '2000-01-01', 'Hà Nội', 'IT2018A'),
('IT2019A01', N'Trần Thị Bích', 0, '2001-02-02', 'Hải Phòng', 'IT2019A'),
('IT2019A02', N'Lê Văn Cường', 1, '2000-03-03', 'Đà Nẵng', 'IT2019A');

-- Chèn bản ghi vào bảng DIEM (Điểm)
INSERT INTO DIEM (MASV, MAMH, HOCKY, DIEMLAN1, DIEMLAN2)
VALUES 
('IT2018A01', 'MH_TOAN01', 1, '8.5', '9.0'),
('IT2019A01', 'MH_LTC02', 2, '7.0', '8.0'),
('IT2019A02', 'MH_MMT03', 3, '6.0', '6.5');

--tạo thủ tục cho phép xem dữ liệu của tất cả các bảng
CREATE PROCEDURE ShowAllTablesData
AS
BEGIN
    DECLARE @tableName NVARCHAR(255)
    DECLARE table_cursor CURSOR FOR
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'

    OPEN table_cursor

    FETCH NEXT FROM table_cursor INTO @tableName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC('SELECT * FROM ' + @tableName)
        FETCH NEXT FROM table_cursor INTO @tableName
    END

    CLOSE table_cursor
    DEALLOCATE table_cursor
END

--chạy thủ tục
EXEC ShowAllTablesData;


