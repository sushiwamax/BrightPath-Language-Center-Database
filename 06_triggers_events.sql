-- =====================================================================
-- 06_triggers_events.sql
-- 3 Triggers (kế thừa 2 trigger giữa kỳ + audit trigger mới CH02)
-- 1 Event (disabled by default, chỉ minh họa cho môi trường lab)
-- Chạy sau 01_schema.sql, 02_seed_data.sql
-- =====================================================================
USE brightpath_language_center;

-- =======================================================================
-- TRIGGER 1: trg_auto_assign_starter_badge  (kế thừa từ giữa kỳ)
-- Timing/event: AFTER INSERT ON STUDENT
-- Mục đích: mọi học viên mới được tự động cấp "Starter Badge" (C001)
--           ngay ngày gia nhập, tránh phải cấp thủ công.
-- =======================================================================
DELIMITER $$

CREATE TRIGGER trg_auto_assign_starter_badge
AFTER INSERT ON STUDENT
FOR EACH ROW
BEGIN
    INSERT INTO STUDENT_CERTIFICATE (StudentID, CertificateID, AwardDate)
    VALUES (NEW.StudentID, 'C001', NEW.JoinDate);
END $$

DELIMITER ;

-- =======================================================================
-- TRIGGER 2: trg_check_meeting_lead  (kế thừa từ giữa kỳ)
-- Timing/event: BEFORE INSERT ON MEETING_INSTRUCTOR
-- Mục đích: đảm bảo mỗi buổi học chỉ có duy nhất 1 instructor giữ vai
--           trò 'lead'. Nếu vi phạm, INSERT bị từ chối bằng SIGNAL.
-- =======================================================================
DELIMITER $$

CREATE TRIGGER trg_check_meeting_lead
BEFORE INSERT ON MEETING_INSTRUCTOR
FOR EACH ROW
BEGIN
    DECLARE v_lead_count INT DEFAULT 0;

    IF NEW.Role = 'lead' THEN
        SELECT COUNT(*) INTO v_lead_count
        FROM MEETING_INSTRUCTOR
        WHERE MeetingID = NEW.MeetingID AND Role = 'lead';

        IF v_lead_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Meeting already has a lead instructor';
        END IF;
    END IF;
END $$

DELIMITER ;

-- =======================================================================
-- TRIGGER 3: trg_ai_student_certificate_audit  (MỚI - CH02)
-- Timing/event: AFTER INSERT ON STUDENT_CERTIFICATE
-- Mục đích: ghi lại lịch sử mỗi lần cấp chứng chỉ vào bảng audit, phục
--           vụ truy vết (ai/khi nào một chứng chỉ được cấp), vì bảng
--           STUDENT_CERTIFICATE gốc không lưu "ai thực hiện" thao tác.
-- Side effect: chỉ ghi thêm (INSERT), không sửa/xóa dữ liệu nghiệp vụ.
-- =======================================================================
DELIMITER $$

CREATE TRIGGER trg_ai_student_certificate_audit
AFTER INSERT ON STUDENT_CERTIFICATE
FOR EACH ROW
BEGIN
    INSERT INTO STUDENT_CERTIFICATE_AUDIT (
        StudentID, CertificateID, AwardDate, ActionType, ChangedBy
    )
    VALUES (
        NEW.StudentID, NEW.CertificateID, NEW.AwardDate, 'AWARDED', CURRENT_USER()
    );
END $$

DELIMITER ;

-- =======================================================================
-- TRIGGER 4: trg_bu_prevent_meeting_reactivation  (MỚI - bổ sung để đầy
-- đủ hơn, không thuộc change log CH01-CH03 nhưng cùng nhóm nghiệp vụ)
-- Timing/event: BEFORE UPDATE ON CLASS_MEETING
-- Mục đích: 'cancelled' và 'completed' là hai trạng thái kết thúc
--   (terminal state) của một buổi học. Trigger này chặn việc cập nhật
--   MeetingStatus quay ngược lại 'scheduled' từ một trong hai trạng
--   thái trên, tránh sai sót thao tác (ví dụ nhân viên bấm nhầm) làm
--   buổi học đã hủy/đã xong bị "mở lại" một cách không kiểm soát.
-- =======================================================================
DELIMITER $$

CREATE TRIGGER trg_bu_prevent_meeting_reactivation
BEFORE UPDATE ON CLASS_MEETING
FOR EACH ROW
BEGIN
    IF OLD.MeetingStatus IN ('cancelled', 'completed')
       AND NEW.MeetingStatus = 'scheduled' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot revert a cancelled/completed meeting back to scheduled';
    END IF;
END $$

DELIMITER ;
-- Mục đích: dọn dẹp log audit cũ hơn 2 năm để tránh phình bảng theo
--           thời gian. TẠO Ở TRẠNG THÁI DISABLE theo đúng khuyến nghị an
--           toàn cho môi trường lab dùng chung - không tự động chạy.
-- Nếu muốn kích hoạt trong lab cá nhân: ALTER EVENT ev_purge_old_certificate_audit ENABLE;
-- =======================================================================
CREATE EVENT IF NOT EXISTS ev_purge_old_certificate_audit
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
ON COMPLETION PRESERVE
DISABLE
DO
    DELETE FROM STUDENT_CERTIFICATE_AUDIT
    WHERE ChangedAt < CURRENT_TIMESTAMP - INTERVAL 730 DAY;

-- Kiểm tra event đã tạo và đang ở trạng thái DISABLED:
-- SHOW EVENTS FROM brightpath_language_center;
