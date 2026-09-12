-- เพิ่มข้อมูลเบอร์โทรศัพท์สำหรับฐานข้อมูล clothing_store ที่มีอยู่แล้ว
USE clothing_store;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(30) NULL AFTER email;
