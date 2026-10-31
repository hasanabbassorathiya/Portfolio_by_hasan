<?php
declare(strict_types=1);
// Shared enquiry logic. No configuration loading, runtime DDL, or public data route.
if (realpath($_SERVER['SCRIPT_FILENAME'] ?? '') === __FILE__) { http_response_code(404); exit; }

const ENQUIRY_TYPES = ['Employment', 'New application', 'Existing improvement', 'AI integration', 'Technical consultation', 'Other'];
const ENQUIRY_STATUSES = ['new', 'contacted', 'qualified', 'proposal', 'won', 'closed', 'spam'];
const ENQUIRY_MAX_BODY = 20480;
const ENQUIRY_MAX_ATTEMPTS = 5;

final class EnquiryError extends RuntimeException {
    public int $httpStatus;
    public string $errorCode;
    public function __construct(int $status, string $code) {
        parent::__construct($code);
        $this->httpStatus = $status;
        $this->errorCode = $code;
    }
}

function enquiry_check_request(array $server): void {
    if (($server['REQUEST_METHOD'] ?? '') !== 'POST') throw new EnquiryError(405, 'method_not_allowed');
    if (!preg_match('~^application/json(?:\s*;\s*charset\s*=\s*"?utf-8"?)?\s*$~iD', $server['CONTENT_TYPE'] ?? '')) {
        throw new EnquiryError(415, 'json_required');
    }
    if (isset($server['CONTENT_LENGTH']) && (!ctype_digit((string)$server['CONTENT_LENGTH']) || (float)$server['CONTENT_LENGTH'] > ENQUIRY_MAX_BODY)) {
        throw new EnquiryError(413, 'body_too_large');
    }
    // Never trust forwarded host/proto/IP headers. TLS-terminating hosts must set HTTPS correctly.
    $https = (!empty($server['HTTPS']) && $server['HTTPS'] !== 'off') || (int)($server['SERVER_PORT'] ?? 0) === 443;
    $expected = ($https ? 'https://' : 'http://') . strtolower($server['HTTP_HOST'] ?? '');
    $origin = strtolower($server['HTTP_ORIGIN'] ?? '');
    if ($origin === '' || !preg_match('~^https?://(?:[a-z0-9.-]+|\[[a-f0-9:]+\])(?::[0-9]{1,5})?$~D', $origin)
        || !hash_equals($expected, $origin)
        || (isset($server['HTTP_SEC_FETCH_SITE']) && $server['HTTP_SEC_FETCH_SITE'] !== 'same-origin')) {
        throw new EnquiryError(403, 'origin_not_allowed');
    }
}

function enquiry_text($value, string $field, int $min, int $max, bool $multiline = false): string {
    if (!is_string($value) || !preg_match('//u', $value)) throw new EnquiryError(422, 'invalid_' . $field);
    // Reject controls before trim, including header injection; allow LF/CR/tab only in long text.
    $controls = $multiline ? '/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/' : '/[\x00-\x1F\x7F]/';
    if (preg_match($controls, $value)) throw new EnquiryError(422, 'invalid_' . $field);
    $value = trim($value);
    $length = preg_match_all('/./us', $value);
    if ($length < $min || $length > $max) throw new EnquiryError(422, 'invalid_' . $field);
    return $value;
}

