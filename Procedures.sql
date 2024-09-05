use BTL_QLDIEMSV

--THỦ TỤC LIÊN QUAN ĐẾN SINH VIÊN
--tạo thủ tục thêm sinh viên
CREATE PROCEDURE AddSinhVien
    @MASV CHAR(15),
    @TENSV NVARCHAR(50),
    @GIOITINH BIT,
    @NGAYSINH DATETIME,
    @QUEQUAN NVARCHAR(50),
    @MALOP CHAR(10)
AS
BEGIN
    INSERT INTO SINHVIEN (MASV, TENSV, GIOITINH, NGAYSINH, QUEQUAN, MALOP)
    VALUES (@MASV, @TENSV, @GIOITINH, @NGAYSINH, @QUEQUAN, @MALOP)
END

--tạo thủ tục sửa thông tin sinh viên
CREATE PROCEDURE UpdateSinhVien
    @MASV CHAR(15),
    @TENSV NVARCHAR(50) = NULL,
    @GIOITINH BIT = NULL,
    @NGAYSINH DATETIME = NULL,
    @QUEQUAN NVARCHAR(50) = NULL,
    @MALOP CHAR(10) = NULL
AS
BEGIN
    UPDATE SINHVIEN
    SET 
        TENSV = COALESCE(@TENSV, TENSV),
        GIOITINH = COALESCE(@GIOITINH, GIOITINH),
        NGAYSINH = COALESCE(@NGAYSINH, NGAYSINH),
        QUEQUAN = COALESCE(@QUEQUAN, QUEQUAN),
        MALOP = COALESCE(@MALOP, MALOP)
    WHERE MASV = @MASV
END

--tạo thủ tục xóa sinh viên (có thể xóa theo mã sinh viên hoặc xóa theo niên khóa)
CREATE PROCEDURE DeleteSinhVien
    @MASV CHAR(15) = NULL,  -- Mã sinh viên cần xóa
    @MAKH CHAR(10) = NULL  -- Mã khóa học để xóa sinh viên
AS
BEGIN
    -- Nếu mã sinh viên được cung cấp, xóa sinh viên theo mã
    IF @MASV IS NOT NULL
    BEGIN
        DELETE FROM SINHVIEN
        WHERE MASV = @MASV
    END
    -- Nếu mã khóa học được cung cấp, xóa tất cả sinh viên thuộc lớp có mã khóa học đó
    ELSE IF @MAKH IS NOT NULL
    BEGIN
        DELETE FROM SINHVIEN
        WHERE MALOP IN (
            SELECT MALOP
            FROM LOP
            WHERE MAKHOAHOC = @MAKH
        )
    END
END

--tạo thủ tục hiện danh sách sinh viên
CREATE PROCEDURE HienDSSV
AS
BEGIN
    SELECT 
        s.MASV,
        s.TENSV,
        s.GIOITINH,
        s.NGAYSINH,
        s.QUEQUAN,
        l.TENLOP
    FROM SINHVIEN s
    INNER JOIN LOP l ON s.MALOP = l.MALOP
END

exec HienDSSV

--tạo thủ tục đếm số lượng sinh viên từng khoa
create proc DemSVTheoKhoa
as
select KHOA.MAKHOA, count(*) as SoLuong from SINHVIEN,LOP,KHOA
where SINHVIEN.MALOP =LOP.MALOP and LOP.MAKHOA = KHOA.MAKHOA
group by KHOA.MAKHOA

exec DemSVTheoKhoa

--THỦ TỤC LIÊN QUAN ĐẾN LỚP
--tạo thủ tục thêm lớp
CREATE PROCEDURE InsertLop
    @MALOP CHAR(10),           -- Mã lớp
    @TENLOP NVARCHAR(50),      -- Tên lớp
    @MAKHOA CHAR(10),          -- Mã khoa
    @MAHDT CHAR(10),           -- Mã hệ đào tạo
    @MAKHOAHOC CHAR(10)        -- Mã khóa học
