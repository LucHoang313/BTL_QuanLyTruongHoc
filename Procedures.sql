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

--tạo thủ tục hiện danh sách sinh viên theo hệ đào tạo
CREATE PROCEDURE SP_HienThiSinhVienTheoHeDaoTao
    @MAHEDT char(10)
AS
BEGIN
    -- Kiểm tra xem mã hệ đào tạo có tồn tại trong bảng HEDT hay không
    IF NOT EXISTS (SELECT 1 FROM HEDT WHERE MAHEDT = @MAHEDT)
    BEGIN
        PRINT 'Mã hệ đào tạo không tồn tại.';
        RETURN;
    END

    -- Truy vấn danh sách sinh viên theo hệ đào tạo
    SELECT SV.MASV, SV.TENSV, SV.GIOITINH, SV.NGAYSINH, SV.QUEQUAN, L.TENLOP, H.TENHEDAOTAO
    FROM SINHVIEN SV
    JOIN LOP L ON SV.MALOP = L.MALOP
    JOIN HEDT H ON L.MAHDT = H.MAHEDT
    WHERE H.MAHEDT = @MAHEDT
    ORDER BY SV.MASV;

    PRINT 'Hiển thị danh sách sinh viên theo hệ đào tạo thành công.';
END;

--tạo thủ tục hiện danh sách sinh viên theo lớp
CREATE PROCEDURE SP_HienThiSinhVienTheoLop
    @MALOP char(10)
