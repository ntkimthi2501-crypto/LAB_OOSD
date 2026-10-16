CREATE DATABASE QuanLyBenhAn;
GO
USE QuanLyBenhAn;
GO

/* ===== DANH MỤC ===== */
CREATE TABLE NhanVienCSKH (
    maNV   INT IDENTITY(1,1) CONSTRAINT PK_NhanVienCSKH PRIMARY KEY,
    hoTen  NVARCHAR(100) NOT NULL
);

CREATE TABLE Khoa (
    maKhoa  INT IDENTITY(1,1) CONSTRAINT PK_Khoa PRIMARY KEY,
    tenKhoa NVARCHAR(100) NOT NULL CONSTRAINT UQ_Khoa_ten UNIQUE
);

CREATE TABLE BacSi (
    maBS      INT IDENTITY(1,1) CONSTRAINT PK_BacSi PRIMARY KEY,
    hoTen     NVARCHAR(100) NOT NULL,
    chuyenMon NVARCHAR(100) NULL,
    maKhoa    INT NOT NULL CONSTRAINT FK_BacSi_Khoa REFERENCES Khoa(maKhoa)
);

CREATE TABLE XetNghiem (
    maXN   INT IDENTITY(1,1) CONSTRAINT PK_XetNghiem PRIMARY KEY,
    tenXN  NVARCHAR(150) NOT NULL CONSTRAINT UQ_XetNghiem_ten UNIQUE,
    donGia DECIMAL(18,0) NOT NULL CONSTRAINT CK_XetNghiem_gia CHECK (donGia >= 0)
);

CREATE TABLE Thuoc (
    maThuoc   INT IDENTITY(1,1) CONSTRAINT PK_Thuoc PRIMARY KEY,
    tenThuoc  NVARCHAR(150) NOT NULL CONSTRAINT UQ_Thuoc_ten UNIQUE,
    donViTinh NVARCHAR(30)  NOT NULL,
    donGia    DECIMAL(18,0) NOT NULL CONSTRAINT CK_Thuoc_gia CHECK (donGia >= 0)
);

/* ===== BỆNH NHÂN - ĐĂNG KÝ - LỆ PHÍ - HỒ SƠ ===== */
CREATE TABLE BenhNhan (
    maBN      INT IDENTITY(1,1) CONSTRAINT PK_BenhNhan PRIMARY KEY,
    hoTen     NVARCHAR(100) NOT NULL,
    diaChi    NVARCHAR(200) NOT NULL,
    ngaySinh  DATE NOT NULL CONSTRAINT CK_BN_ngaySinh CHECK (ngaySinh <= CAST(GETDATE() AS DATE)),
    dienThoai VARCHAR(15) NOT NULL CONSTRAINT CK_BN_dt CHECK (dienThoai NOT LIKE '%[^0-9]%'),
    anh3x4    VARBINARY(MAX) NULL
);
CREATE INDEX IX_BenhNhan_hoTen ON BenhNhan(hoTen);
CREATE INDEX IX_BenhNhan_dienThoai ON BenhNhan(dienThoai);

CREATE TABLE PhieuDangKy (
    maPhieuDK  INT IDENTITY(1,1) CONSTRAINT PK_PhieuDangKy PRIMARY KEY,
    maBN       INT NOT NULL CONSTRAINT UQ_PhieuDK_BN UNIQUE          -- mỗi BN chỉ đăng ký lần đầu 1 lần
               CONSTRAINT FK_PhieuDK_BN REFERENCES BenhNhan(maBN),
    ngayDangKy DATE NOT NULL CONSTRAINT DF_PhieuDK_ngay DEFAULT CAST(GETDATE() AS DATE),
    maNV       INT NOT NULL CONSTRAINT FK_PhieuDK_NV REFERENCES NhanVienCSKH(maNV)
);

CREATE TABLE LePhiNam (
    maLePhi INT IDENTITY(1,1) CONSTRAINT PK_LePhiNam PRIMARY KEY,
    maBN    INT NOT NULL CONSTRAINT FK_LePhi_BN REFERENCES BenhNhan(maBN),
    nam     INT NOT NULL CONSTRAINT CK_LePhi_nam CHECK (nam BETWEEN 2000 AND 2100),
    soTien  DECIMAL(18,0) NOT NULL CONSTRAINT CK_LePhi_tien CHECK (soTien > 0),
    ngayDong DATE NOT NULL CONSTRAINT DF_LePhi_ngay DEFAULT CAST(GETDATE() AS DATE),
    maNV    INT NOT NULL CONSTRAINT FK_LePhi_NV REFERENCES NhanVienCSKH(maNV),
    CONSTRAINT UQ_LePhi_BN_Nam UNIQUE (maBN, nam)                    -- mỗi năm đóng 1 lần
);

