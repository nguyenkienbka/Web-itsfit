---
name: itsfitlab-vps
description: Chạy lệnh trên VPS itsfitlab (129.150.51.181, Oracle Cloud, Ubuntu 22.04, nginx). Dùng khi người dùng muốn thao tác trên VPS/server/máy chủ — kiểm tra dịch vụ, đọc log, sửa nginx, deploy website, restart service — hoặc nhắc tới "VPS", "itsfitlab", "129.150.51.181", "server", "deploy", "nginx", "kết nối đến VPS". Bắt buộc đọc trước khi thử ssh/curl tới VPS, vì kết nối trực tiếp từ sandbox luôn thất bại và skill này mô tả đường đi duy nhất hoạt động được.
---

# VPS itsfitlab

## Đừng thử SSH trực tiếp — nó không bao giờ chạy

Sandbox của Claude Code **không thể** kết nối tới `129.150.51.181`. Đã kiểm chứng:

| Kiểm tra | Kết quả |
|---|---|
| `nc 129.150.51.181 22` | timeout (exit 124) |
| Egress proxy `CONNECT :443` | `403 host_not_allowed` |
| `ssh` client trong container | không được cài |
| `~/.ssh/` | trống |

Egress proxy chỉ tunnel HTTP/HTTPS qua `CONNECT`. SSH là raw TCP nên không đi qua được **kể cả khi host được thêm vào allowlist** — đây là giới hạn kiến trúc, không phải vấn đề policy. `/root/.ccr/README.md` liệt kê raw-TCP trong mục "Not supported through the proxy (report, do not work around)".

Đừng lãng phí lượt gọi để thử lại `ssh`, `nc`, `curl` tới VPS, và tuyệt đối không tìm cách lách proxy.

## Đường đi hoạt động được

GitHub Actions runner không bị giới hạn egress. Workflow `.github/workflows/vps-exec.yml` nhận lệnh làm input rồi SSH vào VPS.

Claude tự chạy toàn bộ, người dùng không cần thao tác gì:

**1. Trigger** (`ref` phải là default branch — hiện là `claude/simple-ios-app-ocjjan`):

```
mcp__github__actions_run_trigger
  method: run_workflow
  owner: nguyenkienbka
  repo: Web-itsfit
  workflow_id: vps-exec.yml
  ref: <default branch>
  inputs: {"command": "...", "workdir": "~", "timeout_seconds": "60"}
```

**2. Chờ** ~60–75 giây. Dùng Bash `run_in_background` với vòng `until`, không dùng `sleep` foreground (bị chặn).

**3. Lấy run id** — `list_workflow_runs` với `resource_id: vps-exec.yml`, `per_page: 1`. Output rất dài; đừng đoán run id, lần nào cũng phải tra.

**4. Lấy job id** — `list_workflow_jobs` với `resource_id: <run id>`.

**5. Đọc log** — `get_job_logs` với `job_id`, `return_content: true`, `tail_lines: 64`. Output của VPS nằm giữa dòng `--- host: ... ---` và `--- exit code: N ---`.

## Bốn cái bẫy đã gặp

**Secret dính khoảng trắng.** `VPS_HOST` từng có tab đứng trước, ssh báo `hostname contains invalid characters` (exit 255). Workflow giờ tự `tr -d '[:space:]'` cho host/user/port và phát `::warning::` khi cắt. `VPS_PASSWORD` cố tình **không** trim.

**`env:` cấp step ghi đè `GITHUB_ENV`.** `VPS_HOST`/`VPS_USER`/`VPS_PORT` chỉ được khai báo ở step đầu. Thêm lại vào `env:` của step sau sẽ kéo giá trị thô còn dính khoảng trắng quay lại.

**Tilde không expand.** `WORKDIR` đi qua `printf %q` nên bị bọc nháy đơn, `cd '~'` sẽ fail. Remote script tự resolve `~` và `~/...` theo `$HOME`. Truyền `~` vào input là an toàn.

