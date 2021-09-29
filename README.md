## Summary

This is the iOS SDK of Omilia™. You can read more about Omilia™ at [omilia.com].

## Table of contents

* [Basic integration](#basic-integration)
   * [Get Omilia SDK for iOS](#sdk-get)
   * [Add SDK to Project](#sdk-add)
   * [Add AVFoundation](#sdk-frameworks)
   * [Integrate SDK into your app](#sdk-integrate)
   * [Basic setup](#basic-setup)
   * [Build your app](#build-the-app)
   * [Use SDK](#use-sdk)


## <a id="basic-integration" />Basic integration

We will describe the steps to integrate the Omilia SDK into your iOS project. We are going to assume that you are using Xcode for your iOS development.

### <a id="sdk-get" />Get Omilia SDK for iOS

Download the latest Omilia SDK version from our [releases page][releases]. Extract the archive into a directory of your choice.

### <a id="sdk-add" />Add SDK to Project  

You can integrate the Omilia SDK by adding it to your project as a framework (also called embedded framworks).
Drag and drop the OmiliaSDK.framework to your project.

![][add]

### <a id="sdk-frameworks" />Add AVFoundation

Select your project in the Project Navigator. In the left hand side of the main view, select your target. In the tab
`Build Phases`, expand the group `Link Binary with Libraries`. On the bottom of that section click on the `+` button.
Select the `AVFoundation.framework` and click the `Add` button.

![][frameworks]


### <a id="sdk-integrate" />Integrate SDK into your app

If you added the Omilia SDK as a dynamic framework, you should use the following import statement:

```objc
#import <OmiliaSdk/OmiliaSdk.h>
```

Next, we'll set up basic functionality.

### <a id="basic-setup" />Basic setup

In the Project Navigator, open the source file of your application delegate. Add the `import` statement at the top of the file, then add the following call to `OmiliaClient` in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate:

```objc
#import <OmiliaSdk/OmiliaSdk.h>

// ...

[OmiliaClient setHost:{YourHost}];
[OmiliaClient setPort:{YourPort}];
[OmiliaClient setUserId:{YourUserId}];

[OmiliaClient launchWithApiKey:@"{YourApiKey}"];
```

![][delegate]

**Note**: Initializing the Omilia SDK like this is `very important`. Replace `{YourApiKey}` with your api key and please provide `{YourHost}`, `{YourPort}` & `{YourUserId}`.
### <a id="build-the-app" />Build your app

Build and run your app. If the build succeeds, you should carefully read the SDK logs in the console. After the app launches for the first time, you should see the info log `Install success`.

### <a id="use-sdk" />Use SDK

In order to use the SDK there are 2 options available:

1. Omilia provides a reference implementation of a chat view controller. So you can instantiate `OmiliaViewController` class.

```objc
    OmiliaViewController *omiliaController = [OmiliaViewController new];
    [self.navigationController pushViewController:omiliaController animated:YES];
```

2. In case you don't want to use the provided chat view controller, you can use the class methods provided by the `OmiliaClient`.

+ First you need to set the SDK's delegate:
```objc
    [OmiliaClient sharedClient].delegate = self;
```

The delegate will be called everytime a new response comes from the server.

+ Then you need to start the SDK:
```objc
    [[OmiliaClient sharedClient] start];
```

+ To manually start or stop a voice recognition:
```objc
    [[OmiliaClient sharedClient] startRecognition];

    [[OmiliaClient sharedClient] stopRecogntion];
```

**Note**: It is not necessary to use `stopRecognition` since recognition will automatically stop, when the system detects that the user stops talking.


+ To send a text:
```objc
    [[OmiliaClient sharedClient] sendText:{YourTextHere}];
```

+ Please make sure to call stop before destroying the `OmiliaClient` class
```objc
    [[OmiliaClient sharedClient] stop];
```

This method will disconnect from the servers and stop any recognition.


[omilia.com]:  http://www.omilia.com

[releases]:    https://github.com/omilia/omilia-ios-sdk/releases

[add]:         ./Resources/add.png
[delegate]:    ./Resources/delegate.png
[frameworks]:  ./Resources/frameworks.png
