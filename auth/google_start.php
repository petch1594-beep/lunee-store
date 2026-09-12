<?php
require_once __DIR__.'/../config.php';

$files = glob(__DIR__.'/../client_secret*.json');
if (!$files) { flash('error', 'ยังไม่พบไฟล์ Google OAuth JSON ในโฟลเดอร์เว็บไซต์'); redirect('../login.php'); }
$credentials = json_decode((string)file_get_contents($files[0]), true);
$oauth = $credentials['web'] ?? $credentials['installed'] ?? null;
if (!$oauth || empty($oauth['client_id'])) { flash('error', 'รูปแบบไฟล์ Google OAuth ไม่ถูกต้อง'); redirect('../login.php'); }
$redirectUri = app_url('auth/google_callback.php');
$_SESSION['google_oauth_state'] = bin2hex(random_bytes(24));
$params = [
    'client_id' => $oauth['client_id'], 'redirect_uri' => $redirectUri,
    'response_type' => 'code', 'scope' => 'openid email profile',
    'access_type' => 'online', 'include_granted_scopes' => 'true',
    'state' => $_SESSION['google_oauth_state'], 'prompt' => 'select_account'
];
header('Location: https://accounts.google.com/o/oauth2/v2/auth?'.http_build_query($params)); exit;
