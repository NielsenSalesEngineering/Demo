# Nielsen App API SDK

This document will guide you through implementing the Nielsen App API SDK.  Read the engineering forum for more details and documentation.

## Configuring the Player

1. Configure the Nielsen App SDK
2. Configure the player
3. Configure the asset
4. Register Key Value Observers on status and rate.  Register currentItem.timedMetadata if using ID3
5. Observe player every 2 seconds and update playheadPosition
6. Watch for rate changes to handle pauses in playback.  A rate of 0 is paused.
7. Watch status to play asset once loaded
8. Parse ID3 Tags and send to Nielsen App API
9. Implement Nielsen App API Delegate
