-- Tạo cơ sở dữ liệu
CREATE DATABASE QuanLyTruongHoc;
GO

-- Sử dụng cơ sở dữ liệu vừa tạo
USE QuanLyTruongHoc;
GO

-- Tạo bảng Khoa (Departments)
CREATE TABLE Khoa (
    MaKhoa INT PRIMARY KEY IDENTITY(1,1),
    TenKhoa NVARCHAR(100) NOT NULL,
    TruongKhoa NVARCHAR(100),
    NgayThanhLap DATE
);
GO

-- Tạo bảng Môn học (Subjects)
CREATE TABLE MonHoc (
    MaMonHoc INT PRIMARY KEY IDENTITY(1,1),
    TenMonHoc NVARCHAR(100) NOT NULL,
    SoTinChi INT NOT NULL,
    MoTa NVARCHAR(255),
    MaKhoa INT,
    FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);
GO

-- Tạo bảng Điều kiện tiên quyết (Prerequisites)
CREATE TABLE DieuKienTienQuyet (
    MaMonHocTienQuyet INT PRIMARY KEY,
    MaMonHoc INT,
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc)
);
GO



-- Tạo bảng Sinh viên (Students)
CREATE TABLE SinhVien (
    MaSV INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    DiaChi NVARCHAR(255),
    MaKhoa INT,
    FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);
GO

-- Tạo bảng Giáo viên (Teachers)
CREATE TABLE GiaoVien (
    MaGV INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    GioiTinh NVARCHAR(10),
    DiaChi NVARCHAR(255),
    MaKhoa INT,
    FOREIGN KEY (MaKhoa) REFERENCES Khoa(MaKhoa)
);
GO

-- Tạo bảng Lớp học (Classes)
CREATE TABLE LopHoc (
    MaLop INT PRIMARY KEY IDENTITY(1,1),
    TenLop NVARCHAR(100) NOT NULL,
    MaGV INT,
    MaMonHoc INT,
    FOREIGN KEY (MaGV) REFERENCES GiaoVien(MaGV),
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc)
);
GO

-- Tạo bảng Điểm số (Grades)
CREATE TABLE DiemSo (
    MaSV INT,
    MaMonHoc INT,
	GhiChu NVARCHAR(50),
    DiemChuyenCan FLOAT CHECK (DiemChuyenCan >= 0 AND DiemChuyenCan <= 10),
    DiemGiuaKy FLOAT CHECK (DiemGiuaKy >= 0 AND DiemGiuaKy <= 10),
    DiemThi FLOAT CHECK (DiemThi >= 0 AND DiemThi <= 10),
    DiemTongKet AS (DiemChuyenCan * 0.1 + DiemGiuaKy * 0.2 + DiemThi * 0.7),
    FOREIGN KEY (MaSV) REFERENCES SinhVien(MaSV),
    FOREIGN KEY (MaMonHoc) REFERENCES MonHoc(MaMonHoc)
);
GO

-- Tạo bảng Thời khóa biểu (Schedule)
CREATE TABLE ThoiKhoaBieu (
    MaLop INT,
    NgayHoc DATE,
    GioHoc TIME,
    PhongHoc NVARCHAR(50),
    FOREIGN KEY (MaLop) REFERENCES LopHoc(MaLop)
);
GO

-- Tạo stored procedure để kiểm tra điều kiện tiên quyết và thêm điểm số
CREATE PROCEDURE KiemTraDieuKienTienQuyet
    @MaSV INT,
    @MaMonHoc INT,
    @DiemChuyenCan FLOAT,
    @DiemGiuaKy FLOAT,
    @DiemThi FLOAT
AS
BEGIN
    DECLARE @GhiChu NVARCHAR(50);

    -- Xác định ghi chú dựa trên điểm tổng kết tự động tính
    IF @DiemChuyenCan * 0.1 + @DiemGiuaKy * 0.2 + @DiemThi * 0.7 < 4
    BEGIN
        SET @GhiChu = N'Chưa qua môn';
    END
    ELSE
    BEGIN
        SET @GhiChu = N'Đã qua môn';
    END

    -- Lưu điểm và ghi chú vào bảng DiemSo
    INSERT INTO DiemSo (MaSV, MaMonHoc, DiemChuyenCan, DiemGiuaKy, DiemThi, GhiChu)
    VALUES (@MaSV, @MaMonHoc, @DiemChuyenCan, @DiemGiuaKy, @DiemThi, @GhiChu);
END;
GO




