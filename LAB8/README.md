# QUẢN LÝ CỬA HÀNG NƯỚC GIẢI KHÁT

## 1. Giới thiệu đề tài

Đề tài xây dựng chương trình quản lý cửa hàng nước giải khát bằng C# WinForms và SQL Server. Mục đích của chương trình là hỗ trợ cửa hàng quản lý thông tin sản phẩm, nhãn hiệu, nhà cung ứng và các nghiệp vụ liên quan đến hoạt động kinh doanh. Thay vì quản lý thông tin bằng cách ghi chép thủ công, hệ thống hướng đến việc lưu trữ dữ liệu tập trung trong cơ sở dữ liệu, giúp việc tìm kiếm và cập nhật thông tin thuận tiện hơn.

Trong quá trình thực hiện, em xây dựng giao diện Windows Forms trên Visual Studio, kết nối với SQL Server để lưu trữ và xử lý dữ liệu. Giao diện được thiết kế đơn giản, dễ sử dụng và có các nút chức năng riêng để người dùng lựa chọn nghiệp vụ cần thực hiện.

## 2. Công nghệ sử dụng

- **Ngôn ngữ lập trình:** C#.
- **Giao diện:** Windows Forms.
- **Môi trường phát triển:** Visual Studio.
- **Hệ quản trị cơ sở dữ liệu:** Microsoft SQL Server.
- **Tên cơ sở dữ liệu:** `QuanLyCuaHangNuocGiaiKhat`.

## 3. Các chức năng đã thực hiện

### 3.1. Giao diện chính

Em đã xây dựng giao diện chính cho chương trình với tiêu đề Quản lý cửa hàng nước giải khát. Trên màn hình chính có các nút chức năng được bố trí thành hai cột để người dùng dễ quan sát và lựa chọn.

Các chức năng được hiển thị trên giao diện gồm:

- Nhãn hiệu.
- Nhà cung ứng.
- Nước giải khát.
- Nhập hàng.
- Bán hàng.
- Phiếu hẹn giao.
- Khách hàng.
- Phiếu ghi nợ.

Hiện tại, các chức năng quản lý nhãn hiệu, nhà cung ứng và nước giải khát đang được triển khai trước. Những chức năng còn lại sẽ tiếp tục được hoàn thiện trong các bước phát triển tiếp theo.

### 3.2. Quản lý nhãn hiệu

Em đã xây dựng form quản lý nhãn hiệu để thao tác với thông tin nhãn hiệu trong cơ sở dữ liệu. Form hỗ trợ hiển thị danh sách nhãn hiệu, thêm nhãn hiệu mới, cập nhật thông tin, xóa và tìm kiếm theo từ khóa.

Khi người dùng chọn một dòng trong bảng dữ liệu, thông tin nhãn hiệu được đưa lên các ô nhập liệu để thuận tiện cho việc chỉnh sửa. Các thao tác được thực hiện thông qua lớp xử lý nghiệp vụ và lớp truy xuất dữ liệu.

### 3.3. Quản lý nhà cung ứng

Tiếp theo, em xây dựng form quản lý nhà cung ứng. Thông tin được quản lý gồm mã nhà cung ứng, tên nhà cung ứng, địa chỉ và số điện thoại.

Form có các chức năng thêm, sửa, xóa, tìm kiếm và làm mới dữ liệu. Danh sách nhà cung ứng được hiển thị trên bảng dữ liệu để người dùng theo dõi. Khi thực hiện thao tác xóa, chương trình yêu cầu xác nhận trước khi tiến hành. Trường hợp dữ liệu không thể xóa do có liên kết với thông tin khác trong cơ sở dữ liệu, chương trình sẽ hiển thị thông báo lỗi.

### 3.4. Quản lý nước giải khát

Em tiếp tục xây dựng chức năng quản lý nước giải khát. Các thông tin dự kiến quản lý gồm mã sản phẩm, tên sản phẩm, đơn vị tính, nhãn hiệu, nhà cung ứng, số lượng tồn và đơn giá.

Form được thiết kế với các ô nhập thông tin, danh sách chọn nhãn hiệu, danh sách chọn nhà cung ứng và bảng hiển thị sản phẩm. Các chức năng được xây dựng gồm thêm, cập nhật, xóa, tìm kiếm và làm mới dữ liệu.

