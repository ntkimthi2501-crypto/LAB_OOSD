IF DB_ID(N'QuanLyKhachSan') IS NULL
    CREATE DATABASE QuanLyKhachSan;
GO

USE QuanLyKhachSan;
GO

-- XÓA CÁC BẢNG CŨ THEO THỨ TỰ KHÓA NGOẠI
IF OBJECT_ID('ThanhToan','U') IS NOT NULL
    DROP TABLE ThanhToan;

IF OBJECT_ID('HoaDon','U') IS NOT NULL
    DROP TABLE HoaDon;

IF OBJECT_ID('ChiTietPhieuDenBu','U') IS NOT NULL
    DROP TABLE ChiTietPhieuDenBu;

IF OBJECT_ID('PhieuDenBu','U') IS NOT NULL
    DROP TABLE PhieuDenBu;

IF OBJECT_ID('QuyDinhDenBu','U') IS NOT NULL
    DROP TABLE QuyDinhDenBu;

IF OBJECT_ID('ChiTietPhieuSuDungDV','U') IS NOT NULL
    DROP TABLE ChiTietPhieuSuDungDV;

IF OBJECT_ID('PhieuSuDungDV','U') IS NOT NULL
    DROP TABLE PhieuSuDungDV;

IF OBJECT_ID('DichVu','U') IS NOT NULL
    DROP TABLE DichVu;

IF OBJECT_ID('NguoiLuuTru','U') IS NOT NULL
    DROP TABLE NguoiLuuTru;

IF OBJECT_ID('ChiTietDatPhong','U') IS NOT NULL
    DROP TABLE ChiTietDatPhong;

IF OBJECT_ID('PhieuDatPhong','U') IS NOT NULL
    DROP TABLE PhieuDatPhong;

IF OBJECT_ID('KhachHang','U') IS NOT NULL
    DROP TABLE KhachHang;

IF OBJECT_ID('PhieuLapDat','U') IS NOT NULL
    DROP TABLE PhieuLapDat;

IF OBJECT_ID('TienNghi','U') IS NOT NULL
    DROP TABLE TienNghi;

IF OBJECT_ID('LoaiTienNghi','U') IS NOT NULL
    DROP TABLE LoaiTienNghi;

IF OBJECT_ID('Phong','U') IS NOT NULL
    DROP TABLE Phong;

IF OBJECT_ID('KhuVuc','U') IS NOT NULL
    DROP TABLE KhuVuc;

IF OBJECT_ID('NhanVien','U') IS NOT NULL
    DROP TABLE NhanVien;
GO


-- 1. NHÂN VIÊN
CREATE TABLE NhanVien
(
    MaNV varchar(20) NOT NULL PRIMARY KEY,
    HoTen nvarchar(120) NOT NULL,
    VaiTro nvarchar(50) NOT NULL,
    SoDienThoai varchar(20) NULL
);

-- 2. KHU VỰC
CREATE TABLE KhuVuc
(
    MaKhuVuc varchar(20) NOT NULL PRIMARY KEY,
    TenKhuVuc nvarchar(100) NOT NULL UNIQUE
);

-- 3. PHÒNG
CREATE TABLE Phong
(
    SoPhong varchar(20) NOT NULL PRIMARY KEY,
    MaKhuVuc varchar(20) NOT NULL,
    SoNguoiToiDa int NOT NULL CHECK(SoNguoiToiDa > 0),
    DonGiaNgay decimal(18,2) NOT NULL CHECK(DonGiaNgay >= 0),
    TrangThai nvarchar(30) NOT NULL DEFAULT N'Trống',

    CONSTRAINT CK_Phong_TrangThai
        CHECK(TrangThai IN
        (
            N'Trống',
            N'Đã đặt',
            N'Đang ở',
            N'Bảo trì'
        )),

    CONSTRAINT FK_Phong_KhuVuc
        FOREIGN KEY(MaKhuVuc)
        REFERENCES KhuVuc(MaKhuVuc)
);

-- 4. LOẠI TIỆN NGHI
CREATE TABLE LoaiTienNghi
(
    MaLoaiTN varchar(20) NOT NULL PRIMARY KEY,
    TenLoaiTN nvarchar(100) NOT NULL UNIQUE
);