CREATE TABLE HoSoBenhAn (
    maHoSo    INT IDENTITY(1,1) CONSTRAINT PK_HoSoBenhAn PRIMARY KEY,
    soHoSo    AS ('HS' + RIGHT('000000' + CAST(maHoSo AS VARCHAR(10)), 6)) PERSISTED, -- mã in trên trang bìa
    maBN      INT NOT NULL CONSTRAINT UQ_HoSo_BN UNIQUE               -- 1 BN = 1 hồ sơ
              CONSTRAINT FK_HoSo_BN REFERENCES BenhNhan(maBN),
    ngayCap   DATE NOT NULL CONSTRAINT DF_HoSo_ngay DEFAULT CAST(GETDATE() AS DATE),
    trangThai VARCHAR(20) NOT NULL CONSTRAINT DF_HoSo_tt DEFAULT 'HoatDong'
              CONSTRAINT CK_HoSo_tt CHECK (trangThai IN ('HoatDong','Khoa')),
    maNV      INT NOT NULL CONSTRAINT FK_HoSo_NV REFERENCES NhanVienCSKH(maNV),
    CONSTRAINT UQ_HoSo_soHoSo UNIQUE (soHoSo)
);

/* ===== LỊCH ĐỊNH KỲ - PHIẾU KHÁM ===== */
CREATE TABLE LichKhamDinhKy (
    maLich     INT IDENTITY(1,1) CONSTRAINT PK_LichKham PRIMARY KEY,
    maHoSo     INT NOT NULL CONSTRAINT FK_Lich_HoSo REFERENCES HoSoBenhAn(maHoSo),
    quy        TINYINT NOT NULL CONSTRAINT CK_Lich_quy CHECK (quy BETWEEN 1 AND 4),
    nam        INT NOT NULL,
    ngayGioHen DATETIME2(0) NOT NULL,
    trangThai  VARCHAR(20) NOT NULL CONSTRAINT DF_Lich_tt DEFAULT 'DaHen'
               CONSTRAINT CK_Lich_tt CHECK (trangThai IN ('DaHen','DaKham','Huy')),
    maNV       INT NOT NULL CONSTRAINT FK_Lich_NV REFERENCES NhanVienCSKH(maNV),
    CONSTRAINT CK_Lich_dungQuy CHECK (DATEPART(QUARTER, ngayGioHen) = quy AND YEAR(ngayGioHen) = nam)
);
-- mỗi hồ sơ chỉ có 1 lịch còn hiệu lực trong 1 quý (lịch đã hủy thì được đặt lại)
CREATE UNIQUE INDEX UX_Lich_HoSo_Nam_Quy ON LichKhamDinhKy(maHoSo, nam, quy) WHERE trangThai <> 'Huy';

CREATE TABLE PhieuKham (
    maPhieuKham INT IDENTITY(1,1) CONSTRAINT PK_PhieuKham PRIMARY KEY,
    maHoSo      INT NOT NULL CONSTRAINT FK_PK_HoSo REFERENCES HoSoBenhAn(maHoSo),
    maBS        INT NOT NULL CONSTRAINT FK_PK_BS   REFERENCES BacSi(maBS),
    maKhoa      INT NOT NULL CONSTRAINT FK_PK_Khoa REFERENCES Khoa(maKhoa),
    ngayGioKham DATETIME2(0) NOT NULL CONSTRAINT DF_PK_ngay DEFAULT SYSDATETIME(),
    loaiKham    VARCHAR(10) NOT NULL CONSTRAINT CK_PK_loai CHECK (loaiKham IN ('DieuTri','DinhKy')),
    trieuChung  NVARCHAR(500) NULL,
    thanNhiet   DECIMAL(3,1) NULL CONSTRAINT CK_PK_nhiet CHECK (thanNhiet BETWEEN 30 AND 45),
    huyetAp     VARCHAR(10) NULL CONSTRAINT CK_PK_ha CHECK (huyetAp LIKE '[0-9][0-9]%/[0-9][0-9]%'),
    chanDoan    NVARCHAR(500) NULL,
    trangThai   VARCHAR(10) NOT NULL CONSTRAINT DF_PK_tt DEFAULT 'DangKham'
                CONSTRAINT CK_PK_tt CHECK (trangThai IN ('DangKham','HoanTat','Huy')),
    maLich      INT NULL CONSTRAINT FK_PK_Lich REFERENCES LichKhamDinhKy(maLich),
    CONSTRAINT CK_PK_lich_loai CHECK (loaiKham = 'DinhKy' OR maLich IS NULL)
);
CREATE UNIQUE INDEX UX_PK_maLich ON PhieuKham(maLich) WHERE maLich IS NOT NULL; -- 1 lịch -> 1 phiếu
CREATE INDEX IX_PK_HoSo ON PhieuKham(maHoSo, ngayGioKham DESC);

