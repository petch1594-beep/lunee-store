# Mellow Wear — ร้านเสื้อผ้า PHP + MySQL

## เริ่มใช้งานกับ XAMPP

สำหรับการย้ายไปเครื่องอื่น ให้ดูขั้นตอนแบบละเอียดใน [SETUP.md](SETUP.md) ก่อน

1. เปิด **Apache** และ **MySQL** ใน XAMPP Control Panel
2. เปิด `http://localhost/phpmyadmin` แล้วเลือกแท็บ **Import**
3. เลือกไฟล์ [database_install.sql](database_install.sql) แล้วกด Import เพียงครั้งเดียว ไฟล์นี้สร้างและเติมข้อมูลฐานข้อมูล `clothing_store` ให้ครบทั้งหมด
4. คัดลอก `config.local.example.php` เป็น `config.local.php` แล้วแก้ค่าฐานข้อมูลและ `APP_URL`
5. เปิด URL ตามที่ตั้งไว้เพื่อดูหน้าร้าน เช่น [http://localhost/DDDD/](http://localhost/DDDD/)

> ถ้าเซิร์ฟเวอร์ไม่อนุญาตให้ไฟล์ SQL สร้างฐานข้อมูล ให้ผู้ดูแลรัน [create_clothing_store_admin.sql](create_clothing_store_admin.sql) ก่อน แล้วค่อย Import `database_install.sql` ขณะเลือกฐานข้อมูล `clothing_store` อยู่

สำหรับฐานข้อมูลที่มีข้อมูลเดิม ให้ Export สำรองก่อน และอย่า Import `database_install.sql` ซ้ำ ให้ใช้ไฟล์ migration แยกเฉพาะรายการที่ยังไม่เคยอัปเดตเท่านั้น

ไฟล์ SQL เก่าหรือของระบบ workshop ถูกเก็บไว้ในโฟลเดอร์ `database_legacy` และไม่จำเป็นต้องใช้ในการติดตั้งร้านค้านี้

ค่าเชื่อมฐานข้อมูลอยู่ใน `config.php` (ค่าเริ่มต้นคือ MySQL ผู้ใช้ `root` และไม่มีรหัสผ่าน) และเชื่อมเฉพาะ `clothing_store` ซึ่งแยกจากฐานข้อมูลอื่นทั้งหมด

## ทดสอบระบบสมาชิก

สมัครสมาชิกจากหน้าเว็บ แล้วกรอกรหัสที่ส่งเข้าอีเมลในหน้า **ยืนยันอีเมล**

บน XAMPP ทั่วไป `mail()` ยังไม่ส่งเมลจริงจนกว่าจะตั้งค่า SMTP ใน `php.ini` และ `sendmail.ini` ดังนั้นระหว่างพัฒนา สามารถคัดลอก `verification_code` จาก phpMyAdmin ตาราง `clothing_store > users` มาใช้ยืนยันได้

## เปิดสิทธิ์แอดมิน

สมัครและยืนยันบัญชีตามปกติก่อน จากนั้นรัน SQL นี้ใน phpMyAdmin:

```sql
UPDATE clothing_store.users SET role = 'admin' WHERE email = 'your@email.com';
```

ออกจากระบบแล้วเข้าสู่ระบบใหม่ จะเห็นเมนู **หลังบ้าน** ซึ่งเพิ่ม/แก้ไข/ลบสินค้า และดูจำนวนสินค้า สมาชิก และสต็อกได้

## Google / Facebook

ปุ่ม Google และ Facebook ถูกเตรียมเป็นส่วนติดต่อไว้แล้ว แต่ยังไม่ได้เชื่อม OAuth จริง เพราะต้องมี Google Client ID / Facebook App ID และ redirect URL ของโดเมนเจ้าของร้านก่อน จึงจะเปิดใช้แบบปลอดภัยได้

สำหรับ Facebook ให้คัดลอก `facebook_app.example.json` เป็น `facebook_app.json` แล้วใส่ App ID และ App Secret จาก Meta for Developers จากนั้นตั้ง Valid OAuth Redirect URI เป็น `APP_URL/auth/facebook_callback.php` และเปิด permission `email` กับ `public_profile` ห้ามส่ง Secret หรือ commit ไฟล์จริงขึ้น Git
