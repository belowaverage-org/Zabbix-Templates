# BA Zabbix Templates

This repository ships a consolidated Zabbix **export** of Below Average (BA) monitoring templates, macros, dashboards, procedures, and profiles designed to bootstrap comprehensive monitoring for networks, servers, UPS units, cameras, and more.

> **Highlights**
> 
> -   Turn‑key profiles for common vendors (Aruba, Cisco, MikroTik, HPE iLO, Dell iDRAC, APC/CyberPower UPS, VMWare/vSphere, Windows, Linux, Avigilon/Axis cameras, pfSense, Ruckus, Ubiquiti).
> -   Ready‑made dashboards (ICMP, SNMP, Interfaces, UPS, RouterOS, iLO/iDRAC, Zabbix internals).
> -   Opinionated **macros** with sane thresholds for CPU/MEM, ICMP, interface errors/discards, temperature, etc.
> -   Discovery‑heavy SNMP coverage (IF, LLDP, BRIDGE, Q‑BRIDGE, ENTITY, HOST‑RESOURCES, UPS, VMWARE‑VMINFO).
> -   Lightweight HTTP/SSH pollers for GitHub releases, Axis/ONVIF, Center Click NTP, Veeam, and config backup shims.
> -   Utility procedures (auto‑maintenance via **Dependable** tag, auto‑rename hosts from inventory).

## Contents

The single file **`combined.yaml`** includes:

-   **Template groups** under `BA/*` (Generic, HTTP, Macros, MIBs, ONVIF, Procedures, Profiles, SSH).
-   **Base pollers**
    -   `BA - Generic - ICMP` (loss/latency/status + dashboard)
    -   `BA - Internal - Zabbix` (server caches, processes, value/write cache usage + dashboard)
-   **HTTP pollers** (Axis, EarthCam status, GitHub releases & per‑release downloads, Center Click NTP metrics, Veeam REST)
-   **SNMP MIB packs** (APC, CyberPower, Generic RFC1213, Host‑Resources, Interfaces + Aruba/LLDP/MAC/POE/VLAN extensions, iLO, iDRAC, MikroTik, UPS, vSphere VMs, Windows LanMgr)
-   **ONVIF (Avigilon)** via shim (scopes, media sources, device info; model/serial/name/mac/firmware extraction).
-   **SSH** pollers: generic SSH up, Aruba config via HTTP shim, MikroTik `export`, NUT/UPS discovery (charge/runtime/status/voltage).
-   **Procedures**: Dependable maintenance automation; Update Visible Name via Inventory.
-   **Profiles**: curated bundles per vendor/device (“wizard ready”).
-   **Dashboards & Graphs**: ICMP, Zabbix stats, Aruba, SNMP basics, Host Resources, Interfaces (grid), iLO/iDRAC, UPS, RouterOS, Center Click NTP, etc.
-   **Valuemaps**: friendly emoji statuses across battery/UPS/object/fan/PSU/oper status, etc.

## Quick Start

### 1) Import into Zabbix

1.  Log in as Admin → **Configuration → Templates → Import**.
2.  Select `combined.yaml` and import with defaults (ensure **Zabbix 7.4**).

> After import, you’ll see new template groups under `BA/*` and dashboards listed in the export.

### 2) Link a Profile to a Host

Profiles bundle base pollers, SNMP sets, and dashboards. Examples:

-   **Aruba CX Switch** → `BA - Profile - Aruba CX Switch` (ICMP, Macros, Entity, Generic, Host Resources, Interfaces, LLDP, MAC, POE, MAC‑to‑IP (IP), Update Name, SSH Aruba Config).
-   **Cisco IOS / Small Business** → respective BA profiles (IF/LLDP/MAC/POE/VLAN variants).
-   **MikroTik** → `BA - Profile - MikroTik` (MIB MikroTik + SSH export).
-   **UPS (APC/CyberPower/generic UPS‑MIB)** → `BA - Profile - APC`, `BA - Profile - Cyber Power`, `BA - Profile - UPS`.
-   **Servers**
    -   **HPE iLO** → `BA - Profile - iLO` (plus Interfaces discovery for NICs)
    -   **Dell iDRAC** → `BA - Profile - iDRAC`
    -   **Windows** → `BA - Profile - Windows` (LanMgr services + SNMP HR/IF + SSH optional)
    -   **Linux** → `BA - Profile - Linux` (RFC1213/HR/IF + SSH optional)
