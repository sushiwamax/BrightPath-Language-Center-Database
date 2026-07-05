# NỘI DUNG BÁO CÁO CUỐI KÌ - CƠ SỞ DỮ LIỆU
## BrightPath Language Center — Bản đầy đủ (v2)

**Trường Đại học Quốc tế - Đại học Quốc gia Hà Nội — Khoa Công nghệ thông tin**
**Giảng viên hướng dẫn:** Vũ Đức Minh
**Sinh viên thực hiện:**

| Họ tên | MSSV |
|---|---|
| Đoàn Việt Anh | 24070501 |
| Nguyễn Hải Anh | 24070451 |
| Nguyễn Duy Khánh | 24070348 |
| Bùi Thanh Long | 24070377 |

**Lớp:** ISV201603

> Tài liệu này viết theo văn phong báo cáo học thuật, có thể dán trực
> tiếp vào Word/LaTeX. Các vị trí cần chèn ảnh chụp màn hình thật từ
> MySQL Workbench được đánh dấu **[ẢNH CHỤP]**. Mọi số liệu "kết quả kỳ
> vọng" trong tài liệu đã được nhóm **tính tay cẩn thận dựa trên đúng
> dữ liệu mẫu trong `02_seed_data.sql` và đúng thứ tự chạy trong
> `README.md`**; khi chạy thật, số liệu trên máy phải khớp với các con
> số này — nếu lệch, đó là dấu hiệu cần kiểm tra lại thao tác chạy.

---

# LỜI SỬA ĐỔI SO VỚI BÁO CÁO GIỮA KỲ

Trước khi trình bày nội dung chính, nhóm liệt kê các lỗi đã phát hiện ở
bản giữa kỳ và cách khắc phục trong bản cuối kỳ này, theo đúng tinh
thần "một khi phát hiện thiết kế/tài liệu có sai sót, phải sửa và ghi
nhận lại, không lặp lại lỗi sang bản sau."

**Bảng 0.1 — Lỗi phát hiện ở bản giữa kỳ và cách khắc phục**

| # | Lỗi ở bản giữa kỳ | Khắc phục ở bản cuối kỳ |
|---|---|---|
| 1 | Trang bìa ghi MSSV của bạn Bùi Thanh Long là `240770377` (9 chữ số), trong khi 3 thành viên còn lại đều có MSSV 8 chữ số (`24070501`, `24070451`, `24070348`) | Chuẩn hóa lại thành `24070377` (8 chữ số, đúng định dạng MSSV của trường) trong trang bìa và danh sách thành viên ở đầu tài liệu này |
| 2 | Phụ lục A ("FULL SQL SCRIPT") của báo cáo giữa kỳ, tại các mục A.3–A.6, bị dán nhầm một đoạn **code Python** (các hàm `check_sender`, `check_urls`, `check_content`, `analyze_email` — vốn là code phát hiện email lừa đảo/phishing, không liên quan gì đến đồ án cơ sở dữ liệu) thay vì nội dung SQL thật sự của Trigger/View/Stored Procedure/Function như tiêu đề mục đã ghi | Ở bản cuối kỳ, toàn bộ SQL được tách thành 9 file riêng biệt, có thể chạy trực tiếp (`01_schema.sql` → `09_tests.sql`), không còn phụ lục dạng dán code lẫn lộn; nhóm cũng rà lại toàn bộ để đảm bảo không còn đoạn code ngôn ngữ khác lẫn vào các listing SQL |
| 3 | Mục lục báo cáo giữa kỳ đánh số "5.5 Kiểm tra chuẩn 3NF" nhưng phần thân bài đôi chỗ hiển thị lệch một bậc so với mục lục (dấu hiệu mục lục được gõ tay thay vì sinh tự động) | Bản cuối kỳ khuyến nghị dùng chức năng Table of Contents tự động của Word/LaTeX (`\tableofcontents` hoặc Word References → Table of Contents) thay vì gõ tay, để mục lục luôn khớp với số chương/mục thật |
| 4 | Dữ liệu mẫu bảng ATTENDANCE ở bản nháp đầu tiên của cuối kỳ khiến **mọi học viên đều đạt đúng 100% tỷ lệ chuyên cần** (vì mỗi học viên luôn tham dự đủ mọi buổi của lớp mình từng tham gia) — không minh họa được ý nghĩa thực sự của hàm `fn_student_attendance_rate` | Đã chỉnh lại dữ liệu mẫu (bớt một lượt điểm danh của học viên S006 tại buổi M012) để có ít nhất một học viên đạt tỷ lệ chuyên cần khác 100%, giúp phần trình bày ở Chương 7 có ý nghĩa minh họa thực tế hơn |

Ngoài 4 điểm trên, phần thiết kế cốt lõi của giữa kỳ (34 business rules
BR01–BR34, 9 thực thể, mô hình quan hệ, chứng minh 3NF) được xác nhận là
**đúng** và được giữ nguyên làm nền tảng cho bản cuối kỳ.

---

# Chương 1. Giới thiệu bài toán và phạm vi (bản tổng hợp, tự thân)

## 1.1 Bối cảnh

BrightPath Language Center là một trung tâm ngoại ngữ cung cấp các khóa
học cho nhiều ngôn ngữ và trình độ khác nhau. Trung tâm cần một hệ
thống cơ sở dữ liệu quan hệ để quản lý toàn bộ vòng đời hoạt động dạy
và học: từ lúc học viên gia nhập, được xếp vào lớp, tham dự từng buổi
học cụ thể, được điểm danh, cho đến khi đạt các mốc năng lực được ghi
nhận bằng chứng chỉ nội bộ. Trung tâm cũng có một lực lượng "instructor"
— là chính các học viên hoặc cựu học viên tham gia hỗ trợ giảng dạy —
nên hệ thống cần mô hình hóa đúng quan hệ subtype/supertype giữa học
viên và instructor.

## 1.2 Mục tiêu của hệ thống

- Quản lý thông tin học viên (mã, họ tên, ngày sinh, ngày gia nhập).
- Quản lý đội ngũ instructor và loại hình hỗ trợ (paid/volunteer).
- Quản lý lớp học (ngôn ngữ, trình độ, lịch học, phòng học, instructor
  phụ trách chính).
- Quản lý từng buổi học cụ thể của mỗi lớp, bao gồm cả trạng thái vận
  hành của buổi học (mới bổ sung ở cuối kỳ — xem CH01).
- Quản lý điểm danh học viên theo từng buổi học.
- Quản lý instructor tham gia hỗ trợ từng buổi học và vai trò
  (lead/assistant).
- Quản lý hệ thống chứng chỉ nội bộ, yêu cầu đạt chứng chỉ, và lịch sử
  cấp chứng chỉ cho học viên, kèm nhật ký truy vết (mới bổ sung ở cuối
  kỳ — xem CH02).
- Đảm bảo toàn vẹn dữ liệu bằng các ràng buộc CSDL (PK/FK/UNIQUE/ENUM),
  và tự động hóa một số quy trình nghiệp vụ bằng trigger.
- Cung cấp khả năng khai thác dữ liệu qua truy vấn, view, stored
  procedure/function phục vụ vận hành và báo cáo thực tế (nội dung
  trọng tâm của bản cuối kỳ).

## 1.3 Phạm vi và ngoài phạm vi

Phạm vi hệ thống: quản lý học viên, instructor, lớp học, buổi học, điểm
danh, chứng chỉ nội bộ — như liệt kê ở mục 1.2.

Ngoài phạm vi (giữ nguyên như giữa kỳ, không mở rộng thêm ở cuối kỳ):
quản lý học phí/thanh toán, quản lý điểm số/bài kiểm tra, quản lý tài
liệu học tập, quản lý lịch nghỉ/đổi lịch học, quản lý tài khoản đăng
nhập của người dùng cuối (khác với tài khoản MySQL phục vụ quản trị ở
Chương 10), quản lý thông báo/giao tiếp, và xây dựng giao diện web/di
động.

## 1.4 Giả định

