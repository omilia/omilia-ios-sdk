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

In the Project Navigator, open the source file of your application delegate. Add the `import` statement at the top of the file, then add the following call to `Omilia` in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate:

```objc
#import <OmiliaSdk/OmiliaSdk.h>

// ...

[Omilia launchWithApiKey:@"{YourApiKey}"];
```

![][delegate]

**Note**: Initializing the Omilia SDK like this is `very important`. Replace `{YourApiKey}` with your api key.

To use the omilia functionality just instantiate `OmiliaViewController` class.

```objc
    OmiliaViewController *omiliaController = [OmiliaViewController new];
    [self.navigationController pushViewController:omiliaController animated:YES];
```


### <a id="build-the-app" />Build your app

Build and run your app. If the build succeeds, you should carefully read the SDK logs in the console. After the app launches for the first time, you should see the info log `Install success`.


[omilia.com]:  http://www.omilia.com

[releases]:    https://github.com/omilia/omilia-ios-sdk/releases

[add]:         ./Resources/add.png
[delegate]:    ./Resources/delegate.png
[frameworks]:  ./Resources/frameworks.png
