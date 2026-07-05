-- =====================================================================
-- 09_tests.sql
-- Positive & negative tests cho toàn bộ hệ thống
-- Chạy sau 01-07. Mỗi test nêu: setup / thao tác / kết quả mong đợi.
-- =====================================================================
USE brightpath_language_center;

-- =======================================================================
-- TEST 1 (POSITIVE) - Trigger trg_auto_assign_starter_badge
-- Setup: chèn học viên mới S008 (chưa tồn tại trong seed data)
-- Expected: STUDENT_CERTIFICATE tự động có 1 dòng (S008, C001, JoinDate)
--           và STUDENT_CERTIFICATE_AUDIT tự động có 1 dòng ActionType=AWARDED
-- =======================================================================
INSERT INTO STUDENT (StudentID, FullName, DateOfBirth, JoinDate)
VALUES ('S008', 'Vũ Thị Hạnh', '1999-12-01', '2026-06-20');

SELECT * FROM STUDENT_CERTIFICATE WHERE StudentID = 'S008';
-- Expected actual: 1 dòng (S008, C001, 2026-06-20)

SELECT * FROM STUDENT_CERTIFICATE_AUDIT WHERE StudentID = 'S008';
-- Expected actual: 1 dòng ActionType = 'AWARDED'

-- =======================================================================
-- TEST 2 (NEGATIVE) - Primary Key duplicate
-- Setup: chèn lại StudentID đã tồn tại (S001)
-- Expected: ERROR 1062 Duplicate entry 'S001' for key 'PRIMARY'
-- =======================================================================
INSERT INTO STUDENT (StudentID, FullName, DateOfBirth, JoinDate)
VALUES ('S001', 'Duplicate Student', '2000-01-01', '2026-01-01');

-- =======================================================================
-- TEST 3 (NEGATIVE) - Foreign Key violation
-- Setup: tạo lớp học tham chiếu tới instructor không tồn tại
-- Expected: ERROR 1452 Cannot add or update a child row: FK constraint fails
-- =======================================================================
INSERT INTO CLASS (ClassID, Language, Level, DayOfWeek, StartTime, Room, MainInstructorID)
VALUES ('CL999', 'English', 'Beginner', 'Monday', '18:00:00', 'A101', 'S999');

-- =======================================================================
-- TEST 4 (NEGATIVE) - UNIQUE constraint violation
-- Setup: tạo chứng chỉ trùng Name với chứng chỉ đã có
-- Expected: ERROR 1062 Duplicate entry 'Starter Badge' for key 'CERTIFICATE.Name'
-- =======================================================================
INSERT INTO CERTIFICATE (CertificateID, Name, BadgeColor, Description)
VALUES ('C999', 'Starter Badge', 'Blue', 'Duplicate certificate name');

-- =======================================================================
-- TEST 5 (NEGATIVE) - Trigger trg_check_meeting_lead
-- Setup: M001 đã có lead là S001 (xem 02_seed_data.sql). Thử thêm 1 lead
--        thứ hai cho cùng buổi học.
-- Expected: ERROR 45000 'Meeting already has a lead instructor'
-- =======================================================================
INSERT INTO MEETING_INSTRUCTOR (MeetingID, StudentID, Role)
VALUES ('M001', 'S004', 'lead');

-- =======================================================================
-- TEST 6 (POSITIVE) - Procedure sp_record_attendance thành công
-- Setup: S008 (vừa tạo ở TEST 1) chưa từng tham dự buổi nào; đồng thời
--        đây cũng là lần gọi CALL đầu tiên cho sp_record_attendance
--        trong toàn bộ pipeline (05_routines.sql chỉ định nghĩa, không
--        tự gọi test, để không làm lệch số liệu của 03_queries.sql)
-- Expected: Query OK, 1 row inserted vào ATTENDANCE
-- =======================================================================
CALL sp_record_attendance('S008', 'M001');
SELECT * FROM ATTENDANCE WHERE StudentID = 'S008';

-- =======================================================================
-- TEST 7 (NEGATIVE) - Procedure sp_record_attendance - student không tồn tại
-- Expected: ERROR 45000 'Student does not exist'
-- =======================================================================
CALL sp_record_attendance('S999', 'M001');

-- =======================================================================
-- TEST 8 (NEGATIVE) - Procedure sp_record_attendance - trùng điểm danh
-- Setup: chạy lại đúng cặp đã ghi ở TEST 6
-- Expected: ERROR 45000 'Attendance already recorded for this student/meeting'
-- =======================================================================
CALL sp_record_attendance('S008', 'M001');

-- =======================================================================
-- TEST 9 (NEGATIVE) - Procedure sp_record_attendance - buổi học đã bị hủy
-- Setup: M009 có MeetingStatus = 'cancelled' (xem 02_seed_data.sql)
-- Expected: ERROR 45000 'Cannot record attendance for a cancelled meeting'
-- =======================================================================
CALL sp_record_attendance('S008', 'M009');

-- =======================================================================
-- TEST 10 (POSITIVE) - Procedure sp_cancel_meeting + rollback dữ liệu liên quan
-- Setup: M003 đang 'scheduled' và có điểm danh (S002,S003,S006,S007)
-- Expected: MeetingStatus -> 'cancelled', bảng ATTENDANCE của M003 rỗng
-- =======================================================================
CALL sp_cancel_meeting('M003');
SELECT MeetingStatus FROM CLASS_MEETING WHERE MeetingID = 'M003';
SELECT * FROM ATTENDANCE WHERE MeetingID = 'M003';  -- Expected: 0 rows

