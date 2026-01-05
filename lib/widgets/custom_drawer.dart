import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

/// A consistent drawer widget following the design system.
/// 
/// Implements Requirements 6.1, 6.2, 6.3, 6.4:
/// - DrawerHeader with primaryColor background
/// - Shop name and phone number in header
/// - Consistent icons and typography for menu items
/// - Selected items highlighted with primaryColor at 0.1 opacity
class CustomDrawer extends StatelessWidget {
  final String shopName;
  final String phoneNumber;
  final String? logoUrl;
  final List<DrawerMenuItem> menuItems;
  final int selectedIndex;
  final VoidCallback? onLogout;

  const CustomDrawer({
    Key? key,
    required this.shopName,
    required this.phoneNumber,
    this.logoUrl,
    required this.menuItems,
    this.selectedIndex = 0,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: secondaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header (Requirement 6.1, 6.2)
            Container(
              padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20, right: 20),
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              logoUrl!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.store_rounded,
                                color: primaryColor,
                                size: 32,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.store_rounded,
                            color: primaryColor,
                            size: 32,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    shopName.toUpperCase(),
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'tabfont',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber,
                    style: TextStyle(
                      color: secondaryColor.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'fontmain',
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items (Requirement 6.3, 6.4)
            ...menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;
              
              return _buildMenuItem(
                icon: item.icon,
                title: item.title,
                isSelected: isSelected,
                onTap: item.onTap,
                trailing: item.trailing,
              );
            }),
            
            // Logout button
            if (onLogout != null) ...[
              const Divider(height: 32),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isSelected: false,
                onTap: onLogout!,
                iconColor: errorColor,
                textColor: errorColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // Requirement 6.4: Selected items with primaryColor at 0.1 opacity
        color: isSelected ? selectedItemBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? (isSelected ? primaryColor : grey),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (isSelected ? primaryColor : black),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
            fontFamily: 'fontmain',
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// A menu item for the drawer.
class DrawerMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });
}