- Mỗi học viên có duy nhất một mã học viên (`StudentID`).
- Mỗi lớp học có đúng một instructor phụ trách chính (`MainInstructorID`).
- Một instructor có thể phụ trách nhiều lớp học khác nhau.
- Một lớp học có thể có nhiều buổi học; một buổi học chỉ thuộc một lớp.
- Một học viên có thể tham dự nhiều buổi học; một buổi học có thể có
  nhiều học viên tham dự.
- Một học viên có thể đạt nhiều chứng chỉ khác nhau; một chứng chỉ có
  thể được trao cho nhiều học viên, nhưng — theo ràng buộc nghiệp vụ bổ
  sung ở `sp_award_certificate` (Chương 8) — **mỗi chứng chỉ chỉ được
  trao một lần cho một học viên**.
- Ngày tháng lưu theo chuẩn quốc tế `YYYY-MM-DD`.
- **(Mới)** Mỗi buổi học luôn ở một trong ba trạng thái: `scheduled`
  (chưa diễn ra), `completed` (đã diễn ra), `cancelled` (đã hủy); hai
  trạng thái sau là trạng thái kết thúc (terminal), không thể quay
  ngược lại `scheduled`.

## 1.5 Danh sách quy tắc nghiệp vụ (Business Rules) — bản đầy đủ BR01–BR36

Nhóm quy tắc liên quan đến học viên: **BR01** Mỗi học viên phải có một
mã học viên duy nhất. **BR02** Hệ thống phải lưu trữ họ tên của học
viên. **BR03** Hệ thống lưu ngày sinh của học viên. **BR04** Hệ thống
lưu ngày tham gia trung tâm của học viên.

Nhóm quy tắc liên quan đến instructor: **BR05** Mọi instructor đều phải
là học viên hoặc cựu học viên của trung tâm. **BR06** Không phải mọi
học viên đều là instructor. **BR07** Hệ thống lưu ngày bắt đầu tham gia
giảng dạy của instructor. **BR08** Instructor chỉ có thể thuộc một
trong hai loại: Paid hoặc Volunteer.

Nhóm quy tắc liên quan đến lớp học: **BR09** Mỗi lớp học có một mã lớp
duy nhất. **BR10** Mỗi lớp học chỉ thuộc một ngôn ngữ. **BR11** Mỗi lớp
học chỉ thuộc một trình độ. **BR12** Mỗi lớp học có một ngày học cố
định trong tuần. **BR13** Mỗi lớp học có một thời gian bắt đầu cố định.
**BR14** Mỗi lớp học được tổ chức tại một phòng học xác định. **BR15**
Mỗi lớp học có đúng một instructor phụ trách chính.

Nhóm quy tắc liên quan đến buổi học: **BR16** Một lớp học có thể có
nhiều buổi học. **BR17** Mỗi buổi học chỉ thuộc về một lớp học. **BR18**
Mỗi buổi học phải có ngày diễn ra cụ thể. **BR35 (mới, CH01)** Mỗi buổi
học có đúng một trạng thái vận hành trong tập
`{scheduled, completed, cancelled}`, mặc định là `scheduled`; trạng
thái `cancelled` và `completed` là trạng thái kết thúc, không được cập
nhật ngược lại thành `scheduled`.

Nhóm quy tắc liên quan đến điểm danh: **BR19** Một học viên có thể tham
dự nhiều buổi học. **BR20** Một buổi học có thể có nhiều học viên tham
dự. **BR21** Hệ thống cần lưu lịch sử tham dự của học viên.

Nhóm quy tắc liên quan đến instructor trong buổi học: **BR22** Một buổi
học phải có ít nhất một instructor tham gia hỗ trợ. **BR23** Một
instructor có thể tham gia nhiều buổi học khác nhau. **BR24** Một buổi
học có thể có nhiều instructor. **BR25** Trong mỗi buổi học cần xác
định vai trò của instructor: Lead hoặc Assistant, và **mỗi buổi học chỉ
có đúng một Lead**.

Nhóm quy tắc liên quan đến chứng chỉ: **BR26** Mỗi chứng chỉ có mã
chứng chỉ duy nhất. **BR27** Mỗi chứng chỉ có tên duy nhất. **BR28** Hệ
thống lưu màu huy hiệu của chứng chỉ. **BR29** Hệ thống lưu mô tả của
chứng chỉ. **BR30** Một chứng chỉ có thể có nhiều yêu cầu. **BR31** Một
yêu cầu chỉ thuộc về một chứng chỉ.

Nhóm quy tắc liên quan đến lịch sử chứng chỉ: **BR32** Một học viên có
thể nhận nhiều chứng chỉ khác nhau (nhưng mỗi loại chứng chỉ chỉ một
lần — xem ràng buộc mới ở `sp_award_certificate`). **BR33** Một chứng
chỉ có thể được trao cho nhiều học viên. **BR34** Hệ thống phải lưu
ngày trao chứng chỉ.

Nhóm quy tắc mới bổ sung ở cuối kỳ: **BR35** (đã nêu ở trên, thuộc
CH01). **BR36 (mới, CH02)** Mọi lần một chứng chỉ được cấp cho học viên
(dù qua trigger tự động hay qua `sp_award_certificate`) đều phải được
ghi lại vào nhật ký `STUDENT_CERTIFICATE_AUDIT`, gồm tối thiểu: học
viên, chứng chỉ, ngày cấp, loại thao tác, người/tài khoản thực hiện,
thời điểm ghi log.

---

# Chương 2. ERD, mô hình quan hệ và chuẩn hóa (bản đầy đủ, final)

## 2.1 Danh sách thực thể

Hệ thống có **10 bảng quan hệ**: 9 bảng nghiệp vụ giữ nguyên từ giữa kỳ
(STUDENT, INSTRUCTOR, CLASS, CLASS_MEETING, ATTENDANCE,
MEETING_INSTRUCTOR, CERTIFICATE, CERTIFICATE_REQUIREMENT,
STUDENT_CERTIFICATE) và 1 bảng nhật ký mới (STUDENT_CERTIFICATE_AUDIT).

## 2.2 Bảng thuộc tính đầy đủ của từng thực thể

**Bảng 2.1 — STUDENT**

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| StudentID | VARCHAR(20) | PK | Mã học viên |
| FullName | VARCHAR(100) | NOT NULL | Họ tên học viên |
| DateOfBirth | DATE | — | Ngày sinh |
| JoinDate | DATE | NOT NULL | Ngày tham gia trung tâm |

**Bảng 2.2 — INSTRUCTOR** (subtype của STUDENT, Shared Primary Key)

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| StudentID | VARCHAR(20) | PK, FK → STUDENT | Mã instructor |
| SupportStartDate | DATE | NOT NULL | Ngày bắt đầu hỗ trợ giảng dạy |
| Status | ENUM('paid','volunteer') | NOT NULL | Trạng thái hỗ trợ |

**Bảng 2.3 — CLASS**

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| ClassID | VARCHAR(20) | PK | Mã lớp |
| Language | VARCHAR(50) | NOT NULL | Ngôn ngữ giảng dạy |
| Level | VARCHAR(50) | NOT NULL | Trình độ |
| DayOfWeek | VARCHAR(10) | NOT NULL | Ngày học trong tuần |
| StartTime | TIME | NOT NULL | Giờ bắt đầu |
| Room | VARCHAR(10) | NOT NULL | Phòng học |
| MainInstructorID | VARCHAR(20) | NOT NULL, FK → INSTRUCTOR | Instructor phụ trách chính |

**Bảng 2.4 — CLASS_MEETING** (có thay đổi CH01)

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| MeetingID | VARCHAR(20) | PK | Mã buổi học |
| ClassID | VARCHAR(20) | NOT NULL, FK → CLASS | Lớp tương ứng |
| MeetingDate | DATE | NOT NULL | Ngày diễn ra |
| **MeetingStatus** | **ENUM('scheduled','completed','cancelled')** | **NOT NULL, DEFAULT 'scheduled'** | **(Mới — CH01) Trạng thái vận hành** |

