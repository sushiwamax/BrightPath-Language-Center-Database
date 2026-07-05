-- =====================================================================
-- 05_routines.sql
-- 2 Stored Procedures + 2 Stored Functions
-- Chạy sau 01_schema.sql và 02_seed_data.sql
-- =====================================================================
USE brightpath_language_center;

-- =======================================================================
-- SP01 - sp_record_attendance
-- Nhu cầu nghiệp vụ: chỉ cho điểm danh khi student và meeting tồn tại,
--   buổi học chưa bị hủy, và học viên chưa được điểm danh trước đó.
-- =======================================================================
DELIMITER $$

CREATE PROCEDURE sp_record_attendance(
    IN p_student_id VARCHAR(20),
    IN p_meeting_id VARCHAR(20)
)
BEGIN
    DECLARE v_student_exists   INT DEFAULT 0;
    DECLARE v_meeting_status   VARCHAR(20);
    DECLARE v_already_recorded INT DEFAULT 0;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_student_exists
    FROM STUDENT WHERE StudentID = p_student_id;

    IF v_student_exists = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    SELECT MeetingStatus INTO v_meeting_status
    FROM CLASS_MEETING WHERE MeetingID = p_meeting_id;

    IF v_meeting_status IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Meeting does not exist';
    END IF;

    IF v_meeting_status = 'cancelled' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot record attendance for a cancelled meeting';
    END IF;

    SELECT COUNT(*) INTO v_already_recorded
    FROM ATTENDANCE
    WHERE StudentID = p_student_id AND MeetingID = p_meeting_id;

    IF v_already_recorded > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Attendance already recorded for this student/meeting';
    END IF;

    INSERT INTO ATTENDANCE (StudentID, MeetingID)
    VALUES (p_student_id, p_meeting_id);

    COMMIT;
END $$

DELIMITER ;

-- =======================================================================
-- SP02 - sp_cancel_meeting
-- Nhu cầu nghiệp vụ: hủy một buổi học chưa diễn ra. Khi hủy, mọi điểm
--   danh (nếu có, do nhập nhầm) của buổi đó phải được xóa để tránh dữ
--   liệu mâu thuẫn (buổi bị hủy nhưng vẫn có người "tham dự").
-- =======================================================================
DELIMITER $$

CREATE PROCEDURE sp_cancel_meeting(
    IN p_meeting_id VARCHAR(20)
)
BEGIN
    DECLARE v_status VARCHAR(20);

    START TRANSACTION;

    SELECT MeetingStatus INTO v_status
    FROM CLASS_MEETING WHERE MeetingID = p_meeting_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Meeting does not exist';
    END IF;

    IF v_status = 'completed' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot cancel a meeting that already completed';
    END IF;

    DELETE FROM ATTENDANCE WHERE MeetingID = p_meeting_id;

    UPDATE CLASS_MEETING
    SET MeetingStatus = 'cancelled'
    WHERE MeetingID = p_meeting_id;

    COMMIT;
END $$

DELIMITER ;

-- =======================================================================
-- FN01 - fn_student_attendance_count
-- Trả về tổng số buổi học mà học viên đã tham dự.
-- =======================================================================
DELIMITER $$

CREATE FUNCTION fn_student_attendance_count(p_student_id VARCHAR(20))
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM ATTENDANCE
    WHERE StudentID = p_student_id;

    RETURN v_count;
END $$

DELIMITER ;

-- =======================================================================
-- FN02 - fn_student_attendance_rate
-- Trả về tỷ lệ chuyên cần (%) của học viên: số buổi đã tham dự / tổng
-- số buổi (không tính buổi bị hủy) của các lớp mà học viên từng tham
-- gia ít nhất một buổi. Trả về NULL nếu học viên chưa tham dự lớp nào
-- (tránh chia cho 0).
-- =======================================================================
DELIMITER $$

