
/*
    DATABASE: QuanLyTourVanHoaViet
    He thong quan ly tour du lich Van Hoa Viet
    SQL Server

    Cac bang chinh:
    Tour, DiemDung, PhuongTien, DiemThamQuan,
    KhachHang, KhachDoan, KhachLe,
    PhieuDangKyDoan, ThanhVienDoan, ChuyenDi,
    PhieuDangKyChuyen, DiemBanVe, DiemDon,
    NhanVienHuongDan, PhanCong, PhieuKhaoSat.

    Bang lien ket:
    Tour_DiemThamQuan, ChuyenDi_DiemDon.
*/

IF DB_ID(N'QuanLyTourVanHoaViet') IS NULL
    CREATE DATABASE QuanLyTourVanHoaViet;
GO

USE QuanLyTourVanHoaViet;
GO

/* XOA CAC BANG CU DE TAO LAI */
DROP TABLE IF EXISTS dbo.PhieuKhaoSat;
DROP TABLE IF EXISTS dbo.PhanCong;
DROP TABLE IF EXISTS dbo.PhieuDangKyChuyen;
DROP TABLE IF EXISTS dbo.ChuyenDi_DiemDon;
DROP TABLE IF EXISTS dbo.ChuyenDi;
DROP TABLE IF EXISTS dbo.ThanhVienDoan;
DROP TABLE IF EXISTS dbo.PhieuDangKyDoan;
DROP TABLE IF EXISTS dbo.KhachLe;
DROP TABLE IF EXISTS dbo.KhachDoan;
DROP TABLE IF EXISTS dbo.KhachHang;
DROP TABLE IF EXISTS dbo.Tour_DiemThamQuan;
DROP TABLE IF EXISTS dbo.DiemThamQuan;
DROP TABLE IF EXISTS dbo.DiemDung;
DROP TABLE IF EXISTS dbo.PhuongTien;
DROP TABLE IF EXISTS dbo.DiemDon;
DROP TABLE IF EXISTS dbo.DiemBanVe;
DROP TABLE IF EXISTS dbo.Tour;
GO

/* 1. TOUR */
CREATE TABLE dbo.Tour (
    maTour VARCHAR(10) PRIMARY KEY,
    tenTour NVARCHAR(150) NOT NULL,
    soNgay INT NOT NULL CHECK (soNgay > 0),
    soDem INT NOT NULL CHECK (soDem >= 0),
    donGia DECIMAL(18,2) NOT NULL CHECK (donGia >= 0),
    CHECK (soDem <= soNgay)
);
GO

/* 2. PHUONG TIEN */
CREATE TABLE dbo.PhuongTien (
    maPT VARCHAR(10) PRIMARY KEY,
    loaiPT NVARCHAR(80) NOT NULL
);
GO

/* 3. DIEM DUNG */
CREATE TABLE dbo.DiemDung (
    maDiemDung VARCHAR(10) PRIMARY KEY,
    maTour VARCHAR(10) NOT NULL,
    maPT VARCHAR(10) NULL,
    tenNoiDung NVARCHAR(150) NOT NULL,
    thuTu INT NOT NULL CHECK (thuTu > 0),
    doiPhuongTien BIT NOT NULL DEFAULT 0,
    coAn BIT NOT NULL DEFAULT 0,
    coKhachSan BIT NOT NULL DEFAULT 0,
    loaiKhachSan INT NULL,

    CONSTRAINT FK_DiemDung_Tour
        FOREIGN KEY (maTour) REFERENCES dbo.Tour(maTour),

    CONSTRAINT FK_DiemDung_PhuongTien
        FOREIGN KEY (maPT) REFERENCES dbo.PhuongTien(maPT),

    CONSTRAINT CK_DiemDung_KhachSan CHECK (
        (coKhachSan = 0 AND loaiKhachSan IS NULL)
        OR
        (coKhachSan = 1 AND loaiKhachSan BETWEEN 2 AND 5)
    ),

    CONSTRAINT UQ_DiemDung_ThuTu UNIQUE (maTour, thuTu)
);
GO

