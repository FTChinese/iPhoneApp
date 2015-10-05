# FTChinese iPhone App

This is SWIFT source code of the new FTChinese iPhone app. 

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
10. It supports the latest social sharing provided by iOS, including both build-in activities and WeChat. 

Notes: 
1. The WeChat SDK is too old and doesn't support BitCode. We need to get the latest one that support BitCode so that the project can support BitCode. 
2. We intentionally didn't enable the web app to be upgraded automatically in order to have some reason to submit an update every two weeks. Updating web app codes through our own server might cause other problems when, for example, there is not enough space on the device. 