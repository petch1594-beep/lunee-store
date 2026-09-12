<?php require_once __DIR__.'/config.php'; session_unset();session_destroy();session_start();flash('success','ออกจากระบบแล้ว');redirect('index.php');