/* ===== XÉT NGHIỆM - TOA THUỐC - THANH TOÁN ===== */
CREATE TABLE ChiTietXetNghiem (
    maCTXN      INT IDENTITY(1,1) CONSTRAINT PK_CTXN PRIMARY KEY,
    maPhieuKham INT NOT NULL CONSTRAINT FK_CTXN_PK REFERENCES PhieuKham(maPhieuKham),
    maXN        INT NOT NULL CONSTRAINT FK_CTXN_XN REFERENCES XetNghiem(maXN),
    ngayXN      DATETIME2(0) NULL,
    ketQua      NVARCHAR(500) NULL,
    CONSTRAINT UQ_CTXN UNIQUE (maPhieuKham, maXN)
);

CREATE TABLE ToaThuoc (
    maToa       INT IDENTITY(1,1) CONSTRAINT PK_ToaThuoc PRIMARY KEY,
    maPhieuKham INT NOT NULL CONSTRAINT UQ_Toa_PK UNIQUE             -- 1 phiếu khám = 1 toa
                CONSTRAINT FK_Toa_PK REFERENCES PhieuKham(maPhieuKham),
    ngayLap     DATETIME2(0) NOT NULL CONSTRAINT DF_Toa_ngay DEFAULT SYSDATETIME(),
    ghiChu      NVARCHAR(300) NULL
);

CREATE TABLE ChiTietToaThuoc (
    maToa    INT NOT NULL CONSTRAINT FK_CTT_Toa REFERENCES ToaThuoc(maToa),
    maThuoc  INT NOT NULL CONSTRAINT FK_CTT_Thuoc REFERENCES Thuoc(maThuoc),
    soLuong  INT NOT NULL CONSTRAINT CK_CTT_sl CHECK (soLuong > 0),
    lieuDung NVARCHAR(100) NULL,
    cachDung NVARCHAR(200) NULL,
    CONSTRAINT PK_ChiTietToaThuoc PRIMARY KEY (maToa, maThuoc)
);

CREATE TABLE ThanhToanVienPhi (
    maTT        INT IDENTITY(1,1) CONSTRAINT PK_ThanhToan PRIMARY KEY,
    maPhieuKham INT NOT NULL CONSTRAINT UQ_TT_PK UNIQUE
                CONSTRAINT FK_TT_PK REFERENCES PhieuKham(maPhieuKham),
    ngayTT      DATETIME2(0) NOT NULL CONSTRAINT DF_TT_ngay DEFAULT SYSDATETIME(),
    tongTien    DECIMAL(18,0) NOT NULL CONSTRAINT CK_TT_tien CHECK (tongTien >= 0),
    hinhThuc    VARCHAR(20) NOT NULL CONSTRAINT CK_TT_ht CHECK (hinhThuc IN ('TienMat','The','ChuyenKhoan','MienPhi')),
    maNV        INT NOT NULL CONSTRAINT FK_TT_NV REFERENCES NhanVienCSKH(maNV)
);
GO

--==================================DỮ LIỆU MẪU===================================
INSERT NhanVienCSKH(hoTen) VALUES (N'Trần Thị Mai'), (N'Lê Văn Hùng');
INSERT Khoa(tenKhoa) VALUES (N'Nội tổng quát'), (N'Tim mạch'), (N'Nhi');
INSERT BacSi(hoTen, chuyenMon, maKhoa) VALUES
 (N'BS. Phạm Minh Khoa', N'Nội tiết', 1),
 (N'BS. Võ Thanh Lan',   N'Tim mạch', 2),
 (N'BS. Đặng Quốc Việt', N'Nhi khoa', 3);
INSERT XetNghiem(tenXN, donGia) VALUES
 (N'Công thức máu', 120000), (N'Đường huyết', 60000), (N'Điện tâm đồ', 150000);
INSERT Thuoc(tenThuoc, donViTinh, donGia) VALUES
 (N'Paracetamol 500mg', N'Viên', 1500),
 (N'Amoxicillin 500mg', N'Viên', 3000),
 (N'Vitamin C 500mg',   N'Viên', 1000);