-- =======================================================================
-- TEST 11 (NEGATIVE) - Procedure sp_cancel_meeting - buổi đã completed
-- Setup: M001 có MeetingStatus = 'completed'
-- Expected: ERROR 45000 'Cannot cancel a meeting that already completed'
-- =======================================================================
CALL sp_cancel_meeting('M001');

-- =======================================================================
-- TEST 12 (POSITIVE) - Function fn_student_attendance_count / rate
-- Expected: S002 (tham dự M001,M002,M003,M007,M008,M013,M014,M015 = 8 buổi
--           trước TEST 10; sau khi M003 bị hủy ở TEST 10 còn 7 buổi)
-- =======================================================================
SELECT fn_student_attendance_count('S002') AS attended_count;
SELECT fn_student_attendance_rate('S002')  AS attendance_rate;

-- Function với input không tồn tại -> theo thiết kế trả về NULL
-- (học viên chưa từng tham dự lớp nào nên mẫu số = 0)
SELECT fn_student_attendance_rate('S999') AS attendance_rate_for_unknown;

-- =======================================================================
-- TEST 12b (POSITIVE) - Procedure sp_award_certificate thành công
-- Setup: S008 chưa từng được cấp chứng chỉ C002
-- Expected: 1 dòng mới trong STUDENT_CERTIFICATE + 1 dòng audit tương ứng
-- =======================================================================
CALL sp_award_certificate('S008', 'C002', CURRENT_DATE());
SELECT * FROM STUDENT_CERTIFICATE WHERE StudentID = 'S008';
SELECT * FROM STUDENT_CERTIFICATE_AUDIT WHERE StudentID = 'S008' ORDER BY AuditID;

-- =======================================================================
-- TEST 12c (NEGATIVE) - Procedure sp_award_certificate - cấp trùng
-- Setup: gọi lại đúng cặp (S008, C001) đã có sẵn từ trigger auto-badge ở TEST 1
-- Expected: ERROR 45000 'This certificate has already been awarded to this student'
-- =======================================================================
CALL sp_award_certificate('S008', 'C001', CURRENT_DATE());

-- =======================================================================
-- TEST 12d (NEGATIVE) - Procedure sp_award_certificate - chứng chỉ không tồn tại
-- Expected: ERROR 45000 'Certificate does not exist'
-- =======================================================================
CALL sp_award_certificate('S008', 'C999', CURRENT_DATE());

-- =======================================================================
-- TEST 12e (POSITIVE) - Function fn_class_instructor
-- Expected: 'Nguyễn Văn An' (main instructor của CL001 là S001)
-- =======================================================================
SELECT fn_class_instructor('CL001') AS main_instructor;
SELECT fn_class_instructor('CLXXX') AS unknown_class;  -- Expected: NULL

-- =======================================================================
-- TEST 12f (NEGATIVE) - Trigger trg_bu_prevent_meeting_reactivation
-- Setup: M001 đang ở trạng thái 'completed' (xem 02_seed_data.sql)
-- Expected: ERROR 45000 'Cannot revert a cancelled/completed meeting back to scheduled'
-- =======================================================================
UPDATE CLASS_MEETING SET MeetingStatus = 'scheduled' WHERE MeetingID = 'M001';

-- =======================================================================
-- TEST 12g (POSITIVE) - Trigger trg_bu_prevent_meeting_reactivation không
-- chặn các cập nhật hợp lệ khác (ví dụ scheduled -> completed)
-- Expected: Query OK, 1 row affected
-- =======================================================================
UPDATE CLASS_MEETING SET MeetingStatus = 'completed' WHERE MeetingID = 'M006';
SELECT MeetingStatus FROM CLASS_MEETING WHERE MeetingID = 'M006';

-- =======================================================================
-- TEST 13 (POSITIVE) - Administration: reporting user chỉ đọc được
-- Thực hiện dưới phiên đăng nhập 'center_reporter'@'localhost'
-- (xem 08_admin_backup.md để tạo user trước khi test)
-- =======================================================================
-- mysql -u center_reporter -p brightpath_language_center
-- SELECT * FROM vw_class_schedule;              -- Expected: thành công
-- INSERT INTO STUDENT VALUES ('SX01','X','2000-01-01','2026-01-01');
--                                                -- Expected: ERROR 1142 command denied

-- =======================================================================
-- CLEANUP NOTES
-- =======================================================================
-- - TEST 2, 3, 4, 5, 7, 8, 9, 11, 12c, 12d, 12f CHỦ ĐÍCH gây lỗi và
--   KHÔNG làm thay đổi dữ liệu (do transaction ROLLBACK hoặc bị
--   constraint/trigger chặn trước khi ghi).
-- - TEST 1, 6, 10, 12b, 12g làm thay đổi dữ liệu thật; nếu cần chạy lại
--   toàn bộ 09_tests.sql từ đầu, hãy chạy lại 01_schema.sql +
--   02_seed_data.sql để đưa database về trạng thái sạch trước khi test lại.
-- - Event ev_purge_old_certificate_audit không được kiểm thử bằng cách
--   chờ lịch chạy thật (đang DISABLE); nếu cần test nhanh, có thể tạm
--   thời set STARTS = CURRENT_TIMESTAMP + INTERVAL 1 MINUTE và ENABLE
--   trên môi trường lab cá nhân, sau đó DISABLE/DROP lại.
