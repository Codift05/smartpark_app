# 🐛 Flutter Debugging Setup - Hot Reload Otomatis

## ✅ Setup Selesai!

File konfigurasi debugging sudah dibuat di `.vscode/`:
- ✅ `launch.json` - Konfigurasi debugging
- ✅ `settings.json` - Hot reload otomatis
- ✅ `tasks.json` - Flutter tasks

---

## 🚀 Cara Menggunakan Debugging

### Metode 1: Pakai Debug Panel (RECOMMENDED)

1. **Buka Debug Panel:**
   - Tekan `Ctrl + Shift + D` (Windows/Linux)
   - Atau klik icon bug di sidebar kiri

2. **Pilih Konfigurasi:**
   - Di dropdown atas, pilih **"smartpark_app"**

3. **Start Debugging:**
   - Tekan `F5` atau klik tombol hijau ▶️ "Start Debugging"
   - App akan otomatis run di emulator

4. **Hot Reload Otomatis:**
   - Setiap kali **save file** (`Ctrl + S`), app akan otomatis **hot reload**!
   - Lihat perubahan langsung tanpa restart app

---

### Metode 2: Pakai Keyboard Shortcuts

| Aksi | Shortcut |
|------|----------|
| **Start Debugging** | `F5` |
| **Stop Debugging** | `Shift + F5` |
| **Restart Debugging** | `Ctrl + Shift + F5` |
| **Hot Reload Manual** | `Ctrl + F5` |
| **Save & Auto Hot Reload** | `Ctrl + S` |

---

### Metode 3: Klik Kanan pada File

1. Buka file `lib/main.dart`
2. Klik kanan di editor
3. Pilih **"Start Debugging"**
4. App akan run dengan debugging mode

---

## ⚙️ Konfigurasi yang Sudah Di-Set

### Auto Hot Reload
```json
"dart.flutterHotReloadOnSave": "all"
```
✅ Setiap save file, otomatis hot reload!

### Auto Save
```json
"files.autoSave": "afterDelay"
"files.autoSaveDelay": 1000
```
✅ File otomatis save setelah 1 detik tidak mengetik!

### Format On Save
```json
"editor.formatOnSave": true
```
✅ Code otomatis rapi saat save!

---

## 🎯 3 Mode Debugging

Di dropdown debug panel, ada 3 pilihan:

### 1. **smartpark_app** (Debug Mode - Default)
- Untuk development
- Hot reload tersedia
- DevTools enabled
- **Paling sering dipakai**

### 2. **smartpark_app (profile mode)**
- Untuk testing performance
- Hot reload disabled
- Mirip production tapi bisa debug

### 3. **smartpark_app (release mode)**
- Seperti production build
- Paling cepat
- Tidak bisa hot reload

---

## 💡 Tips & Tricks

### 1. Hot Reload vs Hot Restart

**Hot Reload** (Otomatis saat save):
- ✅ Cepat (~1 detik)
- ✅ State app tetap terjaga
- ✅ Untuk perubahan UI & logic kecil

**Hot Restart** (Manual - `Ctrl + Shift + F5`):
- ⏱️ Lebih lama (~5-10 detik)
- 🔄 State app di-reset
- 🔧 Untuk perubahan besar (import, initState, dll)

### 2. Breakpoints

Cara set breakpoint:
1. Klik di sebelah kiri nomor baris (muncul dot merah)
2. Saat code sampai breakpoint, app akan pause
3. Bisa inspect variable, step over, step into, dll

### 3. Debug Console

Lihat output di panel "Debug Console" di bawah:
- Print statements
- Error messages
- Hot reload logs

### 4. Flutter DevTools

Saat debugging, klik link DevTools di Debug Console:
- Widget Inspector
- Performance Monitor
- Network Inspector
- Logging

---

## 🔧 Troubleshooting

### Error: "No device found"
**Solusi:**
```bash
# Check devices
flutter devices

# Start emulator dulu
emulator -avd Pixel_7_API_34
```

### Hot Reload Tidak Jalan
**Solusi:**
1. Pastikan file sudah di-save (`Ctrl + S`)
2. Check settings: `dart.flutterHotReloadOnSave` = `"all"`
3. Restart VS Code
4. Restart debugging (`Shift + F5` lalu `F5`)

### App Crash Setelah Hot Reload
**Solusi:**
- Pakai Hot Restart: `Ctrl + Shift + F5`
- Atau stop lalu start ulang debugging

---

## 📝 Workflow Development

### Workflow Ideal:

1. **Start Debugging:**
   ```
   Tekan F5
   ```

2. **Edit Code:**
   ```
   - Edit file .dart
   - Auto save setelah 1 detik (atau Ctrl + S)
   - Hot reload otomatis
   - Lihat perubahan di emulator
   ```

3. **Test:**
   ```
   - Coba fitur di app
   - Jika ada bug, set breakpoint
   - Debug step by step
   ```

4. **Repeat:**
   ```
   - Edit → Save → Hot Reload → Test → Repeat
   ```

5. **Selesai:**
   ```
   Tekan Shift + F5 untuk stop
   ```

---

## 🎨 Debug Loading Animation

Contoh debug loading animation yang baru:

1. **Start debugging** (`F5`)
2. **Buka file** `lib/ui/loading_animation.dart`
3. **Set breakpoint** di baris `_StartupStyleLoader`
4. **Login ke app**
5. App akan **pause** saat loading animation muncul
6. Bisa **inspect** animation controller, nilai rotation, dll
7. **Continue** (`F5`) untuk lanjut

---

## ✅ Quick Checklist

Sebelum mulai coding:
- [ ] Emulator sudah running
- [ ] Tekan `F5` untuk start debugging
- [ ] File auto-save sudah aktif
- [ ] Debug Console terbuka (lihat logs)
- [ ] Siap coding dengan hot reload otomatis! 🚀

---

## 🎉 Selesai!

Sekarang Anda bisa:
- ✅ Debug dengan sekali tekan `F5`
- ✅ Hot reload otomatis setiap save
- ✅ Lihat perubahan langsung di emulator
- ✅ Development lebih cepat dan efisien!

**Happy Debugging! 🐛✨**