/* 4. DIEM THAM QUAN */
CREATE TABLE dbo.DiemThamQuan (
    maDiemTQ VARCHAR(10) PRIMARY KEY,
    tenDiemTQ NVARCHAR(150) NOT NULL,
    diaDiem NVARCHAR(200) NOT NULL,
    noiDung NVARCHAR(MAX) NULL,
    yNghia NVARCHAR(MAX) NULL
);
GO

/* 5. BANG LIEN KET TOUR - DIEM THAM QUAN */
CREATE TABLE dbo.Tour_DiemThamQuan (
    maTour VARCHAR(10) NOT NULL,
    maDiemTQ VARCHAR(10) NOT NULL,
    thuTu INT NOT NULL DEFAULT 1 CHECK (thuTu > 0),

    CONSTRAINT PK_Tour_DiemThamQuan
        PRIMARY KEY (maTour, maDiemTQ),

    FOREIGN KEY (maTour) REFERENCES dbo.Tour(maTour),
    FOREIGN KEY (maDiemTQ) REFERENCES dbo.DiemThamQuan(maDiemTQ)
);
GO

/* 6. KHACH HANG */
CREATE TABLE dbo.KhachHang (
    maKH VARCHAR(10) PRIMARY KEY,
    soDienThoai VARCHAR(15) NOT NULL,
    diaChi NVARCHAR(250) NOT NULL
);
GO

/* 7. KHACH DOAN - KE THUA KHACH HANG */
CREATE TABLE dbo.KhachDoan (
    maKH VARCHAR(10) PRIMARY KEY,
    tenCoQuan NVARCHAR(150) NULL,
    diaChiCoQuan NVARCHAR(250) NULL,
    dienThoaiCoQuan VARCHAR(15) NULL,
    nguoiDaiDien NVARCHAR(100) NOT NULL,

    FOREIGN KEY (maKH) REFERENCES dbo.KhachHang(maKH)
);
GO

/* 8. KHACH LE - KE THUA KHACH HANG */
CREATE TABLE dbo.KhachLe (
    maKH VARCHAR(10) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    cmnd VARCHAR(20) NULL,

    FOREIGN KEY (maKH) REFERENCES dbo.KhachHang(maKH)
);
GO

/* 9. PHIEU DANG KY DOAN */
CREATE TABLE dbo.PhieuDangKyDoan (
    maPhieuDoan VARCHAR(10) PRIMARY KEY,
    maKH VARCHAR(10) NOT NULL,
    maTour VARCHAR(10) NOT NULL,
    ngayLap DATE NOT NULL DEFAULT CONVERT(DATE, GETDATE()),
    ngayDi DATE NOT NULL,
    soNguoi INT NOT NULL CHECK (soNguoi > 0),
    diaDiemDon NVARCHAR(200) NOT NULL,
    tienDatCoc DECIMAL(18,2) NOT NULL DEFAULT 0
        CHECK (tienDatCoc >= 0),
    coMuaBaoHiem BIT NOT NULL DEFAULT 0,
    ngayThanhToan DATE NULL,
    kinhPhi DECIMAL(18,2) NOT NULL DEFAULT 0
        CHECK (kinhPhi >= 0),

    CONSTRAINT FK_PDKD_KhachDoan
        FOREIGN KEY (maKH) REFERENCES dbo.KhachDoan(maKH),

    CONSTRAINT FK_PDKD_Tour
        FOREIGN KEY (maTour) REFERENCES dbo.Tour(maTour),

    CONSTRAINT CK_PDKD_NgayDi CHECK (ngayDi >= ngayLap),

    CONSTRAINT CK_PDKD_DatCoc
        CHECK (tienDatCoc <= kinhPhi OR kinhPhi = 0)
);
GO

/* 10. THANH VIEN DOAN */
CREATE TABLE dbo.ThanhVienDoan (
    maTV VARCHAR(10) PRIMARY KEY,
    maPhieuDoan VARCHAR(10) NOT NULL,
    hoTen NVARCHAR(100) NOT NULL,
    ngaySinh DATE NULL,
    cmnd VARCHAR(20) NULL,

    FOREIGN KEY (maPhieuDoan)
        REFERENCES dbo.PhieuDangKyDoan(maPhieuDoan)
);
GO