function enquiry_validate(string $raw): array {
    if (strlen($raw) > ENQUIRY_MAX_BODY) throw new EnquiryError(413, 'body_too_large');
    try { $object = json_decode($raw, false, 16, JSON_THROW_ON_ERROR); }
    catch (JsonException $e) { throw new EnquiryError(400, 'invalid_json'); }
    if (!$object instanceof stdClass) throw new EnquiryError(400, 'json_object_required');
    $input = (array)$object;
    $keys = ['name', 'email', 'type', 'message', 'website', 'consent', 'requestId'];
    if (array_diff(array_keys($input), $keys)) throw new EnquiryError(422, 'unexpected_field');
    $data = [];
    foreach (['name' => [1, 120], 'email' => [1, 190], 'type' => [1, 60], 'message' => [20, 10000], 'website' => [0, 255], 'requestId' => [36, 36]] as $field => [$min, $max]) {
        $data[$field] = enquiry_text($input[$field] ?? null, $field, $min, $max, $field === 'message');
    }
    if (($input['consent'] ?? null) !== true) throw new EnquiryError(422, 'consent_required');
    if (!enquiry_mail_address($data['email'])) throw new EnquiryError(422, 'invalid_email');
    if (!in_array($data['type'], ENQUIRY_TYPES, true)) throw new EnquiryError(422, 'invalid_type');
    if (!preg_match('/^[a-f0-9]{8}-[a-f0-9]{4}-[1-8][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/iD', $data['requestId'])) throw new EnquiryError(422, 'invalid_requestId');
    if ($data['website'] !== '') throw new EnquiryError(422, 'invalid_submission');
    $data['requestId'] = strtolower($data['requestId']);
    // Fixed key order, but original values: even changed whitespace is a different payload.
    $canonical = [];
    foreach ($keys as $key) if ($key !== 'requestId') $canonical[$key] = $input[$key];
    $data['payload_hash'] = hash('sha256', json_encode($canonical, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
    return $data;
}

function enquiry_ip_hash(string $ip, string $pepper): string {
    $packed = @inet_pton($ip);
    if ($packed === false || $pepper === '') throw new EnquiryError(503, 'enquiry_unavailable');
    return hash_hmac('sha256', $packed, $pepper);
}

function enquiry_submit(PDO $pdo, array $data, string $ipHash): string {
    // IP lock serializes count+insert across PHP workers, using a rolling hour (not a fixed window).
    // Deadlocks/unique-key races across different IPs retry the entire transaction, never only an insert.
    for ($attempt = 0; $attempt < 3; $attempt++) {
        try {
            $pdo->beginTransaction();
            $pdo->prepare('INSERT INTO enquiry_ip_locks (ip_hash) VALUES (?) ON DUPLICATE KEY UPDATE ip_hash = VALUES(ip_hash)')->execute([$ipHash]);
            $st = $pdo->prepare('SELECT reference, payload_hash FROM enquiries WHERE request_id = ? FOR UPDATE');
            $st->execute([$data['requestId']]);
            $existing = $st->fetch(PDO::FETCH_ASSOC);
            if ($existing) {
                if (!hash_equals($existing['payload_hash'], $data['payload_hash'])) throw new EnquiryError(409, 'request_conflict');
                $pdo->commit();
                return $existing['reference'];
            }
            $st = $pdo->prepare('SELECT COUNT(*) FROM enquiries WHERE ip_hash = ? AND created_at > UTC_TIMESTAMP() - INTERVAL 1 HOUR');
            $st->execute([$ipHash]);
            if ((int)$st->fetchColumn() >= 5) throw new EnquiryError(429, 'rate_limited');
            $reference = bin2hex(random_bytes(16));
            $pdo->prepare("INSERT INTO enquiries (reference, request_id, payload_hash, ip_hash, name, email, type, message, consent_at, notes, created_at, updated_at) VALUES (?,?,?,?,?,?,?,?,UTC_TIMESTAMP(),'',UTC_TIMESTAMP(),UTC_TIMESTAMP())")
                ->execute([$reference, $data['requestId'], $data['payload_hash'], $ipHash, $data['name'], $data['email'], $data['type'], $data['message']]);
            $id = (int)$pdo->lastInsertId();
            $st = $pdo->prepare('INSERT INTO enquiry_outbox (enquiry_id, kind, next_attempt_at, created_at, updated_at) VALUES (?,?,UTC_TIMESTAMP(),UTC_TIMESTAMP(),UTC_TIMESTAMP())');
            foreach (['owner', 'ack'] as $kind) $st->execute([$id, $kind]);
            $pdo->commit();
            return $reference;
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            if ($e instanceof PDOException && in_array((int)($e->errorInfo[1] ?? 0), [1062, 1205, 1213], true) && $attempt < 2) continue;
            throw $e;
        }
    }
    throw new EnquiryError(503, 'enquiry_unavailable');
}

function enquiry_validate_update(array $input): array {
    $status = enquiry_text($input['status'] ?? null, 'status', 1, 20);
    if (!in_array($status, ENQUIRY_STATUSES, true)) throw new EnquiryError(422, 'invalid_status');
    $notes = enquiry_text($input['notes'] ?? null, 'notes', 0, 10000, true);
    $next = enquiry_text($input['next_action'] ?? null, 'next_action', 0, 255);
    $date = enquiry_text($input['follow_up_date'] ?? null, 'follow_up_date', 0, 10);
    if ($date !== '') {
        if (!preg_match('/^[1-9][0-9]{3}-[0-9]{2}-[0-9]{2}$/D', $date)) throw new EnquiryError(422, 'invalid_follow_up_date');
        [$y, $m, $d] = array_map('intval', explode('-', $date));
        if (!checkdate($m, $d, $y)) throw new EnquiryError(422, 'invalid_follow_up_date');
    }
    return ['status' => $status, 'notes' => $notes, 'next_action' => $next, 'follow_up_date' => $date === '' ? null : $date];
}

function enquiry_update(PDO $pdo, int $id, int $version, array $input, int $adminId): void {
    $data = enquiry_validate_update($input);
    $st = $pdo->prepare('UPDATE enquiries SET status=?, notes=?, next_action=?, follow_up_date=?, updated_by=?, version=version+1, updated_at=UTC_TIMESTAMP() WHERE id=? AND version=?');
    $st->execute([$data['status'], $data['notes'], $data['next_action'], $data['follow_up_date'], $adminId, $id, $version]);
    if ($st->rowCount() !== 1) throw new EnquiryError(409, 'edit_conflict_reload_before_saving');
}

function enquiry_list(PDO $pdo, int $page, string $status = ''): array {
    $page = max(1, min(10000, $page));
    if ($status !== '' && !in_array($status, ENQUIRY_STATUSES, true)) throw new EnquiryError(422, 'invalid_status');
    $where = $status !== '' ? ' WHERE e.status = ?' : '';
    $sql = 'SELECT e.id, e.reference, e.name, e.type, e.status, e.next_action, e.follow_up_date, e.created_at, o.status AS owner_mail, a.status AS ack_mail FROM enquiries e LEFT JOIN enquiry_outbox o ON o.enquiry_id=e.id AND o.kind=\'owner\' LEFT JOIN enquiry_outbox a ON a.enquiry_id=e.id AND a.kind=\'ack\'' . $where . ' ORDER BY e.created_at DESC, e.id DESC LIMIT 26 OFFSET ?';
    $st = $pdo->prepare($sql);
    $index = 1;
    if ($status !== '') $st->bindValue($index++, $status, PDO::PARAM_STR);
    $st->bindValue($index, ($page - 1) * 25, PDO::PARAM_INT);
    $st->execute();
    $rows = $st->fetchAll(PDO::FETCH_ASSOC);
    return ['rows' => array_slice($rows, 0, 25), 'page' => $page, 'has_more' => count($rows) > 25 && $page < 10000];
}

function enquiry_detail(PDO $pdo, int $id): ?array {
    $st = $pdo->prepare('SELECT id, reference, name, email, type, message, status, notes, next_action, follow_up_date, version, updated_by, consent_at, consent_version, created_at, updated_at FROM enquiries WHERE id=?');
    $st->execute([$id]);
    $row = $st->fetch(PDO::FETCH_ASSOC);
    if (!$row) return null;
    $st = $pdo->prepare('SELECT id, kind, status, attempts, total_attempts, next_attempt_at, last_error, accepted_at FROM enquiry_outbox WHERE enquiry_id=? ORDER BY id');
    $st->execute([$id]);
    $row['outbox'] = $st->fetchAll(PDO::FETCH_ASSOC);
    return $row;
}

function enquiry_escape($value): string { return htmlspecialchars((string)($value ?? ''), ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }

function enquiry_mail_address(string $value): bool {
    return strlen($value) <= 190 && (bool)preg_match('/^[A-Za-z0-9.!#$%&\'*+\/=?^_`{|}~-]+@[A-Za-z0-9.-]+$/D', $value) && filter_var($value, FILTER_VALIDATE_EMAIL) !== false;
}

function enquiry_mail_settings(string $owner, string $from): array {
    if (!enquiry_mail_address($owner) || !enquiry_mail_address($from)) throw new EnquiryError(503, 'mail_configuration_required');
    return ['owner' => $owner, 'from' => $from];
}

function enquiry_mail_message(array $lead, string $kind, array $settings): array {
    if (!in_array($kind, ['owner', 'ack'], true) || !preg_match('/^[a-f0-9]{32}$/D', $lead['reference'])) throw new EnquiryError(503, 'invalid_notification');
    $to = $kind === 'owner' ? $settings['owner'] : $lead['email'];
    if (!enquiry_mail_address($to) || !enquiry_mail_address($settings['from'])) throw new EnquiryError(503, 'invalid_notification');
    $body = $kind === 'owner'
        ? "A portfolio enquiry has been saved.\nReference: " . $lead['reference'] . "\nOpen your private portfolio admin: /admin/enquiries.php?id=" . (int)$lead['id'] . "\n"
        : "Your portfolio enquiry has been saved for review.\nReference: " . $lead['reference'] . "\nThis acknowledgement does not confirm availability or a response time.\nIf you did not submit an enquiry, no action is required.\n";
    return ['to' => $to, 'subject' => $kind === 'owner' ? 'New portfolio enquiry' : 'Portfolio enquiry received', 'body' => $body,
        'headers' => 'From: ' . $settings['from'] . "\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: 8bit\r\nAuto-Submitted: auto-generated"];
}

function enquiry_native_mail(array $mail): bool {
    if (!is_callable('mail')) throw new EnquiryError(503, 'transport_unavailable');
    // No fifth (shell) argument, recipient-supplied headers or contact text in subjects.
    // true means only local transport acceptance, never inbox delivery.
    return @mail($mail['to'], $mail['subject'], $mail['body'], $mail['headers']);
}

function enquiry_worker_lock_name(PDO $pdo): string {
    return 'enquiry-mail-' . substr(hash('sha256', (string)$pdo->query('SELECT DATABASE()')->fetchColumn()), 0, 40);
}

function enquiry_worker(PDO $pdo, bool $send, int $limit, ?int $retryId, bool $acceptDuplicate, array $settings, callable $transport, callable $log): void {
    $limit = max(1, min(100, $limit));
    $due = "status IN ('pending','failed') AND attempts < " . ENQUIRY_MAX_ATTEMPTS . ' AND next_attempt_at IS NOT NULL AND next_attempt_at <= UTC_TIMESTAMP()';
    if (!$send) {
        $st = $pdo->prepare('SELECT id FROM enquiry_outbox WHERE ' . $due . ($retryId !== null ? ' AND id=?' : '') . ' ORDER BY id LIMIT ?');
        $i = 1;
        if ($retryId !== null) $st->bindValue($i++, $retryId, PDO::PARAM_INT);
        $st->bindValue($i, $limit, PDO::PARAM_INT);
        $st->execute();
        foreach ($st->fetchAll(PDO::FETCH_COLUMN) as $id) $log((int)$id, 'dry-run');
        return;
    }
    // Validate before mutating. A MySQL connection-scoped lock serializes actual transports.
    $settings = enquiry_mail_settings($settings['owner'] ?? '', $settings['from'] ?? '');
    $lock = enquiry_worker_lock_name($pdo);
    $st = $pdo->prepare('SELECT GET_LOCK(?, 0)'); $st->execute([$lock]);
    if ((int)$st->fetchColumn() !== 1) throw new EnquiryError(409, 'worker_busy');
    try {
        // A previous worker lost its connection/process during a send. Never blindly resend it.
        $pdo->exec("UPDATE enquiry_outbox SET status='failed', last_error='acceptance_unknown', next_attempt_at=NULL, claim_token=NULL, updated_at=UTC_TIMESTAMP() WHERE status='processing'");
        if ($retryId !== null) {
            $st = $pdo->prepare('SELECT status, last_error FROM enquiry_outbox WHERE id=?'); $st->execute([$retryId]);
            $row = $st->fetch(PDO::FETCH_ASSOC);
            if (!$row || $row['status'] !== 'failed') throw new EnquiryError(409, 'retry_requires_failed_row');
            if ($row['last_error'] === 'acceptance_unknown' && !$acceptDuplicate) throw new EnquiryError(409, 'retry_may_duplicate_use_accept_duplicate_risk');
            $pdo->prepare("UPDATE enquiry_outbox SET status='pending', attempts=0, next_attempt_at=UTC_TIMESTAMP(), updated_at=UTC_TIMESTAMP() WHERE id=?")->execute([$retryId]);
        }
        for ($count = 0; $count < $limit; $count++) {
            $st = $pdo->prepare('SELECT id, enquiry_id, kind, attempts FROM enquiry_outbox WHERE ' . $due . ($retryId !== null ? ' AND id=?' : '') . ' ORDER BY id LIMIT 1');
            $st->execute($retryId !== null ? [$retryId] : []);
            $row = $st->fetch(PDO::FETCH_ASSOC);
            if (!$row) break;
            $id = (int)$row['id'];
            $claim = bin2hex(random_bytes(16));
            $pdo->prepare("UPDATE enquiry_outbox SET status='processing', attempts=attempts+1, total_attempts=total_attempts+1, claim_token=?, claimed_at=UTC_TIMESTAMP(), updated_at=UTC_TIMESTAMP() WHERE id=? AND " . $due)->execute([$claim, $id]);
            $error = null;
            $accepted = false;
            try {
                $lead = enquiry_detail($pdo, (int)$row['enquiry_id']);
                if ($lead === null) throw new EnquiryError(503, 'invalid_notification');
                $message = enquiry_mail_message($lead, $row['kind'], $settings);
            } catch (Throwable $e) { $error = 'transport_unavailable'; }
            if ($error === null) {
                try {
                    $accepted = $transport($message) === true;
                    if (!$accepted) $error = 'transport_rejected';
                } catch (Throwable $e) {
                    $error = $e instanceof EnquiryError && $e->errorCode === 'transport_unavailable' ? 'transport_unavailable' : 'acceptance_unknown';
                }
            }
            $attempts = (int)$row['attempts'] + 1;
            $next = !$accepted && $error !== 'acceptance_unknown' && $attempts < ENQUIRY_MAX_ATTEMPTS
                ? gmdate('Y-m-d H:i:s', time() + min(86400, 60 * (2 ** ($attempts - 1)))) : null;
            // If this write fails after mail(), the processing record remains ambiguous for recovery.
            $st = $pdo->prepare('UPDATE enquiry_outbox SET status=?, last_error=?, next_attempt_at=?, accepted_at=CASE WHEN ?=1 THEN UTC_TIMESTAMP() ELSE NULL END, claim_token=NULL, updated_at=UTC_TIMESTAMP() WHERE id=? AND status=\'processing\' AND claim_token=?');
            $st->execute([$accepted ? 'sent' : 'failed', $error, $next, $accepted ? 1 : 0, $id, $claim]);
            if ($st->rowCount() !== 1) throw new EnquiryError(503, 'claim_lost');
            $log($id, $accepted ? 'sent_transport_accepted' : 'failed_' . $error);
        }
    } finally {
        $st = $pdo->prepare('SELECT RELEASE_LOCK(?)'); $st->execute([$lock]);
    }
}
