
/* =========================================================
   BAI 7 - QUAN LY NHAN SU - CONG TY SON DONG A
   SQL Server
   Du lieu nhan vien la du lieu mau gia lap
   ========================================================= */

USE master;
GO

IF DB_ID(N'QuanLyNhanSu_SonDongA') IS NULL
BEGIN
    CREATE DATABASE QuanLyNhanSu_SonDongA;
END;
GO

USE QuanLyNhanSu_SonDongA;
GO

SET DATEFORMAT YMD;
SET NOCOUNT ON;
GO

/* =========================================================
   1. PHONG BAN
   ========================================================= */
CREATE TABLE dbo.PhongBan
(
    PhongBanID INT IDENTITY(1,1) PRIMARY KEY,
    MaPhongBan VARCHAR(10) NOT NULL UNIQUE,
    TenPhongBan NVARCHAR(100) NOT NULL,
    DiaDiem NVARCHAR(200) NULL,
    SoDienThoai VARCHAR(15) NULL,
    TrangThai BIT NOT NULL DEFAULT 1
);
GO

/* =========================================================
   2. NHAN VIEN
   ========================================================= */
CREATE TABLE dbo.NhanVien
(
    NhanVienID INT IDENTITY(1,1) PRIMARY KEY,
    MaNhanVien VARCHAR(10) NOT NULL UNIQUE,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NULL,
    GioiTinh NVARCHAR(10) NULL,
    CCCD VARCHAR(12) NULL UNIQUE,
    DiaChi NVARCHAR(250) NULL,
    SoDienThoai VARCHAR(15) NULL,
    Email VARCHAR(100) NULL,
    NgayVaoLam DATE NOT NULL,
    PhongBanID INT NOT NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Thu viec',

    CONSTRAINT FK_NhanVien_PhongBan
        FOREIGN KEY (PhongBanID)
        REFERENCES dbo.PhongBan(PhongBanID),

    CONSTRAINT CK_NhanVien_TrangThai
        CHECK (TrangThai IN
        (N'Thu viec', N'Dang lam', N'Ngung lam'))
);
GO

/* =========================================================
   3. QUYET DINH TUYEN DUNG / THU VIEC
   ========================================================= */
CREATE TABLE dbo.QuyetDinhTuyenDung
(
    QuyetDinhTuyenDungID INT IDENTITY(1,1) PRIMARY KEY,
    SoQuyetDinh VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NOT NULL,
    PhongBanID INT NOT NULL,
    NgayQuyetDinh DATE NOT NULL,
    NgayBatDauThuViec DATE NOT NULL,
    NgayKetThucThuViec DATE NOT NULL,
    LuongThuViec DECIMAL(18,2) NOT NULL,
    DieuKhoan NVARCHAR(1000) NOT NULL,
    NguoiKy NVARCHAR(100) NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Da ban hanh',

    CONSTRAINT FK_QDTD_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT FK_QDTD_PhongBan
        FOREIGN KEY (PhongBanID)
        REFERENCES dbo.PhongBan(PhongBanID),

    CONSTRAINT CK_QDTD_Luong
        CHECK (LuongThuViec > 0),

    CONSTRAINT CK_QDTD_Ngay
        CHECK (NgayKetThucThuViec >= NgayBatDauThuViec)
);
GO

/* =========================================================
   4. HOP DONG LAO DONG
   ========================================================= */
CREATE TABLE dbo.HopDongLaoDong
(
    HopDongID INT IDENTITY(1,1) PRIMARY KEY,
    SoHopDong VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NOT NULL,
    LoaiHopDong NVARCHAR(30) NOT NULL,
    NgayKy DATE NOT NULL,
    NgayHieuLuc DATE NOT NULL,
    NgayHetHan DATE NULL,
    NoiDung NVARCHAR(1000) NULL,
    NguoiKy NVARCHAR(100) NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Hieu luc',

    CONSTRAINT FK_HopDong_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT CK_HopDong_Loai
        CHECK (LoaiHopDong IN
        (N'Dai han', N'Ngan han', N'Thu viec')),

    CONSTRAINT CK_HopDong_Ngay
        CHECK (NgayHetHan IS NULL OR NgayHetHan >= NgayHieuLuc)
);
GO

