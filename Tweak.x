@import AVFoundation;
// keep track of the rate
float rate = 1.00;

@interface ISAVPlayer : AVPlayer
@end

// TODO: rate does not change pitch
@interface ISWrappedAVPlayer
- (void)setRate:(float)arg1;
@end
@interface PXVideoSession
@property(nonatomic, readwrite, strong) AVPlayerItem *playerItem;
@end
@interface PUVideoTileViewController
@property(nonatomic, readwrite, strong) PXVideoSession *videoSession;
@end
@interface PUOneUpViewController : UIViewController
- (id)_currentContentTileController;
@end
PUOneUpViewController *OneUpVC = nil;

@interface PUExtendedToolbar : UIToolbar
@property(nonatomic, strong) UIBarButtonItem *item;
- (void)_setToolbarItems:(NSArray *)arg1;
- (void)rateChanged;
- (void)save:(AVURLAsset *)asset;
@end

%hook PUExtendedToolbar
// property to manage item name within the class
%property(nonatomic, strong) UIBarButtonItem *item;
- (void)_setToolbarItems:(NSArray *)arg1 {
  // check if there is a pause button, if so then we have determined that
  // current asset is a video
  if ([arg1.description containsString:@"systemItem=Pause"]) {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"Save"
                                image:[UIImage
                                          systemImageNamed:
                                              @"square.and.arrow.down.fill"]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                PUVideoTileViewController *controller =
                                    [OneUpVC _currentContentTileController];
                                [self save:(AVURLAsset *)controller.videoSession
                                               .playerItem.asset];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"0.25x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 0.25;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"0.5x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 0.50;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"0.75x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 0.75;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"1x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 1.00;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"1.25x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 1.25;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"1.5x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 1.50;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"1.75x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 1.75;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];
    [actions
        addObject:[UIAction
                      actionWithTitle:@"2x"
                                image:[UIImage systemImageNamed:@""]
                           identifier:nil
                              handler:^(__kindof UIAction *_Nonnull action) {
                                rate = 2.00;
                                [self rateChanged];
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:
                                        @"SlowMoChangeRateNotification"
                                                  object:self];
                              }]];

    UIMenu *menu =
        [UIMenu menuWithTitle:[NSString stringWithFormat:@"Playback Speed"]
                     children:actions];
    self.item = [[UIBarButtonItem alloc]
        initWithTitle:[NSString stringWithFormat:@"%.2f", rate]
                 menu:menu];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil
                             action:nil];
    %orig(
        [arg1 arrayByAddingObjectsFromArray:@[ flexibleItem, self.item ]]);
  } else { // not a video
    %orig;
  }
}
%new
- (void)rateChanged {
  self.item.title = [NSString stringWithFormat:@"%.2f", rate];
}
%new
- (void)save:(AVURLAsset *)asset {
  AVAssetTrack *track =
      [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
  AVMutableComposition *mixComposition = [AVMutableComposition composition];
  AVMutableCompositionTrack *compositionVideoTrack = [mixComposition
      addMutableTrackWithMediaType:AVMediaTypeVideo
                  preferredTrackID:kCMPersistentTrackID_Invalid];
  AVMutableCompositionTrack *compositionAudioTrack = [mixComposition
      addMutableTrackWithMediaType:AVMediaTypeAudio
                  preferredTrackID:kCMPersistentTrackID_Invalid];
  NSError *videoInsertError = nil;
  BOOL videoInsertResult = [compositionVideoTrack
      insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
              ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo]
                          objectAtIndex:0]
               atTime:kCMTimeZero
                error:&videoInsertError];
  if (!videoInsertResult || nil != videoInsertError) {
    return;
  }
  NSError *audioInsertError = nil;
  BOOL audioInsertResult = [compositionAudioTrack
      insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
              ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio]
                          objectAtIndex:0]
               atTime:kCMTimeZero
                error:&audioInsertError];

  if (!audioInsertResult || nil != audioInsertError) {
    return;
  }
  CMTime videoDuration = asset.duration;
  double factor = ((double)videoDuration.value / rate);

  [compositionVideoTrack
      scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
          toDuration:CMTimeMake(factor, videoDuration.timescale)];
  [compositionAudioTrack
      scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
          toDuration:CMTimeMake(factor, videoDuration.timescale)];
  [compositionVideoTrack setPreferredTransform:track.preferredTransform];

  AVAssetExportSession *assetExport = [[AVAssetExportSession alloc]
      initWithAsset:mixComposition
         presetName:AVAssetExportPresetHighestQuality];
  assetExport.outputFileType = AVFileTypeQuickTimeMovie;
  NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory()
                                isDirectory:YES];
  NSURL *fileURL =
      [[tmpDirURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]]
          URLByAppendingPathExtension:@"mov"];
  assetExport.outputURL = fileURL;
  [assetExport exportAsynchronouslyWithCompletionHandler:^{
    UISaveVideoAtPathToSavedPhotosAlbum(
        fileURL.path, self,
        @selector(video:didFinishSavingWithError:contextInfo:), nil);
  }];
}

%new

- (void)video:(NSString *)videoPath
    didFinishSavingWithError:(NSError *)error
                 contextInfo:(void *)contextInfo {
  if (!error) {
    [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
  }
}
%end
%hook ISAVPlayer
- (id)currentItem {
  AVPlayerItem *item = %orig;
  item.audioTimePitchAlgorithm =
      AVAudioTimePitchAlgorithmVarispeed; // to allow flexibility for the rate
  return item;
}
%end

%hook PUOneUpViewController
- (void)viewDidLoad {
  %orig;
  OneUpVC = self;
}
%end

%hook ISWrappedAVPlayer
- (void)setRate:(float)arg1 {
  // other than pausing, control our own rate
  return %orig((arg1 == 0.0) ? arg1 : rate);
}
- (void)setLoopingEnabled:(BOOL)arg1 {
  // enable looping by default
  %orig(true);
}

- (id)_initWithAVPlayer:(id)arg1 {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(receiveRateNotification:)
             name:@"SlowMoChangeRateNotification"
           object:nil];
  return %orig;
}

%new
- (void)receiveRateNotification:(NSNotification *)notification {
  if ([[notification name] isEqualToString:@"SlowMoChangeRateNotification"])
    [self setRate:rate];
}
%end
