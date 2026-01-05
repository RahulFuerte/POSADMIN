# Admin App UI Description
## Matching the User-Side POS App Design System

---

## 1. Design System Overview

### Color Palette
| Color Name | Value | Usage |
|------------|-------|-------|
| Primary Color | `Color.fromARGB(255, 12, 107, 15)` | Main accent, buttons, active states |
| Secondary Color | `Colors.white` | Backgrounds, cards |
| Background | `Color.fromARGB(255, 240, 240, 240)` | Screen backgrounds |
| Black | `Colors.black` | Text, icons |
| Grey | `Colors.grey` | Secondary text, hints |
| Theme Accent | `Color.fromARGB(255, 5, 93, 8).withOpacity(0.6)` | Login shapes, buttons |
| Success | `Colors.green` | Online status, confirmations |
| Warning | `Colors.orange` | Offline status, pending items |
| Error | `Colors.red` | Errors, delete actions |

### Typography
```dart
// App Name / Branding
GoogleFonts.alfaSlabOne(fontSize: 35, fontWeight: FontWeight.w500, color: black)

// Headings
TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2, color: black)

// Screen Titles
TextStyle(fontFamily: 'tabfont', fontSize: 19, color: Colors.black)

// Body Text
TextStyle(fontFamily: 'fontmain', fontSize: 14, fontWeight: FontWeight.w400)

// Button Text
TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1, color: white)

// Description
TextStyle(fontSize: 16, letterSpacing: 1, color: black)
```

### Custom Fonts
- `PlaypenSans-SemiBold.ttf`
- `Roboto-Regular.ttf`
- `SometypeMono-Regular.ttf`
- `tabfont` (custom family)
- `fontmain` (custom family)

---

## 2. Core UI Components

### App Bar
```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  title: Row(children: [
    SizedBox(width: 8),
    OfflineStatusIndicator(showWhenOnline: true),
  ]),
  actions: [/* Action buttons */],
)
```

### Zero App Bar (Status Bar Only)
```dart
AppBar(
  toolbarHeight: 0,
  elevation: 0,
  automaticallyImplyLeading: false,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: white,
    statusBarIconBrightness: Brightness.dark,
  ),
)
```

### Custom Button
```dart
Card(
  elevation: 5,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  color: Color.fromARGB(255, 5, 93, 8).withOpacity(0.6),
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.all(15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: white, fontWeight: FontWeight.w600, fontSize: 17, letterSpacing: 1)),
        SizedBox(width: 20),
        Icon(icon, color: white),
      ],
    ),
  ),
)
```

### Text Form Field
```dart
Card(
  elevation: 5,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: TextFormField(
      cursorColor: Colors.black,
      style: TextStyle(fontSize: 18.2, letterSpacing: 1),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: InputBorder.none,
        hintStyle: TextStyle(color: grey),
      ),
    ),
  ),
)
```

### Connection Status Indicator
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: isOnline ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: isOnline ? Colors.green : Colors.orange, width: 1),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(isOnline ? Icons.cloud_done : Icons.cloud_off, size: 16, color: isOnline ? Colors.green : Colors.orange),
      SizedBox(width: 4),
      Text(isOnline ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ],
  ),
)
```

---

## 3. Navigation Structure

### Bottom Navigation Bar
```dart
SizedBox(
  height: 55,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      // Each tab item
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => currentIndex = index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 600),
                curve: Curves.bounceOut,
                width: currentIndex == index ? 25 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Icon(icon, size: 22, color: currentIndex == index ? primaryColor : Colors.black),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### Admin App Navigation Icons (Suggested)
```dart
List<IconData> adminIcons = [
  Icons.dashboard,           // Dashboard
  Icons.inventory,           // Products/Menu Management
  Icons.people,              // Customers
  Icons.receipt_long,        // Orders/Bills
  Icons.analytics,           // Reports
  Icons.settings,            // Settings
];
```

---

## 4. Admin App Screens

### 4.1 Splash Screen
- White background
- App name with `GoogleFonts.alfaSlabOne`
- Lottie animation (centered)
- Company logo at bottom
- Tagline: "Streamlining Success, One Bill at a Time."

### 4.2 Login Screen
- Diagonal clipped shape background (green theme)
- "Sign In" animated text (TyperAnimatedText)
- Phone number input with +91 prefix
- "Send OTP" button
- Terms & Conditions link
- "Or Sign Up!" text at bottom

