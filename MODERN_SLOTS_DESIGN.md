# 🎨 Modern Slots Page - Design Documentation

## 📐 Design Overview

Redesign **ModernSlotsPage** menjadi lebih **profesional & modern** dengan inspirasi dari aplikasi top-tier seperti Gojek, Grab, dan Airbnb.

---

## 🎯 Design Principles

1. **Simplicity** - Less is more, fokus pada informasi penting
2. **Visual Hierarchy** - Gunakan ukuran, warna, dan spacing untuk guide user
3. **Consistency** - Pattern yang sama di seluruh aplikasi
4. **Accessibility** - Kontras warna yang jelas
5. **Delight** - Micro-interactions dan smooth animations

---

## 🎨 Color Palette

### **Available Slots** (Hijau/Cyan)
```dart
Primary:   #00D4AA (Cyan/Teal - Nemu.in brand)
Secondary: #00B894 (Darker Teal)
Gradient:  White → #00D4AA (5% opacity)
```

### **Occupied Slots** (Merah)
```dart
Primary:   #FF6B6B (Soft Red)
Gradient:  #FF6B6B (8% opacity) → #FF6B6B (15% opacity)
```

### **Status Indicators**
```dart
Available: #00D4AA with glow effect
Occupied:  #FF6B6B
Border:    2px solid with 15-30% opacity
```

---

## 📦 Slot Tile Design

### **Layout Structure**
```
┌─────────────────────┐
│  🔴 (decorative)    │  ← Background circle (top-right)
│                     │
│         🅿️          │  ← Icon (P for available, 🔒 for occupied)
│         25          │  ← Slot number (bold)
│                     │
│  ● (status)  🔴     │  ← Status indicator + bg circle (bottom)
└─────────────────────┘
```

### **Available Slot**
```dart
- Gradient: White → Cyan (subtle)
- Border: 2px #00D4AA (15% opacity)
- Icon: Parking icon (P)
- Number: Black #1A1A1A
- Status dot: Glowing green
- Shadow: Soft (16px blur, 8px offset)
```

### **Occupied Slot**
```dart
- Gradient: Red (8%) → Red (15%)
- Border: 2px #FF6B6B (30% opacity)
- Icon: Lock icon 🔒
- Number: Red #FF6B6B
- No status dot
- Shadow: Red tinted (12px blur)
```

---

## 🎭 Visual Elements

### 1️⃣ **Decorative Circles**
Purpose: Add depth and visual interest

```dart
// Top-right circle (subtle)
Container(
  width: 40, height: 40,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: accentColor.withOpacity(0.08),
  ),
)

// Bottom-left circle (more subtle)
Container(
  width: 30, height: 30,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: accentColor.withOpacity(0.06),
  ),
)
```

### 2️⃣ **Status Indicator**
Glowing dot untuk available slots

```dart
Container(
  width: 8, height: 8,
  decoration: BoxDecoration(
    color: #00D4AA,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: #00D4AA (50% opacity),
        blurRadius: 6,
        spreadRadius: 1, // Creates glow effect
      ),
    ],
  ),
)
```

### 3️⃣ **Icons**
- **Available**: `Icons.local_parking_rounded` (size: 24)
- **Occupied**: `Icons.lock_rounded` (size: 24)
- Color matches slot state (cyan or red)

---

## 🎬 Animations

### **Entrance Animation**
Staggered fade-in with slight upward motion

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: Duration(milliseconds: 420 + (index * 30)),
  curve: Curves.easeOutCubic,
  builder: (context, t, child) {
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 12), // Slides up 12px
        child: child,
      ),
    );
  },
)
```

**Parameters:**
- Base duration: 420ms
- Stagger delay: +30ms per item
- Movement: 12px upward
- Curve: `easeOutCubic` for smooth deceleration

### **Tap Animation**
Material InkWell with 20px border radius

```dart
InkWell(
  borderRadius: BorderRadius.circular(20),
  onTap: () => _showBookingDialog(slot),
)
```

### **State Change Animation**
Smooth transition between available/occupied

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 220),
  // All properties animate smoothly
)
```

---

## 📏 Spacing & Sizing

### **Grid Configuration**
```dart
SliverGridDelegate(
  crossAxisCount: 5,           // 5 columns
  childAspectRatio: 1.0,       // Square tiles
  crossAxisSpacing: 10,        // Horizontal gap
  mainAxisSpacing: 10,         // Vertical gap
)
```

