<?php
require_once __DIR__.'/config.php';
unset($_SESSION['pending_email'], $_SESSION['last_verification_code'], $_SESSION['mail_delivery_failed']);
flash('success', 'ระบบสมัครสมาชิกแบบใหม่พร้อมใช้งานแล้ว ไม่ต้องยืนยันอีเมล');
redirect('login.php');
