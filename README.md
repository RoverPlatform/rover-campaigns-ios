# Rover Campaigns iOS SDK

This is Rover Campaigns, the marketing campaigns automation SDK.  Rover Campaigns augments our core Rover product, the Experiences designer, to drive mobile engagement and monetization with better mobile campaigns.

<hr />

The Campaigns SDK is a collection of Cocoa Touch Frameworks written in Swift. Instead of a single monolithic framework, the Rover SDK takes a modular approach, allowing you to include only the functionality relevant to your application. The SDK is 100% open-source and available on [GitHub](https://github.com/RoverPlatform/rover-ios).

Note: if you are looking to include additionally include Experiences functionality, please take a look at the [Rover SDK](https://github.com/RoverPlatform/rover-ios).

---

## Install the SDK

The recommended way to install the Rover SDK is via [Cocoapods](http://cocoapods.org/).

The Rover [Podspec](https://guides.cocoapods.org/syntax/podspec.html) breaks each of the Rover frameworks out into a separate [Subspec](https://guides.cocoapods.org/syntax/podspec.html#group_subspecs).

The simplest approach is to specify `Rover` as a dependency of your app's target which will add all required and optional subspecs to your project.

```ruby
target 'MyAppTarget' do
  pod 'RoverCampaigns', '~> 3.0.0'
end
```

Alternatively you can specify the exact set of subspecs you want to include.

```ruby
target 'MyAppTarget' do
    pod 'Rover/Foundation',    '~> 3.0.0'
    pod 'Rover/Data',          '~> 3.0.0'
    pod 'Rover/UI',            '~> 3.0.0'
    pod 'Rover/Notifications', '~> 3.0.0'
    pod 'Rover/Location',      '~> 3.0.0'
    pod 'Rover/Bluetooth',     '~> 3.0.0'
    pod 'Rover/Debug',         '~> 3.0.0'
end
```

Please continue onwards from https://developer.rover.io/ios/.
