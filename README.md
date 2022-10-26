# Deprecation of the Rover Campaigns iOS SDK

The standlone Rover Campaigns SDK has been deprecated and merged with the Rover Experiences SDK.  In order to upgrade, please use the Rover SDK available on [GitHub](https://github.com/RoverPlatform/rover-ios).

---

## Transition to the Rover SDK

Uninstall the existing Rover Campaigns SDK, then install the new Rover SDK, from 4.0.0 onwards.  There should be no other code changes required, as the API has stayed the same.

In Xcode, in your Project Settings, under Package Depenencides, remove the RoverCampaigns dependency.  Then, install the Rover SDK, following the direction son [GitHub](https://github.com/RoverPlatform/rover-ios).
