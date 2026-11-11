<?php
declare(strict_types=1);
// Shared upload core. Caller (upload.php / media.php) has already authenticated,
// checked CSRF, and loaded bootstrap. Direct hits are refused.
if (realpath($_SERVER['SCRIPT_FILENAME'] ?? '') === __FILE__) { http_response_code(404); exit; }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_out(['error' => 'method not allowed'], 405);

$folder = (string)($_POST['folder'] ?? 'uploads');
if (!preg_match('/\A[a-z0-9][a-z0-9-]{0,59}\z/', $folder)) {
    json_out(['error' => 'invalid folder'], 400);
}
$file = $_FILES['file'] ?? null;
if (!is_array($file) || ($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
    json_out(['error' => 'no file uploaded'], 400);
}
if (($file['size'] ?? 0) <= 0 || $file['size'] > 8 * 1024 * 1024) {
    json_out(['error' => 'file must be between 1 byte and 8 MB'], 413);
}
if (!is_uploaded_file($file['tmp_name'])) json_out(['error' => 'invalid upload'], 400);

$mime = (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']) ?: '';
$extensions = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/avif' => 'avif',
    'image/gif' => 'gif',
];
if (!isset($extensions[$mime])) {
    json_out(['error' => 'only JPEG, PNG, WebP, AVIF or GIF images are allowed'], 415);
}
$ext = $extensions[$mime];
$size = @getimagesize($file['tmp_name']);
if ($size === false && $mime !== 'image/avif') {
    json_out(['error' => 'file is not a readable image'], 415);
}
$width = (int)($size[0] ?? 0);
$height = (int)($size[1] ?? 0);

// Reject decompression bombs before GD allocates: a tiny file can declare gigapixels.
if ($width > 0 && $height > 0 && $width * $height > 40_000_000) {
    json_out(['error' => 'image dimensions are too large'], 413);
}

// Cap oversized raster images at 2400px on the long edge when GD is available.
if (max($width, $height) > 2400 && function_exists('imagecreatetruecolor')) {
    $source = match ($mime) {
        'image/jpeg' => @imagecreatefromjpeg($file['tmp_name']),
        'image/png' => @imagecreatefrompng($file['tmp_name']),
        'image/webp' => @imagecreatefromwebp($file['tmp_name']),
        'image/avif' => function_exists('imagecreatefromavif') ? @imagecreatefromavif($file['tmp_name']) : null,
        default => null,
    };
    if ($source) {
        $scale = 2400 / max($width, $height);
        $newW = max(1, (int)round($width * $scale));
        $newH = max(1, (int)round($height * $scale));
        $canvas = imagecreatetruecolor($newW, $newH);
        if (in_array($mime, ['image/png', 'image/webp', 'image/avif'], true)) {
            imagealphablending($canvas, false);
            imagesavealpha($canvas, true);
            imagefill($canvas, 0, 0, imagecolorallocatealpha($canvas, 0, 0, 0, 127));
        }
        imagecopyresampled($canvas, $source, 0, 0, 0, 0, $newW, $newH, $width, $height);
        $saved = match ($mime) {
            'image/jpeg' => imagejpeg($canvas, $file['tmp_name'], 84),
            'image/png' => imagepng($canvas, $file['tmp_name'], 8),
            'image/webp' => imagewebp($canvas, $file['tmp_name'], 84),
            'image/avif' => function_exists('imageavif') ? imageavif($canvas, $file['tmp_name'], 60) : false,
            default => false,
        };
        if ($saved) {
            $width = $newW;
            $height = $newH;
            $file['size'] = (int)filesize($file['tmp_name']);
        }
    }
}

$root = dirname(__DIR__);
$dir = $root . '/media/uploads/' . $folder;
if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
    json_out(['error' => 'could not create upload directory'], 500);
}
$name = $folder . '-' . bin2hex(random_bytes(4)) . '.' . $ext;
$target = $dir . '/' . $name;
if (!move_uploaded_file($file['tmp_name'], $target)) {
    json_out(['error' => 'could not store the upload'], 500);
}
@chmod($target, 0644);

$path = '/media/uploads/' . $folder . '/' . $name;
try {
    db()->prepare('INSERT INTO media (path, folder, mime, bytes, width, height) VALUES (?,?,?,?,?,?)')
        ->execute([$path, $folder, $mime, (int)$file['size'], $width, $height]);
} catch (Throwable $e) {
    // The file is already served from disk; the library row is best-effort
    // until api/v2-schema.sql is imported.
}

json_out([
    'path' => $path,
    'url' => $path,
    'mime' => $mime,
    'bytes' => (int)$file['size'],
    'width' => $width,
    'height' => $height,
], 201);