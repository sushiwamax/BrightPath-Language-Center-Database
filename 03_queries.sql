-- 03_queries.sql
-- Bộ 8 truy vấn nghiệp vụ (Q01 - Q08)
-- Chạy sau 01_schema.sql, 02_seed_data.sql, 04_views.sql, 05_routines.sql
USE brightpath_language_center;

-- ---------------------------------------------------------------------
-- Q01 - Filter + ORDER BY trên 1 bảng
-- Business question: Trung tâm cần danh sách các lớp học tiếng Anh,
--                     sắp xếp theo giờ bắt đầu để in bảng lịch phòng học.
-- Input: Language = 'English'
-- Expected: các cột ClassID, Level, DayOfWeek, StartTime, Room
-- ---------------------------------------------------------------------
SELECT ClassID, Level, DayOfWeek, StartTime, Room
FROM CLASS
WHERE Language = 'English'
ORDER BY StartTime;

-- ---------------------------------------------------------------------
-- Q02 - INNER JOIN >= 3 bảng
-- Business question: In danh sách điểm danh chi tiết: học viên nào tham
--                     dự buổi học nào của lớp nào, vào ngày nào.
-- SQL technique: INNER JOIN 4 bảng (STUDENT, ATTENDANCE, CLASS_MEETING, CLASS)
-- ---------------------------------------------------------------------
SELECT s.FullName, c.ClassID, c.Language, cm.MeetingID, cm.MeetingDate
FROM ATTENDANCE AS a
INNER JOIN STUDENT AS s        ON s.StudentID = a.StudentID
INNER JOIN CLASS_MEETING AS cm ON cm.MeetingID = a.MeetingID
INNER JOIN CLASS AS c          ON c.ClassID = cm.ClassID
ORDER BY c.ClassID, cm.MeetingDate, s.FullName;

-- ---------------------------------------------------------------------
-- Q03 - LEFT JOIN / tìm dữ liệu thiếu
-- Business question: Buổi học nào chỉ có lead mà CHƯA có assistant hỗ
--                     trợ? (giúp điều phối nhân sự giảng dạy).
-- SQL technique: LEFT JOIN MEETING_INSTRUCTOR (role = assistant) rồi lọc NULL
-- ---------------------------------------------------------------------
SELECT cm.MeetingID, cm.ClassID, cm.MeetingDate
FROM CLASS_MEETING AS cm
LEFT JOIN MEETING_INSTRUCTOR AS mi
       ON mi.MeetingID = cm.MeetingID AND mi.Role = 'assistant'
WHERE mi.MeetingID IS NULL
  AND cm.MeetingStatus <> 'cancelled'
ORDER BY cm.MeetingDate;

-- ---------------------------------------------------------------------
-- Q04 - GROUP BY + HAVING
-- Business question: Những chứng chỉ nào đã được cấp cho từ 3 học viên
--                     trở lên? (đánh giá mức độ phổ biến của chứng chỉ)
-- ---------------------------------------------------------------------
SELECT c.CertificateID, c.Name, COUNT(DISTINCT sc.StudentID) AS student_count
FROM CERTIFICATE AS c
JOIN STUDENT_CERTIFICATE AS sc ON sc.CertificateID = c.CertificateID
GROUP BY c.CertificateID, c.Name
HAVING COUNT(DISTINCT sc.StudentID) >= 3
ORDER BY student_count DESC;

-- ---------------------------------------------------------------------
-- Q05 - Subquery / NOT EXISTS
-- Business question: Học viên nào CHƯA từng tham dự buổi học nào?
--                     (cảnh báo học viên có nguy cơ nghỉ học/rớt lớp)
-- ---------------------------------------------------------------------
SELECT s.StudentID, s.FullName, s.JoinDate
FROM STUDENT AS s
WHERE NOT EXISTS (
    SELECT 1 FROM ATTENDANCE AS a WHERE a.StudentID = s.StudentID
);

-- ---------------------------------------------------------------------
-- Q06 - CTE (Common Table Expression)
-- Business question: Những học viên nào tham dự từ 5 buổi học trở lên?
--                     (ứng viên xét cấp chứng chỉ Beginner - yêu cầu R003)
-- ---------------------------------------------------------------------
WITH attendance_count AS (
    SELECT StudentID, COUNT(*) AS total_attended
    FROM ATTENDANCE
    GROUP BY StudentID
)
SELECT s.StudentID, s.FullName, ac.total_attended
FROM attendance_count AS ac
JOIN STUDENT AS s ON s.StudentID = ac.StudentID
WHERE ac.total_attended >= 5
ORDER BY ac.total_attended DESC;

-- ---------------------------------------------------------------------
-- Q07 - Report theo thời gian / date functions
-- Business question: Mỗi tháng trung tâm tổ chức bao nhiêu buổi học,
--                     phân theo trạng thái (completed/cancelled/scheduled)?
-- ---------------------------------------------------------------------
SELECT DATE_FORMAT(MeetingDate, '%Y-%m') AS meeting_month,
       MeetingStatus,
       COUNT(*) AS meeting_count
FROM CLASS_MEETING
GROUP BY meeting_month, MeetingStatus
ORDER BY meeting_month, MeetingStatus;

-- ---------------------------------------------------------------------
-- Q08 - Query dùng VIEW hoặc FUNCTION
-- Business question: Xem nhanh tỷ lệ chuyên cần của từng học viên bằng
--                     stored function, kết hợp thông tin cơ bản từ STUDENT.
-- SQL technique: gọi fn_student_attendance_rate() trong SELECT
-- ---------------------------------------------------------------------
SELECT s.StudentID,
       s.FullName,
       fn_student_attendance_count(s.StudentID) AS attended_meetings,
       fn_student_attendance_rate(s.StudentID)  AS attendance_rate_percent
FROM STUDENT AS s
ORDER BY attendance_rate_percent DESC;

-- Cách khác cho Q08, dùng VIEW:
-- SELECT * FROM vw_class_schedule ORDER BY meeting_count DESC;