/* 11. CHUYEN DI */
CREATE TABLE dbo.ChuyenDi (
    maChuyen VARCHAR(10) PRIMARY KEY,
    maTour VARCHAR(10) NOT NULL,
    ngayDi DATE NOT NULL,
    ngayVe DATE NOT NULL,

    FOREIGN KEY (maTour) REFERENCES dbo.Tour(maTour),
    CHECK (ngayVe >= ngayDi)
);
GO

/* 12. DIEM BAN VE */
CREATE TABLE dbo.DiemBanVe (
    maDiemBan VARCHAR(10) PRIMARY KEY,
    tenDiemBan NVARCHAR(150) NOT NULL,
    diaChi NVARCHAR(250) NOT NULL
);
GO

/* 13. DIEM DON */
CREATE TABLE dbo.DiemDon (
    maDiemDon VARCHAR(10) PRIMARY KEY,
    diaChi NVARCHAR(250) NOT NULL
);
GO

/* 14. BANG LIEN KET CHUYEN DI - DIEM DON */
CREATE TABLE dbo.ChuyenDi_DiemDon (
    maChuyen VARCHAR(10) NOT NULL,
    maDiemDon VARCHAR(10) NOT NULL,

    CONSTRAINT PK_ChuyenDi_DiemDon
        PRIMARY KEY (maChuyen, maDiemDon),

    FOREIGN KEY (maChuyen) REFERENCES dbo.ChuyenDi(maChuyen),
    FOREIGN KEY (maDiemDon) REFERENCES dbo.DiemDon(maDiemDon)
);
GO

/* 15. PHIEU DANG KY CHUYEN / VE KHACH LE */
CREATE TABLE dbo.PhieuDangKyChuyen (
    maVe VARCHAR(10) PRIMARY KEY,
    maKH VARCHAR(10) NOT NULL,
    maChuyen VARCHAR(10) NOT NULL,
    maDiemBan VARCHAR(10) NOT NULL,
    maDiemDon VARCHAR(10) NOT NULL,
    ngayDangKy DATE NOT NULL DEFAULT CONVERT(DATE, GETDATE()),
    soLuong INT NOT NULL DEFAULT 1 CHECK (soLuong > 0),
    thanhTien DECIMAL(18,2) NOT NULL CHECK (thanhTien >= 0),
    daThanhToan BIT NOT NULL DEFAULT 0,

    FOREIGN KEY (maKH) REFERENCES dbo.KhachLe(maKH),
    FOREIGN KEY (maChuyen) REFERENCES dbo.ChuyenDi(maChuyen),
    FOREIGN KEY (maDiemBan) REFERENCES dbo.DiemBanVe(maDiemBan),
    FOREIGN KEY (maDiemDon) REFERENCES dbo.DiemDon(maDiemDon)
);
GO

/* 16. NHAN VIEN HUONG DAN */
CREATE TABLE dbo.NhanVienHuongDan (
    maNV VARCHAR(10) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    luongCanBan DECIMAL(18,2) NOT NULL CHECK (luongCanBan >= 0)
);
GO

/* 17. PHAN CONG HUONG DAN VIEN */
CREATE TABLE dbo.PhanCong (
    maPC VARCHAR(10) PRIMARY KEY,
    maNV VARCHAR(10) NOT NULL,
    maTour VARCHAR(10) NULL,
    maChuyen VARCHAR(10) NULL,
    maPhieuDoan VARCHAR(10) NULL,
    ngayBatDau DATE NOT NULL,
    ngayKetThuc DATE NOT NULL,
    luongTheoTour DECIMAL(18,2) NOT NULL DEFAULT 0
        CHECK (luongTheoTour >= 0),

    FOREIGN KEY (maNV) REFERENCES dbo.NhanVienHuongDan(maNV),
    FOREIGN KEY (maTour) REFERENCES dbo.Tour(maTour),
    FOREIGN KEY (maChuyen) REFERENCES dbo.ChuyenDi(maChuyen),
    FOREIGN KEY (maPhieuDoan)
        REFERENCES dbo.PhieuDangKyDoan(maPhieuDoan),

    CHECK (ngayKetThuc >= ngayBatDau),

    /* Moi phan cong gan voi mot phieu doan hoac mot chuyen */
    CHECK (
        (maPhieuDoan IS NOT NULL AND maChuyen IS NULL)
        OR
        (maPhieuDoan IS NULL AND maChuyen IS NOT NULL)
    )
);
GO

