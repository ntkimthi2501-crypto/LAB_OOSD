
/* =========================================================
   DE TAI: QUAN LY CUA HANG NUOC GIAI KHAT
   SQL SERVER - DATABASE + TABLES + SAMPLE DATA
   ========================================================= */

USE master;
GO

IF DB_ID(N'QuanLyCuaHangNuocGiaiKhat') IS NULL
BEGIN
    CREATE DATABASE QuanLyCuaHangNuocGiaiKhat;
END;
GO

USE QuanLyCuaHangNuocGiaiKhat;
GO

/* =========================================================
   1. BANG NHAN HIEU
   ========================================================= */
IF OBJECT_ID(N'dbo.NhanHieu', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhanHieu
    (
        MaNhanHieu VARCHAR(10) NOT NULL,
        TenNhanHieu NVARCHAR(100) NOT NULL,

        CONSTRAINT PK_NhanHieu PRIMARY KEY (MaNhanHieu),
        CONSTRAINT UQ_NhanHieu_Ten UNIQUE (TenNhanHieu)
    );
END;
GO

/* =========================================================
   2. BANG NHA CUNG UNG
   ========================================================= */
IF OBJECT_ID(N'dbo.NhaCungUng', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhaCungUng
    (
        MaNCC VARCHAR(10) NOT NULL,
        TenNCC NVARCHAR(150) NOT NULL,
        DiaChi NVARCHAR(250) NOT NULL,
        SoDienThoai VARCHAR(15) NOT NULL,

        CONSTRAINT PK_NhaCungUng PRIMARY KEY (MaNCC)
    );
END;
GO

/* =========================================================
   3. BANG NUOC GIAI KHAT
   Moi san pham thuoc mot nhan hieu va mot nha cung ung.
   ========================================================= */
IF OBJECT_ID(N'dbo.NuocGiaiKhat', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NuocGiaiKhat
    (
        MaNGK VARCHAR(10) NOT NULL,
        TenNGK NVARCHAR(150) NOT NULL,
        DonViTinh NVARCHAR(30) NOT NULL,
        MaNhanHieu VARCHAR(10) NOT NULL,
        MaNCC VARCHAR(10) NOT NULL,
        DonGia DECIMAL(18,2) NOT NULL DEFAULT 0,
        SoLuongTon INT NOT NULL DEFAULT 0,
        DangKinhDoanh BIT NOT NULL DEFAULT 1,

        CONSTRAINT PK_NuocGiaiKhat PRIMARY KEY (MaNGK),

        CONSTRAINT FK_NGK_NhanHieu
            FOREIGN KEY (MaNhanHieu)
            REFERENCES dbo.NhanHieu(MaNhanHieu),

        CONSTRAINT FK_NGK_NhaCungUng
            FOREIGN KEY (MaNCC)
            REFERENCES dbo.NhaCungUng(MaNCC),

        CONSTRAINT CK_NGK_DonGia
            CHECK (DonGia >= 0),

        CONSTRAINT CK_NGK_TonKho
            CHECK (SoLuongTon >= 0)
    );
END;
GO

/* =========================================================
   4. BANG NHAN VIEN
   ========================================================= */
IF OBJECT_ID(N'dbo.NhanVien', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhanVien
    (
        MaNhanVien VARCHAR(10) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        SoDienThoai VARCHAR(15) NULL,
        DiaChi NVARCHAR(250) NULL,
        DangHoatDong BIT NOT NULL DEFAULT 1,

        CONSTRAINT PK_NhanVien PRIMARY KEY (MaNhanVien)
    );
END;
GO

/* =========================================================
   5. BANG KHACH HANG
   LoaiKhach: KhachQuen / KhachVangLai
   ========================================================= */
IF OBJECT_ID(N'dbo.KhachHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.KhachHang
    (
        MaKH VARCHAR(10) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        SoDienThoai VARCHAR(15) NULL,
        DiaChi NVARCHAR(250) NULL,
        LoaiKhach VARCHAR(20) NOT NULL,

        CONSTRAINT PK_KhachHang PRIMARY KEY (MaKH),

        CONSTRAINT CK_KhachHang_Loai
            CHECK (LoaiKhach IN ('KhachQuen', 'KhachVangLai'))
    );
END;
GO

/* =========================================================
   6. BANG DON DAT HANG
   ========================================================= */
IF OBJECT_ID(N'dbo.DonDatHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DonDatHang
    (
        MaDDH VARCHAR(10) NOT NULL,
        MaNCC VARCHAR(10) NOT NULL,
        MaNhanVien VARCHAR(10) NOT NULL,
        NgayDat DATE NOT NULL,
        NgayDuKienNhan DATE NULL,
        TrangThai NVARCHAR(30) NOT NULL DEFAULT N'MoiLap',

        CONSTRAINT PK_DonDatHang PRIMARY KEY (MaDDH),

        CONSTRAINT FK_DDH_NCC
            FOREIGN KEY (MaNCC)
            REFERENCES dbo.NhaCungUng(MaNCC),

        CONSTRAINT FK_DDH_NhanVien
            FOREIGN KEY (MaNhanVien)
            REFERENCES dbo.NhanVien(MaNhanVien),

        CONSTRAINT CK_DDH_TrangThai
            CHECK (TrangThai IN
            (N'MoiLap', N'DangGiao', N'DaNhanDu', N'DaHuy'))
    );
END;
GO

/* =========================================================
   7. BANG CHI TIET DON DAT HANG
   ========================================================= */
IF OBJECT_ID(N'dbo.ChiTietDonDatHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChiTietDonDatHang
    (
        MaDDH VARCHAR(10) NOT NULL,
        MaNGK VARCHAR(10) NOT NULL,
        SoLuongDat INT NOT NULL,
        DonGiaDat DECIMAL(18,2) NOT NULL,

        CONSTRAINT PK_ChiTietDonDatHang
            PRIMARY KEY (MaDDH, MaNGK),

        CONSTRAINT FK_CTDDH_DDH
            FOREIGN KEY (MaDDH)
            REFERENCES dbo.DonDatHang(MaDDH),

        CONSTRAINT FK_CTDDH_NGK
            FOREIGN KEY (MaNGK)
            REFERENCES dbo.NuocGiaiKhat(MaNGK),

        CONSTRAINT CK_CTDDH_SoLuong
            CHECK (SoLuongDat > 0),

        CONSTRAINT CK_CTDDH_DonGia
            CHECK (DonGiaDat >= 0)
    );
END;
GO

/* =========================================================
   8. BANG PHIEU GIAO HANG TU NHA CUNG UNG
   Moi don dat hang toi da 3 dot giao.
   ========================================================= */
IF OBJECT_ID(N'dbo.PhieuGiaoHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PhieuGiaoHang
    (
        MaPhieuGiao VARCHAR(10) NOT NULL,
        MaDDH VARCHAR(10) NOT NULL,
        SoDotGiao TINYINT NOT NULL,
        NgayGiao DATE NOT NULL,
        TongTien DECIMAL(18,2) NOT NULL DEFAULT 0,

        CONSTRAINT PK_PhieuGiaoHang
            PRIMARY KEY (MaPhieuGiao),

        CONSTRAINT FK_PGH_DDH
            FOREIGN KEY (MaDDH)
            REFERENCES dbo.DonDatHang(MaDDH),

        CONSTRAINT UQ_PGH_DotGiao
            UNIQUE (MaDDH, SoDotGiao),

        CONSTRAINT CK_PGH_SoDot
            CHECK (SoDotGiao BETWEEN 1 AND 3),

        CONSTRAINT CK_PGH_TongTien
            CHECK (TongTien >= 0)
    );
END;
GO

/* =========================================================
   9. BANG CHI TIET PHIEU GIAO HANG
   ========================================================= */
IF OBJECT_ID(N'dbo.ChiTietPhieuGiao', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChiTietPhieuGiao
    (
        MaPhieuGiao VARCHAR(10) NOT NULL,
        MaNGK VARCHAR(10) NOT NULL,
        SoLuongGiao INT NOT NULL,
        DonGia DECIMAL(18,2) NOT NULL,

        CONSTRAINT PK_ChiTietPhieuGiao
            PRIMARY KEY (MaPhieuGiao, MaNGK),

        CONSTRAINT FK_CTPG_PGH
            FOREIGN KEY (MaPhieuGiao)
            REFERENCES dbo.PhieuGiaoHang(MaPhieuGiao),

        CONSTRAINT FK_CTPG_NGK
            FOREIGN KEY (MaNGK)
            REFERENCES dbo.NuocGiaiKhat(MaNGK),

        CONSTRAINT CK_CTPG_SoLuong
            CHECK (SoLuongGiao > 0),

        CONSTRAINT CK_CTPG_DonGia
            CHECK (DonGia >= 0)
    );
END;
GO

/* =========================================================
   10. BANG HOA DON
   ========================================================= */
IF OBJECT_ID(N'dbo.HoaDon', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HoaDon
    (
        MaHD VARCHAR(10) NOT NULL,
        MaKH VARCHAR(10) NOT NULL,
        MaNhanVien VARCHAR(10) NOT NULL,
        NgayLap DATETIME NOT NULL DEFAULT GETDATE(),
        TongTien DECIMAL(18,2) NOT NULL DEFAULT 0,
        TrangThaiThanhToan NVARCHAR(30) NOT NULL
            DEFAULT N'ChuaThanhToan',

        CONSTRAINT PK_HoaDon PRIMARY KEY (MaHD),

        CONSTRAINT FK_HD_KhachHang
            FOREIGN KEY (MaKH)
            REFERENCES dbo.KhachHang(MaKH),

        CONSTRAINT FK_HD_NhanVien
            FOREIGN KEY (MaNhanVien)
            REFERENCES dbo.NhanVien(MaNhanVien),

        CONSTRAINT CK_HD_TongTien
            CHECK (TongTien >= 0),

        CONSTRAINT CK_HD_ThanhToan
            CHECK (TrangThaiThanhToan IN
            (N'ChuaThanhToan', N'ThanhToanMotPhan',
             N'DaThanhToan'))
    );
END;
GO

/* =========================================================
   11. BANG CHI TIET HOA DON
   SoLuongGiaoNgay: so luong giao ngay tai cua hang.
   SoLuongHen: so luong con lai du kien giao sau.
   ========================================================= */
IF OBJECT_ID(N'dbo.ChiTietHoaDon', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChiTietHoaDon
    (
        MaHD VARCHAR(10) NOT NULL,
        MaNGK VARCHAR(10) NOT NULL,
        SoLuong INT NOT NULL,
        DonGia DECIMAL(18,2) NOT NULL,
        SoLuongGiaoNgay INT NOT NULL DEFAULT 0,
        SoLuongHen INT NOT NULL DEFAULT 0,

        CONSTRAINT PK_ChiTietHoaDon
            PRIMARY KEY (MaHD, MaNGK),

        CONSTRAINT FK_CTHD_HD
            FOREIGN KEY (MaHD)
            REFERENCES dbo.HoaDon(MaHD),

        CONSTRAINT FK_CTHD_NGK
            FOREIGN KEY (MaNGK)
            REFERENCES dbo.NuocGiaiKhat(MaNGK),

        CONSTRAINT CK_CTHD_SoLuong
            CHECK (SoLuong > 0),

        CONSTRAINT CK_CTHD_DonGia
            CHECK (DonGia >= 0),

        CONSTRAINT CK_CTHD_GiaoHen
            CHECK (
                SoLuongGiaoNgay >= 0
                AND SoLuongHen >= 0
                AND SoLuongGiaoNgay + SoLuongHen = SoLuong
            )
    );
END;
GO

/* =========================================================
   12. BANG PHIEU HEN GIAO HANG CHO KHACH
   Mot hoa don co the co nhieu phieu hen.
   ========================================================= */
IF OBJECT_ID(N'dbo.PhieuHenGiaoHang', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PhieuHenGiaoHang
    (
        MaPhieuHen VARCHAR(10) NOT NULL,
        MaHD VARCHAR(10) NOT NULL,
        NgayLap DATETIME NOT NULL DEFAULT GETDATE(),
        TrangThai NVARCHAR(30) NOT NULL DEFAULT N'ChoGiao',

        CONSTRAINT PK_PhieuHenGiaoHang
            PRIMARY KEY (MaPhieuHen),

        CONSTRAINT FK_PHG_HD
            FOREIGN KEY (MaHD)
            REFERENCES dbo.HoaDon(MaHD),

        CONSTRAINT CK_PHG_TrangThai
            CHECK (TrangThai IN
            (N'ChoGiao', N'DangGiao', N'DaGiaoDu', N'DaHuy'))
    );
END;
GO

/* =========================================================
   13. BANG CHI TIET PHIEU HEN
   SoLuongDaGiao dung de theo doi giao hang nhieu dot.
   ========================================================= */
IF OBJECT_ID(N'dbo.ChiTietPhieuHen', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChiTietPhieuHen
    (
        MaPhieuHen VARCHAR(10) NOT NULL,
        MaNGK VARCHAR(10) NOT NULL,
        NgayHen DATE NOT NULL,
        SoLuongHen INT NOT NULL,
        SoLuongDaGiao INT NOT NULL DEFAULT 0,

        CONSTRAINT PK_ChiTietPhieuHen
            PRIMARY KEY (MaPhieuHen, MaNGK, NgayHen),

        CONSTRAINT FK_CTPH_PHG
            FOREIGN KEY (MaPhieuHen)
            REFERENCES dbo.PhieuHenGiaoHang(MaPhieuHen),

        CONSTRAINT FK_CTPH_NGK
            FOREIGN KEY (MaNGK)
            REFERENCES dbo.NuocGiaiKhat(MaNGK),

        CONSTRAINT CK_CTPH_SoLuong
            CHECK (
                SoLuongHen > 0
                AND SoLuongDaGiao >= 0
                AND SoLuongDaGiao <= SoLuongHen
            )
    );
END;
GO

/* =========================================================
   14. BANG PHIEU GHI NO
   SoTienNo: tong tien ghi no ban dau.
   SoTienDaTra: tong tien khach da tra.
   SoTienConNo: cot tinh tu dong.
   ========================================================= */
IF OBJECT_ID(N'dbo.PhieuGhiNo', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PhieuGhiNo
    (
        MaPhieuNo VARCHAR(10) NOT NULL,
        MaKH VARCHAR(10) NOT NULL,
        MaHD VARCHAR(10) NOT NULL,
        MaNhanVien VARCHAR(10) NOT NULL,
        NgayLap DATETIME NOT NULL DEFAULT GETDATE(),
        SoTienNo DECIMAL(18,2) NOT NULL,
        SoTienDaTra DECIMAL(18,2) NOT NULL DEFAULT 0,
        SoTienConNo AS (SoTienNo - SoTienDaTra) PERSISTED,
        NgayDuKienTra DATE NOT NULL,
        LyDoNo NVARCHAR(250) NOT NULL,

        CONSTRAINT PK_PhieuGhiNo PRIMARY KEY (MaPhieuNo),

        CONSTRAINT FK_PGN_KH
            FOREIGN KEY (MaKH)
            REFERENCES dbo.KhachHang(MaKH),

        CONSTRAINT FK_PGN_HD
            FOREIGN KEY (MaHD)
            REFERENCES dbo.HoaDon(MaHD),

        CONSTRAINT FK_PGN_NV
            FOREIGN KEY (MaNhanVien)
            REFERENCES dbo.NhanVien(MaNhanVien),

        CONSTRAINT CK_PGN_SoTien
            CHECK (
                SoTienNo > 0
                AND SoTienDaTra >= 0
                AND SoTienDaTra <= SoTienNo
            )
    );
END;
GO

/* =========================================================
   PHAN 2. DU LIEU DANH MUC MAU
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhanHieu WHERE MaNhanHieu = 'NH001'
)
    INSERT INTO dbo.NhanHieu (MaNhanHieu, TenNhanHieu)
    VALUES ('NH001', N'Pepsi');

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhanHieu WHERE MaNhanHieu = 'NH002'
)
    INSERT INTO dbo.NhanHieu (MaNhanHieu, TenNhanHieu)
    VALUES ('NH002', N'Coca-Cola');

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhanHieu WHERE MaNhanHieu = 'NH003'
)
    INSERT INTO dbo.NhanHieu (MaNhanHieu, TenNhanHieu)
    VALUES ('NH003', N'Sting');

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhanHieu WHERE MaNhanHieu = 'NH004'
)
    INSERT INTO dbo.NhanHieu (MaNhanHieu, TenNhanHieu)
    VALUES ('NH004', N'Aquafina');
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhaCungUng WHERE MaNCC = 'NCC001'
)
    INSERT INTO dbo.NhaCungUng
        (MaNCC, TenNCC, DiaChi, SoDienThoai)
    VALUES
        ('NCC001', N'Công ty Phân phối Pepsi',
         N'Quận 1, TP. Hồ Chí Minh', '0901000001');

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhaCungUng WHERE MaNCC = 'NCC002'
)
    INSERT INTO dbo.NhaCungUng
        (MaNCC, TenNCC, DiaChi, SoDienThoai)
    VALUES
        ('NCC002', N'Công ty Phân phối Coca-Cola',
         N'Quận 3, TP. Hồ Chí Minh', '0901000002');

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhaCungUng WHERE MaNCC = 'NCC003'
)
    INSERT INTO dbo.NhaCungUng
        (MaNCC, TenNCC, DiaChi, SoDienThoai)
    VALUES
        ('NCC003', N'Công ty Nước giải khát tổng hợp',
         N'TP. Thủ Đức, TP. Hồ Chí Minh', '0901000003');
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhanVien WHERE MaNhanVien = 'NV001'
)
    INSERT INTO dbo.NhanVien
        (MaNhanVien, HoTen, SoDienThoai, DiaChi)
    VALUES
        ('NV001', N'Nguyễn Văn An', '0911000001',
         N'Quận Bình Thạnh, TP. Hồ Chí Minh');

IF NOT EXISTS (
    SELECT 1 FROM dbo.NhanVien WHERE MaNhanVien = 'NV002'
)
    INSERT INTO dbo.NhanVien
        (MaNhanVien, HoTen, SoDienThoai, DiaChi)
    VALUES
        ('NV002', N'Trần Thị Bình', '0911000002',
         N'Quận Gò Vấp, TP. Hồ Chí Minh');
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.KhachHang WHERE MaKH = 'KH001'
)
    INSERT INTO dbo.KhachHang
        (MaKH, HoTen, SoDienThoai, DiaChi, LoaiKhach)
    VALUES
        ('KH001', N'Lê Thị Lan', '0922000001',
         N'Quận 5, TP. Hồ Chí Minh', 'KhachQuen');

IF NOT EXISTS (
    SELECT 1 FROM dbo.KhachHang WHERE MaKH = 'KH002'
)
    INSERT INTO dbo.KhachHang
        (MaKH, HoTen, SoDienThoai, DiaChi, LoaiKhach)
    VALUES
        ('KH002', N'Phạm Minh Tuấn', '0922000002',
         N'Quận 10, TP. Hồ Chí Minh', 'KhachQuen');

IF NOT EXISTS (
    SELECT 1 FROM dbo.KhachHang WHERE MaKH = 'KH003'
)
    INSERT INTO dbo.KhachHang
        (MaKH, HoTen, SoDienThoai, DiaChi, LoaiKhach)
    VALUES
        ('KH003', N'Khách vãng lai', NULL,
         NULL, 'KhachVangLai');
GO

/* =========================================================
   DU LIEU SAN PHAM
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 FROM dbo.NuocGiaiKhat WHERE MaNGK = 'NGK001'
)
    INSERT INTO dbo.NuocGiaiKhat
        (MaNGK, TenNGK, DonViTinh, MaNhanHieu,
         MaNCC, DonGia, SoLuongTon)
    VALUES
        ('NGK001', N'Pepsi Cola', N'Lon',
         'NH001', 'NCC001', 10000, 82);

IF NOT EXISTS (
    SELECT 1 FROM dbo.NuocGiaiKhat WHERE MaNGK = 'NGK002'
)
    INSERT INTO dbo.NuocGiaiKhat
        (MaNGK, TenNGK, DonViTinh, MaNhanHieu,
         MaNCC, DonGia, SoLuongTon)
    VALUES
        ('NGK002', N'Coca-Cola', N'Lon',
         'NH002', 'NCC002', 10000, 45);

IF NOT EXISTS (
    SELECT 1 FROM dbo.NuocGiaiKhat WHERE MaNGK = 'NGK003'
)
    INSERT INTO dbo.NuocGiaiKhat
        (MaNGK, TenNGK, DonViTinh, MaNhanHieu,
         MaNCC, DonGia, SoLuongTon)
    VALUES
        ('NGK003', N'Sting dâu', N'Lon',
         'NH003', 'NCC003', 12000, 60);

IF NOT EXISTS (
    SELECT 1 FROM dbo.NuocGiaiKhat WHERE MaNGK = 'NGK004'
)
    INSERT INTO dbo.NuocGiaiKhat
        (MaNGK, TenNGK, DonViTinh, MaNhanHieu,
         MaNCC, DonGia, SoLuongTon)
    VALUES
        ('NGK004', N'Aquafina 500ml', N'Chai',
         'NH004', 'NCC003', 8000, 100);
GO

/* =========================================================
   DU LIEU DON DAT HANG VA PHIEU GIAO
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 FROM dbo.DonDatHang WHERE MaDDH = 'DDH001'
)
    INSERT INTO dbo.DonDatHang
        (MaDDH, MaNCC, MaNhanVien, NgayDat,
         NgayDuKienNhan, TrangThai)
    VALUES
        ('DDH001', 'NCC001', 'NV001',
         '2026-10-20', '2026-10-25', N'DangGiao');

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietDonDatHang
    WHERE MaDDH = 'DDH001' AND MaNGK = 'NGK001'
)
    INSERT INTO dbo.ChiTietDonDatHang
        (MaDDH, MaNGK, SoLuongDat, DonGiaDat)
    VALUES ('DDH001', 'NGK001', 100, 8000);

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietDonDatHang
    WHERE MaDDH = 'DDH001' AND MaNGK = 'NGK002'
)
    INSERT INTO dbo.ChiTietDonDatHang
        (MaDDH, MaNGK, SoLuongDat, DonGiaDat)
    VALUES ('DDH001', 'NGK002', 50, 8000);

IF NOT EXISTS (
    SELECT 1 FROM dbo.PhieuGiaoHang WHERE MaPhieuGiao = 'PGH001'
)
    INSERT INTO dbo.PhieuGiaoHang
        (MaPhieuGiao, MaDDH, SoDotGiao, NgayGiao, TongTien)
    VALUES ('PGH001', 'DDH001', 1, '2026-10-22', 720000);

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietPhieuGiao
    WHERE MaPhieuGiao = 'PGH001' AND MaNGK = 'NGK001'
)
    INSERT INTO dbo.ChiTietPhieuGiao
        (MaPhieuGiao, MaNGK, SoLuongGiao, DonGia)
    VALUES ('PGH001', 'NGK001', 60, 8000);

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietPhieuGiao
    WHERE MaPhieuGiao = 'PGH001' AND MaNGK = 'NGK002'
)
    INSERT INTO dbo.ChiTietPhieuGiao
        (MaPhieuGiao, MaNGK, SoLuongGiao, DonGia)
    VALUES ('PGH001', 'NGK002', 30, 8000);
GO

/* =========================================================
   DU LIEU HOA DON BAN HANG
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 FROM dbo.HoaDon WHERE MaHD = 'HD001'
)
    INSERT INTO dbo.HoaDon
        (MaHD, MaKH, MaNhanVien, NgayLap,
         TongTien, TrangThaiThanhToan)
    VALUES
        ('HD001', 'KH001', 'NV001',
         '2026-10-26 09:00:00', 150000,
         N'DaThanhToan');

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietHoaDon
    WHERE MaHD = 'HD001' AND MaNGK = 'NGK001'
)
    INSERT INTO dbo.ChiTietHoaDon
        (MaHD, MaNGK, SoLuong, DonGia,
         SoLuongGiaoNgay, SoLuongHen)
    VALUES ('HD001', 'NGK001', 10, 10000, 8, 2);

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietHoaDon
    WHERE MaHD = 'HD001' AND MaNGK = 'NGK002'
)
    INSERT INTO dbo.ChiTietHoaDon
        (MaHD, MaNGK, SoLuong, DonGia,
         SoLuongGiaoNgay, SoLuongHen)
    VALUES ('HD001', 'NGK002', 5, 10000, 5, 0);

/* Phieu hen giao 2 lon Pepsi con thieu */
IF NOT EXISTS (
    SELECT 1 FROM dbo.PhieuHenGiaoHang
    WHERE MaPhieuHen = 'PHG001'
)
    INSERT INTO dbo.PhieuHenGiaoHang
        (MaPhieuHen, MaHD, NgayLap, TrangThai)
    VALUES
        ('PHG001', 'HD001', '2026-10-26 09:05:00',
         N'ChoGiao');

IF NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietPhieuHen
    WHERE MaPhieuHen = 'PHG001'
      AND MaNGK = 'NGK001'
      AND NgayHen = '2026-10-29'
)
    INSERT INTO dbo.ChiTietPhieuHen
        (MaPhieuHen, MaNGK, NgayHen,
         SoLuongHen, SoLuongDaGiao)
    VALUES ('PHG001', 'NGK001', '2026-10-29', 2, 0);
GO

/* =========================================================
   DU LIEU PHIEU GHI NO
   ========================================================= */

IF NOT EXISTS (
    SELECT 1 FROM dbo.HoaDon WHERE MaHD = 'HD002'
)
    INSERT INTO dbo.HoaDon
        (MaHD, MaKH, MaNhanVien, NgayLap,
         TongTien, TrangThaiThanhToan)
    VALUES
        ('HD002', 'KH002', 'NV002',
         '2026-10-27 10:00:00', 500000,
         N'ThanhToanMotPhan');

IF NOT EXISTS (
    SELECT 1 FROM dbo.PhieuGhiNo
    WHERE MaPhieuNo = 'PN001'
)
    INSERT INTO dbo.PhieuGhiNo
        (MaPhieuNo, MaKH, MaHD, MaNhanVien,
         NgayLap, SoTienNo, SoTienDaTra,
         NgayDuKienTra, LyDoNo)
    VALUES
        ('PN001', 'KH002', 'HD002', 'NV002',
         '2026-10-27 10:05:00', 500000, 200000,
         '2026-11-05', N'Khách quen xin thanh toán phần còn lại sau');
GO

/* =========================================================
   PHAN 3. KIEM TRA DU LIEU SAU KHI CHAY
   ========================================================= */

SELECT * FROM dbo.NhanHieu;
SELECT * FROM dbo.NhaCungUng;
SELECT * FROM dbo.NuocGiaiKhat;
SELECT * FROM dbo.NhanVien;
SELECT * FROM dbo.KhachHang;

SELECT * FROM dbo.DonDatHang;
SELECT * FROM dbo.ChiTietDonDatHang;
SELECT * FROM dbo.PhieuGiaoHang;
SELECT * FROM dbo.ChiTietPhieuGiao;

SELECT * FROM dbo.HoaDon;
SELECT * FROM dbo.ChiTietHoaDon;
SELECT * FROM dbo.PhieuHenGiaoHang;
SELECT * FROM dbo.ChiTietPhieuHen;
SELECT * FROM dbo.PhieuGhiNo;
GO

PRINT N'Hoan tat tao CSDL va nap du lieu mau.';
GO