-- 5. TIỆN NGHI
CREATE TABLE TienNghi
(
    MaTienNghi varchar(30) NOT NULL PRIMARY KEY,
    MaLoaiTN varchar(20) NOT NULL,
    SoThuTu int NOT NULL,
    TinhTrangHienTai nvarchar(100) NULL,

    CONSTRAINT UQ_TienNghi_Loai_STT
        UNIQUE(MaLoaiTN, SoThuTu),

    CONSTRAINT FK_TienNghi_Loai
        FOREIGN KEY(MaLoaiTN)
        REFERENCES LoaiTienNghi(MaLoaiTN)
);

-- 6. PHIẾU LẮP ĐẶT
CREATE TABLE PhieuLapDat
(
    SoPhieuLapDat varchar(30) NOT NULL PRIMARY KEY,
    MaTienNghi varchar(30) NOT NULL,
    SoPhong varchar(20) NOT NULL,
    NgayLap date NOT NULL,
    TinhTrang nvarchar(100) NOT NULL,
    MaNV varchar(20) NOT NULL,
    GhiChu nvarchar(250) NULL,

    CONSTRAINT UQ_PhieuLapDat_ThietBi_Ngay
        UNIQUE(MaTienNghi, NgayLap),

    CONSTRAINT FK_PhieuLapDat_TienNghi
        FOREIGN KEY(MaTienNghi)
        REFERENCES TienNghi(MaTienNghi),

    CONSTRAINT FK_PhieuLapDat_Phong
        FOREIGN KEY(SoPhong)
        REFERENCES Phong(SoPhong),

    CONSTRAINT FK_PhieuLapDat_NV
        FOREIGN KEY(MaNV)
        REFERENCES NhanVien(MaNV)
);

-- 7. KHÁCH HÀNG
CREATE TABLE KhachHang
(
    MaKhach varchar(20) NOT NULL PRIMARY KEY,
    HoTen nvarchar(120) NOT NULL,
    SoCMND varchar(30) NOT NULL UNIQUE,
    QuocTich nvarchar(80) NOT NULL,
    SoDienThoai varchar(20) NULL
);

-- 8. PHIẾU ĐẶT PHÒNG
CREATE TABLE PhieuDatPhong
(
    SoPhieuDat varchar(30) NOT NULL PRIMARY KEY,
    MaKhach varchar(20) NOT NULL,
    MaNVLeTan varchar(20) NOT NULL,
    NgayLap datetime NOT NULL,
    NgayNhan date NOT NULL,
    NgayTraDuKien date NOT NULL,
    TienCoc decimal(18,2) NOT NULL DEFAULT 0 CHECK(TienCoc >= 0),
    KenhDat nvarchar(20) NOT NULL,
    TrangThai nvarchar(30) NOT NULL DEFAULT N'Đã đặt',
    NgayNhanThucTe datetime NULL,
    NgayTraThucTe datetime NULL,

    CONSTRAINT CK_PhieuDat_Ngay
        CHECK(NgayTraDuKien >= NgayNhan),

    CONSTRAINT CK_PhieuDat_Kenh
        CHECK(KenhDat IN
        (
            N'Điện thoại',
            N'Website',
            N'Trực tiếp'
        )),

    CONSTRAINT CK_PhieuDat_TrangThai
        CHECK(TrangThai IN
        (
            N'Đã đặt',
            N'Đang ở',
            N'Đã trả',
            N'No-show',
            N'Hủy'
        )),

    CONSTRAINT FK_PhieuDat_Khach
        FOREIGN KEY(MaKhach)
        REFERENCES KhachHang(MaKhach),

    CONSTRAINT FK_PhieuDat_NV
        FOREIGN KEY(MaNVLeTan)
        REFERENCES NhanVien(MaNV)
);

-- 9. CHI TIẾT ĐẶT PHÒNG
CREATE TABLE ChiTietDatPhong
(
    SoPhieuDat varchar(30) NOT NULL,
    SoPhong varchar(20) NOT NULL,
    SoNguoi int NOT NULL CHECK(SoNguoi > 0),

    PRIMARY KEY(SoPhieuDat, SoPhong),

    CONSTRAINT FK_CTDat_Phieu
        FOREIGN KEY(SoPhieuDat)
        REFERENCES PhieuDatPhong(SoPhieuDat),

    CONSTRAINT FK_CTDat_Phong
        FOREIGN KEY(SoPhong)
        REFERENCES Phong(SoPhong)
);