/* 18. PHIEU KHAO SAT */
CREATE TABLE dbo.PhieuKhaoSat (
    maKS VARCHAR(10) PRIMARY KEY,
    maKH VARCHAR(10) NOT NULL,
    maTour VARCHAR(10) NOT NULL,
    ngayGui DATE NOT NULL DEFAULT CONVERT(DATE, GETDATE()),
    noiDungGopY NVARCHAR(MAX) NULL,
    diemDanhGia INT NOT NULL CHECK (diemDanhGia BETWEEN 1 AND 5),

    FOREIGN KEY (maKH) REFERENCES dbo.KhachHang(maKH),
    FOREIGN KEY (maTour) REFERENCES dbo.Tour(maTour)
);
GO

/* CAC INDEX HO TRO TRA CUU */
CREATE INDEX IX_DiemDung_maTour
    ON dbo.DiemDung(maTour);

CREATE INDEX IX_PDKD_maKH
    ON dbo.PhieuDangKyDoan(maKH);

CREATE INDEX IX_PDKD_maTour
    ON dbo.PhieuDangKyDoan(maTour);

CREATE INDEX IX_PDKC_maKH
    ON dbo.PhieuDangKyChuyen(maKH);

CREATE INDEX IX_PDKC_maChuyen
    ON dbo.PhieuDangKyChuyen(maChuyen);

CREATE INDEX IX_PhanCong_maNV_Ngay
    ON dbo.PhanCong(maNV, ngayBatDau, ngayKetThuc);
GO

/* ==========================================
   DU LIEU MAU DE KIEM THU
   ========================================== */

/* TOUR */
INSERT INTO dbo.Tour
    (maTour, tenTour, soNgay, soDem, donGia)
VALUES
    ('T001', N'TP.HCM - Đà Lạt', 3, 2, 2500000),
    ('T002', N'TP.HCM - Nha Trang', 3, 2, 3200000);

/* PHUONG TIEN */
INSERT INTO dbo.PhuongTien (maPT, loaiPT)
VALUES
    ('PT01', N'Xe du lịch'),
    ('PT02', N'Tàu thủy');

/* DIEM DUNG */
INSERT INTO dbo.DiemDung
    (maDiemDung, maTour, maPT, tenNoiDung, thuTu,
     doiPhuongTien, coAn, coKhachSan, loaiKhachSan)
VALUES
    ('DD01', 'T001', 'PT01', N'Bảo Lộc - nghỉ chân',
     1, 0, 1, 0, NULL),

    ('DD02', 'T001', 'PT01', N'Đà Lạt - lưu trú',
     2, 0, 1, 1, 3),

    ('DD03', 'T002', 'PT01', N'Phan Thiết - đổi phương tiện',
     1, 1, 1, 0, NULL);

/* DIEM THAM QUAN */
INSERT INTO dbo.DiemThamQuan
    (maDiemTQ, tenDiemTQ, diaDiem, noiDung, yNghia)
VALUES
    ('TQ01', N'Hồ Xuân Hương', N'Đà Lạt',
     N'Tham quan hồ và khu vực trung tâm',
     N'Điểm tham quan nổi bật của Đà Lạt'),

    ('TQ02', N'VinWonders', N'Nha Trang',
     N'Khu vui chơi và giải trí',
     N'Điểm tham quan vui chơi');

/* TOUR - DIEM THAM QUAN */
INSERT INTO dbo.Tour_DiemThamQuan (maTour, maDiemTQ, thuTu)
VALUES
    ('T001', 'TQ01', 1),
    ('T002', 'TQ02', 1);

/* KHACH HANG */
INSERT INTO dbo.KhachHang (maKH, soDienThoai, diaChi)
VALUES
    ('KH001', '0901234567', N'Quận 1, TP.HCM'),
    ('KH002', '0912345678', N'Thủ Đức, TP.HCM');

/* KHACH DOAN */
INSERT INTO dbo.KhachDoan
    (maKH, tenCoQuan, diaChiCoQuan, dienThoaiCoQuan, nguoiDaiDien)
