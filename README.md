# The SWIFT Source Code for FT Chinese iPhone App

This is a simple SWIFT project that enable a web developer to quickly create a native app, using the simplist SWIFT and XCode knowlege. 

It does these things: 

1. Support iOS 7 and above. 
2. Seamless launch experience, dealing with the white screen when loading a web view. 
3. After launching, the app opens a single-page app. 
4. On iOS 8 and above, it uses the new WKWebView, which claims to offer vast performance improvements. 
5. On iOS 7, it falls back to UIWebView. 
6. Since WKWebView doesn't support manifest, it starts the page from an HTML file in the app bundle. 
7. Clicking advertisement or outside link, which the FTChinese team have no control over, will launch the new Safari view in iOS 9 and above. This falls back to WKWebView on iOS 8 and UIWebView on iOS 7.  
8. When going back from the new scene or other app, the main view will check whether the web app has been cleared. If it has, an error will be caught and HTML will be reloaded. 
9. If user tap on the status bar, the web app will scroll to top. 