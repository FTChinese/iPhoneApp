# FT-Academy
The SWIFT Source Code for FT Academy

This is a simple SWIFT project that enable a web developer to quickly create a native app, using the simplist SWIFT and XCode knowlege. 

It does these things: 
1. Support iOS 7 and above. 
2. Seamless launch experience, dealing with the white screen when loading a web view. 
3. After launching, the app opens a single page app. 
4. On iOS 8 and above, it uses the new WKWebView, which claims to offer vast performance improvements. 
5. On iOS 7, it falls back to UIWebView. 
6. Since WKWebView doesn't support manifest, we can start the page from an HTML file in the app bundle. 
7. Clicking advertisement or outside link in the single page app will open a new scene. 
8. When going back from the new scene, the SWIFT will do a reload to avoid white screen. 