### **Tile Dimensions**
- Calculated from screen width: `(screenWidth - padding - gaps) / 5`
- Example (360px screen): ~62px per tile
- Border radius: 20px
- Border width: 2px

### **Padding**
```dart
Grid padding: 20px (left, right, bottom)
Header padding: 16-24px
Filter chips: 20px horizontal
```

---

## 🎨 Before vs After Comparison

### **Old Design:**
```
❌ Plain white background
❌ Simple number display
❌ Small status dot (10px)
❌ Basic border
❌ No gradients
❌ No decorative elements
❌ Single color scheme
```

### **New Design:**
```
✅ Gradient backgrounds
✅ Icon + number (visual hierarchy)
✅ Glowing status indicator (8px)
✅ Thick colored borders (2px)
✅ Subtle gradients for depth
✅ Decorative circles
✅ Color-coded states (cyan/red)
✅ Professional shadows
```

---

## 🎯 Design Inspiration

### **Gojek/Grab Style:**
- ✅ Gradient cards
- ✅ Bold borders
- ✅ Clear status indicators
- ✅ Smooth animations

### **Airbnb Style:**
- ✅ Clean spacing
- ✅ Professional shadows
- ✅ Subtle decorative elements

### **Material Design 3:**
- ✅ Large tap targets (62px+)
- ✅ Accessible contrast ratios
- ✅ Smooth state transitions

---

## 🔧 Customization Options

### **Change Color Palette**
```dart
// Available color
const accentAvailable = Color(0xFF00D4AA); // Current cyan
// Try: Color(0xFF5B86E5) for blue

// Occupied color
const accentOccupied = Color(0xFFFF6B6B); // Current red
// Try: Color(0xFFFF9800) for orange
```

### **Adjust Border Thickness**
```dart
border: Border.all(
  width: 2, // Current: 2px
  // Try: 1.5 for thinner, 3 for thicker
)
```

### **Change Border Radius**
```dart
borderRadius: BorderRadius.circular(20), // Current
// Try: 16 for less rounded, 24 for more rounded
```

### **Modify Shadows**
```dart
BoxShadow(
  blurRadius: 16,    // Current: 16
  offset: Offset(0, 8), // Current: 8px down
)
// Try: blurRadius: 20, offset: (0, 10) for deeper shadow
```

---

## 📱 Responsive Design

### **Grid Columns by Screen Size**
Current: Fixed 5 columns

**Recommendation for tablets:**
```dart
final columns = MediaQuery.of(context).size.width > 600 ? 7 : 5;
```

### **Font Sizes**
- Slot number: 18px (bold 800)
- Icon: 24px
- Status dot: 8px

---

## ✨ Micro-interactions

1. **Tap Feedback**
   - InkWell ripple effect
   - Material design compliant

2. **Hover Effect** (for web)
   - Add `MouseRegion` wrapper
   - Scale up to 1.05 on hover

3. **Long Press** (future)
   - Show slot details
   - History of bookings

---

## 🎨 SVG Icons (Future Enhancement)

Package sudah diinstall: `flutter_svg: ^2.0.10+1`

**Usage example:**
```dart
SvgPicture.asset(
  'assets/icons/parking.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(
    accentColor,
    BlendMode.srcIn,
  ),
)
```

**Recommended icons:**
- `parking.svg` - For available slots
- `lock.svg` - For occupied slots
- `car.svg` - For booked by user
- `electric.svg` - For EV slots

---

## 📊 Design Metrics

- **Border Radius:** 20px (consistent with app style)
- **Shadow Blur:** 16px (depth without clutter)
- **Icon Size:** 24px (optimal for 62px tiles)
- **Font Weight:** 800 (Poppins ExtraBold)
- **Animation Duration:** 220ms (state), 420ms (entrance)
- **Grid Gap:** 10px (balanced spacing)

---

## 🚀 Performance Considerations

✅ **Optimized:**
- AnimatedContainer instead of setState rebuilds
- Const constructors where possible
- SingleTickerProviderStateMixin for animations

✅ **Efficient:**
- StreamBuilder only rebuilds on data change
- TweenAnimationBuilder runs once per item
- Material InkWell hardware-accelerated

---

## 🎯 Accessibility

- ✅ **High Contrast:** Red/Green clearly distinguishable
- ✅ **Large Tap Targets:** 62px+ (recommended minimum: 48px)
- ✅ **Clear Icons:** Lock vs Parking easily recognizable
- ✅ **Color + Icon:** Not relying on color alone for status

---

**Created:** November 8, 2025
**Design System:** Nemu.in SmartPark v2.0