VALUES
    ('KH001', N'Công ty Ánh Dương',
     N'Quận 1, TP.HCM', '0901234567', N'Nguyễn Minh Anh');

/* KHACH LE */
INSERT INTO dbo.KhachLe (maKH, hoTen, cmnd)
VALUES
    ('KH002', N'Trần Minh Khoa', '079123456789');

/* PHIEU DANG KY DOAN */
INSERT INTO dbo.PhieuDangKyDoan
    (maPhieuDoan, maKH, maTour, ngayLap, ngayDi,
     soNguoi, diaDiemDon, tienDatCoc, coMuaBaoHiem,
     ngayThanhToan, kinhPhi)
VALUES
    ('PD001', 'KH001', 'T001', '2026-10-09', '2026-11-10',
     15, N'Nhà văn hóa Thanh Niên', 5000000, 1,
     NULL, 37500000);

/* THANH VIEN DOAN */
INSERT INTO dbo.ThanhVienDoan
    (maTV, maPhieuDoan, hoTen, ngaySinh, cmnd)
VALUES
    ('TV001', 'PD001', N'Nguyễn Minh Anh',
     '1988-03-12', '079123450001'),

    ('TV002', 'PD001', N'Lê Hoàng Nam',
     '1990-07-25', '079123450002');

/* CHUYEN DI */
INSERT INTO dbo.ChuyenDi (maChuyen, maTour, ngayDi, ngayVe)
VALUES
    ('C001', 'T002', '2026-11-15', '2026-11-17');

/* DIEM BAN VE */
INSERT INTO dbo.DiemBanVe (maDiemBan, tenDiemBan, diaChi)
VALUES
    ('DB01', N'Văn phòng trung tâm', N'Quận 1, TP.HCM');

/* DIEM DON */
INSERT INTO dbo.DiemDon (maDiemDon, diaChi)
VALUES
    ('DN01', N'Nhà văn hóa Thanh Niên, Quận 1'),
    ('DN02', N'Bến xe Miền Đông mới');

/* CHUYEN DI - DIEM DON */
INSERT INTO dbo.ChuyenDi_DiemDon (maChuyen, maDiemDon)
VALUES
    ('C001', 'DN01'),
    ('C001', 'DN02');

/* VE KHACH LE */
INSERT INTO dbo.PhieuDangKyChuyen
    (maVe, maKH, maChuyen, maDiemBan, maDiemDon,
     ngayDangKy, soLuong, thanhTien, daThanhToan)
VALUES
    ('V001', 'KH002', 'C001', 'DB01', 'DN01',
     '2026-10-09', 1, 3200000, 1);

/* NHAN VIEN HUONG DAN */
INSERT INTO dbo.NhanVienHuongDan (maNV, hoTen, luongCanBan)
VALUES
    ('NV001', N'Phạm Quốc Bảo', 8000000),
    ('NV002', N'Võ Ngọc Lan', 7500000);

/* PHAN CONG HUONG DAN VIEN */
INSERT INTO dbo.PhanCong
    (maPC, maNV, maTour, maChuyen, maPhieuDoan,
     ngayBatDau, ngayKetThuc, luongTheoTour)
VALUES
    ('PC001', 'NV001', 'T001', NULL, 'PD001',
     '2026-11-10', '2026-11-12', 1500000),

    ('PC002', 'NV002', 'T002', 'C001', NULL,
     '2026-11-15', '2026-11-17', 1200000);

/* PHIEU KHAO SAT */
INSERT INTO dbo.PhieuKhaoSat
    (maKS, maKH, maTour, ngayGui, noiDungGopY, diemDanhGia)
VALUES
    ('KS001', 'KH002', 'T002', '2026-11-18',
     N'Hướng dẫn viên nhiệt tình, lịch trình hợp lý.', 5);
GO

/* ==========================================
   CAC TRUY VAN KIEM THU
   Chay tung truy van de xem ket qua
   ========================================== */

/* TC01: Xem danh sach tour */
SELECT maTour, tenTour, soNgay, soDem, donGia
FROM dbo.Tour
ORDER BY maTour;

/* TC02: Xem phieu dang ky tour doan */
SELECT
    p.maPhieuDoan,
    t.tenTour,
    kd.nguoiDaiDien,
    p.soNguoi,
    p.tienDatCoc,
    p.kinhPhi,
    p.ngayDi
