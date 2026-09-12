<?php
declare(strict_types=1);
// กำหนด cookie ให้ session ใช้ได้สม่ำเสมอในโฟลเดอร์ร้าน และไม่ให้หน้าเก่าค้างหลังแก้ตะกร้า
if (session_status() === PHP_SESSION_NONE) {
    session_set_cookie_params(['lifetime'=>0, 'path'=>'/', 'httponly'=>true, 'samesite'=>'Lax']);
    session_start();
}
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');

$localConfig = [];
$localConfigFile = __DIR__.'/config.local.php';
if (is_file($localConfigFile)) {
    $loadedConfig = require $localConfigFile;
    if (is_array($loadedConfig)) $localConfig = $loadedConfig;
}
$setting = static function (string $key, string $default = '') use ($localConfig): string {
    $env = getenv($key);
    if ($env !== false && $env !== '') return (string)$env;
    return array_key_exists($key, $localConfig) ? (string)$localConfig[$key] : $default;
};

// ค่าทั้งหมดเปลี่ยนได้จาก config.local.php หรือ environment variables เมื่อย้ายเครื่อง
define('DB_HOST', $setting('DB_HOST', '127.0.0.1'));
define('DB_NAME', $setting('DB_NAME', 'clothing_store'));
define('DB_USER', $setting('DB_USER', 'root'));
define('DB_PASS', $setting('DB_PASS'));
define('STORE_NAME', $setting('STORE_NAME', 'LUNEÉ'));
define('APP_URL', rtrim($setting('APP_URL'), '/'));
// Gmail App Password 16 หลัก (เว้นว่างไว้จะใช้ mail() แบบเดิม)
define('MAIL_USERNAME', $setting('MAIL_USERNAME'));
define('MAIL_APP_PASSWORD', $setting('MAIL_APP_PASSWORD'));
define('MAIL_FROM_NAME', $setting('MAIL_FROM_NAME', STORE_NAME));

function app_url(string $path = ''): string {
    $base = APP_URL;
    if ($base === '') {
        $https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        $scheme = $https ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $script = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '/'));
        $base = $scheme.'://'.$host;
        if (str_ends_with($script, '/auth')) $script = dirname($script);
        if ($script !== '/' && $script !== '.') $base .= rtrim($script, '/');
    }
    return $base.'/'.ltrim($path, '/');
}

function db(): PDO {
    static $pdo;
    if (!$pdo) {
        $pdo = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4', DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
    return $pdo;
}
function current_user(): ?array { return $_SESSION['user'] ?? null; }
function csrf_token(): string { if (empty($_SESSION['csrf_token'])) $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); return $_SESSION['csrf_token']; }
function verify_csrf(?string $token): bool { return is_string($token) && hash_equals($_SESSION['csrf_token'] ?? '', $token); }
function current_lang(): string { return ($_SESSION['lang'] ?? 'th') === 'en' ? 'en' : 'th'; }
function t(string $thai, string $english): string { return current_lang() === 'en' ? $english : $thai; }
function cart_items(): array { return is_array($_SESSION['cart'] ?? null) ? $_SESSION['cart'] : []; }
function cart_count(): int { return array_sum(array_map(static fn($item) => (int)($item['quantity'] ?? 0), cart_items())); }
function cart_key(int $productId, string $size = '', string $color = ''): string { return $productId.'|'.rawurlencode($size).'|'.rawurlencode($color); }
function cart_add(array $product, int $quantity = 1, string $size = '', string $color = ''): void {
    $quantity = max(1, $quantity); $key = cart_key((int)$product['id'], $size, $color);
    $existing = $_SESSION['cart'][$key] ?? null;
    $newQuantity = (int)($existing['quantity'] ?? 0) + $quantity;
    $_SESSION['cart'][$key] = ['product_id'=>(int)$product['id'], 'name'=>$product['name'], 'price'=>(float)$product['price'], 'image_url'=>$product['image_url'], 'size'=>$size, 'color'=>$color, 'quantity'=>min($newQuantity, max(0, (int)$product['stock']))];
    if ($_SESSION['cart'][$key]['quantity'] < 1) unset($_SESSION['cart'][$key]);
}
function cart_remove(string $key): void { unset($_SESSION['cart'][$key]); }
function cart_clear(): void { unset($_SESSION['cart']); }
function is_admin(): bool { return (current_user()['role'] ?? '') === 'admin'; }
function redirect(string $url): never { header('Location: '.$url); exit; }
function flash(string $key, ?string $message = null): ?string {
    if ($message !== null) { $_SESSION['flash'][$key] = $message; return null; }
    $value = $_SESSION['flash'][$key] ?? null; unset($_SESSION['flash'][$key]); return $value;
}
function e(?string $value): string { return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8'); }
function send_verification_email(string $email, string $name, string $code): bool {
    $_SESSION['mail_delivery_failed'] = true; $_SESSION['last_verification_code'] = $code;
    $subject = 'รหัสยืนยันบัญชี '.STORE_NAME;
    $body = "สวัสดี {$name}\n\nรหัสยืนยันของคุณคือ: {$code}\nรหัสนี้ใช้ได้ 15 นาที\n\n".STORE_NAME;
    if (MAIL_USERNAME === '' || MAIL_APP_PASSWORD === '') return @mail($email, $subject, $body, 'Content-Type: text/plain; charset=UTF-8');
    $socket = @stream_socket_client('tcp://smtp.gmail.com:587', $errno, $errstr, 15);
    if (!$socket) return false;
    $read = static function($socket): string { return (string)fgets($socket, 2048); };
    $expect = static function($socket, string $code) use ($read): bool { $line=''; while (($part=$read($socket)) !== '') { $line=$part; if (isset($part[3]) && $part[3] === ' ') break; } return str_starts_with($line, $code); };
    $expect($socket, '220'); fwrite($socket, "EHLO localhost\r\n"); $expect($socket, '250');
    fwrite($socket, "STARTTLS\r\n"); if (!$expect($socket, '220') || !@stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) { fclose($socket); return false; }
    fwrite($socket, "EHLO localhost\r\n"); $expect($socket, '250'); fwrite($socket, "AUTH LOGIN\r\n"); if (!$expect($socket, '334')) { fclose($socket); return false; }
    fwrite($socket, base64_encode(MAIL_USERNAME)."\r\n"); if (!$expect($socket, '334')) { fclose($socket); return false; }
    $appPassword = preg_replace('/\s+/', '', MAIL_APP_PASSWORD);
    fwrite($socket, base64_encode($appPassword)."\r\n"); if (!$expect($socket, '235')) { fclose($socket); return false; }
    fwrite($socket, "MAIL FROM:<".MAIL_USERNAME.">\r\n"); $expect($socket, '250'); fwrite($socket, "RCPT TO:<".$email.">\r\n"); if (!$expect($socket, '250')) { fclose($socket); return false; }
    fwrite($socket, "DATA\r\n"); if (!$expect($socket, '354')) { fclose($socket); return false; }
    $safeName = mb_encode_mimeheader(MAIL_FROM_NAME, 'UTF-8'); $safeSubject = mb_encode_mimeheader($subject, 'UTF-8');
    $headers = "From: {$safeName} <".MAIL_USERNAME.">\r\nTo: <{$email}>\r\nSubject: {$safeSubject}\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: 8bit\r\n\r\n";
    fwrite($socket, $headers.$body."\r\n.\r\n"); $ok=$expect($socket, '250'); fwrite($socket, "QUIT\r\n"); fclose($socket); $_SESSION['mail_delivery_failed'] = !$ok; return $ok;
}