AS
BEGIN
    -- Kiểm tra xem lớp đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        RAISERROR('Lớp với mã %s đã tồn tại.', 16, 1, @MALOP)
        RETURN
    END

    -- Thêm lớp mới
    INSERT INTO LOP (MALOP, TENLOP, MAKHOA, MAHDT, MAKHOAHOC)
    VALUES (@MALOP, @TENLOP, @MAKHOA, @MAHDT, @MAKHOAHOC)

    PRINT 'Lớp đã được thêm thành công.'
END

EXEC InsertLop
    @MALOP = '',
    @TENLOP = '',
    @MAKHOA = '',
    @MAHDT = '',
    @MAKHOAHOC = ''

--tạo thủ tục sửa thông tin lớp
CREATE PROCEDURE UpdateLop
    @MALOP CHAR(10),           -- Mã lớp cần sửa
    @TENLOP NVARCHAR(50) = NULL, -- Tên lớp mới (NULL nếu không thay đổi)
    @MAKHOA CHAR(10) = NULL,   -- Mã khoa mới (NULL nếu không thay đổi)
    @MAHDT CHAR(10) = NULL,    -- Mã hệ đào tạo mới (NULL nếu không thay đổi)
    @MAKHOAHOC CHAR(10) = NULL -- Mã khóa học mới (NULL nếu không thay đổi)
AS
BEGIN
    -- Kiểm tra xem lớp có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        RAISERROR('Lớp với mã %s không tồn tại.', 16, 1, @MALOP)
        RETURN
    END

    -- Cập nhật thông tin lớp
    UPDATE LOP
    SET 
        TENLOP = COALESCE(@TENLOP, TENLOP),  -- Cập nhật tên lớp nếu có thay đổi
        MAKHOA = COALESCE(@MAKHOA, MAKHOA),  -- Cập nhật mã khoa nếu có thay đổi
        MAHDT = COALESCE(@MAHDT, MAHDT),    -- Cập nhật mã hệ đào tạo nếu có thay đổi
        MAKHOAHOC = COALESCE(@MAKHOAHOC, MAKHOAHOC)  -- Cập nhật mã khóa học nếu có thay đổi
    WHERE MALOP = @MALOP

    PRINT 'Thông tin lớp đã được cập nhật thành công.'
END

EXEC UpdateLop
    @MALOP = '',
    @TENLOP = '',
    @MAKHOA = '',
    @MAHDT = '',
    @MAKHOAHOC = ''

--tạo thủ tục xóa lớp
CREATE PROCEDURE DeleteLop
    @MALOP CHAR(10)  -- Mã lớp cần xóa
AS
BEGIN
    -- Kiểm tra xem lớp có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        RAISERROR('Lớp với mã %s không tồn tại.', 16, 1, @MALOP)
        RETURN
    END

    -- Xóa lớp theo mã lớp
    DELETE FROM LOP
    WHERE MALOP = @MALOP

    -- Thông báo thành công
    RAISERROR('Lớp với mã %s đã được xóa thành công.', 10, 1, @MALOP)
END

EXEC DeleteLop
    @MALOP = ''

--tạo thủ tục hiện danh sách lớp theo khóa
CREATE PROCEDURE GetLopByKhoaHoc
    @MAKHOAHOC CHAR(10)  -- Mã khóa học để lọc lớp
AS
BEGIN
    -- Lấy danh sách lớp theo mã khóa học
    SELECT 
        MALOP,
        TENLOP,
        MAKHOA,
        MAHDT,
        MAKHOAHOC
    FROM LOP
    WHERE MAKHOAHOC = @MAKHOAHOC
END

EXEC GetLopByKhoaHoc
    @MAKHOAHOC = 'KH2018'

--tạo thủ tục hiển thị số lượng sinh viên mỗi lớp
CREATE PROCEDURE GetStudentCountByLop
AS
BEGIN
    SELECT 
        l.MALOP,
        l.TENLOP,
        COUNT(s.MASV) AS SoLuongSinhVien
    FROM LOP l
    LEFT JOIN SINHVIEN s ON l.MALOP = s.MALOP
    GROUP BY l.MALOP, l.TENLOP
END

exec GetStudentCountByLop

--tạo thủ tục 