GO

--======================Stored procedure (có transaction)=======================
/* 3.1 Đăng ký lần đầu + lệ phí năm + cấp hồ sơ (4 bảng, 1 transaction) */
CREATE OR ALTER PROCEDURE sp_DangKyBenhNhanLanDau
    @hoTen NVARCHAR(100), @diaChi NVARCHAR(200), @ngaySinh DATE, @dienThoai VARCHAR(15),
    @anh3x4 VARBINARY(MAX) = NULL, @maNV INT, @soTienLePhi DECIMAL(18,0),
    @maBN INT OUTPUT, @maHoSo INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRAN;
            INSERT BenhNhan(hoTen, diaChi, ngaySinh, dienThoai, anh3x4)
            VALUES (@hoTen, @diaChi, @ngaySinh, @dienThoai, @anh3x4);
            SET @maBN = SCOPE_IDENTITY();

            INSERT PhieuDangKy(maBN, maNV) VALUES (@maBN, @maNV);
            INSERT LePhiNam(maBN, nam, soTien, maNV) VALUES (@maBN, YEAR(GETDATE()), @soTienLePhi, @maNV);
            INSERT HoSoBenhAn(maBN, maNV) VALUES (@maBN, @maNV);
            SET @maHoSo = SCOPE_IDENTITY();
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

/* 3.2 Gia hạn lệ phí cho năm mới */
CREATE OR ALTER PROCEDURE sp_DongLePhiNam
    @maBN INT, @nam INT, @soTien DECIMAL(18,0), @maNV INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM LePhiNam WHERE maBN = @maBN AND nam = @nam)
        THROW 50001, N'Bệnh nhân đã đóng lệ phí cho năm này.', 1;
    INSERT LePhiNam(maBN, nam, soTien, maNV) VALUES (@maBN, @nam, @soTien, @maNV);
END
GO

/* 3.3 Tra cứu hồ sơ theo mã hồ sơ / tên / số điện thoại */
CREATE OR ALTER PROCEDURE sp_TraCuuHoSo
    @soHoSo VARCHAR(10) = NULL, @hoTen NVARCHAR(100) = NULL, @dienThoai VARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.maHoSo, h.soHoSo, b.maBN, b.hoTen, b.ngaySinh, b.diaChi, b.dienThoai, h.ngayCap, h.trangThai,
           CASE WHEN EXISTS (SELECT 1 FROM LePhiNam l WHERE l.maBN = b.maBN AND l.nam = YEAR(GETDATE()))
                THEN N'Đã đóng' ELSE N'Chưa đóng' END AS lePhiNamNay
    FROM HoSoBenhAn h JOIN BenhNhan b ON b.maBN = h.maBN
    WHERE (@soHoSo    IS NULL OR h.soHoSo = @soHoSo)
      AND (@hoTen     IS NULL OR b.hoTen LIKE N'%' + @hoTen + N'%')
      AND (@dienThoai IS NULL OR b.dienThoai = @dienThoai);
END
GO

/* 3.4 Lịch sử khám: 3 result set (phiếu khám / xét nghiệm / thuốc) */
CREATE OR ALTER PROCEDURE sp_LichSuKham @maHoSo INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pk.maPhieuKham, pk.ngayGioKham, pk.loaiKham, bs.hoTen AS bacSi, k.tenKhoa,
           pk.trieuChung, pk.thanNhiet, pk.huyetAp, pk.chanDoan, pk.trangThai
    FROM PhieuKham pk
    JOIN BacSi bs ON bs.maBS = pk.maBS
    JOIN Khoa k   ON k.maKhoa = pk.maKhoa
    WHERE pk.maHoSo = @maHoSo
    ORDER BY pk.ngayGioKham DESC;

    SELECT pk.maPhieuKham, x.tenXN, c.ngayXN, c.ketQua
    FROM PhieuKham pk
    JOIN ChiTietXetNghiem c ON c.maPhieuKham = pk.maPhieuKham
    JOIN XetNghiem x ON x.maXN = c.maXN
    WHERE pk.maHoSo = @maHoSo
    ORDER BY pk.ngayGioKham DESC;

    SELECT pk.maPhieuKham, t.tenThuoc, ct.soLuong, t.donViTinh, ct.lieuDung, ct.cachDung
    FROM PhieuKham pk
    JOIN ToaThuoc tt ON tt.maPhieuKham = pk.maPhieuKham
    JOIN ChiTietToaThuoc ct ON ct.maToa = tt.maToa
    JOIN Thuoc t ON t.maThuoc = ct.maThuoc
    WHERE pk.maHoSo = @maHoSo
    ORDER BY pk.ngayGioKham DESC;
