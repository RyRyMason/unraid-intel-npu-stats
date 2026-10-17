# Intel NPU Stats for Unraid

A small, **read-only** Unraid dashboard tile for the Intel NPU built into Core Ultra processors (Meteor Lake, Arrow Lake and later).

It shows:

| Field | Source (`intel_vpu` sysfs) |
|---|---|
| Busy % | `npu_busy_time_us`, delta between two polls |
| Peak Clock (MHz) | Highest `npu_current_frequency_mhz` reading in the last 10 s, bar scaled to `npu_max_frequency_mhz`. A single reading is often 0 because the NPU powers down between jobs. |
| Memory | `npu_memory_utilization` |
| Scheduler | `sched_mode` |

## Requirements

- Unraid 6.12 or newer (developed and tested on 7.3.3)
- Intel CPU with an NPU, `intel_vpu` driver loaded, kernel 6.11+ (for `npu_busy_time_us`)

## Install

In Unraid: **Plugins → Install Plugin**, paste:

```
https://raw.githubusercontent.com/RyRyMason/unraid-intel-npu-stats/main/intel-npu-stats.plg
```

Then open the Dashboard. If the tile isn't visible, enable **Intel NPU** in the dashboard's Content Manager.

## Remove

**Plugins → Installed Plugins → intel-npu-stats → Remove**, or:

```
plugin remove intel-npu-stats.plg
```

## How it works

- `npustat.php` reads the sysfs files and returns raw values as JSON. It keeps no state and runs nothing in the background.
- The tile polls it every 2 seconds (never faster than 1 s, as the kernel docs recommend), and only while the browser tab is visible.
- Busy % is calculated in the browser from the difference between two readings, using a monotonic timestamp.
- Nothing is written to the system. Uninstalling removes all plugin files.

## Build

```
bash build.sh [version]
```

Builds `pkg/intel-npu-stats-<version>-x86_64-1.txz` and stamps the version and MD5 into `intel-npu-stats.plg`.

## Status

Personal project, provided as-is with no support commitment.

## Licence and credit

MIT. The dashboard tile structure is adapted from [gpustat](https://github.com/b3rs3rk/gpustat-unraid) by b3rs3rk (MIT).