### 4.3 Dashboard Screen
```
┌─────────────────────────────────────┐
│ AppBar: [Logo] Admin Dashboard [≡]  │
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ Today's │ │ Total   │ │ Pending │ │
│ │ Sales   │ │ Orders  │ │ Orders  │ │
│ │ ₹12,500 │ │   45    │ │    3    │ │
│ └─────────┘ └─────────┘ └─────────┘ │
├─────────────────────────────────────┤
│ Quick Actions                       │
│ ┌─────────┐ ┌─────────┐             │
│ │ Add     │ │ View    │             │
│ │ Product │ │ Reports │             │
│ └─────────┘ └─────────┘             │
├─────────────────────────────────────┤
│ Recent Orders                       │
│ ┌─────────────────────────────────┐ │
│ │ Order #123 - ₹450 - Completed   │ │
│ │ Order #122 - ₹320 - Pending     │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4.4 Product Management Screen
```
┌─────────────────────────────────────┐
│ AppBar: Products [🔍] [+]           │
├─────────────────────────────────────┤
│ Categories (Horizontal Scroll)      │
│ [All] [Pizza] [Burger] [Drinks]     │
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐             │
│ │ [Image] │ │ [Image] │             │
│ │ Pizza   │ │ Burger  │             │
│ │ ₹250    │ │ ₹150    │             │
│ │ [Edit]  │ │ [Edit]  │             │
│ └─────────┘ └─────────┘             │
│ ┌─────────┐ ┌─────────┐             │
│ │ [Image] │ │ [Image] │             │
│ │ Pasta   │ │ Coke    │             │
│ │ ₹180    │ │ ₹50     │             │
│ │ [Edit]  │ │ [Edit]  │             │
│ └─────────┘ └─────────┘             │
└─────────────────────────────────────┘
```

### 4.5 Customer Management Screen
```
┌─────────────────────────────────────┐
│ AppBar: Customers [🔍] [+]          │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [Avatar] John Doe               │ │
│ │          +91 9876543210         │ │
│ │          Total Orders: 15       │ │
│ │          [View] [Edit]          │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [Avatar] Jane Smith             │ │
│ │          +91 9876543211         │ │
│ │          Total Orders: 8        │ │
│ │          [View] [Edit]          │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4.6 Orders/Bills Screen
```
┌─────────────────────────────────────┐
│ AppBar: Orders [Filter] [🔍]        │
├─────────────────────────────────────┤
│ Tabs: [All] [Pending] [Completed]   │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Order #1234                     │ │
│ │ Customer: John Doe              │ │
│ │ Items: 5 | Total: ₹850          │ │
│ │ Status: [Completed ✓]           │ │
│ │ Date: 29 Dec 2025, 10:30 AM     │ │
│ │ [View Details] [Print]          │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4.7 Reports Screen
```
┌─────────────────────────────────────┐
│ AppBar: Reports                     │
├─────────────────────────────────────┤
│ Date Range: [From] - [To]           │
├─────────────────────────────────────┤
│ Report Types:                       │
│ ┌─────────────────────────────────┐ │
│ │ 📊 Bill-wise Report        [→]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 📈 Item-wise Report        [→]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 📅 Date-wise Report        [→]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 💰 Sales Summary           [→]  │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4.8 Settings Screen
```
┌─────────────────────────────────────┐
│ AppBar: Settings                    │
├─────────────────────────────────────┤
│ Profile                             │
│ ┌─────────────────────────────────┐ │
│ │ [Avatar] Shop Name              │ │
│ │          +91 9876543210         │ │
│ │          [Edit Profile]         │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🖨️ Printer Settings        [→]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🔔 Notifications           [→]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🔄 Sync Settings           [→]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🚪 Logout                  [→]  │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 5. Drawer Menu (Side Navigation)

```dart
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: primaryColor),
        child: Row(
          children: [
            CircleAvatar(radius: 45, backgroundImage: NetworkImage(logoUrl)),
            Column(
              children: [
                Text(shopName, style: TextStyle(color: white, fontFamily: 'tabfont')),
                Text(phoneNumber, style: TextStyle(color: white, fontFamily: 'fontmain', fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
      // Printer Status Card
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isConnected ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isConnected ? Colors.green : Colors.orange),
        ),
        child: Row(children: [/* Printer status info */]),
      ),
      // Menu Items
      ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard')),
      ListTile(leading: Icon(Icons.inventory), title: Text('Products')),
      ListTile(leading: Icon(Icons.category), title: Text('Categories')),
      ListTile(leading: Icon(Icons.people), title: Text('Customers')),
      ListTile(leading: Icon(Icons.receipt), title: Text('Orders')),
      ListTile(leading: Icon(Icons.analytics), title: Text('Reports')),
      ListTile(leading: Icon(Icons.sync), title: Text('Sync Status')),
      ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
      ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Logout')),
    ],
  ),
)
```

---

## 6. Common UI Patterns

### Card Style
```dart
Card(
  elevation: 5,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  margin: EdgeInsets.all(8),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: /* Content */,
  ),
)
```

### List Item Style
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.3),
        spreadRadius: 1,
        blurRadius: 5,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: /* Content */,
)
```