END
GO

/* 3.5 Đặt lịch khám định kỳ theo quý (miễn phí, mỗi quý 1 lịch) */
CREATE OR ALTER PROCEDURE sp_DatLichDinhKy
    @maHoSo INT, @ngayGioHen DATETIME2(0), @maNV INT, @maLich INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @maBN INT, @nam INT = YEAR(@ngayGioHen), @quy TINYINT = DATEPART(QUARTER, @ngayGioHen);

    SELECT @maBN = maBN FROM HoSoBenhAn WHERE maHoSo = @maHoSo AND trangThai = 'HoatDong';
    IF @maBN IS NULL THROW 50010, N'Hồ sơ không tồn tại hoặc đã bị khóa.', 1;
    IF @ngayGioHen <= SYSDATETIME() THROW 50011, N'Ngày giờ hẹn phải ở tương lai.', 1;
    IF NOT EXISTS (SELECT 1 FROM LePhiNam WHERE maBN = @maBN AND nam = @nam)
        THROW 50012, N'Bệnh nhân chưa đóng lệ phí của năm này nên không có quyền khám định kỳ.', 1;
    IF EXISTS (SELECT 1 FROM LichKhamDinhKy WHERE maHoSo = @maHoSo AND nam = @nam AND quy = @quy AND trangThai <> 'Huy')
        THROW 50013, N'Quý này bệnh nhân đã có lịch khám định kỳ.', 1;

    INSERT LichKhamDinhKy(maHoSo, quy, nam, ngayGioHen, maNV) VALUES (@maHoSo, @quy, @nam, @ngayGioHen, @maNV);
    SET @maLich = SCOPE_IDENTITY();
END
GO

/* 3.6 Tạo phiếu khám (điều trị hoặc định kỳ) */
CREATE OR ALTER PROCEDURE sp_TaoPhieuKham
    @maHoSo INT, @maBS INT, @maKhoa INT, @loaiKham VARCHAR(10),
    @trieuChung NVARCHAR(500) = NULL, @thanNhiet DECIMAL(3,1) = NULL, @huyetAp VARCHAR(10) = NULL,
    @maLich INT = NULL, @maPhieuKham INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        DECLARE @maBN INT;
        SELECT @maBN = maBN FROM HoSoBenhAn WHERE maHoSo = @maHoSo AND trangThai = 'HoatDong';
        IF @maBN IS NULL THROW 50020, N'Hồ sơ không tồn tại hoặc đã bị khóa.', 1;
        IF NOT EXISTS (SELECT 1 FROM LePhiNam WHERE maBN = @maBN AND nam = YEAR(GETDATE()))
            THROW 50021, N'Bệnh nhân chưa đóng lệ phí năm nay.', 1;
        IF NOT EXISTS (SELECT 1 FROM BacSi WHERE maBS = @maBS AND maKhoa = @maKhoa)
            THROW 50022, N'Bác sĩ không thuộc khoa đã chọn.', 1;

        IF @loaiKham = 'DinhKy'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM LichKhamDinhKy WHERE maLich = @maLich AND maHoSo = @maHoSo AND trangThai = 'DaHen')
                THROW 50023, N'Khám định kỳ phải có lịch hẹn hợp lệ (đúng hồ sơ, còn ở trạng thái Đã hẹn).', 1;
        END
        ELSE IF @maLich IS NOT NULL
            THROW 50024, N'Khám điều trị không được gắn với lịch định kỳ.', 1;

        BEGIN TRAN;
            INSERT PhieuKham(maHoSo, maBS, maKhoa, loaiKham, trieuChung, thanNhiet, huyetAp, maLich)
            VALUES (@maHoSo, @maBS, @maKhoa, @loaiKham, @trieuChung, @thanNhiet, @huyetAp, @maLich);
            SET @maPhieuKham = SCOPE_IDENTITY();

            IF @maLich IS NOT NULL
                UPDATE LichKhamDinhKy SET trangThai = 'DaKham' WHERE maLich = @maLich;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