FROM dbo.PhieuDangKyDoan p
JOIN dbo.KhachDoan kd ON kd.maKH = p.maKH
JOIN dbo.Tour t ON t.maTour = p.maTour;

/* TC03: Xem ve khach le */
SELECT
    v.maVe,
    kl.hoTen,
    t.tenTour,
    c.ngayDi,
    c.ngayVe,
    db.tenDiemBan,
    dd.diaChi AS diemDon,
    v.thanhTien,
    v.daThanhToan
FROM dbo.PhieuDangKyChuyen v
JOIN dbo.KhachLe kl ON kl.maKH = v.maKH
JOIN dbo.ChuyenDi c ON c.maChuyen = v.maChuyen
JOIN dbo.Tour t ON t.maTour = c.maTour
JOIN dbo.DiemBanVe db ON db.maDiemBan = v.maDiemBan
JOIN dbo.DiemDon dd ON dd.maDiemDon = v.maDiemDon;

/* TC04: Xem lich phan cong huong dan vien */
SELECT
    pc.maPC,
    nv.hoTen,
    pc.maTour,
    pc.maChuyen,
    pc.maPhieuDoan,
    pc.ngayBatDau,
    pc.ngayKetThuc,
    pc.luongTheoTour
FROM dbo.PhanCong pc
JOIN dbo.NhanVienHuongDan nv ON nv.maNV = pc.maNV
ORDER BY pc.ngayBatDau;

/* TC05: Tinh luong minh hoa
   Luong thang = luong co ban + tong luong theo tour */
SELECT
    nv.maNV,
    nv.hoTen,
    nv.luongCanBan,
    nv.luongCanBan + COALESCE(SUM(pc.luongTheoTour), 0)
        AS tongLuongMinhHoa
FROM dbo.NhanVienHuongDan nv
LEFT JOIN dbo.PhanCong pc ON pc.maNV = nv.maNV
GROUP BY nv.maNV, nv.hoTen, nv.luongCanBan;
GO

/* TC06: Xem diem danh gia va gop y */
SELECT
    ks.maKS,
    kh.maKH,
    ks.maTour,
    ks.ngayGui,
    ks.diemDanhGia,
    ks.noiDungGopY
FROM dbo.PhieuKhaoSat ks
JOIN dbo.KhachHang kh ON kh.maKH = ks.maKH;
GO

/* TC07: Kiem tra so luong ban ghi moi bang */
SELECT 'Tour' AS TenBang, COUNT(*) AS SoLuong FROM dbo.Tour
UNION ALL
SELECT 'DiemDung', COUNT(*) FROM dbo.DiemDung
UNION ALL
SELECT 'PhuongTien', COUNT(*) FROM dbo.PhuongTien
UNION ALL
SELECT 'DiemThamQuan', COUNT(*) FROM dbo.DiemThamQuan
UNION ALL
SELECT 'KhachHang', COUNT(*) FROM dbo.KhachHang
UNION ALL
SELECT 'KhachDoan', COUNT(*) FROM dbo.KhachDoan
UNION ALL
SELECT 'KhachLe', COUNT(*) FROM dbo.KhachLe
UNION ALL
SELECT 'PhieuDangKyDoan', COUNT(*) FROM dbo.PhieuDangKyDoan
UNION ALL
SELECT 'ThanhVienDoan', COUNT(*) FROM dbo.ThanhVienDoan
UNION ALL
SELECT 'ChuyenDi', COUNT(*) FROM dbo.ChuyenDi
UNION ALL
SELECT 'PhieuDangKyChuyen', COUNT(*) FROM dbo.PhieuDangKyChuyen
UNION ALL
SELECT 'DiemBanVe', COUNT(*) FROM dbo.DiemBanVe
UNION ALL
SELECT 'DiemDon', COUNT(*) FROM dbo.DiemDon
UNION ALL
SELECT 'NhanVienHuongDan', COUNT(*) FROM dbo.NhanVienHuongDan
UNION ALL
SELECT 'PhanCong', COUNT(*) FROM dbo.PhanCong
UNION ALL
SELECT 'PhieuKhaoSat', COUNT(*) FROM dbo.PhieuKhaoSat;
GO