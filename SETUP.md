# คู่มือติดตั้ง LUNEÉ บนเครื่องใหม่

## 1) คัดลอกไฟล์เว็บไซต์

วางโฟลเดอร์นี้ไว้ใน document root ของเว็บเซิร์ฟเวอร์ เช่น `htdocs/DDDD` ใน XAMPP หรือโฟลเดอร์ public ของ Apache/Nginx จากนั้นตรวจว่า PHP เปิดใช้งาน `pdo_mysql`, `curl`, `openssl`, `mbstring` และ `session` แล้ว

## 2) ตั้งค่าฐานข้อมูล

ใน phpMyAdmin เลือกเมนู **Import** แล้วเลือกไฟล์ [database_install.sql](database_install.sql) เพียงไฟล์เดียว จากนั้นกด Import ระบบจะสร้างฐานข้อมูล `clothing_store` พร้อมตาราง สินค้า ประเภทสินค้า wishlist และข้อมูลไซซ์ให้ครบในครั้งเดียว

ไฟล์นี้เหมาะสำหรับฐานข้อมูลใหม่หรือฐานข้อมูลว่าง หากมีข้อมูลเดิมอยู่แล้ว ให้ Export สำรองก่อน และอย่านำเข้าไฟล์นี้ซ้ำ เพราะอาจเกิดข้อมูลซ้ำหรือชนกับตารางเดิม ไฟล์ SQL แยกรายการเดิมยังเก็บไว้สำหรับ migration เฉพาะกรณีที่จำเป็น และไม่ควรนำเข้า `database_legacy/database_workshop.sql` เพราะเป็นฐานข้อมูลคนละระบบ

ไฟล์ SQL รุ่นเก่าหรือของระบบ workshop ถูกเก็บไว้ในโฟลเดอร์ `database_legacy` เพื่อไม่ให้ปะปนกับไฟล์ติดตั้งหลัก ไม่ต้องนำเข้าไฟล์ในโฟลเดอร์นี้สำหรับร้านค้านี้

## 3) ตั้งค่าเว็บไซต์

คัดลอก `config.local.example.php` เป็น `config.local.php` แล้วแก้ `DB_USER`, `DB_PASS` และ `APP_URL` ให้ตรงกับเครื่องใหม่ โดย `APP_URL` ต้องเป็น URL ที่เปิดหน้าเว็บได้จริง เช่น `http://localhost/DDDD` หรือโดเมนจริง

## 4) ตั้งค่าอีเมล (ถ้าต้องการส่งรหัสจริง)

ใส่ Gmail และ App Password ใน `config.local.php` หรือกำหนดเป็น environment variables ชื่อ `MAIL_USERNAME` และ `MAIL_APP_PASSWORD` ห้ามใส่รหัสผ่านไว้ในไฟล์หลักหรืออัปโหลดขึ้น Git

## 5) OAuth (ถ้าเปิดใช้)

วางไฟล์ Google OAuth JSON ชื่อขึ้นต้นด้วย `client_secret` และวาง `facebook_app.json` จากไฟล์ตัวอย่าง จากนั้นเพิ่ม redirect URI ให้ตรงกับ URL เครื่องใหม่:

- `APP_URL/auth/google_callback.php`
- `APP_URL/auth/facebook_callback.php`

ไฟล์ credential ถูกป้องกันไม่ให้เว็บเรียกดูโดย `.htaccess` แล้ว

## 6) เปิดใช้งาน

เปิด `APP_URL` ในเบราว์เซอร์ สมัครสมาชิก/ยืนยันอีเมล แล้วกำหนดแอดมินด้วย SQL:

```sql
UPDATE clothing_store.users SET role = 'admin' WHERE email = 'your@email.com';
```

## ปัญหาที่พบบ่อย

- `could not find driver`: เปิด `extension=pdo_mysql` ใน `php.ini`
- เชื่อมฐานข้อมูลไม่ได้: ตรวจชื่อฐานข้อมูล ผู้ใช้ และรหัสผ่านใน `config.local.php`
- OAuth แจ้ง redirect URI ไม่ตรง: แก้ `APP_URL` และเพิ่ม URI เดิมใน Google/Meta Developer Console
- ไม่ได้รับอีเมลบนเครื่องพัฒนา: ใช้รหัสที่แสดงในหน้า verify หรือดู `verification_code` ในตาราง `users`
