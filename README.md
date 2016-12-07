# FTChinese iOS news App

This is SWIFT source code of the new FTChinese iPhone and iPad app. 

It does these things: 

1. Support iOS 8 and above using SWIFT 3.  
2. Seamless launch experience, dealing with the white screen when loading a web view. 
3. After launching, the app opens a single-page app. 
4. On iOS 8 and above, it uses the new WKWebView, which offers vast performance improvements. 
5. It no longer uses UIWebView. 
6. Since WKWebView doesn't support manifest, it starts the page from an HTML file in the app bundle. This way, the user will see something even when launching for the first time with no internet. 
7. Clicking advertisement or outside link, which the FTChinese team have no control over, will launch the new Safari view in iOS 9 and above. This falls back to WKWebView on iOS 8.  
8. When going back from the new scene or other app, the main view will check whether the web app has been cleared. If it has, an error will be caught and HTML will be reloaded. 
9. If user tap on the status bar, the web app will scroll to top. 
10. It supports the latest social sharing provided by iOS, including both build-in activities and WeChat. 
11. It can react to a number of types of remote notifications, including story, tag, channel, video, data journalism, quiz, photo slide, and page ect...
12. When the app launches, it will also check for advertisement creatives locally. If a scheduled creative is available locally, it will display immediately. It supports image, video and HTML 5 for launch screen advertisement. 

Notes: 

1. The WeChat SDK is too old and doesn't support BitCode. We need to get the latest one that support BitCode so that the project can support BitCode. 
2. We intentionally didn't enable the web app to be upgraded automatically in order to have some reason to submit an update every two weeks. Updating web app codes through our own server might cause other problems when, for example, there is not enough space on the device. 
3. Local notification codes are commented out as this is a news app. If we have other types of apps, for example, education apps, local notifications would come in handy. 