-- 10. NGƯỜI LƯU TRÚ
CREATE TABLE NguoiLuuTru
(
    MaNguoiLT int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SoPhieuDat varchar(30) NOT NULL,
    SoPhong varchar(20) NOT NULL,
    HoTen nvarchar(120) NOT NULL,
    SoCMND varchar(30) NOT NULL,
    QuocTich nvarchar(80) NOT NULL,

    CONSTRAINT FK_NguoiLT_CTDat
        FOREIGN KEY(SoPhieuDat, SoPhong)
        REFERENCES ChiTietDatPhong(SoPhieuDat, SoPhong)
);

-- 11. DỊCH VỤ
CREATE TABLE DichVu
(
    MaDV varchar(20) NOT NULL PRIMARY KEY,
    TenDV nvarchar(120) NOT NULL,
    DonViTinh nvarchar(40) NOT NULL,
    DonGia decimal(18,2) NOT NULL CHECK(DonGia >= 0)
);

-- 12. PHIẾU SỬ DỤNG DỊCH VỤ
CREATE TABLE PhieuSuDungDV
(
    SoPhieuSDDV varchar(30) NOT NULL PRIMARY KEY,
    SoPhieuDat varchar(30) NOT NULL,
    SoPhong varchar(20) NOT NULL,
    NgaySuDung date NOT NULL,
    MaNV varchar(20) NOT NULL,

    CONSTRAINT UQ_PhieuSDDV_PhongNgay
        UNIQUE(SoPhieuDat, SoPhong, NgaySuDung),

    CONSTRAINT FK_PhieuSDDV_CTDat
        FOREIGN KEY(SoPhieuDat, SoPhong)
        REFERENCES ChiTietDatPhong(SoPhieuDat, SoPhong),

    CONSTRAINT FK_PhieuSDDV_NV
        FOREIGN KEY(MaNV)
        REFERENCES NhanVien(MaNV)
);

-- 13. CHI TIẾT PHIẾU SỬ DỤNG DỊCH VỤ
CREATE TABLE ChiTietPhieuSuDungDV
(
    SoPhieuSDDV varchar(30) NOT NULL,
    MaDV varchar(20) NOT NULL,
    SoLuong int NOT NULL CHECK(SoLuong > 0),
    DonGia decimal(18,2) NOT NULL CHECK(DonGia >= 0),

    ThanhTien AS
    (
        CONVERT(decimal(18,2), SoLuong * DonGia)
    ) PERSISTED,

    PRIMARY KEY(SoPhieuSDDV, MaDV),

    CONSTRAINT FK_CTSDDV_Phieu
        FOREIGN KEY(SoPhieuSDDV)
        REFERENCES PhieuSuDungDV(SoPhieuSDDV),

    CONSTRAINT FK_CTSDDV_DV
        FOREIGN KEY(MaDV)
        REFERENCES DichVu(MaDV)
);

-- 14. QUY ĐỊNH ĐỀN BÙ
CREATE TABLE QuyDinhDenBu
(
    MaQuyDinh varchar(30) NOT NULL PRIMARY KEY,
    MaLoaiTN varchar(20) NOT NULL,
    MucDoThietHai nvarchar(80) NOT NULL,
    MucDenBu decimal(18,2) NOT NULL CHECK(MucDenBu >= 0),

    CONSTRAINT UQ_QDDB_Loai_MucDo
        UNIQUE(MaLoaiTN, MucDoThietHai),

    CONSTRAINT FK_QDDB_Loai
        FOREIGN KEY(MaLoaiTN)
        REFERENCES LoaiTienNghi(MaLoaiTN)
);

-- 15. PHIẾU ĐỀN BÙ
CREATE TABLE PhieuDenBu
(
    SoPhieuDenBu varchar(30) NOT NULL PRIMARY KEY,
    SoPhieuDat varchar(30) NOT NULL,
    SoPhong varchar(20) NOT NULL,
    NgayLap datetime NOT NULL,
    MaNV varchar(20) NOT NULL,
    TongTien decimal(18,2) NOT NULL DEFAULT 0 CHECK(TongTien >= 0),

    CONSTRAINT FK_PhieuDB_CTDat
        FOREIGN KEY(SoPhieuDat, SoPhong)
        REFERENCES ChiTietDatPhong(SoPhieuDat, SoPhong),

    CONSTRAINT FK_PhieuDB_NV
        FOREIGN KEY(MaNV)
        REFERENCES NhanVien(MaNV)
);