/* =========================================================
   5. QUYET DINH CHUC VU
   ========================================================= */
CREATE TABLE dbo.QuyetDinhChucVu
(
    QuyetDinhChucVuID INT IDENTITY(1,1) PRIMARY KEY,
    SoQuyetDinh VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NOT NULL,
    ChucVu NVARCHAR(100) NOT NULL,
    PhuCapChucVu DECIMAL(18,2) NOT NULL DEFAULT 0,
    NgayQuyetDinh DATE NOT NULL,
    NgayHieuLuc DATE NOT NULL,
    GhiChu NVARCHAR(500) NULL,

    CONSTRAINT FK_QDCV_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT CK_QDCV_PhuCap
        CHECK (PhuCapChucVu >= 0)
);
GO

/* =========================================================
   6. QUYET DINH LUONG
   ========================================================= */
CREATE TABLE dbo.QuyetDinhLuong
(
    QuyetDinhLuongID INT IDENTITY(1,1) PRIMARY KEY,
    SoQuyetDinh VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NOT NULL,
    LuongCoBan DECIMAL(18,2) NOT NULL,
    PhuCapLuong DECIMAL(18,2) NOT NULL DEFAULT 0,
    PhuCapDocHai DECIMAL(18,2) NOT NULL DEFAULT 0,
    NgayQuyetDinh DATE NOT NULL,
    NgayHieuLuc DATE NOT NULL,
    LyDo NVARCHAR(300) NULL,

    CONSTRAINT FK_QDL_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT CK_QDL_Tien
        CHECK (LuongCoBan > 0
           AND PhuCapLuong >= 0
           AND PhuCapDocHai >= 0)
);
GO

/* =========================================================
   7. CHAM CONG
   ========================================================= */
CREATE TABLE dbo.ChamCong
(
    ChamCongID INT IDENTITY(1,1) PRIMARY KEY,
    NhanVienID INT NOT NULL,
    Thang TINYINT NOT NULL,
    Nam SMALLINT NOT NULL,
    SoNgayCong DECIMAL(5,2) NOT NULL,
    SoNgayNghi DECIMAL(5,2) NOT NULL DEFAULT 0,
    NguoiChamCong NVARCHAR(100) NULL,
    NgayCapNhat DATE NOT NULL,
    GhiChu NVARCHAR(300) NULL,

    CONSTRAINT FK_ChamCong_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT UQ_ChamCong_NhanVien_Thang
        UNIQUE (NhanVienID, Thang, Nam),

    CONSTRAINT CK_ChamCong_Thang
        CHECK (Thang BETWEEN 1 AND 12),

    CONSTRAINT CK_ChamCong_SoNgay
        CHECK (SoNgayCong >= 0 AND SoNgayNghi >= 0)
);
GO

/* =========================================================
   8. PHIEU PHU TROI / LAM THEM
   He so 1.5 theo mo ta de bai
   ========================================================= */
CREATE TABLE dbo.PhieuPhuTroi
(
    PhieuPhuTroiID INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieu VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NOT NULL,
    NgayPhuTroi DATE NOT NULL,
    SoGio DECIMAL(5,2) NOT NULL,
    HinhThuc NVARCHAR(30) NOT NULL,
    HeSoLuong DECIMAL(4,2) NOT NULL DEFAULT 1.5,
    NguoiXacNhan NVARCHAR(100) NULL,
    GhiChu NVARCHAR(300) NULL,

    CONSTRAINT FK_PhieuPhuTroi_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT CK_PhieuPhuTroi_SoGio
        CHECK (SoGio > 0),

    CONSTRAINT CK_PhieuPhuTroi_HeSo
        CHECK (HeSoLuong > 0),

    CONSTRAINT CK_PhieuPhuTroi_HinhThuc
        CHECK (HinhThuc IN
        (N'Tang ca', N'Ngay le', N'Ngay nghi'))
);
GO

/* =========================================================
   9. BANG LUONG
   ========================================================= */
