DROP DATABASE IF EXISTS brightpath_language_center;

CREATE DATABASE brightpath_language_center
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE brightpath_language_center;

-- ---------------------------------------------------------------------
-- STUDENT
-- ---------------------------------------------------------------------
CREATE TABLE STUDENT (
    StudentID     VARCHAR(20)  PRIMARY KEY,
    FullName      VARCHAR(100) NOT NULL,
    DateOfBirth   DATE,
    JoinDate      DATE         NOT NULL
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- INSTRUCTOR (subtype của STUDENT - Shared Primary Key)
-- ---------------------------------------------------------------------
CREATE TABLE INSTRUCTOR (
    StudentID         VARCHAR(20) PRIMARY KEY,
    SupportStartDate  DATE NOT NULL,
    Status            ENUM('paid', 'volunteer') NOT NULL,
    FOREIGN KEY (StudentID)
        REFERENCES STUDENT(StudentID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- CLASS
-- ---------------------------------------------------------------------
CREATE TABLE CLASS (
    ClassID            VARCHAR(20)  PRIMARY KEY,
    Language           VARCHAR(50)  NOT NULL,
    Level              VARCHAR(50)  NOT NULL,
    DayOfWeek          VARCHAR(10)  NOT NULL,
    StartTime          TIME         NOT NULL,
    Room               VARCHAR(10)  NOT NULL,
    MainInstructorID   VARCHAR(20)  NOT NULL,
    FOREIGN KEY (MainInstructorID)
        REFERENCES INSTRUCTOR(StudentID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- CLASS_MEETING
-- CH01: thêm MeetingStatus để phân biệt buổi học đã diễn ra / bị hủy /
--       chưa diễn ra -> phục vụ báo cáo và ràng buộc nghiệp vụ mới.
-- ---------------------------------------------------------------------
CREATE TABLE CLASS_MEETING (
    MeetingID      VARCHAR(20) PRIMARY KEY,
    ClassID        VARCHAR(20) NOT NULL,
    MeetingDate    DATE        NOT NULL,
    MeetingStatus  ENUM('scheduled', 'completed', 'cancelled')
                       NOT NULL DEFAULT 'scheduled',   -- CH01
    FOREIGN KEY (ClassID)
        REFERENCES CLASS(ClassID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- ATTENDANCE (bảng trung gian N:M STUDENT <-> CLASS_MEETING)
-- ---------------------------------------------------------------------
CREATE TABLE ATTENDANCE (
    StudentID   VARCHAR(20),
    MeetingID   VARCHAR(20),
    PRIMARY KEY (StudentID, MeetingID),
    FOREIGN KEY (StudentID)
        REFERENCES STUDENT(StudentID)
        ON DELETE CASCADE,
    FOREIGN KEY (MeetingID)
        REFERENCES CLASS_MEETING(MeetingID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- MEETING_INSTRUCTOR (bảng trung gian N:M INSTRUCTOR <-> CLASS_MEETING)
-- ---------------------------------------------------------------------
CREATE TABLE MEETING_INSTRUCTOR (
    MeetingID   VARCHAR(20),
    StudentID   VARCHAR(20),
    Role        ENUM('lead', 'assistant') NOT NULL,
    PRIMARY KEY (MeetingID, StudentID),
    FOREIGN KEY (MeetingID)
        REFERENCES CLASS_MEETING(MeetingID)
        ON DELETE CASCADE,
    FOREIGN KEY (StudentID)
        REFERENCES INSTRUCTOR(StudentID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- CERTIFICATE
-- ---------------------------------------------------------------------
CREATE TABLE CERTIFICATE (
    CertificateID  VARCHAR(20)  PRIMARY KEY,
    Name           VARCHAR(100) NOT NULL UNIQUE,
    BadgeColor     VARCHAR(30)  NOT NULL,
    Description    TEXT
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- CERTIFICATE_REQUIREMENT
-- ---------------------------------------------------------------------
CREATE TABLE CERTIFICATE_REQUIREMENT (
    RequirementID           VARCHAR(20) PRIMARY KEY,
    CertificateID           VARCHAR(20) NOT NULL,
    RequirementDescription  TEXT        NOT NULL,
    FOREIGN KEY (CertificateID)
        REFERENCES CERTIFICATE(CertificateID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- STUDENT_CERTIFICATE (bảng trung gian N:M STUDENT <-> CERTIFICATE)
-- ---------------------------------------------------------------------
CREATE TABLE STUDENT_CERTIFICATE (
    StudentID      VARCHAR(20),
    CertificateID  VARCHAR(20),
    AwardDate      DATE NOT NULL,
    PRIMARY KEY (StudentID, CertificateID, AwardDate),
    FOREIGN KEY (StudentID)
        REFERENCES STUDENT(StudentID)
        ON DELETE CASCADE,
    FOREIGN KEY (CertificateID)
        REFERENCES CERTIFICATE(CertificateID)
        ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- STUDENT_CERTIFICATE_AUDIT  (CH02 - bảng mới)
-- Ghi lại lịch sử mỗi lần một chứng chỉ được cấp cho học viên, phục vụ
-- truy vết và đối soát dữ liệu (không cho phép sửa/xóa trực tiếp lịch sử).
-- ---------------------------------------------------------------------
CREATE TABLE STUDENT_CERTIFICATE_AUDIT (
    AuditID        BIGINT AUTO_INCREMENT PRIMARY KEY,
    StudentID      VARCHAR(20)  NOT NULL,
    CertificateID  VARCHAR(20)  NOT NULL,
    AwardDate      DATE         NOT NULL,
    ActionType     VARCHAR(20)  NOT NULL DEFAULT 'AWARDED',
    ChangedBy      VARCHAR(100) NOT NULL,
    ChangedAt      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;