-- 16. CHI TIẾT PHIẾU ĐỀN BÙ
CREATE TABLE ChiTietPhieuDenBu
(
    SoPhieuDenBu varchar(30) NOT NULL,
    MaTienNghi varchar(30) NOT NULL,
    MucDoThietHai nvarchar(80) NOT NULL,
    SoTien decimal(18,2) NOT NULL CHECK(SoTien >= 0),

    PRIMARY KEY(SoPhieuDenBu, MaTienNghi),

    CONSTRAINT FK_CTDB_Phieu
        FOREIGN KEY(SoPhieuDenBu)
        REFERENCES PhieuDenBu(SoPhieuDenBu),

    CONSTRAINT FK_CTDB_TienNghi
        FOREIGN KEY(MaTienNghi)
        REFERENCES TienNghi(MaTienNghi)
);

-- 17. HÓA ĐƠN
CREATE TABLE HoaDon
(
    SoHoaDon varchar(30) NOT NULL PRIMARY KEY,
    SoPhieuDat varchar(30) NOT NULL UNIQUE,
    NgayLap datetime NOT NULL,
    MaNV varchar(20) NOT NULL,
    SoNgayTinhTien int NOT NULL CHECK(SoNgayTinhTien > 0),
    TienPhong decimal(18,2) NOT NULL CHECK(TienPhong >= 0),
    TienDichVu decimal(18,2) NOT NULL CHECK(TienDichVu >= 0),

    TongTien AS
    (
        CONVERT(decimal(18,2), TienPhong + TienDichVu)
    ) PERSISTED,

    TrangThai nvarchar(30) NOT NULL DEFAULT N'Chưa thanh toán',

    CONSTRAINT CK_HoaDon_TrangThai
        CHECK(TrangThai IN
        (
            N'Chưa thanh toán',
            N'Đã thanh toán'
        )),

    CONSTRAINT FK_HoaDon_PhieuDat
        FOREIGN KEY(SoPhieuDat)
        REFERENCES PhieuDatPhong(SoPhieuDat),

    CONSTRAINT FK_HoaDon_NV
        FOREIGN KEY(MaNV)
        REFERENCES NhanVien(MaNV)
);

-- 18. THANH TOÁN
CREATE TABLE ThanhToan
(
    MaThanhToan varchar(30) NOT NULL PRIMARY KEY,
    SoHoaDon varchar(30) NOT NULL,
    NgayThanhToan datetime NOT NULL,
    HinhThuc nvarchar(30) NOT NULL,
    SoTien decimal(18,2) NOT NULL CHECK(SoTien > 0),

    CONSTRAINT CK_ThanhToan_HinhThuc
        CHECK(HinhThuc IN
        (
            N'Tiền mặt',
            N'Chuyển khoản',
            N'Thẻ',
            N'Ví điện tử'
        )),

    CONSTRAINT FK_ThanhToan_HoaDon
        FOREIGN KEY(SoHoaDon)
        REFERENCES HoaDon(SoHoaDon)
);
GO

-- INDEX
CREATE INDEX IX_PhieuDatPhong_Ngay
ON PhieuDatPhong(NgayNhan, NgayTraDuKien, TrangThai);

CREATE INDEX IX_CTDat_Phong
ON ChiTietDatPhong(SoPhong, SoPhieuDat);

CREATE INDEX IX_PhieuSDDV_DatPhong
ON PhieuSuDungDV(SoPhieuDat, SoPhong, NgaySuDung);
GO

USE QuanLyKhachSan;
GO

-- NHÂN VIÊN
INSERT INTO NhanVien
(
    MaNV,
    HoTen,
    VaiTro,
    SoDienThoai
)
VALUES
('NV01', N'Nguyễn Thu Hà', N'Lễ tân', '0901000001'),
('NV02', N'Trần Minh An', N'Phục vụ phòng', '0901000002'),
('NV03', N'Lê Hoàng Nam', N'Thanh toán', '0901000003');


-- KHU VỰC
INSERT INTO KhuVuc
(
    MaKhuVuc,
    TenKhuVuc
)
VALUES
('A', N'Khu A'),
('B', N'Khu B');


-- PHÒNG
INSERT INTO Phong
(
    SoPhong,
    MaKhuVuc,
    SoNguoiToiDa,
    DonGiaNgay,
    TrangThai
)
VALUES
('A101', 'A', 2, 600000, N'Trống'),
('A102', 'A', 3, 800000, N'Trống'),
('B201', 'B', 4, 1200000, N'Trống');