### Search Bar (Expandable)
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  width: isExpanded ? MediaQuery.of(context).size.width * 0.75 : 50,
  height: 45,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(25),
    color: Colors.white,
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: Offset(0, 2))],
  ),
  child: Row(
    children: [
      IconButton(icon: Icon(Icons.search, color: primaryColor), onPressed: toggleSearch),
      if (isExpanded) Expanded(child: TextField(/* ... */)),
      if (isExpanded) IconButton(icon: Icon(Icons.clear, size: 20), onPressed: clearSearch),
    ],
  ),
)
```

### Grid Item (Product Card)
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  margin: EdgeInsets.all(5),
  decoration: BoxDecoration(
    color: isSelected ? Color.fromARGB(106, 133, 238, 187) : Colors.blueGrey.shade50,
    borderRadius: BorderRadius.circular(30),
  ),
  child: Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: CachedBlobImage(imageUrl: imageUrl, width: 50, height: 50),
      ),
      Text(name, style: TextStyle(fontSize: 14, fontFamily: 'fontmain', fontWeight: isSelected ? FontWeight.bold : FontWeight.w400)),
    ],
  ),
)
```

---

## 7. Animations & Transitions

### Page Transitions
```dart
MaterialPageRoute(builder: (context) => TargetScreen())
```

### Container Animations
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300-600),
  curve: Curves.bounceOut, // or Curves.easeInOut
)
```

### Text Animations
```dart
AnimatedTextKit(
  animatedTexts: [
    TyperAnimatedText('Text', speed: Duration(milliseconds: 400)),
    WavyAnimatedText('Text', speed: Duration(milliseconds: 400)),
  ],
  isRepeatingAnimation: true,
  repeatForever: true,
)
```

### Lottie Animations
```dart
Lottie.asset(
  "assets/lottie/animation.json",
  fit: BoxFit.fitWidth,
  alignment: Alignment.center,
  width: Screen(context).width * 0.9,
  frameRate: FrameRate(90),
)
```

---

## 8. Responsive Design

### Screen Utility Class
```dart
class Screen {
  late BuildContext context;
  Screen(this.context);

  MediaQueryData get mediaQuery => MediaQuery.of(context);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  double get customWidth => width / 423; // Based on reference device width
  double get topPadding => mediaQuery.viewPadding.top;
  double get bottomPadding => mediaQuery.viewPadding.bottom;
}
```

### Usage
```dart
Screen s = Screen(context);
Padding(padding: EdgeInsets.all(40 * s.customWidth))
Text('Hello', style: TextStyle(fontSize: 17 * s.customWidth))
```

---

## 9. Offline Support UI

### Offline Banner
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.orange, width: 1),
  ),
  child: Row(
    children: [
      Icon(Icons.cloud_off, size: 16, color: Colors.orange),
      SizedBox(width: 4),
      Text('Offline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange)),
      if (pendingCount > 0) ...[
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
          child: Text('$pendingCount pending', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ],
  ),
)
```

---

## 10. Toast Messages

```dart
Fluttertoast.showToast(
  msg: "Message",
  toastLength: Toast.LENGTH_SHORT,
  gravity: ToastGravity.BOTTOM, // or ToastGravity.CENTER
  timeInSecForIosWeb: 2,
  backgroundColor: Colors.grey, // or primaryColor, Colors.red
  textColor: Colors.white,
  fontSize: 16.0,
)
```

---

## 11. Bottom Sheets

### Save Order Bottom Sheet Pattern
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Form fields
          TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
          TextFormField(controller: mobileController, decoration: InputDecoration(labelText: 'Mobile')),
          // Action buttons
          Row(
            children: [
              ElevatedButton(onPressed: onCancel, child: Text('Cancel')),
              ElevatedButton(onPressed: onSave, style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: Text('Save')),
            ],
          ),
        ],
      ),
    ),
  ),
)
```

---

## Summary

This admin app should maintain visual consistency with the user-side POS app by using:
- Same green primary color scheme (`Color.fromARGB(255, 12, 107, 15)`)
- Same typography (tabfont, fontmain, Google Fonts)
- Same card elevation and border radius patterns
- Same animation durations and curves
- Same offline status indicators
- Same drawer header design
- Same button and form field styles

The admin app extends the user app with additional management screens while keeping the familiar look and feel.