**Bảng 2.5 — ATTENDANCE** (bảng trung gian N:M)

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| StudentID | VARCHAR(20) | PK, FK → STUDENT | Học viên tham dự |
| MeetingID | VARCHAR(20) | PK, FK → CLASS_MEETING | Buổi học tham dự |

**Bảng 2.6 — MEETING_INSTRUCTOR** (bảng trung gian N:M)

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| MeetingID | VARCHAR(20) | PK, FK → CLASS_MEETING | Buổi học |
| StudentID | VARCHAR(20) | PK, FK → INSTRUCTOR | Instructor tham gia |
| Role | ENUM('lead','assistant') | NOT NULL | Vai trò trong buổi học |

**Bảng 2.7 — CERTIFICATE**

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| CertificateID | VARCHAR(20) | PK | Mã chứng chỉ |
| Name | VARCHAR(100) | NOT NULL, UNIQUE | Tên chứng chỉ |
| BadgeColor | VARCHAR(30) | NOT NULL | Màu huy hiệu |
| Description | TEXT | — | Mô tả chứng chỉ |

**Bảng 2.8 — CERTIFICATE_REQUIREMENT**

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| RequirementID | VARCHAR(20) | PK | Mã yêu cầu |
| CertificateID | VARCHAR(20) | NOT NULL, FK → CERTIFICATE | Chứng chỉ tương ứng |
| RequirementDescription | TEXT | NOT NULL | Nội dung yêu cầu |

**Bảng 2.9 — STUDENT_CERTIFICATE** (bảng trung gian N:M)

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| StudentID | VARCHAR(20) | PK, FK → STUDENT | Học viên |
| CertificateID | VARCHAR(20) | PK, FK → CERTIFICATE | Chứng chỉ |
| AwardDate | DATE | PK, NOT NULL | Ngày cấp |

**Bảng 2.10 — STUDENT_CERTIFICATE_AUDIT** (bảng nhật ký, mới — CH02)

| Thuộc tính | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| AuditID | BIGINT | PK, AUTO_INCREMENT | Số thứ tự log |
| StudentID | VARCHAR(20) | NOT NULL | Học viên được cấp |
| CertificateID | VARCHAR(20) | NOT NULL | Chứng chỉ được cấp |
| AwardDate | DATE | NOT NULL | Ngày cấp (sao chép) |
| ActionType | VARCHAR(20) | NOT NULL, DEFAULT 'AWARDED' | Loại thao tác |
| ChangedBy | VARCHAR(100) | NOT NULL | `CURRENT_USER()` |
| ChangedAt | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Thời điểm ghi log |

*Bảng này cố ý không đặt FK cứng tới `STUDENT_CERTIFICATE`, vì mục đích
của nhật ký là lưu vết độc lập — kể cả khi dữ liệu nghiệp vụ gốc có thể
bị dọn dẹp/lưu trữ (archive) sau này, log vẫn còn nguyên vẹn.*

## 2.3 Mối quan hệ giữa các thực thể (không đổi so với giữa kỳ)

- STUDENT — INSTRUCTOR: 1-1 tùy chọn (instructor bắt buộc là student,
  student không bắt buộc là instructor).
- INSTRUCTOR — CLASS: 1-N (một instructor phụ trách nhiều lớp, một lớp
  chỉ có một main instructor).
- CLASS — CLASS_MEETING: 1-N.
- STUDENT — ATTENDANCE — CLASS_MEETING: N-M qua bảng trung gian.
- INSTRUCTOR — MEETING_INSTRUCTOR — CLASS_MEETING: N-M qua bảng trung
  gian, có thuộc tính `Role`.
- CERTIFICATE — CERTIFICATE_REQUIREMENT: 1-N.
- STUDENT — STUDENT_CERTIFICATE — CERTIFICATE: N-M qua bảng trung gian,
  có thuộc tính `AwardDate`.

## 2.4 Phụ thuộc hàm và chứng minh chuẩn hóa 3NF

```
STUDENT:                  StudentID -> FullName, DateOfBirth, JoinDate
INSTRUCTOR:                StudentID -> SupportStartDate, Status
CLASS:                     ClassID -> Language, Level, DayOfWeek,
                                       StartTime, Room, MainInstructorID
CLASS_MEETING:              MeetingID -> ClassID, MeetingDate, MeetingStatus
ATTENDANCE:                (StudentID, MeetingID) -> {}            (khóa ghép, không dư thừa)
MEETING_INSTRUCTOR:        (MeetingID, StudentID) -> Role
CERTIFICATE:                CertificateID -> Name, BadgeColor, Description
                            Name -> CertificateID, BadgeColor, Description (UNIQUE)
CERTIFICATE_REQUIREMENT:   RequirementID -> CertificateID, RequirementDescription
STUDENT_CERTIFICATE:       (StudentID, CertificateID, AwardDate) -> {}
STUDENT_CERTIFICATE_AUDIT: AuditID -> StudentID, CertificateID, AwardDate,
                                       ActionType, ChangedBy, ChangedAt
```

**1NF:** mọi thuộc tính đều nguyên tố, không có nhóm lặp/mảng, mọi bảng
có khóa chính xác định duy nhất bản ghi → toàn bộ 10 bảng đạt 1NF.

**2NF:** các bảng khóa đơn tự động thỏa 2NF. Với các bảng khóa ghép
(ATTENDANCE, MEETING_INSTRUCTOR, STUDENT_CERTIFICATE): `Role` trong
MEETING_INSTRUCTOR phụ thuộc đầy đủ vào cả cặp (MeetingID, StudentID),
không phụ thuộc bộ phận; hai bảng còn lại không có thuộc tính không
khóa nào ngoài khóa → toàn bộ đạt 2NF.

**3NF:** không tồn tại phụ thuộc bắc cầu trong bất kỳ bảng nào — ví dụ
trong CLASS, `ClassID → MainInstructorID` nhưng không tồn tại
`MainInstructorID → Room`; trong STUDENT_CERTIFICATE_AUDIT,
`AuditID → ChangedBy` là phụ thuộc trực tiếp, không có thuộc tính không
khóa nào quyết định thuộc tính không khóa khác → toàn bộ 10 bảng đạt
3NF.

---

# Chương 3. Triển khai schema và dữ liệu mẫu (đầy đủ)

## 3.1 Toàn bộ script `CREATE TABLE` (file `01_schema.sql`)

