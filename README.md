# **Cappella**

Originally launched as an iTunes controller in 2007, CoverSutra is making its comeback as a standalone music player for your Mac! Version 4.0, code-named **Cappella**, brings you seamless music access directly from your menu bar. With its elegant interface, you can instantly search by album, artist, or song—all while staying focused on your work without needing to switch apps.

[Download CoverSutra 4.0 on the Mac App Store](https://sophiestication.com/CoverSutra/Download/)

---

## **Getting Started**

To build and run Cappella, you need to configure some local build settings. These settings are essential for specifying your development team and bundle identifier. Follow the steps below to set up your development environment.

### **Step 1: Create the `Team.xcconfig` File**

1. Navigate to the `Build/Configuration/` directory within your project.
2. Create a new file named `Team.xcconfig`.

### **Step 2: Add Build Variables**

Add the following variables to your `Team.xcconfig` file, replacing the placeholders with your custom values:

```xcconfig
SOSO_VENDOR_IDENTIFIER = com.WidmoreCorp.Cappella
SOSO_DEVELOPMENT_TEAM = 4815162342
