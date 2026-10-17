<?php
/*
 * intel-npu-stats: read-only Intel NPU counters from the intel_vpu sysfs interface.
 * Stateless. The dashboard tile computes busy % from the delta between two polls.
 * Copyright (c) 2026 RyRyMason. MIT License (see LICENSE).
 */
header('Content-Type: application/json');
header('Cache-Control: no-store');

$dev = glob('/sys/bus/pci/drivers/intel_vpu/0000:*');
if (!$dev) {
  http_response_code(404);
  echo json_encode(['ok' => false, 'error' => 'intel_vpu device not found']);
  exit;
}
$p = $dev[0];

function rd(string $f): ?string { $v = @file_get_contents($f); return $v === false ? null : trim($v); }
function rdi(string $f): ?int  { $v = rd($f); return ($v === null || !is_numeric($v)) ? null : (int)$v; }

$busy = rdi("$p/npu_busy_time_us");
echo json_encode([
  'ok'           => $busy !== null,
  'ts_us'        => intdiv(hrtime(true), 1000),   // monotonic clock, microseconds
  'busy_us'      => $busy,
  'mem_bytes'    => rdi("$p/npu_memory_utilization"),
  'freq_mhz'     => rdi("$p/npu_current_frequency_mhz"),
  'max_freq_mhz' => rdi("$p/npu_max_frequency_mhz"),
  'sched_mode'   => rd("$p/sched_mode"),
  'pci'          => basename($p),
]);