```sql
DROP DATABASE IF EXISTS brightpath_language_center;

CREATE DATABASE brightpath_language_center
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE brightpath_language_center;

CREATE TABLE STUDENT (
    StudentID     VARCHAR(20)  PRIMARY KEY,
    FullName      VARCHAR(100) NOT NULL,
    DateOfBirth   DATE,
    JoinDate      DATE         NOT NULL
) ENGINE = InnoDB;

CREATE TABLE INSTRUCTOR (
    StudentID         VARCHAR(20) PRIMARY KEY,
    SupportStartDate  DATE NOT NULL,
    Status            ENUM('paid', 'volunteer') NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE CLASS (
    ClassID            VARCHAR(20)  PRIMARY KEY,
    Language           VARCHAR(50)  NOT NULL,
    Level              VARCHAR(50)  NOT NULL,
    DayOfWeek          VARCHAR(10)  NOT NULL,
    StartTime          TIME         NOT NULL,
    Room               VARCHAR(10)  NOT NULL,
    MainInstructorID   VARCHAR(20)  NOT NULL,
    FOREIGN KEY (MainInstructorID) REFERENCES INSTRUCTOR(StudentID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE CLASS_MEETING (
    MeetingID      VARCHAR(20) PRIMARY KEY,
    ClassID        VARCHAR(20) NOT NULL,
    MeetingDate    DATE        NOT NULL,
    MeetingStatus  ENUM('scheduled', 'completed', 'cancelled')
                       NOT NULL DEFAULT 'scheduled',
    FOREIGN KEY (ClassID) REFERENCES CLASS(ClassID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE ATTENDANCE (
    StudentID   VARCHAR(20),
    MeetingID   VARCHAR(20),
    PRIMARY KEY (StudentID, MeetingID),
    FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (MeetingID) REFERENCES CLASS_MEETING(MeetingID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE MEETING_INSTRUCTOR (
    MeetingID   VARCHAR(20),
    StudentID   VARCHAR(20),
    Role        ENUM('lead', 'assistant') NOT NULL,
    PRIMARY KEY (MeetingID, StudentID),
    FOREIGN KEY (MeetingID) REFERENCES CLASS_MEETING(MeetingID) ON DELETE CASCADE,
    FOREIGN KEY (StudentID) REFERENCES INSTRUCTOR(StudentID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE CERTIFICATE (
    CertificateID  VARCHAR(20)  PRIMARY KEY,
    Name           VARCHAR(100) NOT NULL UNIQUE,
    BadgeColor     VARCHAR(30)  NOT NULL,
    Description    TEXT
) ENGINE = InnoDB;

CREATE TABLE CERTIFICATE_REQUIREMENT (
    RequirementID           VARCHAR(20) PRIMARY KEY,
    CertificateID           VARCHAR(20) NOT NULL,
    RequirementDescription  TEXT        NOT NULL,
    FOREIGN KEY (CertificateID) REFERENCES CERTIFICATE(CertificateID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE STUDENT_CERTIFICATE (
    StudentID      VARCHAR(20),
    CertificateID  VARCHAR(20),
    AwardDate      DATE NOT NULL,
    PRIMARY KEY (StudentID, CertificateID, AwardDate),
    FOREIGN KEY (StudentID) REFERENCES STUDENT(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (CertificateID) REFERENCES CERTIFICATE(CertificateID) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE STUDENT_CERTIFICATE_AUDIT (
    AuditID        BIGINT AUTO_INCREMENT PRIMARY KEY,
    StudentID      VARCHAR(20)  NOT NULL,
    CertificateID  VARCHAR(20)  NOT NULL,
    AwardDate      DATE         NOT NULL,
    ActionType     VARCHAR(20)  NOT NULL DEFAULT 'AWARDED',
    ChangedBy      VARCHAR(100) NOT NULL,
    ChangedAt      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;
```

**Vì sao dùng InnoDB / utf8mb4:** `InnoDB` là storage engine duy nhất
của MySQL hỗ trợ đầy đủ ràng buộc khóa ngoại và transaction (bắt buộc
cho các stored procedure ở Chương 8 dùng `START TRANSACTION`/`COMMIT`/
`ROLLBACK`); `utf8mb4`/`utf8mb4_unicode_ci` đảm bảo lưu trữ và so sánh
chính xác tiếng Việt có dấu (họ tên học viên, mô tả chứng chỉ...).

## 3.2 Dữ liệu mẫu — mô tả chi tiết (file `02_seed_data.sql`)

**Bảng 3.1 — Quy mô dữ liệu mẫu (bản đã sửa lỗi, xem mục "Lời sửa đổi")**

| Loại dữ liệu | Số lượng | Ghi chú |
|---|---|---|
| Học viên (khi seed xong) | 7 (S001–S007) | S008 được thêm sau, ở `09_tests.sql`, để minh họa trigger |
| Instructor | 5 | S001 (paid), S002 (volunteer), S003 (paid), S004 (volunteer), S005 (paid) |
| Lớp học | 5 | CL001 Anh-Trung cấp, CL002 Hàn-Sơ cấp, CL003 Nhật-Nâng cao, CL004 Anh-Sơ cấp, CL005 Hàn-Trung cấp |
| Buổi học | 15 | 10 `completed`, 1 `cancelled` (M009), 4 `scheduled` |
| Lượt điểm danh | **45** | Xem chi tiết theo lớp bên dưới |
| Chứng chỉ | 5 | Starter (C001), Beginner (C002), Intermediate (C003), Advanced (C004), Mastery (C005) |
| Yêu cầu chứng chỉ | 10 | 2 yêu cầu / chứng chỉ |
| Lượt cấp chứng chỉ | 16 | Xem chi tiết theo học viên bên dưới |

**Bảng 3.2 — Điểm danh theo lớp (45 dòng)**

| Lớp | Học viên tham dự | Số buổi/HV | Tổng dòng |
|---|---|---|---|
| CL001 | S002, S003, S006, S007 | 3/3 mỗi người | 12 |
| CL002 | S001, S004, S005, S006 | 3/3 mỗi người | 12 |
| CL003 | S002, S007 | 2/2 (M009 hủy, không điểm danh) | 4 |
| CL004 | S003, S005, S007 (3/3); **S006 (2/3 — vắng M012)** | — | 11 |
| CL005 | S001, S002 | 3/3 mỗi người | 6 |
| **Tổng** | | | **45** |

**Bảng 3.3 — Tổng số buổi đã tham dự theo từng học viên**

| Học viên | Số buổi đã tham dự |
|---|---|
| S001 | 6 |
| S002 | 8 |
| S003 | 6 |
| S004 | 3 |
| S005 | 6 |
| S006 | 8 (đã trừ 1 buổi vắng ở CL004) |
| S007 | 8 |

**Bảng 3.4 — Lượt cấp chứng chỉ theo học viên (16 dòng)**

| Học viên | Chứng chỉ đã đạt |
|---|---|
| S001 | C001, C002, C003 |
| S002 | C001, C002 |
| S003 | C001, C002, C003, C004 |
| S004 | C001, C002 |
| S005 | C001, C002, C003 |
| S006 | C001 |
| S007 | C001 |

*(Chèn [ẢNH CHỤP] `SELECT COUNT(*) FROM ...` cho từng bảng sau khi nạp
`02_seed_data.sql`, đối chiếu đúng các con số ở Bảng 3.1)*

## 3.3 Ghi chú quan trọng về thứ tự chạy trigger và dữ liệu mẫu

`06_triggers_events.sql` (chứa `trg_auto_assign_starter_badge` và
`trg_ai_student_certificate_audit`) được chạy **sau** `02_seed_data.sql`
theo đúng thứ tự trong `README.md`. Điều này có nghĩa: 16 lượt cấp
chứng chỉ ban đầu (Bảng 3.4) được `INSERT` thủ công trong
`02_seed_data.sql` **sẽ không** tự động sinh ra dòng nào trong
`STUDENT_CERTIFICATE_AUDIT`, vì tại thời điểm đó trigger audit chưa tồn
tại — đây là hành vi đúng, không phải lỗi. Bảng `STUDENT_CERTIFICATE_AUDIT`
chỉ bắt đầu có dữ liệu từ các thao tác `INSERT` xảy ra **sau khi**
`06_triggers_events.sql` được chạy, ví dụ: TEST 1 (chèn học viên S008)
trong `09_tests.sql`.

---

# Chương 4. SQL Query Pack (8 truy vấn, đã tính tay kết quả kỳ vọng)

File: `03_queries.sql`. Các kết quả kỳ vọng dưới đây được tính đúng
theo trạng thái dữ liệu **tại thời điểm `03_queries.sql` chạy** — tức
là sau `01, 02, 04, 05, 06, 07` và trước `09_tests.sql` (đúng thứ tự
khuyến nghị trong `README.md`). Ở thời điểm này, dữ liệu vẫn nguyên vẹn
như Bảng 3.1–3.4, chưa có S008, chưa có buổi học nào bị hủy thêm.

## Q01 — Lọc và sắp xếp trên một bảng

**Business question:** Danh sách các lớp học tiếng Anh, sắp theo giờ
bắt đầu, để bố trí lịch phòng học.

```sql
SELECT ClassID, Level, DayOfWeek, StartTime, Room
FROM CLASS
WHERE Language = 'English'
ORDER BY StartTime;
```

**Kết quả kỳ vọng (2 dòng):**

| ClassID | Level | DayOfWeek | StartTime | Room |
|---|---|---|---|---|
| CL004 | Beginner | Thursday | 10:00:00 | A2 |
| CL001 | Intermediate | Monday | 18:00:00 | A1 |

## Q02 — INNER JOIN từ 3 bảng trở lên

**Business question:** Chi tiết điểm danh: học viên nào tham dự buổi
học nào của lớp nào, ngày nào.

