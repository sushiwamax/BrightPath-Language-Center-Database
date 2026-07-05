-- =====================================================================
-- 07_indexes_explain.sql
-- 3 secondary index (CH03) + SHOW INDEX + EXPLAIN cho các query liên quan
-- Chạy sau 01_schema.sql, 02_seed_data.sql
-- =====================================================================
USE brightpath_language_center;

-- ---------------------------------------------------------------------
-- INDEX 1: idx_meeting_class_date
-- Query workload: Q01/Q07 và các báo cáo "các buổi học của 1 lớp theo
--   thời gian" -> lọc theo ClassID (equality) rồi sắp theo MeetingDate
--   (range/order). Cột ClassID đặt trước để hỗ trợ equality trước.
-- ---------------------------------------------------------------------
CREATE INDEX idx_meeting_class_date
    ON CLASS_MEETING (ClassID, MeetingDate);

EXPLAIN
SELECT MeetingID, MeetingDate, MeetingStatus
FROM CLASS_MEETING
WHERE ClassID = 'CL001'
ORDER BY MeetingDate;

-- ---------------------------------------------------------------------
-- INDEX 2: idx_meeting_instructor_student
-- Query workload: tra cứu lịch dạy của 1 instructor cụ thể (StudentID)
--   trên bảng MEETING_INSTRUCTOR. PK hiện tại là (MeetingID, StudentID)
--   nên lookup theo StudentID một mình không tận dụng được PK -> cần
--   thêm index phụ theo chiều ngược lại.
-- ---------------------------------------------------------------------
CREATE INDEX idx_meeting_instructor_student
    ON MEETING_INSTRUCTOR (StudentID, Role);

EXPLAIN
SELECT MeetingID, Role
FROM MEETING_INSTRUCTOR
WHERE StudentID = 'S001';

-- ---------------------------------------------------------------------
-- INDEX 3: idx_attendance_meeting_student
-- Query workload: "buổi học này có những học viên nào tham dự?" (dùng
--   trong Q03 - kiểm tra thiếu dữ liệu theo meeting, và trong sp_cancel_meeting
--   khi cần xóa toàn bộ attendance của 1 meeting). PK (StudentID, MeetingID)
--   không tối ưu cho lookup theo MeetingID trước.
-- ---------------------------------------------------------------------
CREATE INDEX idx_attendance_meeting_student
    ON ATTENDANCE (MeetingID, StudentID);

EXPLAIN
SELECT StudentID
FROM ATTENDANCE
WHERE MeetingID = 'M001';

-- ---------------------------------------------------------------------
-- Vì sao KHÔNG tạo thêm index trên các cột khóa ngoại (FK) khác?
-- ---------------------------------------------------------------------
-- InnoDB tự động tạo index cho mọi cột khóa ngoại khi bảng được tạo
-- (ví dụ: CLASS.MainInstructorID, CLASS_MEETING.ClassID,
-- CERTIFICATE_REQUIREMENT.CertificateID đã có index ẩn do ràng buộc FK
-- sinh ra). Nhóm chủ động không tạo thêm index trùng lặp trên các cột
-- này để tránh lãng phí dung lượng và chi phí ghi không cần thiết; xem
-- SHOW INDEX bên dưới để xác nhận các index do FK tự sinh.
SHOW INDEX FROM CLASS;
SHOW INDEX FROM CERTIFICATE_REQUIREMENT;

-- ---------------------------------------------------------------------
-- Metadata kiểm tra index đã tạo
-- ---------------------------------------------------------------------
SHOW INDEX FROM CLASS_MEETING;
SHOW INDEX FROM MEETING_INSTRUCTOR;
SHOW INDEX FROM ATTENDANCE;

-- ---------------------------------------------------------------------
-- Ghi chú đọc EXPLAIN (điền vào report.md sau khi chạy thật trên máy):
--   - key: kỳ vọng optimizer chọn đúng index vừa tạo thay vì full scan.
--   - rows: với dữ liệu mẫu nhỏ (15 meeting, 48 attendance), MySQL có thể
--     vẫn chọn table scan vì bảng quá nhỏ để index có lợi - đây KHÔNG
--     phải lỗi, mà là giới hạn của bộ dữ liệu demo. Cần nạp dữ liệu lớn
--     hơn (hàng nghìn dòng) để thấy rõ hiệu quả của index trên EXPLAIN.
--   - Extra: theo dõi "Using index" (covering index) hay "Using filesort".
--
-- Trade-off: 3 index trên đều là index phụ (secondary), làm tăng chi phí
-- ghi (INSERT/UPDATE/DELETE phải cập nhật thêm index) và tốn thêm dung
-- lượng lưu trữ, đổi lại giúp các truy vấn tra cứu theo ClassID/StudentID/
-- MeetingID nhanh hơn khi dữ liệu lớn dần theo thời gian vận hành thực tế.
-- ---------------------------------------------------------------------