/* 3.7 Yêu cầu xét nghiệm + nhập kết quả */
CREATE OR ALTER PROCEDURE sp_YeuCauXetNghiem @maPhieuKham INT, @maXN INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM PhieuKham WHERE maPhieuKham = @maPhieuKham AND trangThai = 'DangKham')
        THROW 50030, N'Phiếu khám không tồn tại hoặc đã hoàn tất.', 1;
    INSERT ChiTietXetNghiem(maPhieuKham, maXN) VALUES (@maPhieuKham, @maXN);
END
GO

CREATE OR ALTER PROCEDURE sp_NhapKetQuaXetNghiem @maCTXN INT, @ketQua NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ChiTietXetNghiem c JOIN PhieuKham p ON p.maPhieuKham = c.maPhieuKham
                   WHERE c.maCTXN = @maCTXN AND p.trangThai = 'DangKham')
        THROW 50031, N'Không tìm thấy xét nghiệm hoặc phiếu khám đã hoàn tất.', 1;
    UPDATE ChiTietXetNghiem SET ketQua = @ketQua, ngayXN = SYSDATETIME() WHERE maCTXN = @maCTXN;
END
GO

/* 3.8 Lập toa thuốc: @dsThuoc là JSON, ví dụ:
   [{"maThuoc":1,"soLuong":10,"lieuDung":"2 viên/lần","cachDung":"Sau ăn"}] */
CREATE OR ALTER PROCEDURE sp_LapToaThuoc
    @maPhieuKham INT, @ghiChu NVARCHAR(300) = NULL, @dsThuoc NVARCHAR(MAX), @maToa INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM PhieuKham WHERE maPhieuKham = @maPhieuKham AND trangThai = 'DangKham')
            THROW 50040, N'Phiếu khám không tồn tại hoặc đã hoàn tất, không thể lập toa.', 1;
        IF ISJSON(@dsThuoc) = 0 OR NOT EXISTS (SELECT 1 FROM OPENJSON(@dsThuoc))
            THROW 50041, N'Toa thuốc phải có ít nhất một loại thuốc.', 1;

        BEGIN TRAN;
            INSERT ToaThuoc(maPhieuKham, ghiChu) VALUES (@maPhieuKham, @ghiChu);
            SET @maToa = SCOPE_IDENTITY();

            INSERT ChiTietToaThuoc(maToa, maThuoc, soLuong, lieuDung, cachDung)
            SELECT @maToa, maThuoc, soLuong, lieuDung, cachDung
            FROM OPENJSON(@dsThuoc) WITH (
                maThuoc  INT           '$.maThuoc',
                soLuong  INT           '$.soLuong',
                lieuDung NVARCHAR(100) '$.lieuDung',
                cachDung NVARCHAR(200) '$.cachDung');
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

/* 3.9 Thanh toán viện phí (khám định kỳ: 0 đồng, hình thức MienPhi) */
CREATE OR ALTER PROCEDURE sp_ThanhToanVienPhi
    @maPhieuKham INT, @hinhThuc VARCHAR(20), @maNV INT, @tongTien DECIMAL(18,0) OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        DECLARE @loai VARCHAR(10);
        SELECT @loai = loaiKham FROM PhieuKham WHERE maPhieuKham = @maPhieuKham AND trangThai = 'DangKham';
        IF @loai IS NULL THROW 50050, N'Phiếu khám không tồn tại hoặc đã hoàn tất.', 1;
        IF EXISTS (SELECT 1 FROM ThanhToanVienPhi WHERE maPhieuKham = @maPhieuKham)
            THROW 50051, N'Phiếu khám này đã được thanh toán.', 1;
        IF EXISTS (SELECT 1 FROM ChiTietXetNghiem WHERE maPhieuKham = @maPhieuKham AND ketQua IS NULL)
            THROW 50052, N'Còn xét nghiệm chưa có kết quả, chưa thể thanh toán.', 1;

        IF @loai = 'DinhKy'
        BEGIN
            SET @tongTien = 0; SET @hinhThuc = 'MienPhi';
        END
        ELSE
            SELECT @tongTien =
                ISNULL((SELECT SUM(x.donGia)
                        FROM ChiTietXetNghiem c JOIN XetNghiem x ON x.maXN = c.maXN
                        WHERE c.maPhieuKham = @maPhieuKham), 0)
              + ISNULL((SELECT SUM(ct.soLuong * t.donGia)
                        FROM ToaThuoc tt
                        JOIN ChiTietToaThuoc ct ON ct.maToa = tt.maToa
                        JOIN Thuoc t ON t.maThuoc = ct.maThuoc
                        WHERE tt.maPhieuKham = @maPhieuKham), 0);

        INSERT ThanhToanVienPhi(maPhieuKham, tongTien, hinhThuc, maNV)
        VALUES (@maPhieuKham, @tongTien, @hinhThuc, @maNV);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