```sql
SELECT s.FullName, c.ClassID, c.Language, cm.MeetingID, cm.MeetingDate
FROM ATTENDANCE AS a
INNER JOIN STUDENT AS s        ON s.StudentID = a.StudentID
INNER JOIN CLASS_MEETING AS cm ON cm.MeetingID = a.MeetingID
INNER JOIN CLASS AS c          ON c.ClassID = cm.ClassID
ORDER BY c.ClassID, cm.MeetingDate, s.FullName;
```

**Kết quả kỳ vọng:** đúng **45 dòng**, bằng tổng số lượt điểm danh
(Bảng 3.2). Mỗi dòng ATTENDANCE nối 1-1 với đúng 1 học viên, 1 buổi học,
1 lớp nên `INNER JOIN` không nhân bản dòng.

## Q03 — LEFT JOIN để tìm dữ liệu thiếu

**Business question:** Buổi học nào (chưa bị hủy) hiện chỉ có lead mà
chưa có assistant hỗ trợ?

```sql
SELECT cm.MeetingID, cm.ClassID, cm.MeetingDate
FROM CLASS_MEETING AS cm
LEFT JOIN MEETING_INSTRUCTOR AS mi
       ON mi.MeetingID = cm.MeetingID AND mi.Role = 'assistant'
WHERE mi.MeetingID IS NULL
  AND cm.MeetingStatus <> 'cancelled';
```

**Kết quả kỳ vọng (11 dòng):** M002, M003, M004, M006, M007, M008,
M010, M012, M013, M014, M015. (Bốn buổi có assistant nên bị loại:
M001, M005, M011; buổi M009 tuy không có assistant nhưng bị loại vì đã
`cancelled` — minh họa trực tiếp lợi ích của cột `MeetingStatus` mới.)

## Q04 — GROUP BY kết hợp HAVING

**Business question:** Chứng chỉ nào đã cấp cho từ 3 học viên trở lên?

```sql
SELECT c.CertificateID, c.Name, COUNT(DISTINCT sc.StudentID) AS student_count
FROM CERTIFICATE AS c
JOIN STUDENT_CERTIFICATE AS sc ON sc.CertificateID = c.CertificateID
GROUP BY c.CertificateID, c.Name
HAVING COUNT(DISTINCT sc.StudentID) >= 3
ORDER BY student_count DESC;
```

**Kết quả kỳ vọng (3 dòng):**

| CertificateID | Name | student_count |
|---|---|---|
| C001 | Starter Badge | 7 |
| C002 | Beginner Level 1 | 5 |
| C003 | Intermediate Level | 3 |

## Q05 — Subquery dạng NOT EXISTS

**Business question:** Học viên nào chưa từng tham dự buổi học nào?

```sql
SELECT s.StudentID, s.FullName, s.JoinDate
FROM STUDENT AS s
WHERE NOT EXISTS (
    SELECT 1 FROM ATTENDANCE AS a WHERE a.StudentID = s.StudentID
);
```

**Kết quả kỳ vọng: RỖNG (0 dòng)** tại thời điểm `03_queries.sql` chạy,
vì cả 7 học viên S001–S007 đều đã có ít nhất một lượt điểm danh (xem
Bảng 3.3, giá trị nhỏ nhất là S004 = 3 > 0). Đây là kết quả **đúng**,
không phải lỗi truy vấn. Truy vấn này chỉ trả về học viên S008 sau khi
TEST 1 trong `09_tests.sql` chèn S008 (chưa từng điểm danh) — nhóm cố ý
thiết kế thứ tự này để minh họa rõ ràng ý nghĩa của `NOT EXISTS` khi
dữ liệu thay đổi theo thời gian.

## Q06 — CTE (Common Table Expression)

**Business question:** Học viên nào tham dự từ 5 buổi học trở lên
(điều kiện R003 để xét chứng chỉ Beginner)?

```sql
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
```

**Kết quả kỳ vọng (6 dòng, loại duy nhất S004 = 3):**

| StudentID | total_attended |
|---|---|
| S002 | 8 |
| S006 | 8 |
| S007 | 8 |
| S001 | 6 |
| S003 | 6 |
| S005 | 6 |

*(Ba học viên cùng đạt 8 và ba học viên cùng đạt 6 — thứ tự giữa các
dòng có cùng giá trị `total_attended` không được đảm bảo trừ khi thêm
tiêu chí `ORDER BY` phụ, ví dụ `s.FullName`.)*

## Q07 — Report theo thời gian

**Business question:** Mỗi tháng có bao nhiêu buổi học, theo trạng
thái?

```sql
SELECT DATE_FORMAT(MeetingDate, '%Y-%m') AS meeting_month,
       MeetingStatus,
       COUNT(*) AS meeting_count
FROM CLASS_MEETING
GROUP BY meeting_month, MeetingStatus
ORDER BY meeting_month, MeetingStatus;
```

**Kết quả kỳ vọng (3 dòng, cùng tháng 2026-06):**

| meeting_month | MeetingStatus | meeting_count |
|---|---|---|
| 2026-06 | cancelled | 1 |
| 2026-06 | completed | 10 |
| 2026-06 | scheduled | 4 |

## Q08 — Truy vấn dùng stored function

**Business question:** Tỷ lệ chuyên cần của từng học viên.

```sql
SELECT s.StudentID,
       s.FullName,
       fn_student_attendance_count(s.StudentID) AS attended_meetings,
       fn_student_attendance_rate(s.StudentID)  AS attendance_rate_percent
FROM STUDENT AS s
ORDER BY attendance_rate_percent DESC;
```

**Kết quả kỳ vọng (7 dòng):**

| StudentID | attended_meetings | attendance_rate_percent |
|---|---|---|
| S001 | 6 | 100.00 |
| S002 | 8 | 100.00 |
| S003 | 6 | 100.00 |
| S004 | 3 | 100.00 |
| S005 | 6 | 100.00 |
| S007 | 8 | 100.00 |
| **S006** | **8** | **88.89** |

Sáu học viên đạt 100% vì trong dữ liệu mẫu, các học viên này luôn tham
dự đủ mọi buổi của (các) lớp mình từng tham gia; riêng S006 vắng 1/9
buổi thuộc các lớp mình tham gia (CL001, CL002, CL004) nên đạt
`8/9 ≈ 88.89%` — đây chính là ví dụ minh họa mà nhóm chủ động chỉnh sửa
dữ liệu mẫu để có được (xem mục "Lời sửa đổi" đầu tài liệu).

*(Chèn [ẢNH CHỤP] kết quả thật của cả 8 query sau khi chạy trên MySQL
Workbench, đối chiếu với các bảng kết quả kỳ vọng ở trên)*

---

# Chương 5. Views

File: `04_views.sql`. Hai view dưới đây đều dùng `JOIN`/`GROUP BY`/tính
toán dẫn xuất, không phải `SELECT * FROM table` đơn thuần.

## 5.1 vw_class_schedule

**Đối tượng sử dụng:** nhân viên vận hành/lễ tân xem lịch lớp kèm
instructor phụ trách và số buổi đã tổ chức/hủy.

```sql
CREATE OR REPLACE VIEW vw_class_schedule AS
SELECT
    c.ClassID, c.Language, c.Level, c.DayOfWeek, c.StartTime, c.Room,
    s.FullName AS main_instructor_name,
    COUNT(cm.MeetingID) AS meeting_count,
    SUM(CASE WHEN cm.MeetingStatus = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN cm.MeetingStatus = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count
FROM CLASS AS c
JOIN INSTRUCTOR AS i ON i.StudentID = c.MainInstructorID
JOIN STUDENT AS s    ON s.StudentID = i.StudentID
LEFT JOIN CLASS_MEETING AS cm ON cm.ClassID = c.ClassID
GROUP BY c.ClassID, c.Language, c.Level, c.DayOfWeek, c.StartTime, c.Room, s.FullName;
```

**Kết quả kỳ vọng khi `SELECT * FROM vw_class_schedule`:** 5 dòng
(CL001–CL005), mỗi lớp có `meeting_count = 3`; `completed_count = 2` và
`cancelled_count = 0` cho tất cả các lớp ngoại trừ CL003 có
`cancelled_count = 1` (do buổi M009).