-   **Cameras**
    -   **Avigilon (ONVIF)** → `BA - Profile - Avigilon` (shim‑backed ONVIF polling)
    -   **Axis (HTTP)** → `BA - Profile - Axis`
-   **VMware** → `BA - Profile - vSphere` (VMINFO + host resources)
-   **Edge firewalls** → `BA - Profile - pfSense`
-   **Wireless** → `BA - Profile - Ruckus`, `BA - Profile - Ubiquiti`.

Link the profile on the host’s **Templates** tab and make sure the host’s **SNMP**, **SSH**, or **HTTP** connectivity and credentials/macros are set accordingly.

## Required Host Interfaces & Access

Depending on the chosen profile/template, you’ll need:

-   **SNMP** (v2/v3) enabled and reachable for all MIB‑based templates.
-   **SSH** for RouterOS export, NUT UPS, and Aruba config via shim (or native).
-   **HTTP/HTTPS** for Axis camera parameters, EarthCam status, GitHub API, Center Click NTP JSON, Veeam REST, and ONVIF shim calls.
-   **ICMP** for base availability/latency/loss triggers and dashboards.

## Global Macros (Defaults & Meaning)

Many thresholds and integration endpoints are parameterized via **macros**. Key ones:

### Generic thresholds (`BA - Macro - Generic`)

-   `{$CPU_USAGE_WARN}` = **90** (%); `{$CPU_HIGH_AVG_TIME_WARN}` = **15m**.
-   `{$MEM_USAGE_WARN}` = **95** (%).
-   `{$DISK_HIGH_AVG_PERC_WARN}` = **95** (%).
-   `{$ICMP_HIGH_LATENCY_WARN}` = **500 ms**; `{$ICMP_HIGH_LOSS_WARN}` = **0.5 %** over `{$ICMP_HIGH_LOSS_WARN_PERIOD}` = **24h**.
-   `{$TEMP_C_WARN}` = **75°C** (temperature triggers).
-   `{$REBOOT_WARN_DURATION}` = **10m** (recent reboot alert window).
-   `{$SOFTWARE_VERSION_STRINGS}` (regex for acceptable versions in Aruba/MikroTik checks).

### Interfaces (`BA - Macro - Interfaces`)

-   Errors/Discards/Flaps time & count thresholds, uplink detection limits, and **filter regex** to ignore virtual/tunnel/loopback/etc.

### Windows (`BA - Macro - Windows`)

-   Regex lists of **services to poll** and **to ignore** via LanMgr.

### Procedure Macros

-   `{$ZABSELFAPI}`, `{$ZABSELFKEY}` (Zabbix API endpoint + token) for procedures like **Update Name** and **Dependable** automation.
-   `{$DEPENDABLE}` string to link dependable host → dependent hosts via tag `Dependable=<value>`.

### Integrations (set per environment)

-   **Axis**: `{$AXIS_CAM_USERNAME}`, `{$AXIS_CAM_PASSWORD}`.
-   **ONVIF Avigilon**: `{$ONVIF_SHIM_URL}`, `{$AVIG_CAM_USERNAME}`, `{$AVIG_CAM_PASSWORD}`.
-   **Center Click NTP**: host must serve `/json`.
-   **Veeam REST**: `{$VEEAM_USER}`, `{$VEEAM_PASS}` (OAuth, `https://<host>:9419/api/`).
-   **SSH shims**: `{$SSH_SHIM_URL}`, Aruba creds `{$ARUBA_SSH_USER}`, `{$ARUBA_SSH_PASS}`; MikroTik `{$ROS_SSH_USER}`, `{$ROS_SSH_PASS}`; generic `{$SSH_USERNAME}`, `{$SSH_PASSWORD}` for NUT.