CREATE TABLE dbo.BangLuong
(
    BangLuongID INT IDENTITY(1,1) PRIMARY KEY,
    SoBangLuong VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NOT NULL,
    Thang TINYINT NOT NULL,
    Nam SMALLINT NOT NULL,
    QuyetDinhLuongID INT NOT NULL,
    TongLuongCoBan DECIMAL(18,2) NOT NULL,
    TongPhuCap DECIMAL(18,2) NOT NULL DEFAULT 0,
    TienLamThem DECIMAL(18,2) NOT NULL DEFAULT 0,
    TienThuong DECIMAL(18,2) NOT NULL DEFAULT 0,
    TienBaoHiem DECIMAL(18,2) NOT NULL DEFAULT 0,
    TienPhat DECIMAL(18,2) NOT NULL DEFAULT 0,
    ThueTNCN DECIMAL(18,2) NOT NULL DEFAULT 0,
    ThucLanh DECIMAL(18,2) NOT NULL,
    NgayLap DATE NOT NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Chua thanh toan',

    CONSTRAINT FK_BangLuong_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT FK_BangLuong_QDL
        FOREIGN KEY (QuyetDinhLuongID)
        REFERENCES dbo.QuyetDinhLuong(QuyetDinhLuongID),

    CONSTRAINT UQ_BangLuong_NhanVien_Thang
        UNIQUE (NhanVienID, Thang, Nam),

    CONSTRAINT CK_BangLuong_Thang
        CHECK (Thang BETWEEN 1 AND 12),

    CONSTRAINT CK_BangLuong_Tien
        CHECK (TongLuongCoBan >= 0
           AND TongPhuCap >= 0
           AND TienLamThem >= 0
           AND TienThuong >= 0
           AND TienBaoHiem >= 0
           AND TienPhat >= 0
           AND ThueTNCN >= 0
           AND ThucLanh >= 0)
);
GO

/* =========================================================
   10. QUYET DINH KHEN THUONG
   Moi quyet dinh danh cho ca nhan hoac tap the phong ban
   ========================================================= */
CREATE TABLE dbo.QuyetDinhKhenThuong
(
    QuyetDinhKhenThuongID INT IDENTITY(1,1) PRIMARY KEY,
    SoQuyetDinh VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NULL,
    PhongBanID INT NULL,
    LoaiKhenThuong NVARCHAR(50) NOT NULL,
    LyDo NVARCHAR(500) NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    NgayQuyetDinh DATE NOT NULL,
    NguoiKy NVARCHAR(100) NOT NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Cho ky',

    CONSTRAINT FK_QDKT_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT FK_QDKT_PhongBan
        FOREIGN KEY (PhongBanID)
        REFERENCES dbo.PhongBan(PhongBanID),

    CONSTRAINT CK_QDKT_DoiTuong
        CHECK (
            (NhanVienID IS NOT NULL AND PhongBanID IS NULL)
            OR
            (NhanVienID IS NULL AND PhongBanID IS NOT NULL)
        ),

    CONSTRAINT CK_QDKT_SoTien
        CHECK (SoTien > 0)
);
GO

/* =========================================================
   11. PHIEU CHI KHEN THUONG
   ========================================================= */
CREATE TABLE dbo.PhieuChiKhenThuong
(
    PhieuChiID INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieuChi VARCHAR(30) NOT NULL UNIQUE,
    QuyetDinhKhenThuongID INT NOT NULL UNIQUE,
    NgayChi DATE NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    NguoiNhan NVARCHAR(100) NOT NULL,
    NguoiLapPhieu NVARCHAR(100) NOT NULL,
    GhiChu NVARCHAR(300) NULL,

    CONSTRAINT FK_PhieuChi_QDKT
        FOREIGN KEY (QuyetDinhKhenThuongID)
        REFERENCES dbo.QuyetDinhKhenThuong(QuyetDinhKhenThuongID),

    CONSTRAINT CK_PhieuChi_SoTien
        CHECK (SoTien > 0)
);
GO

/* =========================================================
   12. QUYET DINH KY LUAT
   ========================================================= */
