# BrightPath Language Center — Database Final Project

Hệ thống cơ sở dữ liệu quản lý học viên, instructor, lớp học, buổi học,
điểm danh và chứng chỉ nội bộ cho một trung tâm ngoại ngữ, xây dựng
bằng **MySQL 8+**.

> Đồ án cuối kỳ môn **Cơ sở dữ liệu** — Trường Đại học Quốc tế, ĐHQG Hà Nội
> Lớp ISV201603 — GVHD: Vũ Đức Minh

---

## Thành viên nhóm

| Họ tên | MSSV 

| Đoàn Việt Anh | 24070501 
| Nguyễn Hải Anh | 24070451 
| Nguyễn Duy Khánh | 24070348 
| Bùi Thanh Long | 24070377 

---

## Tổng quan

Bản **giữa kỳ** tập trung vào thiết kế: phân tích yêu cầu nghiệp vụ
(34 business rules), ERD (Crow's Foot), mô hình quan hệ, chuẩn hóa 3NF
và `CREATE TABLE`.

Bản **cuối kỳ** kế thừa toàn bộ thiết kế trên, bổ sung 3 thay đổi
(xem change log trong `report.md`) và hoàn thiện phần khai thác/vận
hành: dữ liệu mẫu, truy vấn, view, stored procedure/function,
trigger/event, index, quản trị người dùng, backup/restore và kiểm thử.

## Checklist các thành phần đã hoàn thành

- [x] ERD, mô hình quan hệ, chuẩn hóa 3NF (final, có change log)
- [x] 10 bảng (`01_schema.sql`) — 9 bảng nghiệp vụ + 1 bảng audit mới
- [x] Dữ liệu mẫu đầy đủ (`02_seed_data.sql`)
- [x] 8 business query: filter/order, join ≥3 bảng, left join, group+having, not exists, CTE, report theo thời gian, dùng view/function (`03_queries.sql`)
- [x] 2 view phục vụ reporting (`04_views.sql`)
- [x] **3** stored procedure có transaction + validation (`sp_record_attendance`, `sp_cancel_meeting`, `sp_award_certificate`) + **3** stored function (`fn_student_attendance_count`, `fn_student_attendance_rate`, `fn_class_instructor`) — vượt yêu cầu tối thiểu 2 SP + 1 FN (`05_routines.sql`)
- [x] **4** trigger (kể cả 1 trigger chống "hồi sinh" buổi học đã kết thúc) + 1 event an toàn (disabled) (`06_triggers_events.sql`)
- [x] 3 secondary index + `EXPLAIN`, kèm ghi chú về index tự sinh của FK (`07_indexes_explain.sql`)
- [x] Role/user least-privilege + backup/restore runbook (`08_admin_backup.md`)
- [x] **19** test case positive/negative (`09_tests.sql`)

## Cấu trúc repo

```
brightpath-language-center/
├── README.md 
├── report.md / report.pdf 
├── noi_dung_bao_cao_cuoi_ky.md
├── erd.png
├── 01_schema.sql
├── 02_seed_data.sql
├── 03_queries.sql
├── 04_views.sql
├── 05_routines.sql
├── 06_triggers_events.sql
├── 07_indexes_explain.sql
├── 08_admin_backup.md
└── 09_tests.sql
```

## Công nghệ sử dụng

- **MySQL Server 8.0+** — InnoDB, utf8mb4/utf8mb4_unicode_ci
- **MySQL Workbench 8.0 CE** — thiết kế ERD, chạy script, EXPLAIN

## Cách chạy nhanh

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_seed_data.sql
mysql -u root -p < 04_views.sql
mysql -u root -p < 05_routines.sql
mysql -u root -p < 06_triggers_events.sql
mysql -u root -p < 07_indexes_explain.sql
mysql -u root -p < 03_queries.sql
mysql -u root -p < 09_tests.sql
```

Phần `08_admin_backup.md` chạy thủ công theo hướng dẫn trong file (có
bước tạo user/mật khẩu cần tự điều chỉnh, không nên chạy tự động).

> **Lưu ý:** `01_schema.sql` bắt đầu bằng `DROP DATABASE IF EXISTS`,
> nên có thể chạy lại toàn bộ pipeline bất cứ lúc nào để có database
> sạch. Không chạy các script quản trị/backup trên server dùng chung.

## Tài liệu chi tiết

- Thiết kế & phân tích nghiệp vụ đầy đủ: xem `report.md`
- Nội dung diễn giải từng chương (bản dựng sẵn để đưa vào Word/LaTeX): `noi_dung_bao_cao_cuoi_ky.md`
- Không commit mật khẩu thật — mọi credential trong repo chỉ là placeholder demo.