> **Tip:** define these as **Global macros** (Administration → General → Macros) or on Host/Template levels as appropriate.

## Dashboards (Examples)

-   **⏱️ ICMP** — Status gauge, latency gauge, and 3‑series ICMP graph.
-   **📖 SNMP** — Name/Location/Description items + Uptime graph.
-   **🌐 Interfaces** — Graph‑prototype grid for per‑interface rates/errors.
-   **📈 Zabbix Statistics** — Value/Write cache usage, counts, top items.
-   **🔋 UPS / 💡 iLO / iDRAC / 🔀 RouterOS / 🕑 Center Click NTP** — vendor‑specific layouts.

All dashboards are included in the export and will appear after import.

## Triggers & Valuemaps

The templates standardize statuses with emoji **valuemaps** (e.g., 🟢 OK, 🔴 Failed, 🟡 Warning) across battery/UPS/object/fan/PSU/oper states, plus threshold triggers for CPU/MEM/usage/errors/discards/temperature, “Device offline,” “SNMP not responding,” “recent reboot,” and more.

## Procedures

### Dependable Maintenance

-   Link `BA - Procedure - Dependable` on your **dependable** host.
-   Set `{$DEPENDABLE}` (e.g., `Branch-XYZ`).
-   On **dependent** hosts, add tag `Dependable=Branch-XYZ`.
-   The procedure auto‑creates or removes **maintenance** windows for dependents based on the dependable host’s ICMP status.

### Update Visible Name via Inventory

-   Optional script that renames host visible name using Inventory → `name` (uppercased prefix + `(host)`), requires `{$ZABSELFAPI}` and `{$ZABSELFKEY}`. Disabled by default.

## Known External Dependencies

Some templates call **shims** or external APIs:

-   **ONVIF Shim**: HTTP endpoint that accepts SOAP and returns XML→JSON for device scopes/media/info. Set `{$ONVIF_SHIM_URL}`.
-   **SSH Config Shim (Aruba)**: `{$SSH_SHIM_URL}` to post “show run” and capture running config.
-   **Veeam REST API**: OAuth password grant to get token and poll `v1/jobs/states` & `v1/serverInfo`.
-   **GitHub API**: releases list & download counts per tag (`github.releases`, dependent item prototypes).
-   **Center Click NTP**: expects `http://{HOST.HOST}/json` with structured fields (ntp.jitter/clients/pps, gps.sat/snr, temp.soc, cpu.used).

Ensure firewall/DNS/certs and credentials are configured for these endpoints.

## Troubleshooting

-   **Template import fails / version mismatch** → confirm Zabbix **7.4** server and UI.
-   **No SNMP data** → verify SNMP community/user (v2/v3), ACLs, firewall, and host interface in Zabbix.
-   **Axis/ONVIF/Center Click/Veeam polls fail** → check HTTP creds, shim URLs, SSL trust, and “Device offline” dependency triggers.
-   **SSH items unsupported** → validate creds, enable service, and ensure the device allows command execution (`export show-sensitive` on MikroTik; NUT tools present).
-   **Interface noise** → tune `{$INTER_FILTER_REGEX}` and thresholds for errors/discards/usage; disable triggers on Wi‑Fi via provided overrides.
-   **Host rename procedure fails** → verify `{$ZABSELFAPI}` and `{$ZABSELFKEY}`; check trigger “Device name could not be updated.”

## License & Attribution

-   Authored as “**below average**” vendor templates; bundled for convenience.
-   Review all thresholds/macros to match your environment before production.