## 5.2 vw_student_certificate_progress

**Đối tượng sử dụng:** bộ phận học vụ/phụ huynh theo dõi tiến độ chứng
chỉ.

```sql
CREATE OR REPLACE VIEW vw_student_certificate_progress AS
SELECT
    s.StudentID, s.FullName,
    COUNT(sc.CertificateID) AS total_certificates,
    (
        SELECT c2.Name FROM STUDENT_CERTIFICATE sc2
        JOIN CERTIFICATE c2 ON c2.CertificateID = sc2.CertificateID
        WHERE sc2.StudentID = s.StudentID
        ORDER BY sc2.AwardDate DESC LIMIT 1
    ) AS latest_certificate_name,
    MAX(sc.AwardDate) AS latest_award_date
FROM STUDENT AS s
LEFT JOIN STUDENT_CERTIFICATE AS sc ON sc.StudentID = s.StudentID
GROUP BY s.StudentID, s.FullName;
```

**Kết quả kỳ vọng:** `total_certificates` khớp đúng Bảng 3.4 (S003 cao
nhất với 4 chứng chỉ; S006, S007 thấp nhất với 1 chứng chỉ).

## 5.3 Khả năng cập nhật của view

Cả hai view đều dùng aggregation/subquery tương quan nên **không
updatable**. Mọi ghi dữ liệu phải qua bảng gốc hoặc qua các stored
procedure ở Chương 6.

*(Chèn [ẢNH CHỤP] kết quả `SELECT * FROM` từng view)*

---

# Chương 6. Kiểm thử nhanh sau khi tạo View (khuyến nghị)

Trước khi sang phần Stored Procedure, nhóm khuyến nghị chạy thử 2 lệnh
sau để xác nhận view hoạt động đúng ngay sau khi tạo, tránh việc phát
hiện lỗi muộn ở Chương 11 mới bắt đầu sửa:

```sql
SELECT * FROM vw_class_schedule ORDER BY meeting_count DESC;
SELECT * FROM vw_student_certificate_progress
ORDER BY total_certificates DESC, latest_award_date DESC;
```

---

# Chương 7. Stored Procedures và Stored Functions (mở rộng: 3 SP + 3 FN)

File: `05_routines.sql`. Ở bản mở rộng này, nhóm bổ sung thêm 1
procedure (SP03) và 1 function (FN03) so với yêu cầu tối thiểu (2
procedure + 1 function), để hệ thống hỗ trợ đầy đủ hơn quy trình cấp
chứng chỉ và tra cứu instructor phụ trách lớp.

## 7.1 SP01 — sp_record_attendance

| Mục | Nội dung |
|---|---|
| Nhu cầu nghiệp vụ | Chỉ điểm danh khi học viên & buổi học tồn tại, buổi chưa hủy, và chưa điểm danh trước đó |
| Input/Output | `(p_student_id, p_meeting_id)`; thành công thêm 1 dòng ATTENDANCE |
| Cơ chế | `START TRANSACTION` + `SIGNAL SQLSTATE '45000'` khi vi phạm, `ROLLBACK` trước khi báo lỗi |

```sql
DELIMITER $$
CREATE PROCEDURE sp_record_attendance(
    IN p_student_id VARCHAR(20), IN p_meeting_id VARCHAR(20)
)
BEGIN
    DECLARE v_student_exists   INT DEFAULT 0;
    DECLARE v_meeting_status   VARCHAR(20);
    DECLARE v_already_recorded INT DEFAULT 0;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_student_exists FROM STUDENT WHERE StudentID = p_student_id;
    IF v_student_exists = 0 THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    SELECT MeetingStatus INTO v_meeting_status FROM CLASS_MEETING WHERE MeetingID = p_meeting_id;
    IF v_meeting_status IS NULL THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meeting does not exist';
    END IF;
    IF v_meeting_status = 'cancelled' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot record attendance for a cancelled meeting';
    END IF;

    SELECT COUNT(*) INTO v_already_recorded FROM ATTENDANCE
    WHERE StudentID = p_student_id AND MeetingID = p_meeting_id;
    IF v_already_recorded > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance already recorded for this student/meeting';
    END IF;

    INSERT INTO ATTENDANCE (StudentID, MeetingID) VALUES (p_student_id, p_meeting_id);
    COMMIT;
END $$
DELIMITER ;
```

## 7.2 SP02 — sp_cancel_meeting

| Mục | Nội dung |
|---|---|
| Nhu cầu nghiệp vụ | Hủy buổi học chưa `completed`, đồng thời dọn sạch điểm danh sai lệch của buổi đó |
| Cơ chế | `SELECT ... FOR UPDATE` khóa dòng trước khi kiểm tra, tránh race condition khi nhiều người thao tác đồng thời |

```sql
DELIMITER $$
CREATE PROCEDURE sp_cancel_meeting(IN p_meeting_id VARCHAR(20))
BEGIN
    DECLARE v_status VARCHAR(20);
    START TRANSACTION;

    SELECT MeetingStatus INTO v_status FROM CLASS_MEETING
    WHERE MeetingID = p_meeting_id FOR UPDATE;

    IF v_status IS NULL THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Meeting does not exist';
    END IF;
    IF v_status = 'completed' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot cancel a meeting that already completed';
    END IF;

    DELETE FROM ATTENDANCE WHERE MeetingID = p_meeting_id;
    UPDATE CLASS_MEETING SET MeetingStatus = 'cancelled' WHERE MeetingID = p_meeting_id;
    COMMIT;
END $$
DELIMITER ;
```

## 7.3 SP03 — sp_award_certificate (mới, bổ sung cho đầy đủ)

| Mục | Nội dung |
|---|---|
| Nhu cầu nghiệp vụ | Cấp một chứng chỉ cho học viên; chặn cấp trùng đúng chứng chỉ đó cho cùng học viên (hiện thực hóa BR32 phiên bản chặt hơn) |
| Liên kết | `INSERT` thành công sẽ tự động kích hoạt `trg_ai_student_certificate_audit` (Chương 8), tạo dây chuyền ghi log hoàn toàn tự động |

```sql
DELIMITER $$
CREATE PROCEDURE sp_award_certificate(
    IN p_student_id VARCHAR(20), IN p_certificate_id VARCHAR(20), IN p_award_date DATE
)
BEGIN
    DECLARE v_student_exists     INT DEFAULT 0;
    DECLARE v_certificate_exists INT DEFAULT 0;
    DECLARE v_already_awarded    INT DEFAULT 0;
    START TRANSACTION;

    SELECT COUNT(*) INTO v_student_exists FROM STUDENT WHERE StudentID = p_student_id;
    IF v_student_exists = 0 THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    SELECT COUNT(*) INTO v_certificate_exists FROM CERTIFICATE WHERE CertificateID = p_certificate_id;
    IF v_certificate_exists = 0 THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Certificate does not exist';
    END IF;

    SELECT COUNT(*) INTO v_already_awarded FROM STUDENT_CERTIFICATE
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
```

## 7.4 FN01 — fn_student_attendance_count / 7.5 FN02 — fn_student_attendance_rate

```sql
DELIMITER $$
CREATE FUNCTION fn_student_attendance_count(p_student_id VARCHAR(20))
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;
    SELECT COUNT(*) INTO v_count FROM ATTENDANCE WHERE StudentID = p_student_id;
    RETURN v_count;
END $$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION fn_student_attendance_rate(p_student_id VARCHAR(20))
RETURNS DECIMAL(5,2) READS SQL DATA
BEGIN
    DECLARE v_attended INT DEFAULT 0;
    DECLARE v_total    INT DEFAULT 0;

    SELECT COUNT(*) INTO v_attended FROM ATTENDANCE WHERE StudentID = p_student_id;

    SELECT COUNT(*) INTO v_total FROM CLASS_MEETING cm
    WHERE cm.MeetingStatus <> 'cancelled'
      AND cm.ClassID IN (
          SELECT DISTINCT cm2.ClassID FROM ATTENDANCE a2
          JOIN CLASS_MEETING cm2 ON cm2.MeetingID = a2.MeetingID
          WHERE a2.StudentID = p_student_id
      );

    IF v_total = 0 THEN RETURN NULL; END IF;
    RETURN ROUND(v_attended / v_total * 100, 2);
END $$
DELIMITER ;
```