**GitHub che secret trong log.** `VPS_USER` = `root`, nên mọi chuỗi "root" bị thay bằng `***`, kể cả trong `/root` → `/***`. Không phải lỗi, đừng đi debug nó.

## Sửa workflow

`workflow_dispatch` chỉ chạy bản nằm trên **default branch**. Sửa xong phải commit lên branch làm việc, mở PR, merge vào default branch, rồi mới trigger — nếu không sẽ chạy bản cũ.

## Secrets

Đã cấu hình trong repo settings: `VPS_HOST`, `VPS_USER`, `VPS_PASSWORD`. `VPS_PORT` tuỳ chọn (mặc định 22).

Claude **không có tool ghi GitHub Secrets** — nếu thiếu hoặc sai, phải nhờ người dùng tự sửa. Không bao giờ đặt credential vào file trong repo: **repo này là public**.

Workflow hỗ trợ cả `VPS_SSH_KEY` (qua `ssh -i`) lẫn `VPS_PASSWORD` (qua `sshpass -e`); có key thì key được ưu tiên. Chuyển sang key chỉ cần thêm secret, không phải sửa code.

## Thông tin máy

Đo ngày 2026-07-26:

- `instance-20231231-0858`, Oracle Cloud, Ubuntu 22.04.3 LTS
- Disk `/dev/sda1`: 89G, dùng 18G, trống 71G
- RAM 11Gi, khả dụng ~6Gi; swap 5Gi chưa dùng
- **nginx active**; apache2 và docker inactive
- Uptime 64 ngày, load ~0

Đây là ảnh chụp tại thời điểm đó, không phải trạng thái hiện tại — cần số liệu mới thì chạy lệnh kiểm tra lại.

## Website itsfitlab.com trên máy này

WordPress 7.0.2 + WooCommerce, EasyEngine-style, đứng sau Cloudflare.

- Webroot `/var/www/itsfitlab.com/htdocs`, wp-cli tại `/usr/local/bin/wp` (cần `--allow-root`)
- Site config `/etc/nginx/sites-available/itsfitlab.com`, `server_name itsfitlab.com www.itsfitlab.com`
- Cache config `/etc/nginx/common/wpfc.conf` (include ở dòng 36 của site config)
- fastcgi cache ở `/run/nginx-cache`, keys_zone `WORDPRESS`, `fastcgi_cache_valid 200 30d`

**Test HTTP phải dùng HTTPS.** `curl http://127.0.0.1/...` chỉ nhận redirect 80→443, chưa chạm WordPress. Dùng:

```sh
curl -skI --resolve itsfitlab.com:443:127.0.0.1 https://itsfitlab.com/<path>
```

**Sự cố markdown (đã xử lý 2026-07-27).** `fastcgi_cache_key` là `"$scheme$request_method$host$request_uri"` — không chứa `Accept`, trong khi origin trả `Vary: accept`. Một request `Accept: text/markdown` từng sinh bản markdown rồi đè lên bản HTML dùng chung entry, làm 6 URL phát markdown thô cho mọi khách.

Đã thêm vào cuối `wpfc.conf`:

```nginx
if ($http_accept ~* "text/markdown") {
    set $skip_cache 1;
}
```

Bản markdown vẫn phục vụ được nhưng không vào cache. Nếu tái diễn, tìm và xoá đúng entry hỏng thay vì xoá sạch cache:

```sh
grep -rli 'content-type: *text/markdown' /run/nginx-cache/
```

**Sau `systemctl reload nginx`, đừng test ngay.** Reload là graceful, worker cũ vẫn phục vụ vài giây — một lần kiểm chứng đã báo `HIT` nhầm rồi mới ra `BYPASS` ở lượt sau.

## Lưu ý an toàn

Lệnh chạy dưới quyền `root`. Với thao tác khó đảo ngược (xoá dữ liệu, sửa config đang phục vụ, restart service production), xác nhận với người dùng trước. Đọc file config trước khi ghi đè.