CREATE TABLE dbo.QuyetDinhKyLuat
(
    QuyetDinhKyLuatID INT IDENTITY(1,1) PRIMARY KEY,
    SoQuyetDinh VARCHAR(30) NOT NULL UNIQUE,
    NhanVienID INT NULL,
    PhongBanID INT NULL,
    HinhThuc NVARCHAR(50) NOT NULL,
    LyDo NVARCHAR(500) NOT NULL,
    SoTienPhat DECIMAL(18,2) NOT NULL DEFAULT 0,
    NgayQuyetDinh DATE NOT NULL,
    NguoiKy NVARCHAR(100) NOT NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Da ban hanh',

    CONSTRAINT FK_QDKL_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT FK_QDKL_PhongBan
        FOREIGN KEY (PhongBanID)
        REFERENCES dbo.PhongBan(PhongBanID),

    CONSTRAINT CK_QDKL_DoiTuong
        CHECK (
            (NhanVienID IS NOT NULL AND PhongBanID IS NULL)
            OR
            (NhanVienID IS NULL AND PhongBanID IS NOT NULL)
        ),

    CONSTRAINT CK_QDKL_SoTien
        CHECK (SoTienPhat >= 0)
);
GO

/* =========================================================
   13. PHIEU THU PHAT
   Neu tru vao luong thi PhieuThuID co the chua phat sinh
   ========================================================= */
CREATE TABLE dbo.PhieuThuPhat
(
    PhieuThuPhatID INT IDENTITY(1,1) PRIMARY KEY,
    SoPhieuThu VARCHAR(30) NOT NULL UNIQUE,
    QuyetDinhKyLuatID INT NOT NULL UNIQUE,
    NgayThu DATE NOT NULL,
    SoTien DECIMAL(18,2) NOT NULL,
    HinhThucThu NVARCHAR(30) NOT NULL,
    NguoiThu NVARCHAR(100) NULL,
    GhiChu NVARCHAR(300) NULL,

    CONSTRAINT FK_PhieuThu_QDKL
        FOREIGN KEY (QuyetDinhKyLuatID)
        REFERENCES dbo.QuyetDinhKyLuat(QuyetDinhKyLuatID),

    CONSTRAINT CK_PhieuThu_SoTien
        CHECK (SoTien > 0),

    CONSTRAINT CK_PhieuThu_HinhThuc
        CHECK (HinhThucThu IN
        (N'Tien mat', N'Chuyen khoan'))
);
GO

/* =========================================================
   14. HO SO BAO HIEM
   ========================================================= */
CREATE TABLE dbo.BaoHiem
(
    BaoHiemID INT IDENTITY(1,1) PRIMARY KEY,
    NhanVienID INT NOT NULL,
    SoBHXH VARCHAR(20) NOT NULL UNIQUE,
    SoBHYT VARCHAR(20) NULL UNIQUE,
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NULL,
    TyLeBHXH DECIMAL(5,2) NOT NULL DEFAULT 8.00,
    TyLeBHYT DECIMAL(5,2) NOT NULL DEFAULT 1.50,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Dang tham gia',

    CONSTRAINT FK_BaoHiem_NhanVien
        FOREIGN KEY (NhanVienID)
        REFERENCES dbo.NhanVien(NhanVienID),

    CONSTRAINT CK_BaoHiem_TyLe
        CHECK (TyLeBHXH >= 0 AND TyLeBHYT >= 0),

    CONSTRAINT CK_BaoHiem_Ngay
        CHECK (NgayKetThuc IS NULL OR NgayKetThuc >= NgayBatDau)
);
GO

/* =========================================================
   INSERT DU LIEU MAU
   ========================================================= */