## 7.6 FN03 — fn_class_instructor (mới, bổ sung cho đầy đủ)

Trả về họ tên instructor phụ trách chính của một lớp; trả `NULL` nếu
`ClassID` không tồn tại.

```sql
DELIMITER $$
CREATE FUNCTION fn_class_instructor(p_class_id VARCHAR(20))
RETURNS VARCHAR(100) READS SQL DATA
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
```

**Ghi chú thiết kế quan trọng:** để tránh số liệu của `03_queries.sql`
bị lệch tùy theo có chạy các lệnh `CALL`/`SELECT` thử nghiệm hay không,
file `05_routines.sql` **chỉ định nghĩa** routine, không tự gọi test.
Toàn bộ lời gọi kiểm thử được tập trung vào `09_tests.sql` — đây là một
sửa đổi nhỏ về tổ chức file so với bản nháp đầu tiên, giúp mọi số liệu
trong Chương 4 luôn tái lập được chính xác.

*(Chèn [ẢNH CHỤP] test 3 procedure + 3 function ở Chương 11)*

---

# Chương 8. Trigger và Event Scheduler (mở rộng: 4 trigger + 1 event)

File: `06_triggers_events.sql`.

## 8.1 trg_auto_assign_starter_badge

AFTER INSERT ON STUDENT → tự động thêm dòng Starter Badge (C001) vào
STUDENT_CERTIFICATE cho học viên mới, dùng chính ngày `JoinDate` làm
`AwardDate`.

## 8.2 trg_check_meeting_lead

BEFORE INSERT ON MEETING_INSTRUCTOR → chặn thêm lead thứ hai cho cùng
một buổi học (thực thi BR25).

## 8.3 trg_ai_student_certificate_audit (CH02)

AFTER INSERT ON STUDENT_CERTIFICATE → ghi 1 dòng vào
STUDENT_CERTIFICATE_AUDIT (thực thi BR36). Vì trigger 8.1 cũng INSERT
vào STUDENT_CERTIFICATE, hai trigger tạo thành dây chuyền: học viên mới
→ tự động có Starter Badge → tự động có audit log, hoàn toàn không cần
ứng dụng can thiệp.

## 8.4 trg_bu_prevent_meeting_reactivation (mới, bổ sung cho đầy đủ)

BEFORE UPDATE ON CLASS_MEETING → chặn việc đổi trạng thái từ
`cancelled`/`completed` quay ngược lại `scheduled` (thực thi BR35 phần
"trạng thái kết thúc"), phòng trường hợp thao tác nhầm.

```sql
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
```

## 8.5 Event ev_purge_old_certificate_audit

`EVERY 1 DAY`, `DISABLE` mặc định, dọn log audit cũ hơn 730 ngày. Không
bật trên môi trường lab dùng chung vì đây là thao tác `DELETE` tự động
theo lịch.

*(Chèn [ẢNH CHỤP] `SHOW TRIGGERS` và `SHOW EVENTS` — event phải hiển
thị `Status = DISABLED`)*

---

# Chương 9. Index và Execution Plan

File: `07_indexes_explain.sql`.

**Bảng 9.1 — 3 secondary index**

| Index | Cột | Query workload | Pattern |
|---|---|---|---|
| idx_meeting_class_date | (ClassID, MeetingDate) | Q01, Q07, tra lịch buổi học theo lớp | equality + order |
| idx_meeting_instructor_student | (StudentID, Role) | Tra lịch dạy của 1 instructor | equality ngược chiều PK |
| idx_attendance_meeting_student | (MeetingID, StudentID) | Q03, `sp_cancel_meeting` | equality ngược chiều PK |

**Vì sao không tạo thêm index trên các cột FK khác?** InnoDB tự động
tạo index ẩn cho mọi cột khóa ngoại (ví dụ `CLASS.MainInstructorID`,
`CERTIFICATE_REQUIREMENT.CertificateID` đã có index do ràng buộc FK
sinh ra) — nhóm chủ động không tạo trùng lặp, xác nhận bằng
`SHOW INDEX FROM CLASS;` và `SHOW INDEX FROM CERTIFICATE_REQUIREMENT;`.

**Giới hạn dữ liệu demo:** với 15 dòng CLASS_MEETING và 45 dòng
ATTENDANCE, optimizer có thể vẫn chọn full table scan vì bảng quá nhỏ —
không phải lỗi thiết kế index, mà là đặc điểm tự nhiên của dữ liệu mẫu
nhỏ; cần điền kết quả `EXPLAIN` thật vào Bảng 9.2 dưới đây sau khi chạy
trên máy.

**Bảng 9.2 — Bảng điền kết quả EXPLAIN thực tế (điền sau khi chạy)**

| Query | possible_keys | key | rows | Extra |
|---|---|---|---|---|
| EXPLAIN cho idx_meeting_class_date | | | | |
| EXPLAIN cho idx_meeting_instructor_student | | | | |
| EXPLAIN cho idx_attendance_meeting_student | | | | |

*(Chèn [ẢNH CHỤP] `SHOW INDEX` và `EXPLAIN` thật)*

---

# Chương 10. Administration, quyền truy cập và Backup/Restore

File: `08_admin_backup.md`. Toàn bộ chỉ thực hành trên MySQL local/lab.

## 10.1 Least privilege

```sql
CREATE ROLE IF NOT EXISTS 'role_center_reporter';
GRANT SELECT ON brightpath_language_center.vw_class_schedule,
             brightpath_language_center.vw_student_certificate_progress
    TO 'role_center_reporter';
GRANT SELECT ON brightpath_language_center.STUDENT,
             brightpath_language_center.CLASS,
             brightpath_language_center.CLASS_MEETING,
             brightpath_language_center.CERTIFICATE
    TO 'role_center_reporter';

CREATE USER IF NOT EXISTS 'center_reporter'@'localhost'
    IDENTIFIED BY 'ChangeThisLocalLabPassword!';
GRANT 'role_center_reporter' TO 'center_reporter'@'localhost';
SET DEFAULT ROLE 'role_center_reporter' TO 'center_reporter'@'localhost';
```

## 10.2 Bằng chứng cấp quyền

```sql
SHOW GRANTS FOR 'center_reporter'@'localhost';
SHOW CREATE USER 'center_reporter'@'localhost';
```

## 10.3 Backup

```bash
mysqldump -u root -p --routines --triggers --events \
    brightpath_language_center > brightpath_language_center_20260701.sql
```

## 10.4 Restore vào database test riêng biệt

```bash
mysql -u root -p -e "CREATE DATABASE brightpath_language_center_restore_test
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p brightpath_language_center_restore_test \
    < brightpath_language_center_20260701.sql
```

Nguyên tắc: **không bao giờ restore đè lên database nguồn đang chạy**.

## 10.5 Ghi chú bảo mật

Mật khẩu ví dụ chỉ là placeholder; không dùng `'user'@'%'` nếu không có
kiểm soát mạng; không commit file dump/mật khẩu thật lên báo cáo hay
Git.

*(Chèn [ẢNH CHỤP] `SHOW GRANTS`, kết quả backup/restore thành công)*

---

# Chương 11. Kiểm thử (19 test case)

File: `09_tests.sql`.

**Bảng 11.1 — Toàn bộ 19 test case**