/* 3.10 Hoàn tất đợt điều trị: chỉ được sau khi đã thanh toán */
CREATE OR ALTER PROCEDURE sp_HoanTatPhieuKham @maPhieuKham INT, @chanDoan NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM PhieuKham WHERE maPhieuKham = @maPhieuKham AND trangThai = 'DangKham')
        THROW 50060, N'Phiếu khám không tồn tại hoặc đã hoàn tất.', 1;
    IF NOT EXISTS (SELECT 1 FROM ThanhToanVienPhi WHERE maPhieuKham = @maPhieuKham)
        THROW 50061, N'Chưa thanh toán viện phí nên chưa thể hoàn tất và ghi nhận hồ sơ.', 1;
    UPDATE PhieuKham SET trangThai = 'HoanTat', chanDoan = @chanDoan WHERE maPhieuKham = @maPhieuKham;
END
GO
--===============================Kịch bản kiểm thử
USE QuanLyBenhAn;
GO
/* TC1: Đăng ký lần đầu + lệ phí + cấp hồ sơ -> thành công, 4 bảng đều có dữ liệu */
DECLARE @bn INT, @hs INT;
EXEC sp_DangKyBenhNhanLanDau N'Nguyễn Văn An', N'12 Lê Lợi, Q1', '1990-05-20', '0901234567',
     NULL, 1, 200000, @bn OUTPUT, @hs OUTPUT;
SELECT @bn AS maBN, @hs AS maHoSo;
SELECT * FROM BenhNhan; SELECT * FROM PhieuDangKy; SELECT * FROM LePhiNam; SELECT * FROM HoSoBenhAn;
GO

/* TC2: Lệ phí = 0 -> PHẢI LỖI và ROLLBACK, số bệnh nhân không đổi */
DECLARE @bn INT, @hs INT, @truoc INT = (SELECT COUNT(*) FROM BenhNhan);
BEGIN TRY
    EXEC sp_DangKyBenhNhanLanDau N'Trần Thị Bình', N'45 Hai Bà Trưng', '1995-01-01', '0912345678',
         NULL, 1, 0, @bn OUTPUT, @hs OUTPUT;
END TRY
BEGIN CATCH
    PRINT N'Lỗi (đúng mong đợi): ' + ERROR_MESSAGE();
END CATCH
SELECT @truoc AS truoc, (SELECT COUNT(*) FROM BenhNhan) AS sau;   -- 2 số phải bằng nhau
GO

/* TC3: Tra cứu hồ sơ theo mã / tên / SĐT */
EXEC sp_TraCuuHoSo @soHoSo = 'HS000001';
EXEC sp_TraCuuHoSo @hoTen = N'An';
EXEC sp_TraCuuHoSo @dienThoai = '0901234567';
GO

/* TC4: Lịch định kỳ theo quý */
DECLARE @lich INT, @ngay DATETIME2(0) = DATEADD(DAY, 7, SYSDATETIME());
EXEC sp_DatLichDinhKy 1, @ngay, 1, @lich OUTPUT;                  -- OK
SELECT * FROM LichKhamDinhKy;
BEGIN TRY EXEC sp_DatLichDinhKy 1, @ngay, 2, @lich OUTPUT;        -- PHẢI LỖI: trùng quý
END TRY BEGIN CATCH PRINT N'Trùng quý: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY
    DECLARE @namSau DATETIME2(0) = DATEADD(YEAR, 1, @ngay);
    EXEC sp_DatLichDinhKy 1, @namSau, 1, @lich OUTPUT;            -- PHẢI LỖI: chưa đóng lệ phí năm sau
END TRY BEGIN CATCH PRINT N'Chưa đóng lệ phí: ' + ERROR_MESSAGE(); END CATCH
GO

/* TC5: Khám định kỳ từ lịch hẹn -> thanh toán 0 đồng -> hoàn tất */
DECLARE @pk INT, @tien DECIMAL(18,0);
DECLARE @lich INT = (SELECT TOP 1 maLich FROM LichKhamDinhKy WHERE maHoSo = 1 AND trangThai = 'DaHen');
EXEC sp_TaoPhieuKham 1, 1, 1, 'DinhKy', N'Không có triệu chứng', 36.6, '120/80', @lich, @pk OUTPUT;
EXEC sp_ThanhToanVienPhi @pk, 'TienMat', 1, @tien OUTPUT;
SELECT @tien AS tongTien_phaiLa0;
EXEC sp_HoanTatPhieuKham @pk, N'Sức khỏe bình thường';
SELECT * FROM LichKhamDinhKy;                                     -- trạng thái lịch = DaKham
BEGIN TRY                                                          -- PHẢI LỖI: dùng lại lịch đã khám
    EXEC sp_TaoPhieuKham 1, 1, 1, 'DinhKy', NULL, NULL, NULL, @lich, @pk OUTPUT;
