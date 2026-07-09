# Roblox FE Headless Script

Script hỗ trợ ẩn phần đầu nhân vật (Headless) bằng phương pháp dịch chuyển tọa độ khớp nối cổ hoạt động trên cơ chế FilteringEnabled (FE - Người chơi xung quanh đều nhìn thấy).

## Tính năng
- **Bypass FE**: Người chơi khác trong server đều thấy bạn không có đầu.
- **Auto-Rebirth Support**: Tự động nhận diện và áp dụng lại sau khi nhân vật hồi sinh.
- **Toggle Key**: Phím bật/tắt nhanh tiện lợi (Mặc định: `H`).

## Cách sử dụng

Sao chép lệnh dưới đây và dán vào Executor của bạn:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO_NAME/main/build/bundled.lua"))()
