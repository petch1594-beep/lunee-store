-- รันไฟล์นี้ด้วย "บัญชี MySQL ผู้ดูแลระบบ" ที่มีสิทธิ์ CREATE และ GRANT OPTION เท่านั้น
-- ไฟล์นี้ไม่ยุ่งเกี่ยวกับ workshop_db
CREATE DATABASE IF NOT EXISTS clothing_store CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON clothing_store.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