-- LOẠI TIỆN NGHI
INSERT INTO LoaiTienNghi
(
    MaLoaiTN,
    TenLoaiTN
)
VALUES
('TV', N'Ti vi'),
('TL', N'Tủ lạnh'),
('DT', N'Điện thoại');


-- TIỆN NGHI
INSERT INTO TienNghi
(
    MaTienNghi,
    MaLoaiTN,
    SoThuTu,
    TinhTrangHienTai
)
VALUES
('TV01', 'TV', 1, N'Tốt'),
('TV02', 'TV', 2, N'Tốt'),
('TL01', 'TL', 1, N'Tốt');


-- DỊCH VỤ
INSERT INTO DichVu
(
    MaDV,
    TenDV,
    DonViTinh,
    DonGia
)
VALUES
('DV01', N'Ăn sáng', N'Suất', 120000),
('DV02', N'Tắm hơi', N'Lượt', 250000),
('DV03', N'Karaoke', N'Giờ', 300000);


-- QUY ĐỊNH ĐỀN BÙ
INSERT INTO QuyDinhDenBu
(
    MaQuyDinh,
    MaLoaiTN,
    MucDoThietHai,
    MucDenBu
)
VALUES
('QD01', 'TV', N'Hư hỏng nhẹ', 500000),
('QD02', 'TV', N'Mất', 5000000),
('QD03', 'TL', N'Hư hỏng nhẹ', 400000),
('QD04', 'TL', N'Mất', 4000000);
GO


USE QuanLyKhachSan;
GO

INSERT INTO DichVu(MaDV, TenDV, DonViTinh, DonGia)
VALUES
('DV01', N'Ăn sáng', N'Suất', 120000),
('DV02', N'Tắm hơi', N'Lượt', 250000),
('DV03', N'Karaoke', N'Giờ', 300000);
GO

SELECT * FROM DichVu;

SELECT * FROM PhieuDatPhong;
SELECT * FROM ChiTietDatPhong;

-- ============================================
-- 1. THÊM KHÁCH HÀNG
-- ============================================
INSERT INTO KhachHang
(
    MaKhach,
    HoTen,
    SoCMND,
    QuocTich,
    SoDienThoai
)
VALUES
(
    'KH01',
    N'Nguyễn Văn An',
    '079123456789',
    N'Việt Nam',
    '0901234567'
),
(
    'KH02',
    N'Trần Thị Bình',
    '079987654321',
    N'Việt Nam',
    '0912345678'
);
GO


-- ============================================
-- 2. THÊM PHIẾU ĐẶT PHÒNG
-- ============================================
INSERT INTO PhieuDatPhong
(
    SoPhieuDat,
    MaKhach,
    MaNVLeTan,
    NgayLap,
    NgayNhan,
    NgayTraDuKien,
    TienCoc,
    KenhDat,
    TrangThai
)
VALUES
(
    'PD01',
    'KH01',
    'NV01',
    '2026-09-20',
    '2026-09-20',
    '2026-09-22',
    300000,
    N'Trực tiếp',
    N'Đang ở'
),
(
    'PD02',
    'KH02',
    'NV01',
    '2026-09-21',
    '2026-09-21',
    '2026-09-23',
    500000,
    N'Website',
    N'Đã đặt'
);
GO


-- ============================================
-- 3. GÁN PHÒNG CHO PHIẾU ĐẶT
-- ============================================
INSERT INTO ChiTietDatPhong
(
    SoPhieuDat,
    SoPhong,
    SoNguoi
)
VALUES
(
    'PD01',
    'A101',
    2
),
(
    'PD02',
    'A102',
    2
);
GO


-- ============================================
-- 4. CẬP NHẬT TRẠNG THÁI PHÒNG
-- ============================================
UPDATE Phong
SET TrangThai = N'Đang ở'
WHERE SoPhong = 'A101';

UPDATE Phong
SET TrangThai = N'Đã đặt'
WHERE SoPhong = 'A102';
GO


-- ============================================
-- 5. KIỂM TRA DỮ LIỆU
-- ============================================
SELECT
    pd.SoPhieuDat,
    kh.HoTen,
    ct.SoPhong,
    pd.NgayNhan,
    pd.NgayTraDuKien,
    pd.TienCoc,
    pd.KenhDat,
    pd.TrangThai
FROM PhieuDatPhong pd
INNER JOIN KhachHang kh
    ON pd.MaKhach = kh.MaKhach
INNER JOIN ChiTietDatPhong ct
    ON pd.SoPhieuDat = ct.SoPhieuDat;
GO