BEGIN TRY
    BEGIN TRANSACTION;

    /* PHONG BAN */
    INSERT INTO dbo.PhongBan
        (MaPhongBan, TenPhongBan, DiaDiem, SoDienThoai)
    VALUES
        ('PB001', N'Phòng Nhân sự', N'Tầng 1 - Văn phòng công ty', '02838220001'),
        ('PB002', N'Phòng Tài chính - Kế toán', N'Tầng 1 - Văn phòng công ty', '02838220002'),
        ('PB003', N'Phòng Kỹ thuật', N'Khu kỹ thuật', '02838220003'),
        ('PB004', N'Phòng Sản xuất', N'Nhà xưởng số 1', '02838220004'),
        ('PB005', N'Phòng Kinh doanh', N'Tầng 2 - Văn phòng công ty', '02838220005');

    /* NHAN VIEN */
    INSERT INTO dbo.NhanVien
        (MaNhanVien, HoTen, NgaySinh, GioiTinh, CCCD,
         DiaChi, SoDienThoai, Email, NgayVaoLam, PhongBanID, TrangThai)
    VALUES
        ('NV001', N'Nguyễn Minh An', '1995-04-12', N'Nam',
         '079095000101', N'Quận 12, TP. Hồ Chí Minh',
         '0903000001', 'an.nv001@example.com', '2026-01-05', 1, N'Dang lam'),

        ('NV002', N'Trần Thị Bích Ngọc', '1998-09-20', N'Nữ',
         '079098000102', N'Gò Vấp, TP. Hồ Chí Minh',
         '0903000002', 'ngoc.nv002@example.com', '2026-02-02', 2, N'Dang lam'),

        ('NV003', N'Lê Quốc Bảo', '1993-02-18', N'Nam',
         '079093000103', N'Thủ Đức, TP. Hồ Chí Minh',
         '0903000003', 'bao.nv003@example.com', '2026-03-01', 3, N'Dang lam'),

        ('NV004', N'Phạm Thị Thu Hà', '2000-06-25', N'Nữ',
         '079100000104', N'Bình Tân, TP. Hồ Chí Minh',
         '0903000004', 'ha.nv004@example.com', '2026-07-01', 4, N'Thu viec'),

        ('NV005', N'Võ Thành Đạt', '1997-11-03', N'Nam',
         '079097000105', N'Tân Phú, TP. Hồ Chí Minh',
         '0903000005', 'dat.nv005@example.com', '2026-01-15', 5, N'Dang lam'),

        ('NV006', N'Đặng Hoàng Phúc', '1992-08-14', N'Nam',
         '079092000106', N'Bình Thạnh, TP. Hồ Chí Minh',
         '0903000006', 'phuc.nv006@example.com', '2026-04-01', 3, N'Dang lam');

    /* QUYET DINH TUYEN DUNG */
    INSERT INTO dbo.QuyetDinhTuyenDung
        (SoQuyetDinh, NhanVienID, PhongBanID, NgayQuyetDinh,
         NgayBatDauThuViec, NgayKetThucThuViec, LuongThuViec,
         DieuKhoan, NguoiKy, TrangThai)
    VALUES
        ('QDTD-2026-001', 4, 4, '2026-06-25',
         '2026-07-01', '2026-08-31', 8500000,
         N'Thử việc 2 tháng; thực hiện nội quy lao động và quy trình an toàn sản xuất.',
         N'Nguyễn Văn Hùng', N'Da ban hanh'),

        ('QDTD-2026-002', 6, 3, '2026-03-25',
         '2026-04-01', '2026-05-31', 11000000,
         N'Thử việc 2 tháng; thực hiện nhiệm vụ kỹ thuật theo phân công.',
         N'Nguyễn Văn Hùng', N'Da ban hanh');

    /* HOP DONG LAO DONG */
    INSERT INTO dbo.HopDongLaoDong
        (SoHopDong, NhanVienID, LoaiHopDong, NgayKy,
         NgayHieuLuc, NgayHetHan, NoiDung, NguoiKy, TrangThai)
    VALUES
        ('HD-2026-001', 1, N'Dai han', '2026-01-05',
         '2026-01-05', NULL,
         N'Hợp đồng lao động dài hạn; thực hiện công việc nhân sự theo phân công.',
         N'Nguyễn Văn Hùng', N'Hieu luc'),

        ('HD-2026-002', 2, N'Dai han', '2026-02-02',
         '2026-02-02', NULL,
         N'Hợp đồng lao động dài hạn; thực hiện nghiệp vụ kế toán theo phân công.',
         N'Nguyễn Văn Hùng', N'Hieu luc'),

        ('HD-2026-003', 3, N'Dai han', '2026-03-01',
         '2026-03-01', NULL,
         N'Hợp đồng lao động dài hạn; phụ trách công việc kỹ thuật.',
         N'Nguyễn Văn Hùng', N'Hieu luc'),

        ('HD-2026-004', 5, N'Ngan han', '2026-01-15',
         '2026-01-15', '2026-12-31',
         N'Hợp đồng lao động có thời hạn đến hết ngày 31/12/2026.',
         N'Nguyễn Văn Hùng', N'Hieu luc');

    /* QUYET DINH CHUC VU */
    INSERT INTO dbo.QuyetDinhChucVu
        (SoQuyetDinh, NhanVienID, ChucVu, PhuCapChucVu,
         NgayQuyetDinh, NgayHieuLuc, GhiChu)
    VALUES
        ('QDCV-2026-001', 1, N'Chuyên viên nhân sự', 500000,
         '2026-01-05', '2026-01-05', N'Bổ nhiệm vị trí chuyên viên nhân sự'),

        ('QDCV-2026-002', 2, N'Kế toán viên', 700000,
         '2026-02-02', '2026-02-02', N'Bổ nhiệm vị trí kế toán viên'),

        ('QDCV-2026-003', 3, N'Kỹ thuật viên', 600000,
         '2026-03-01', '2026-03-01', N'Bổ nhiệm vị trí kỹ thuật viên'),

        ('QDCV-2026-004', 5, N'Nhân viên kinh doanh', 300000,
         '2026-01-15', '2026-01-15', N'Bố trí công việc kinh doanh');

    /* QUYET DINH LUONG */
    INSERT INTO dbo.QuyetDinhLuong
        (SoQuyetDinh, NhanVienID, LuongCoBan, PhuCapLuong,
         PhuCapDocHai, NgayQuyetDinh, NgayHieuLuc, LyDo)
    VALUES
        ('QDL-2026-001', 1, 12000000, 1000000, 0,
         '2026-01-05', '2026-01-05', N'Quyết định lương khi nhận việc'),

        ('QDL-2026-002', 2, 13500000, 800000, 0,
         '2026-02-02', '2026-02-02', N'Quyết định lương khi nhận việc'),

        ('QDL-2026-003', 3, 15000000, 1000000, 500000,
         '2026-03-01', '2026-03-01', N'Lương vị trí kỹ thuật có phụ cấp độc hại'),

        ('QDL-2026-004', 4, 10000000, 500000, 500000,
         '2026-07-01', '2026-07-01', N'Mức lương dự kiến theo quyết định tuyển dụng'),

        ('QDL-2026-005', 5, 11000000, 500000, 0,
         '2026-01-15', '2026-01-15', N'Quyết định lương khi nhận việc'),

        ('QDL-2026-006', 6, 14000000, 1000000, 500000,
         '2026-04-01', '2026-04-01', N'Quyết định lương vị trí kỹ thuật');

    /* CHAM CONG THANG 09/2026 */
    INSERT INTO dbo.ChamCong
        (NhanVienID, Thang, Nam, SoNgayCong, SoNgayNghi,
         NguoiChamCong, NgayCapNhat, GhiChu)
    VALUES
        (1, 9, 2026, 22, 0, N'Trần Văn Long', '2026-10-01', N'Đủ ngày công theo lịch làm việc'),
        (2, 9, 2026, 21, 1, N'Trần Văn Long', '2026-10-01', N'Nghỉ phép 1 ngày'),
        (3, 9, 2026, 22, 0, N'Trần Văn Long', '2026-10-01', N'Đủ ngày công theo lịch làm việc'),
        (5, 9, 2026, 22, 0, N'Trần Văn Long', '2026-10-01', N'Đủ ngày công theo lịch làm việc'),
        (6, 9, 2026, 21, 1, N'Trần Văn Long', '2026-10-01', N'Nghỉ phép 1 ngày');

    /* PHIEU PHU TROI */
    INSERT INTO dbo.PhieuPhuTroi
        (SoPhieu, NhanVienID, NgayPhuTroi, SoGio, HinhThuc,
         HeSoLuong, NguoiXacNhan, GhiChu)
    VALUES
        ('PPT-2026-001', 1, '2026-09-10', 2, N'Tang ca', 1.5,
         N'Trần Văn Long', N'Hỗ trợ hoàn thiện hồ sơ nhân sự'),

        ('PPT-2026-002', 3, '2026-09-12', 3, N'Tang ca', 1.5,
         N'Lê Văn Thành', N'Xử lý công việc kỹ thuật ngoài giờ'),

        ('PPT-2026-003', 3, '2026-09-02', 4, N'Ngay le', 1.5,
         N'Lê Văn Thành', N'Làm việc theo kế hoạch ngày lễ'),

        ('PPT-2026-004', 5, '2026-09-15', 2, N'Tang ca', 1.5,
         N'Trần Văn Long', N'Hỗ trợ tổng hợp đơn hàng');

    /* QUYET DINH KHEN THUONG */
    INSERT INTO dbo.QuyetDinhKhenThuong
        (SoQuyetDinh, NhanVienID, PhongBanID, LoaiKhenThuong,
         LyDo, SoTien, NgayQuyetDinh, NguoiKy, TrangThai)
    VALUES
        ('QDKT-2026-001', 1, NULL, N'Khen thưởng cá nhân',
         N'Hoàn thành tốt công tác rà soát hồ sơ nhân sự quý III.',
         1000000, '2026-09-30', N'Nguyễn Văn Hùng', N'Da ky'),

        ('QDKT-2026-002', NULL, 3, N'Khen thưởng tập thể',
         N'Tập thể phòng kỹ thuật hoàn thành kế hoạch bảo trì thiết bị.',
         5000000, '2026-09-30', N'Nguyễn Văn Hùng', N'Da ky'),

        ('QDKT-2026-003', 5, NULL, N'Khen thưởng cá nhân',
         N'Đạt kết quả tốt trong hoạt động chăm sóc khách hàng.',
         800000, '2026-09-30', N'Nguyễn Văn Hùng', N'Cho ky');

    /* PHIEU CHI KHEN THUONG - chi cho cac quyet dinh da ky */
    INSERT INTO dbo.PhieuChiKhenThuong
        (SoPhieuChi, QuyetDinhKhenThuongID, NgayChi,
         SoTien, NguoiNhan, NguoiLapPhieu, GhiChu)
    VALUES
        ('PCKT-2026-001', 1, '2026-10-02', 1000000,
         N'Nguyễn Minh An', N'Trần Thị Bích Ngọc',
         N'Chi thưởng theo quyết định QDKT-2026-001'),

        ('PCKT-2026-002', 2, '2026-10-02', 5000000,
         N'Tập thể Phòng Kỹ thuật', N'Trần Thị Bích Ngọc',
         N'Chi thưởng tập thể theo quyết định QDKT-2026-002');

    /* QUYET DINH KY LUAT */
    INSERT INTO dbo.QuyetDinhKyLuat
        (SoQuyetDinh, NhanVienID, PhongBanID, HinhThuc,
         LyDo, SoTienPhat, NgayQuyetDinh, NguoiKy, TrangThai)
    VALUES
        ('QDKL-2026-001', 5, NULL, N'Nhắc nhở',
         N'Không cập nhật báo cáo công việc đúng thời hạn.',
         0, '2026-09-18', N'Nguyễn Văn Hùng', N'Da ban hanh'),

        ('QDKL-2026-002', 3, NULL, N'Phạt tiền',
         N'Vi phạm quy trình bàn giao thiết bị theo biên bản.',
         300000, '2026-09-25', N'Nguyễn Văn Hùng', N'Da ban hanh');

    /* PHIEU THU PHAT */
    INSERT INTO dbo.PhieuThuPhat
        (SoPhieuThu, QuyetDinhKyLuatID, NgayThu, SoTien,
         HinhThucThu, NguoiThu, GhiChu)
    VALUES
        ('PTP-2026-001', 2, '2026-09-28', 300000,
         N'Tien mat', N'Trần Thị Bích Ngọc',
         N'Thu phạt theo quyết định QDKL-2026-002');

    /* BAO HIEM */
    INSERT INTO dbo.BaoHiem
        (NhanVienID, SoBHXH, SoBHYT, NgayBatDau,
         TyLeBHXH, TyLeBHYT, TrangThai)
    VALUES
        (1, 'BHXH-MAU-0001', 'BHYT-MAU-0001', '2026-01-05', 8.00, 1.50, N'Dang tham gia'),
        (2, 'BHXH-MAU-0002', 'BHYT-MAU-0002', '2026-02-02', 8.00, 1.50, N'Dang tham gia'),
        (3, 'BHXH-MAU-0003', 'BHYT-MAU-0003', '2026-03-01', 8.00, 1.50, N'Dang tham gia'),
        (5, 'BHXH-MAU-0005', 'BHYT-MAU-0005', '2026-01-15', 8.00, 1.50, N'Dang tham gia');

    /* BANG LUONG THANG 09/2026
       ThucLanh = Luong + Phu cap + Lam them + Thuong
                  - Bao hiem - Phat - Thue
       So lieu duoi day la du lieu mau de test.
    */
    INSERT INTO dbo.BangLuong
        (SoBangLuong, NhanVienID, Thang, Nam, QuyetDinhLuongID,
         TongLuongCoBan, TongPhuCap, TienLamThem, TienThuong,
         TienBaoHiem, TienPhat, ThueTNCN, ThucLanh,
         NgayLap, TrangThai)
    VALUES
        ('BL-2026-09-001', 1, 9, 2026, 1,
         12000000, 1500000, 163636, 1000000,
         1140000, 0, 0, 13523636,
         '2026-10-03', N'Chua thanh toan'),

        ('BL-2026-09-002', 2, 9, 2026, 2,
         12886364, 1500000, 0, 0,
         1425000, 0, 0, 12961364,
         '2026-10-03', N'Chua thanh toan'),

        ('BL-2026-09-003', 3, 9, 2026, 3,
         15000000, 2000000, 460227, 0,
         1650000, 300000, 0, 15510227,
         '2026-10-03', N'Chua thanh toan'),

        ('BL-2026-09-004', 5, 9, 2026, 5,
         11000000, 800000, 125000, 800000,
         920000, 0, 0, 11805000,
         '2026-10-03', N'Chua thanh toan'),

        ('BL-2026-09-005', 6, 9, 2026, 6,
         13500000, 1500000, 0, 0,
         1550000, 0, 0, 13450000,
         '2026-10-03', N'Chua thanh toan');

    COMMIT TRANSACTION;
    PRINT N'Da tao CSDL va them du lieu mau thanh cong.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