AS
BEGIN
    -- Kiểm tra xem mã lớp có tồn tại trong bảng LOP hay không
    IF NOT EXISTS (SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        PRINT 'Mã lớp không tồn tại.';
        RETURN;
    END

    -- Truy vấn danh sách sinh viên theo lớp
    SELECT SV.MASV, SV.TENSV, SV.GIOITINH, SV.NGAYSINH, SV.QUEQUAN, L.TENLOP
    FROM SINHVIEN SV
    JOIN LOP L ON SV.MALOP = L.MALOP
    WHERE L.MALOP = @MALOP
    ORDER BY SV.MASV;

    PRINT 'Hiển thị danh sách sinh viên theo lớp thành công.';
END;

--tạo thủ tục hiện danh sách sinh viên theo khoa
CREATE PROCEDURE SP_HienThiSinhVienTheoKhoa
    @MAKHOA char(10)
AS
BEGIN
    -- Kiểm tra xem mã khoa có tồn tại trong bảng KHOA hay không
    IF NOT EXISTS (SELECT 1 FROM KHOA WHERE MAKHOA = @MAKHOA)
    BEGIN
        PRINT 'Mã khoa không tồn tại.';
        RETURN;
    END

    -- Truy vấn danh sách sinh viên theo khoa
    SELECT SV.MASV, SV.TENSV, SV.GIOITINH, SV.NGAYSINH, SV.QUEQUAN, L.TENLOP, K.TENKHOA
    FROM SINHVIEN SV
    JOIN LOP L ON SV.MALOP = L.MALOP
    JOIN KHOA K ON L.MAKHOA = K.MAKHOA
    WHERE K.MAKHOA = @MAKHOA
    ORDER BY SV.MASV;

    PRINT 'Hiển thị danh sách sinh viên theo khoa thành công.';
END;

-- tạo thủ tục hiện danh sách sinh viên không qua môn và hiển thị môn học không qua
CREATE PROCEDURE SP_HienThiSinhVienKhongQuaMon
AS
BEGIN
    -- Truy vấn danh sách sinh viên không qua môn và môn học tương ứng
    SELECT 
        SV.MASV, 
        SV.TENSV, 
        MH.TENMH, 
        CASE 
            WHEN DIEM.DIEMLAN1 IS NOT NULL AND CAST(DIEM.DIEMLAN1 AS FLOAT) < 5 THEN DIEM.DIEMLAN1
            WHEN DIEM.DIEMLAN2 IS NOT NULL AND CAST(DIEM.DIEMLAN2 AS FLOAT) < 5 THEN DIEM.DIEMLAN2
        END AS DIEMKHONGQUA
    FROM SINHVIEN SV
    JOIN DIEM ON SV.MASV = DIEM.MASV
    JOIN MONHOC MH ON DIEM.MAMH = MH.MAMH
    WHERE 
        (DIEM.DIEMLAN1 IS NOT NULL AND CAST(DIEM.DIEMLAN1 AS FLOAT) < 5) 
        OR (DIEM.DIEMLAN2 IS NOT NULL AND CAST(DIEM.DIEMLAN2 AS FLOAT) < 5)
    ORDER BY SV.MASV, MH.MAMH;

    PRINT 'Hiển thị danh sách sinh viên không qua môn thành công.';
END;

EXEC SP_HienThiSinhVienKhongQuaMon;

--tạo thủ tục hiển thị danh sách sinh viên theo điểm
CREATE PROCEDURE SP_HienThiSinhVienTheoDiem
AS
BEGIN
    -- Truy vấn danh sách sinh viên và điểm trung bình của họ
    SELECT 
        SV.MASV, 
        SV.TENSV, 
        AVG(CASE 
            WHEN CAST(DIEM.DIEMLAN1 AS FLOAT) IS NOT NULL THEN CAST(DIEM.DIEMLAN1 AS FLOAT)
            ELSE CAST(DIEM.DIEMLAN2 AS FLOAT)
        END) AS DIEM_TRUNG_BINH
    FROM SINHVIEN SV
    LEFT JOIN DIEM ON SV.MASV = DIEM.MASV
    GROUP BY SV.MASV, SV.TENSV
    ORDER BY DIEM_TRUNG_BINH DESC;

    PRINT 'Hiển thị danh sách sinh viên theo điểm thành công.';
END;

--tạo thủ tục hiển thị danh sách 100 sinh viên đủ điều kiện xét học bổng
CREATE PROCEDURE SP_HienThiSinhVienXetHocBong
AS
BEGIN
    -- Truy vấn danh sách 100 sinh viên đủ điều kiện xét học bổng
    SELECT TOP 100 
        SV.MASV, 
        SV.TENSV, 
        AVG(CASE 
            WHEN CAST(DIEM.DIEMLAN1 AS FLOAT) IS NOT NULL THEN CAST(DIEM.DIEMLAN1 AS FLOAT)
            ELSE CAST(DIEM.DIEMLAN2 AS FLOAT)
        END) AS DIEM_TRUNG_BINH
    FROM SINHVIEN SV
    LEFT JOIN DIEM ON SV.MASV = DIEM.MASV
    GROUP BY SV.MASV, SV.TENSV
    HAVING AVG(CASE 
            WHEN CAST(DIEM.DIEMLAN1 AS FLOAT) IS NOT NULL THEN CAST(DIEM.DIEMLAN1 AS FLOAT)
            ELSE CAST(DIEM.DIEMLAN2 AS FLOAT)
        END) >= 7.0
    ORDER BY DIEM_TRUNG_BINH DESC;

    PRINT 'Hiển thị danh sách 100 sinh viên đủ điều kiện xét học bổng thành công.';
END;

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

--tạo thủ tục hiện danh sách lớp theo khoa
CREATE PROCEDURE SP_HienDanhSachLopTheoKhoa
    @MAKHOA char(10)
AS
BEGIN
    SELECT LOP.MALOP, LOP.TENLOP, KHOA.TENKHOA
    FROM LOP
    INNER JOIN KHOA ON LOP.MAKHOA = KHOA.MAKHOA
    WHERE KHOA.MAKHOA = @MAKHOA;
END;
EXEC SP_HienDanhSachLopTheoKhoa @MAKHOA = 'IT01';

--tạo thủ tục hiện danh sách lớp theo môn học
CREATE PROCEDURE SP_HienDanhSachLopTheoMonHoc
    @MAMH char(10)
AS
BEGIN
    -- Kiểm tra nếu mã môn học không tồn tại
    IF NOT EXISTS (SELECT 1 FROM MONHOC WHERE MAMH = @MAMH)
    BEGIN
        PRINT 'Môn học không tồn tại';
        RETURN;
    END

    -- Kiểm tra nếu không có lớp nào cho môn học
    IF NOT EXISTS (
        SELECT DISTINCT LOP.MALOP 
        FROM DIEM
        INNER JOIN SINHVIEN ON DIEM.MASV = SINHVIEN.MASV
        INNER JOIN LOP ON SINHVIEN.MALOP = LOP.MALOP
        WHERE DIEM.MAMH = @MAMH
    )
    BEGIN
        PRINT 'Không có lớp nào cho môn học này';
        RETURN;
    END

    -- Nếu có dữ liệu, hiển thị danh sách lớp
    SELECT DISTINCT LOP.MALOP, LOP.TENLOP
    FROM DIEM
    INNER JOIN SINHVIEN ON DIEM.MASV = SINHVIEN.MASV
    INNER JOIN LOP ON SINHVIEN.MALOP = LOP.MALOP
    WHERE DIEM.MAMH = @MAMH;
END;

insert into dbo.MONHOC
values('MH_GT01', 'Giải tích 1', 3);

EXEC SP_HienDanhSachLopTheoMonHoc @MAMH = 'MH_MMT03  '; --môn học tồn tại
EXEC SP_HienDanhSachLopTheoMonHoc @MAMH = 'MH_M  '; -- môn học không tồn tại 
EXEC SP_HienDanhSachLopTheoMonHoc @MAMH = 'MH_GT01  '; -- môn học không có lớp


--THỦ TỤC LIÊN QUAN ĐẾN MÔN HỌC
--tạo thủ tục thêm môn học
CREATE PROCEDURE SP_ThemMonHoc
    @MAMH char(10),
    @TENMH nvarchar(50),
    @SOTIN int
AS
BEGIN
    -- Kiểm tra nếu mã môn học đã tồn tại
    IF EXISTS (SELECT 1 FROM MONHOC WHERE MAMH = @MAMH)
    BEGIN
        PRINT 'Mã môn học đã tồn tại.';
        RETURN;
    END

    -- Kiểm tra điều kiện số tín chỉ
    IF @SOTIN <= 0 OR @SOTIN >= 9
    BEGIN
        PRINT 'Số tín chỉ không hợp lệ. Phải lớn hơn 0 và nhỏ hơn 9.';
        RETURN;
    END

    -- Chèn bản ghi vào bảng MONHOC
    INSERT INTO MONHOC (MAMH, TENMH, SOTIN)
    VALUES (@MAMH, @TENMH, @SOTIN);

    PRINT 'Thêm môn học thành công.';
END;

--tạo thủ tục sửa thông tin môn học
CREATE PROCEDURE SP_SuaMonHoc
    @MAMH char(10),
    @TENMH nvarchar(50),
    @SOTIN int
AS
BEGIN
    -- Kiểm tra nếu mã môn học không tồn tại
    IF NOT EXISTS (SELECT 1 FROM MONHOC WHERE MAMH = @MAMH)
    BEGIN
        PRINT 'Mã môn học không tồn tại.';
        RETURN;
    END

    -- Kiểm tra điều kiện số tín chỉ
    IF @SOTIN <= 0 OR @SOTIN >= 9
    BEGIN
        PRINT 'Số tín chỉ không hợp lệ. Phải lớn hơn 0 và nhỏ hơn 9.';
        RETURN;
    END

    -- Cập nhật thông tin môn học
    UPDATE MONHOC
    SET TENMH = @TENMH, SOTIN = @SOTIN
    WHERE MAMH = @MAMH;

    PRINT 'Sửa thông tin môn học thành công.';
END;

--tạo thủ tục xóa môn học
CREATE PROCEDURE SP_XoaMonHoc
    @MAMH char(10)
AS
BEGIN
    -- Kiểm tra nếu mã môn học không tồn tại
    IF NOT EXISTS (SELECT 1 FROM MONHOC WHERE MAMH = @MAMH)
    BEGIN
        PRINT 'Mã môn học không tồn tại.';
        RETURN;
    END

    -- Xóa môn học
    DELETE FROM MONHOC
    WHERE MAMH = @MAMH;

    PRINT 'Xóa môn học thành công.';
END;

--tạo thủ tục hiện tất cả môn học
CREATE PROCEDURE SP_HienTatCaMonHoc
AS
BEGIN
    -- Truy vấn và trả về tất cả các môn học
    SELECT MAMH, TENMH, SOTIN
    FROM MONHOC;

    PRINT 'Hiển thị tất cả các môn học thành công.';
END;

--tạo thủ tục hiển thị danh sách môn học theo khoa
CREATE PROCEDURE SP_HienMonHocTheoKhoa
    @MAKHOA char(10)
AS
BEGIN
    -- Kiểm tra xem mã khoa có tồn tại trong bảng KHOA hay không
    IF NOT EXISTS (SELECT 1 FROM KHOA WHERE MAKHOA = @MAKHOA)
    BEGIN
        PRINT 'Mã khoa không tồn tại.';
        RETURN;
    END

    -- Truy vấn và trả về danh sách môn học theo mã khoa
    SELECT MH.MAMH, MH.TENMH, MH.SOTIN
    FROM MONHOC MH
    INNER JOIN LOP L ON L.MAKHOA = @MAKHOA
    WHERE L.MALOP IN (SELECT MALOP FROM SINHVIEN WHERE MALOP IS NOT NULL)
    ORDER BY MH.MAMH;

    PRINT 'Hiển thị danh sách môn học theo khoa thành công.';
END;

--tạo thủ tục hiển thị danh sách môn học theo khóa học
CREATE PROCEDURE SP_HienMonHocTheoKhoaHoc
    @MAKH char(10)
AS
BEGIN
    -- Kiểm tra xem mã khóa học có tồn tại trong bảng KHOAHOC hay không
    IF NOT EXISTS (SELECT 1 FROM KHOAHOC WHERE MAKH = @MAKH)
    BEGIN
        PRINT 'Mã khóa học không tồn tại.';
        RETURN;
    END

    -- Truy vấn và trả về danh sách môn học theo mã khóa học
    SELECT MH.MAMH, MH.TENMH, MH.SOTIN
    FROM MONHOC MH
    INNER JOIN LOP L ON L.MAKHOAHOC = @MAKH
    WHERE L.MALOP IN (SELECT MALOP FROM SINHVIEN WHERE MALOP IS NOT NULL)
    ORDER BY MH.MAMH;

    PRINT 'Hiển thị danh sách môn học theo khóa học thành công.';
END;

--tạo thủ tục hiển thị danh sách môn học theo lớp
CREATE PROCEDURE SP_HienMonHocTheoLop
    @MALOP char(10)
AS
BEGIN
    -- Kiểm tra xem mã lớp có tồn tại trong bảng LOP hay không
    IF NOT EXISTS (SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        PRINT 'Mã lớp không tồn tại.';
        RETURN;
    END

    -- Truy vấn và trả về danh sách môn học theo mã lớp
    SELECT MH.MAMH, MH.TENMH, MH.SOTIN
    FROM MONHOC MH
    INNER JOIN SINHVIEN SV ON SV.MALOP = @MALOP
    INNER JOIN LOP L ON L.MALOP = SV.MALOP
    WHERE L.MALOP = @MALOP
    ORDER BY MH.MAMH;

    PRINT 'Hiển thị danh sách môn học theo lớp thành công.';
END;

--tạo thủ tục lọc danh sách môn theo hệ đào tạo
CREATE PROCEDURE SP_LocDanhSachMonTheoHeDaoTao
    @MAHEDT char(10)
AS
BEGIN
    -- Kiểm tra nếu hệ đào tạo không tồn tại
    IF NOT EXISTS (SELECT 1 FROM HEDT WHERE MAHEDT = @MAHEDT)
    BEGIN
        PRINT 'Hệ đào tạo không tồn tại';
        RETURN;
    END

    -- Lọc danh sách môn học theo hệ đào tạo
    SELECT DISTINCT MONHOC.MAMH, MONHOC.TENMH, MONHOC.SOTIN
    FROM LOP
    INNER JOIN SINHVIEN ON LOP.MALOP = SINHVIEN.MALOP
    INNER JOIN DIEM ON SINHVIEN.MASV = DIEM.MASV
    INNER JOIN MONHOC ON DIEM.MAMH = MONHOC.MAMH
    WHERE LOP.MAHDT = @MAHEDT;
    
    -- Kiểm tra nếu không có môn học nào cho hệ đào tạo
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Không có môn học nào cho hệ đào tạo này';
    END
END;

EXEC SP_LocDanhSachMonTheoHeDaoTao @MAHEDT = 'HDT_DHCQ    ';

--THỦ TỤC LIÊN QUAN ĐẾN KHÓA HỌC
--tạo thủ tục thêm khóa học
CREATE PROCEDURE SP_ThemKhoaHoc
    @MAKH char(10),
    @TENKH nvarchar(50),
    @NIENKHOA nvarchar(50)
AS
BEGIN
    -- Kiểm tra xem mã khóa học đã tồn tại chưa
    IF EXISTS (SELECT 1 FROM KHOAHOC WHERE MAKH = @MAKH)
    BEGIN
        PRINT 'Mã khóa học đã tồn tại.';
        RETURN;
    END

    -- Thêm bản ghi vào bảng KHOAHOC
    INSERT INTO KHOAHOC (MAKH, TENKH, NIENKHOA)
    VALUES (@MAKH, @TENKH, @NIENKHOA);

    PRINT 'Thêm khóa học thành công.';
END;

--tạo thủ tục sửa khóa học
CREATE PROCEDURE SP_SuaKhoaHoc
    @MAKH char(10),
    @TENKH nvarchar(50),
    @NIENKHOA nvarchar(50)
AS
BEGIN
    -- Kiểm tra xem mã khóa học có tồn tại trong bảng KHOAHOC hay không
    IF NOT EXISTS (SELECT 1 FROM KHOAHOC WHERE MAKH = @MAKH)
    BEGIN
        PRINT 'Mã khóa học không tồn tại.';
        RETURN;
    END

    -- Cập nhật thông tin khóa học
    UPDATE KHOAHOC
    SET TENKH = @TENKH,
        NIENKHOA = @NIENKHOA
    WHERE MAKH = @MAKH;

    PRINT 'Sửa thông tin khóa học thành công.';
END;

--tạo thủ tục xóa khóa học
CREATE PROCEDURE SP_XoaKhoaHoc
    @MAKH char(10)
AS
BEGIN
    -- Kiểm tra xem mã khóa học có tồn tại trong bảng KHOAHOC hay không
    IF NOT EXISTS (SELECT 1 FROM KHOAHOC WHERE MAKH = @MAKH)
    BEGIN
        PRINT 'Mã khóa học không tồn tại.';
        RETURN;
    END

    -- Xóa bản ghi khỏi bảng KHOAHOC
    DELETE FROM KHOAHOC
    WHERE MAKH = @MAKH;

    PRINT 'Xóa khóa học thành công.';
END;

----tạo thủ tục hiển thị danh sách các khóa học
CREATE PROCEDURE SP_HienThiDanhSachKhoaHoc
AS
BEGIN
    -- Truy vấn và trả về toàn bộ danh sách khóa học
    SELECT MAKH, TENKH, NIENKHOA
    FROM KHOAHOC
    ORDER BY MAKH;

    PRINT 'Hiển thị danh sách khóa học thành công.';
END;

--THỦ TỤC LIÊN QUAN ĐẾN ĐIỂM
--tạo thủ tục hiện bảng điểm theo lớp
CREATE PROCEDURE SP_HienBangDiemTheoLop
    @MALOP CHAR(10)  -- Nhận mã lớp làm tham số đầu vào
AS
BEGIN
    -- Truy vấn bảng điểm theo lớp
    SELECT 
        SV.MASV, 
        SV.TENSV, 
        MH.TENMH, 
        DIEM.HOCKY, 
        DIEM.DIEMLAN1, 
        DIEM.DIEMLAN2,
        CASE 
            WHEN CAST(DIEM.DIEMLAN1 AS FLOAT) IS NOT NULL AND CAST(DIEM.DIEMLAN2 AS FLOAT) IS NOT NULL 
            THEN (CAST(DIEM.DIEMLAN1 AS FLOAT) + CAST(DIEM.DIEMLAN2 AS FLOAT)) / 2
            ELSE NULL 
        END AS DIEM_TRUNG_BINH
    FROM SINHVIEN SV
    JOIN LOP L ON SV.MALOP = L.MALOP
    LEFT JOIN DIEM ON SV.MASV = DIEM.MASV
    LEFT JOIN MONHOC MH ON DIEM.MAMH = MH.MAMH
    WHERE L.MALOP = @MALOP
    ORDER BY SV.MASV;

    PRINT 'Hiển thị bảng điểm theo lớp thành công.';
END;

--tạo thủ tục hiển thi bảng điểm theo mã sinh viên
CREATE PROCEDURE SP_HienBangDiemTheoMaSV
    @MASV CHAR(15)  -- Nhận mã sinh viên làm tham số đầu vào
AS
BEGIN
    -- Truy vấn bảng điểm theo mã sinh viên
    SELECT 
        SV.MASV, 
        SV.TENSV, 
        MH.TENMH, 
        DIEM.HOCKY, 
        DIEM.DIEMLAN1, 
        DIEM.DIEMLAN2,
        CASE 
            WHEN CAST(DIEM.DIEMLAN1 AS FLOAT) IS NOT NULL AND CAST(DIEM.DIEMLAN2 AS FLOAT) IS NOT NULL 
            THEN (CAST(DIEM.DIEMLAN1 AS FLOAT) + CAST(DIEM.DIEMLAN2 AS FLOAT)) / 2
            ELSE NULL 
        END AS DIEM_TRUNG_BINH
    FROM SINHVIEN SV
    LEFT JOIN DIEM ON SV.MASV = DIEM.MASV
    LEFT JOIN MONHOC MH ON DIEM.MAMH = MH.MAMH
    WHERE SV.MASV = @MASV;

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Không tìm thấy sinh viên với mã đã cho.';
    END
    ELSE
    BEGIN
        PRINT 'Hiển thị bảng điểm theo mã sinh viên thành công.';
    END
END;
