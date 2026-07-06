USE brightpath_language_center;

-- ---------------------------------------------------------------------
-- STUDENT (8 học viên - S008 dùng để test trigger auto-badge & Q05/NOT EXISTS)
-- ---------------------------------------------------------------------
INSERT INTO STUDENT (StudentID, FullName, DateOfBirth, JoinDate) VALUES
('S001', 'Nguyễn Văn An',    '1995-03-15', '2023-01-10'),
('S002', 'Trần Thị Bình',    '1990-07-22', '2022-05-15'),
('S003', 'Lê Văn Cường',     '2000-11-30', '2023-09-05'),
('S004', 'Phạm Thị Dung',    '1988-02-18', '2021-08-20'),
('S005', 'Hoàng Văn Em',     '1997-09-10', '2024-01-15'),
('S006', 'Ngô Thị Phương',   '1998-06-25', '2023-11-01'),
('S007', 'Đỗ Văn Giang',     '1996-04-12', '2022-09-10');
-- Lưu ý: S008 KHÔNG chèn ở đây - sẽ được chèn trong 09_tests.sql
-- để minh họa trigger trg_auto_assign_starter_badge hoạt động.

-- ---------------------------------------------------------------------
-- INSTRUCTOR (5 instructor, đều là subtype của STUDENT)
-- ---------------------------------------------------------------------
INSERT INTO INSTRUCTOR (StudentID, SupportStartDate, Status) VALUES
('S001', '2023-06-01', 'paid'),
('S002', '2022-10-01', 'volunteer'),
('S003', '2024-01-15', 'paid'),
('S004', '2022-01-10', 'volunteer'),
('S005', '2024-03-01', 'paid');

-- ---------------------------------------------------------------------
-- CLASS
-- ---------------------------------------------------------------------
INSERT INTO CLASS (ClassID, Language, Level, DayOfWeek, StartTime, Room, MainInstructorID) VALUES
('CL001', 'English', 'Intermediate', 'Monday',    '18:00:00', 'A1', 'S001'),
('CL002', 'Korean',  'Beginner',     'Tuesday',   '17:30:00', 'B2', 'S002'),
('CL003', 'Japanese','Advanced',     'Wednesday', '19:00:00', 'C3', 'S003'),
('CL004', 'English', 'Beginner',     'Thursday',  '10:00:00', 'A2', 'S001'),
('CL005', 'Korean',  'Intermediate', 'Friday',    '14:00:00', 'B1', 'S004');

-- ---------------------------------------------------------------------
-- CLASS_MEETING (3 buổi / lớp = 15 buổi, có đủ 3 trạng thái để test CH01)
-- ---------------------------------------------------------------------
INSERT INTO CLASS_MEETING (MeetingID, ClassID, MeetingDate, MeetingStatus) VALUES
('M001', 'CL001', '2026-06-01', 'completed'),
('M002', 'CL001', '2026-06-08', 'completed'),
('M003', 'CL001', '2026-06-15', 'scheduled'),
('M004', 'CL002', '2026-06-02', 'completed'),
('M005', 'CL002', '2026-06-09', 'completed'),
('M006', 'CL002', '2026-06-16', 'scheduled'),
('M007', 'CL003', '2026-06-03', 'completed'),
('M008', 'CL003', '2026-06-10', 'completed'),
('M009', 'CL003', '2026-06-17', 'cancelled'),
('M010', 'CL004', '2026-06-04', 'completed'),
('M011', 'CL004', '2026-06-11', 'completed'),
('M012', 'CL004', '2026-06-18', 'scheduled'),
('M013', 'CL005', '2026-06-05', 'completed'),
('M014', 'CL005', '2026-06-12', 'completed'),
('M015', 'CL005', '2026-06-19', 'scheduled');

-- ---------------------------------------------------------------------
-- MEETING_INSTRUCTOR (mỗi buổi có đúng 1 lead = main instructor của lớp,
-- một số buổi có thêm 1 assistant)
-- ---------------------------------------------------------------------
INSERT INTO MEETING_INSTRUCTOR (MeetingID, StudentID, Role) VALUES
('M001', 'S001', 'lead'), ('M001', 'S002', 'assistant'),
('M002', 'S001', 'lead'),
('M003', 'S001', 'lead'),
('M004', 'S002', 'lead'),
('M005', 'S002', 'lead'), ('M005', 'S004', 'assistant'),
('M006', 'S002', 'lead'),
('M007', 'S003', 'lead'),
('M008', 'S003', 'lead'),
('M009', 'S003', 'lead'),
('M010', 'S001', 'lead'),
('M011', 'S001', 'lead'), ('M011', 'S005', 'assistant'),
('M012', 'S001', 'lead'),
('M013', 'S004', 'lead'),
('M014', 'S004', 'lead'),
('M015', 'S004', 'lead');

