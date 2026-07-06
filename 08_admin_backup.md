# 08_admin_backup.md
## Quản trị và Backup/Restore (local/lab only)

> Toàn bộ nội dung dưới đây chỉ áp dụng trên MySQL cài local/lab. Không
> chạy trên server dùng chung, không dùng tài khoản root cho ứng dụng
> demo, không commit mật khẩu thật vào báo cáo hay Git.

## 1. Least privilege - Role và User cho reporting

Trung tâm cần một tài khoản chỉ đọc (read-only) cho nhân viên lập báo
cáo, không được sửa/xóa dữ liệu gốc.

```sql
CREATE ROLE IF NOT EXISTS 'role_center_reporter';

-- LƯU Ý: MySQL không cho phép liệt kê nhiều bảng/view cách nhau bằng
-- dấu phẩy trong CÙNG MỘT câu GRANT (Error Code 1064). Mỗi câu GRANT
-- chỉ áp dụng cho đúng một object (bảng/view) duy nhất.
GRANT SELECT ON brightpath_language_center.vw_class_schedule
    TO 'role_center_reporter';

GRANT SELECT ON brightpath_language_center.vw_student_certificate_progress
    TO 'role_center_reporter';

GRANT SELECT ON brightpath_language_center.STUDENT
    TO 'role_center_reporter';

GRANT SELECT ON brightpath_language_center.CLASS
    TO 'role_center_reporter';

GRANT SELECT ON brightpath_language_center.CLASS_MEETING
    TO 'role_center_reporter';

GRANT SELECT ON brightpath_language_center.CERTIFICATE
    TO 'role_center_reporter';

CREATE USER IF NOT EXISTS 'center_reporter'@'localhost'
    IDENTIFIED BY '123456';

GRANT 'role_center_reporter' TO 'center_reporter'@'localhost';

SET DEFAULT ROLE 'role_center_reporter' TO 'center_reporter'@'localhost';
```

## 2. Bằng chứng cấp quyền

```sql
SHOW GRANTS FOR 'center_reporter'@'localhost';
SHOW CREATE USER 'center_reporter'@'localhost';
SHOW TABLES FROM brightpath_language_center;
SHOW CREATE TABLE STUDENT_CERTIFICATE_AUDIT;
SHOW INDEX FROM CLASS_MEETING;
```

Kiểm thử least privilege (xem thêm 09_tests.sql):
- `center_reporter` `SELECT` được từ `vw_class_schedule` → thành công.
- `center_reporter` thử `INSERT INTO STUDENT ...` → phải bị từ chối
  (`ERROR 1142: INSERT command denied`).

## 3. Backup (mysqldump)

```bash
# Mật khẩu được nhập tương tác, không hard-code trong script
mysqldump -u root -p \
    --routines --triggers --events \
    brightpath_language_center \
    > brightpath_language_center_20260701.sql
```

Quy ước đặt tên file: `<database>_<YYYYMMDD>.sql`, lưu ở thư mục backup
riêng có phân quyền hạn chế, không đưa vào Git repository công khai.

## 4. Restore (vào database test riêng biệt)

```bash
mysql -u root -p -e "CREATE DATABASE brightpath_language_center_restore_test
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

mysql -u root -p brightpath_language_center_restore_test \
    < brightpath_language_center_20260701.sql
```

**Nguyên tắc:** không bao giờ restore đè lên database nguồn đang chạy.
Restore luôn được test vào một schema riêng (`..._restore_test`) trước.

Kiểm tra sau khi restore:

```sql
USE brightpath_language_center_restore_test;
SHOW TABLES;                       -- phải đủ 10 bảng
SELECT COUNT(*) FROM STUDENT;      -- đối chiếu số dòng với bản gốc
SELECT COUNT(*) FROM ATTENDANCE;
SHOW TRIGGERS;                     -- phải đủ 3 trigger
SHOW EVENTS;                       -- ev_purge_old_certificate_audit ở trạng thái DISABLED
```

## 5. Ghi chú bảo mật

- Mật khẩu trong ví dụ (`ChangeThisLocalLabPassword!`) chỉ là placeholder,
  phải đổi trước khi dùng thật.
- Không dùng `'user'@'%'` nếu không có kiểm soát mạng cụ thể; ở đây chỉ
  cấp `'center_reporter'@'localhost'`.
- File dump chứa toàn bộ schema + dữ liệu + routine, cần được bảo vệ như
  dữ liệu nhạy cảm.