/* =========================================================
   KIEM TRA DU LIEU SAU KHI INSERT
   ========================================================= */
SELECT * FROM dbo.PhongBan;
SELECT * FROM dbo.NhanVien;
SELECT * FROM dbo.QuyetDinhTuyenDung;
SELECT * FROM dbo.HopDongLaoDong;
SELECT * FROM dbo.QuyetDinhChucVu;
SELECT * FROM dbo.QuyetDinhLuong;
SELECT * FROM dbo.ChamCong;
SELECT * FROM dbo.PhieuPhuTroi;
SELECT * FROM dbo.BangLuong;
SELECT * FROM dbo.QuyetDinhKhenThuong;
SELECT * FROM dbo.PhieuChiKhenThuong;
SELECT * FROM dbo.QuyetDinhKyLuat;
SELECT * FROM dbo.PhieuThuPhat;
SELECT * FROM dbo.BaoHiem;
GO

/* =========================================================
   TRUY VAN MAU: DANH SACH NHAN VIEN VA PHONG BAN
   ========================================================= */
SELECT
    nv.MaNhanVien,
    nv.HoTen,
    pb.TenPhongBan,
    nv.NgayVaoLam,
    nv.TrangThai
FROM dbo.NhanVien AS nv
INNER JOIN dbo.PhongBan AS pb
    ON nv.PhongBanID = pb.PhongBanID
ORDER BY nv.MaNhanVien;
GO

/* TRUY VAN MAU: QUYET DINH KHEN THUONG VA PHIEU CHI */
SELECT
    q.SoQuyetDinh,
    q.LoaiKhenThuong,
    nv.HoTen AS NhanVienDuocThuong,
    pb.TenPhongBan AS TapTheDuocThuong,
    q.SoTien,
    q.TrangThai,
    pc.SoPhieuChi,
    pc.NgayChi
FROM dbo.QuyetDinhKhenThuong AS q
LEFT JOIN dbo.NhanVien AS nv
    ON q.NhanVienID = nv.NhanVienID
LEFT JOIN dbo.PhongBan AS pb
    ON q.PhongBanID = pb.PhongBanID
LEFT JOIN dbo.PhieuChiKhenThuong AS pc
    ON q.QuyetDinhKhenThuongID = pc.QuyetDinhKhenThuongID
ORDER BY q.NgayQuyetDinh;
GO