END TRY BEGIN CATCH PRINT N'Lịch đã dùng: ' + ERROR_MESSAGE(); END CATCH
GO

/* TC6: Khám điều trị: phiếu -> xét nghiệm -> toa -> thanh toán -> hoàn tất */
DECLARE @pk INT, @toa INT, @tien DECIMAL(18,0);
EXEC sp_TaoPhieuKham 1, 2, 2, 'DieuTri', N'Đau ngực, khó thở', 37.2, '140/90', NULL, @pk OUTPUT;

EXEC sp_YeuCauXetNghiem @pk, 3;                                    -- Điện tâm đồ
BEGIN TRY EXEC sp_ThanhToanVienPhi @pk, 'The', 1, @tien OUTPUT;   -- PHẢI LỖI: XN chưa có kết quả
END TRY BEGIN CATCH PRINT N'XN chưa có KQ: ' + ERROR_MESSAGE(); END CATCH

EXEC sp_NhapKetQuaXetNghiem @maCTXN = 1, @ketQua = N'Nhịp xoang bình thường';

EXEC sp_LapToaThuoc @pk, N'Tái khám sau 1 tuần',
     N'[{"maThuoc":1,"soLuong":10,"lieuDung":"1 viên/lần","cachDung":"Uống sau ăn"},
        {"maThuoc":3,"soLuong":14,"lieuDung":"1 viên/ngày","cachDung":"Uống buổi sáng"}]', @toa OUTPUT;

BEGIN TRY EXEC sp_HoanTatPhieuKham @pk, N'Chưa thanh toán';       -- PHẢI LỖI: chưa thanh toán
END TRY BEGIN CATCH PRINT N'Hoàn tất sớm: ' + ERROR_MESSAGE(); END CATCH

EXEC sp_ThanhToanVienPhi @pk, 'The', 1, @tien OUTPUT;
SELECT @tien AS tongTien_phaiLa_179000;                            -- 150000 + 10*1500 + 14*1000
EXEC sp_HoanTatPhieuKham @pk, N'Đau thắt ngực ổn định';

BEGIN TRY                                                          -- PHẢI LỖI: phiếu đã hoàn tất
    DECLARE @t2 INT;
    EXEC sp_LapToaThuoc @pk, NULL, N'[{"maThuoc":2,"soLuong":5}]', @t2 OUTPUT;
END TRY BEGIN CATCH PRINT N'Toa sau hoàn tất: ' + ERROR_MESSAGE(); END CATCH
GO

/* TC7: Toa kê trùng thuốc -> PHẢI LỖI và ROLLBACK (không còn toa mồ côi) */
DECLARE @pk INT, @toa INT, @truoc INT = (SELECT COUNT(*) FROM ToaThuoc);
EXEC sp_TaoPhieuKham 1, 1, 1, 'DieuTri', N'Sốt, ho', 38.5, '110/70', NULL, @pk OUTPUT;
BEGIN TRY
    EXEC sp_LapToaThuoc @pk, NULL,
         N'[{"maThuoc":1,"soLuong":5},{"maThuoc":1,"soLuong":3}]', @toa OUTPUT;
END TRY BEGIN CATCH PRINT N'Trùng thuốc: ' + ERROR_MESSAGE(); END CATCH
SELECT @truoc AS truoc, (SELECT COUNT(*) FROM ToaThuoc) AS sau;   -- bằng nhau
GO

/* TC8: Liên kết toa/XN với phiếu khám: chèn trực tiếp phiếu không tồn tại -> PHẢI LỖI FK */
BEGIN TRY INSERT ToaThuoc(maPhieuKham) VALUES (99999);
END TRY BEGIN CATCH PRINT N'FK: ' + ERROR_MESSAGE(); END CATCH
BEGIN TRY INSERT ChiTietXetNghiem(maPhieuKham, maXN) VALUES (99999, 1);
END TRY BEGIN CATCH PRINT N'FK: ' + ERROR_MESSAGE(); END CATCH
GO

/* TC9: Tra cứu lịch sử khám của hồ sơ */
EXEC sp_LichSuKham 1;
GO