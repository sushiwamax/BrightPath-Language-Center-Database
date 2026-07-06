USE brightpath_language_center;

-- ---------------------------------------------------------------------
-- VIEW 1: vw_class_schedule
-- Audience: nhân viên vận hành / lễ tân cần xem lịch lớp học kèm
--           instructor phụ trách và số buổi đã tổ chức.
-- Base tables: CLASS, INSTRUCTOR, STUDENT, CLASS_MEETING
-- Aggregation: COUNT(meeting) theo từng lớp
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_class_schedule AS
SELECT
    c.ClassID,
    c.Language,
    c.Level,
    c.DayOfWeek,
    c.StartTime,
    c.Room,
    s.FullName AS main_instructor_name,
    COUNT(cm.MeetingID) AS meeting_count,
    SUM(CASE WHEN cm.MeetingStatus = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN cm.MeetingStatus = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count
FROM CLASS AS c
JOIN INSTRUCTOR AS i ON i.StudentID = c.MainInstructorID
JOIN STUDENT AS s    ON s.StudentID = i.StudentID
LEFT JOIN CLASS_MEETING AS cm ON cm.ClassID = c.ClassID
GROUP BY c.ClassID, c.Language, c.Level, c.DayOfWeek, c.StartTime, c.Room, s.FullName;

-- Test:
SELECT * FROM vw_class_schedule ORDER BY meeting_count DESC;

-- ---------------------------------------------------------------------
-- VIEW 2: vw_student_certificate_progress
-- Audience: học vụ / phụ huynh cần xem tiến độ chứng chỉ của học viên.
-- Base tables: STUDENT, STUDENT_CERTIFICATE, CERTIFICATE
-- Derived calculation: tổng số chứng chỉ + chứng chỉ gần nhất
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_student_certificate_progress AS
SELECT
    s.StudentID,
    s.FullName,
    COUNT(sc.CertificateID) AS total_certificates,
    (
        SELECT c2.Name
        FROM STUDENT_CERTIFICATE sc2
        JOIN CERTIFICATE c2 ON c2.CertificateID = sc2.CertificateID
        WHERE sc2.StudentID = s.StudentID
        ORDER BY sc2.AwardDate DESC
        LIMIT 1
    ) AS latest_certificate_name,
    MAX(sc.AwardDate) AS latest_award_date
FROM STUDENT AS s
LEFT JOIN STUDENT_CERTIFICATE AS sc ON sc.StudentID = s.StudentID
GROUP BY s.StudentID, s.FullName;

-- Test:
SELECT * FROM vw_student_certificate_progress
ORDER BY total_certificates DESC, latest_award_date DESC;