CREATE FUNCTION fn_student_attendance_rate(p_student_id VARCHAR(20))
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_attended INT DEFAULT 0;
    DECLARE v_total    INT DEFAULT 0;

    SELECT COUNT(*) INTO v_attended
    FROM ATTENDANCE
    WHERE StudentID = p_student_id;

    SELECT COUNT(*) INTO v_total
    FROM CLASS_MEETING cm
    WHERE cm.MeetingStatus <> 'cancelled'
      AND cm.ClassID IN (
          SELECT DISTINCT cm2.ClassID
          FROM ATTENDANCE a2
          JOIN CLASS_MEETING cm2 ON cm2.MeetingID = a2.MeetingID
          WHERE a2.StudentID = p_student_id
      );

    IF v_total = 0 THEN
        RETURN NULL;
    END IF;

    RETURN ROUND(v_attended / v_total * 100, 2);
END $$

DELIMITER ;

-- =======================================================================
-- SP03 - sp_award_certificate
-- Nhu cầu nghiệp vụ: cấp một chứng chỉ cho học viên, chỉ khi học viên
--   và chứng chỉ tồn tại, và học viên CHƯA từng được cấp đúng chứng chỉ
--   này trước đó (mỗi chứng chỉ chỉ cấp một lần cho một học viên).
--   INSERT thành công sẽ tự động kích hoạt trigger audit (Chương 7).
-- =======================================================================
DELIMITER $$

CREATE PROCEDURE sp_award_certificate(
    IN p_student_id    VARCHAR(20),
    IN p_certificate_id VARCHAR(20),
    IN p_award_date    DATE
)
BEGIN
    DECLARE v_student_exists     INT DEFAULT 0;
    DECLARE v_certificate_exists INT DEFAULT 0;
    DECLARE v_already_awarded    INT DEFAULT 0;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_student_exists
    FROM STUDENT WHERE StudentID = p_student_id;

    IF v_student_exists = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    SELECT COUNT(*) INTO v_certificate_exists
    FROM CERTIFICATE WHERE CertificateID = p_certificate_id;

    IF v_certificate_exists = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Certificate does not exist';
    END IF;

    SELECT COUNT(*) INTO v_already_awarded
    FROM STUDENT_CERTIFICATE
    WHERE StudentID = p_student_id AND CertificateID = p_certificate_id;

    IF v_already_awarded > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This certificate has already been awarded to this student';
    END IF;

    INSERT INTO STUDENT_CERTIFICATE (StudentID, CertificateID, AwardDate)
    VALUES (p_student_id, p_certificate_id, p_award_date);

    COMMIT;
END $$

DELIMITER ;

-- =======================================================================
-- FN03 - fn_class_instructor
-- Trả về họ tên instructor phụ trách chính của một lớp học. Trả về
-- NULL nếu ClassID không tồn tại.
-- =======================================================================
DELIMITER $$

CREATE FUNCTION fn_class_instructor(p_class_id VARCHAR(20))
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE v_name VARCHAR(100) DEFAULT NULL;

    SELECT s.FullName INTO v_name
    FROM CLASS c
    JOIN INSTRUCTOR i ON i.StudentID = c.MainInstructorID
    JOIN STUDENT s    ON s.StudentID = i.StudentID
    WHERE c.ClassID = p_class_id;

    RETURN v_name;
END $$

DELIMITER ;

-- =======================================================================
-- Ghi chú về thứ tự chạy và test calls
-- =======================================================================
-- File này CHỈ định nghĩa các routine (CREATE PROCEDURE/FUNCTION).
-- Toàn bộ lời gọi kiểm thử (CALL/SELECT) được đặt tập trung trong
-- 09_tests.sql để tránh việc chạy 03_queries.sql cho ra số liệu khác
-- nhau tùy theo có chạy trước các test call ở đây hay không (một lỗi
-- nhóm từng gặp phải ở phiên bản nháp và đã sửa lại theo nguyên tắc:
-- các file có tiền tố 0X chỉ nên làm đúng một việc).