Trong quá trình nhập thông tin, chương trình có kiểm tra một số dữ liệu cơ bản như số lượng tồn phải là số nguyên và đơn giá phải nhập đúng định dạng số. Số lượng tồn và đơn giá không được âm. Việc sử dụng danh sách chọn nhãn hiệu và nhà cung ứng giúp hạn chế nhập sai mã liên kết.

## 4. Thiết kế chương trình

Trong quá trình xây dựng, em tách chương trình thành các phần để dễ quản lý và sửa lỗi hơn.

- **Form:** Xử lý phần giao diện, nhận thông tin do người dùng nhập và hiển thị kết quả.
- **Service:** Xử lý nghiệp vụ và kiểm tra dữ liệu trước khi thực hiện các thao tác.
- **Data:** Thực hiện truy vấn SQL Server để lấy dữ liệu, thêm mới, cập nhật hoặc xóa dữ liệu.

Cách tổ chức này giúp phần giao diện không phải trực tiếp thực hiện tất cả các câu lệnh SQL. Khi cần thay đổi giao diện hoặc bổ sung nghiệp vụ, chương trình cũng dễ bảo trì hơn.

## 5. Kết nối cơ sở dữ liệu

Em đã cấu hình kết nối từ chương trình C# đến SQL Server và kiểm tra kết nối thành công. Các chức năng quản lý sử dụng cơ sở dữ liệu `QuanLyCuaHangNuocGiaiKhat` để lưu trữ thông tin.

Đối với chức năng nước giải khát, dữ liệu sản phẩm có liên quan đến nhãn hiệu và nhà cung ứng. Vì vậy, khi hiển thị thông tin, chương trình sử dụng các truy vấn kết hợp bảng để lấy thêm tên nhãn hiệu và các thông tin liên quan thay vì chỉ hiển thị mã.

## 6. Kiểm thử chương trình

Trong quá trình phát triển, em thực hiện kiểm tra chương trình bằng cách chạy thử trên Visual Studio và thao tác trực tiếp trên các form.

Các nội dung kiểm thử gồm:

- Kiểm tra chương trình có mở được giao diện chính hay không.
- Kiểm tra các nút chức năng có mở đúng form hay không.
- Kiểm tra dữ liệu có được tải từ SQL Server lên bảng hay không.
- Thử thêm mới, chỉnh sửa, xóa và tìm kiếm thông tin.
- Kiểm tra trường hợp bỏ trống thông tin bắt buộc.
- Kiểm tra dữ liệu số lượng tồn và đơn giá không hợp lệ.
- Kiểm tra thông báo khi thao tác dữ liệu gặp lỗi.
- Kiểm tra lại dữ liệu trong SQL Server sau khi thêm hoặc cập nhật.

Các trường hợp kiểm thử được tổng hợp trong bảng Test Case để thuận tiện theo dõi kết quả. Kết quả thực tế sẽ được ghi nhận sau khi chạy từng trường hợp trên chương trình.

## 7. Hướng phát triển

Trong các giai đoạn tiếp theo, em sẽ tiếp tục hoàn thiện các chức năng còn lại của hệ thống, bao gồm quản lý nhập hàng, bán hàng, khách hàng, phiếu hẹn giao và phiếu ghi nợ.

Đối với nghiệp vụ nhập hàng, chương trình cần hỗ trợ quản lý đơn đặt hàng và phiếu giao hàng. Đối với nghiệp vụ bán hàng, cần xử lý chi tiết hóa đơn và cập nhật số lượng tồn kho. Ngoài ra, hệ thống sẽ được bổ sung các chức năng liên quan đến lịch hẹn giao hàng và theo dõi công nợ khách hàng để đáp ứng đầy đủ hơn yêu cầu quản lý cửa hàng.

## 8. Kết luận

Qua quá trình thực hiện đề tài, em đã bước đầu xây dựng được chương trình quản lý cửa hàng nước giải khát bằng C# WinForms kết hợp SQL Server. Em đã thực hành thiết kế giao diện, tổ chức mã nguồn theo các lớp giao diện, nghiệp vụ và truy xuất dữ liệu, đồng thời xây dựng các chức năng quản lý thông tin cơ bản.

Đề tài vẫn cần được tiếp tục hoàn thiện để các nghiệp vụ nhập hàng, bán hàng, giao hàng và quản lý công nợ có thể hoạt động đồng bộ với dữ liệu tồn kho. Đây cũng là hướng phát triển tiếp theo để chương trình đáp ứng tốt hơn yêu cầu thực tế của một cửa hàng nước giải khát.