| # | Test | Loại | Kết quả mong đợi |
|---|---|---|---|
| 1 | Chèn học viên mới S008 | Positive (trigger) | Tự động có Starter Badge + audit log |
| 2 | Chèn lại StudentID='S001' | Negative (PK) | `ERROR 1062 Duplicate entry 'S001'` |
| 3 | Tạo lớp tham chiếu instructor 'S999' không tồn tại | Negative (FK) | `ERROR 1452` |
| 4 | Tạo chứng chỉ trùng tên 'Starter Badge' | Negative (UNIQUE) | `ERROR 1062` |
| 5 | Thêm lead thứ 2 cho M001 | Negative (trigger) | `ERROR 45000 'already has a lead'` |
| 6 | `sp_record_attendance('S008','M001')` | Positive | Thêm 1 dòng ATTENDANCE |
| 7 | `sp_record_attendance('S999','M001')` | Negative | `'Student does not exist'` |
| 8 | Gọi lại cặp ở test 6 | Negative | `'Attendance already recorded...'` |
| 9 | `sp_record_attendance('S008','M009')` (đã hủy) | Negative | `'Cannot record attendance for a cancelled meeting'` |
| 10 | `sp_cancel_meeting('M003')` | Positive | Status → cancelled, xóa sạch điểm danh M003 |
| 11 | `sp_cancel_meeting('M001')` (đã completed) | Negative | `'Cannot cancel a meeting that already completed'` |
| 12 | `fn_student_attendance_count/rate('S002')` và `('S999')` | Positive/Negative | Số đúng; `NULL` cho học viên không có lớp nào |
| 12b | `sp_award_certificate('S008','C002',...)` | Positive | Thêm STUDENT_CERTIFICATE + audit |
| 12c | `sp_award_certificate('S008','C001',...)` (trùng) | Negative | `'already been awarded'` |
| 12d | `sp_award_certificate('S008','C999',...)` | Negative | `'Certificate does not exist'` |
| 12e | `fn_class_instructor('CL001')` và `('CLXXX')` | Positive/Negative | Tên instructor đúng; `NULL` cho lớp không tồn tại |
| 12f | `UPDATE ... SET MeetingStatus='scheduled' WHERE MeetingID='M001'` | Negative (trigger) | `'Cannot revert...'` |
| 12g | `UPDATE ... SET MeetingStatus='completed' WHERE MeetingID='M006'` | Positive (trigger không chặn nhầm) | 1 row affected |
| 13 | `center_reporter` SELECT view / thử INSERT | Positive + Negative (admin) | SELECT OK; INSERT bị từ chối `ERROR 1142` |

## 11.1 Ghi chú dọn dẹp

Test 2,3,4,5,7,8,9,11,12c,12d,12f chủ đích gây lỗi, không đổi dữ liệu
(nhờ `ROLLBACK`/bị chặn trước khi ghi). Test 1,6,10,12b,12g có đổi dữ
liệu; muốn chạy lại từ đầu, chạy lại `01_schema.sql` + `02_seed_data.sql`.

*(Chèn [ẢNH CHỤP] từng test — đặc biệt test negative cần thấy rõ mã
lỗi)*

---

# Chương 12. Phân công công việc trong nhóm

> Bảng dưới đây là gợi ý phân chia theo từng phần của báo cáo/hệ thống,
> để mỗi thành viên nắm chắc và có thể trả lời riêng khi được hỏi (theo
> yêu cầu "ký và hỏi ngắn gọn theo cá nhân" của giảng viên). Nhóm điền
> lại đúng theo phân công thực tế đã làm.

| Thành viên | Phần phụ trách chính | Nội dung cần nắm chắc |
|---|---|---|
| Đoàn Việt Anh | Thiết kế (Chương 1–3): business rules, ERD, chuẩn hóa, schema | Vì sao INSTRUCTOR dùng Shared Primary Key; vì sao mỗi bảng đạt 3NF |
| Nguyễn Hải Anh | Khai thác dữ liệu (Chương 4–6): query pack, view | Giải thích từng kỹ thuật SQL trong Q01–Q08; view có updatable không, vì sao |
| Nguyễn Duy Khánh | Lập trình CSDL (Chương 7–8): procedure, function, trigger, event | Vì sao dùng `SIGNAL`/transaction; trình tự kích hoạt trigger dây chuyền |
| Bùi Thanh Long | Vận hành (Chương 9–11): index, admin, backup, testing | Đọc kết quả `EXPLAIN`; giải thích least-privilege; đối chiếu kết quả test thực tế |

---

# Chương 13. Bài học kinh nghiệm, hạn chế và hướng phát triển

## 13.1 Bài học kinh nghiệm

- **Luôn tính tay/đối chiếu số liệu kỳ vọng trước khi chạy thật:** khi
  chuẩn bị bộ dữ liệu mẫu, nhóm từng vô tình thiết kế dữ liệu khiến mọi
  học viên đều đạt tỷ lệ chuyên cần 100%, làm mất ý nghĩa minh họa của
  hàm `fn_student_attendance_rate`. Việc rà soát kỹ số liệu trước khi
  hoàn thiện báo cáo giúp phát hiện và sửa kịp thời.
- **Tách bạch "định nghĩa" và "gọi thử" trong các file SQL:** việc để
  lời gọi `CALL`/`SELECT` thử nghiệm ngay trong file định nghĩa routine
  (`05_routines.sql`) gây ra hiệu ứng phụ làm lệch số liệu của file
  chạy sau đó (`03_queries.sql`). Bài học: mỗi file nên làm đúng một
  việc, mọi thao tác có side-effect nên gom về một file test riêng.
- **Không dán nhầm nội dung giữa các phụ lục:** lỗi Phụ lục A ở bản
  giữa kỳ (dán code Python thay vì SQL) là lời nhắc cần kiểm tra kỹ nội
  dung trước khi nộp, đặc biệt với các phần copy-paste giữa nhiều tài
  liệu nguồn.

## 13.2 Hạn chế

- Hệ thống chưa có khái niệm "đăng ký lớp" (enrollment) tường minh, nên
  `fn_student_attendance_rate` phải suy luận "lớp đã tham gia" gián
  tiếp qua bảng ATTENDANCE.
- `STUDENT_CERTIFICATE_AUDIT` mới chỉ ghi log khi `AWARDED` (INSERT);
  chưa có trigger cho `UPDATE`/`DELETE` vì nghiệp vụ hiện tại chưa cho
  sửa/xóa chứng chỉ đã cấp.
- Event dọn log audit đang `DISABLE`, chưa được kiểm thử chạy tự động
  thật (chỉ kiểm thử được cấu trúc, không kiểm thử được lịch chạy).

## 13.3 Hướng phát triển

- Bổ sung bảng `ENROLLMENT` để tách biệt "đăng ký lớp" khỏi "điểm danh
  buổi học", giúp tính tỷ lệ chuyên cần chính xác theo từng lớp đã đăng
  ký thay vì suy luận gián tiếp.
- Bổ sung trigger `AFTER UPDATE`/`AFTER DELETE` cho `STUDENT_CERTIFICATE`
  nếu nghiệp vụ sau này cho phép thu hồi/sửa chứng chỉ.
- Xây dựng thêm bảng quản lý học phí và liên kết với `STUDENT`, mở rộng
  đúng như định hướng đã nêu ở phần "Ngoài phạm vi" của Chương 1.

---

# Chương 14. Kết luận

Hệ thống cơ sở dữ liệu BrightPath Language Center bản cuối kỳ kế thừa
đầy đủ và **đã sửa các sai sót phát hiện được** ở thiết kế giữa kỳ (ERD,
mô hình quan hệ, chuẩn hóa 3NF, chuẩn hóa lại MSSV, loại bỏ nội dung
dán nhầm ở phụ lục), đồng thời mở rộng đáng kể phần khai thác và vận
hành so với yêu cầu tối thiểu: 8 truy vấn nghiệp vụ có kết quả kỳ vọng
được tính tay chính xác; 2 view reporting; **3** stored procedure (thay
vì tối thiểu 2) có giao tác/validation rõ ràng; **3** stored function
(thay vì tối thiểu 1); **4** trigger (thay vì tối thiểu 1) cùng 1 event
an toàn; 3 secondary index có luận cứ và kế hoạch `EXPLAIN`; một kế
hoạch quản trị người dùng theo nguyên tắc least-privilege và
backup/restore ở mức local/lab; và **19** test case positive/negative.
Báo cáo cũng bổ sung phần phân công công việc và bài học kinh nghiệm để
phục vụ tốt hơn cho việc trình bày và trả lời câu hỏi cá nhân của từng
thành viên trong buổi bảo vệ.