-- ---------------------------------------------------------------------
-- ATTENDANCE (48 lượt điểm danh - S008 cố ý KHÔNG có mặt ở đây)
-- ---------------------------------------------------------------------
INSERT INTO ATTENDANCE (StudentID, MeetingID) VALUES
-- CL001: S002, S003, S006, S007
('S002','M001'), ('S003','M001'), ('S006','M001'), ('S007','M001'),
('S002','M002'), ('S003','M002'), ('S006','M002'), ('S007','M002'),
('S002','M003'), ('S003','M003'), ('S006','M003'), ('S007','M003'),
-- CL002: S001, S004, S005, S006
('S001','M004'), ('S004','M004'), ('S005','M004'), ('S006','M004'),
('S001','M005'), ('S004','M005'), ('S005','M005'), ('S006','M005'),
('S001','M006'), ('S004','M006'), ('S005','M006'), ('S006','M006'),
-- CL003: S002, S007
('S002','M007'), ('S007','M007'),
('S002','M008'), ('S007','M008'),
-- (M009 bị hủy - không có điểm danh)
-- CL004: S003, S005, S006, S007 (S006 vắng buổi M012 - tạo ví dụ
-- tỷ lệ chuyên cần thực tế <100% cho fn_student_attendance_rate)
('S003','M010'), ('S005','M010'), ('S006','M010'), ('S007','M010'),
('S003','M011'), ('S005','M011'), ('S006','M011'), ('S007','M011'),
('S003','M012'), ('S005','M012'), ('S007','M012'),
-- CL005: S001, S002
('S001','M013'), ('S002','M013'),
('S001','M014'), ('S002','M014'),
('S001','M015'), ('S002','M015');

-- ---------------------------------------------------------------------
-- CERTIFICATE
-- ---------------------------------------------------------------------
INSERT INTO CERTIFICATE (CertificateID, Name, BadgeColor, Description) VALUES
('C001', 'Starter Badge',      'Grey',     'Chứng chỉ cho học viên mới gia nhập trung tâm'),
('C002', 'Beginner Level 1',   'Green',    'Hiểu biết cơ bản về ngôn ngữ'),
('C003', 'Intermediate Level', 'Blue',     'Có thể giao tiếp về các chủ đề quen thuộc'),
('C004', 'Advanced Level',     'Gold',     'Thành thạo ngôn ngữ'),
('C005', 'Mastery Level',      'Platinum', 'Trình độ gần như người bản xứ');

-- ---------------------------------------------------------------------
-- CERTIFICATE_REQUIREMENT (2 yêu cầu / chứng chỉ)
-- ---------------------------------------------------------------------
INSERT INTO CERTIFICATE_REQUIREMENT (RequirementID, CertificateID, RequirementDescription) VALUES
('R001', 'C001', 'Hoàn thành đăng ký học tại trung tâm'),
('R002', 'C001', 'Tham dự buổi học đầu tiên'),
('R003', 'C002', 'Tham dự tối thiểu 5 buổi học'),
('R004', 'C002', 'Đạt yêu cầu kiểm tra đầu vào cơ bản'),
('R005', 'C003', 'Hoàn thành khóa Beginner'),
('R006', 'C003', 'Tham dự tối thiểu 10 buổi học'),
('R007', 'C004', 'Hoàn thành khóa Intermediate'),
('R008', 'C004', 'Đạt tỷ lệ chuyên cần trên 80%'),
('R009', 'C005', 'Hoàn thành khóa Advanced'),
('R010', 'C005', 'Được instructor đề xuất');

-- ---------------------------------------------------------------------
-- STUDENT_CERTIFICATE (16 lượt cấp chứng chỉ)
-- ---------------------------------------------------------------------
INSERT INTO STUDENT_CERTIFICATE (StudentID, CertificateID, AwardDate) VALUES
('S001','C001','2023-01-10'), ('S002','C001','2022-05-15'),
('S003','C001','2023-09-05'), ('S004','C001','2021-08-20'),
('S005','C001','2024-01-15'), ('S006','C001','2023-11-01'),
('S007','C001','2022-09-10'),
('S001','C002','2023-04-01'), ('S001','C003','2024-02-01'),
('S002','C002','2022-08-01'),
('S003','C002','2023-12-01'), ('S003','C003','2024-06-01'), ('S003','C004','2025-05-01'),
('S004','C002','2021-12-01'),
('S005','C002','2024-05-01'), ('S005','C003','2025-01-01');
