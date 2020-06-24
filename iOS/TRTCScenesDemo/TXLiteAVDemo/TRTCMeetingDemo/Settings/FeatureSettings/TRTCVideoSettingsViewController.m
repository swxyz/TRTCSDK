/*
* Module:   TRTCVideoSettingsViewController
*
* Function: 视频设置页
*
*    1. 通过TRTCCloudManager来设置视频参数
*
*    2. 设置分辨率后，码率的设置范围以及默认值会根据分辨率进行调整
*
*/

#import "TRTCVideoSettingsViewController.h"

@interface TRTCVideoSettingsViewController ()

@property (strong, nonatomic) TRTCSettingsSliderItem *bitrateItem;

@end

@implementation TRTCVideoSettingsViewController

- (NSString *)title {
    return @"Video";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    TRTCVideoConfig *config = self.settingsManager.videoConfig;
    __weak __typeof(self) wSelf = self;
    
    self.bitrateItem = [[TRTCSettingsSliderItem alloc]
                        initWithTitle:@"Code rate"
                        value:0 min:0 max:0 step:0
                        continuous:NO
                        action:^(float bitrate) {
        [wSelf onSetBitrate:bitrate];
    }];
    
    self.items = @[
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"Resolution"
                                                  items:TRTCVideoConfig.resolutionNames
                                          selectedIndex:config.resolutionIndex
                                                 action:^(NSInteger index) {
            [wSelf onSelectResolutionIndex:index];
        }],
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"Frame rate"
                                                  items:TRTCVideoConfig.fpsList
                                          selectedIndex:config.fpsIndex
                                                 action:^(NSInteger index) {
            [wSelf onSelectFpsIndex:index];
        }],
        self.bitrateItem,
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Picture quality"
                                                 items:@[@"Fluency", @"Clarity"]
                                         selectedIndex:config.qosPreferenceIndex
                                                action:^(NSInteger index) {
            [wSelf onSelectQosPreferenceIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Screen direction"
                                                 items:@[@"Landscape", @"Portrait"]
                                         selectedIndex:config.videoEncConfig.resMode
                                                action:^(NSInteger index) {
            [wSelf onSelectResolutionModelIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Fill mode"
                                                 items:@[@"Full", @"Adapt"]
                                         selectedIndex:config.fillMode
                                                action:^(NSInteger index) {
            [wSelf onSelectFillModeIndex:index];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Start video capture"
                                                 isOn:config.isEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableVideo:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Open push video"
                                                 isOn:!config.isMuted
                                               action:^(BOOL isOn) {
            [wSelf onMuteVideo:!isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Pause screen capture"
                                                 isOn:config.isScreenCapturePaused
                                               action:^(BOOL isOn) {
            [wSelf onPauseScreenCapture:isOn];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Preview image"
                                                 items:TRTCVideoConfig.localMirrorTypeNames
                                         selectedIndex:config.localMirrorType
                                                action:^(NSInteger index) {
            [wSelf onSelectLocalMirror:index];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on remote mirroring"
                                                 isOn:config.isRemoteMirrorEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableRemoteMirror:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on video watermark" isOn:NO action:^(BOOL isOn) {
            [wSelf onEnableWatermark:isOn];
        }],
        [[TRTCSettingsButtonItem alloc] initWithTitle:@"Screenshot sharing" buttonTitle:@"Share it" action:^{
            [wSelf snapshotLocalVideo];
        }],
    ];
    
    [self updateBitrateItemWithResolution:config.videoEncConfig.videoResolution];
}

#pragma mark - Actions

- (void)onSelectResolutionIndex:(NSInteger)index {
    TRTCVideoResolution resolution = [TRTCVideoConfig.resolutions[index] integerValue];
    [self.settingsManager setResolution:resolution];
    [self updateBitrateItemWithResolution:resolution];
}

- (void)onSelectFpsIndex:(NSInteger)index {
    [self.settingsManager setVideoFps:[TRTCVideoConfig.fpsList[index] intValue]];
}

- (void)onSetBitrate:(float)bitrate {
    [self.settingsManager setVideoBitrate:bitrate];
}

- (void)onSelectQosPreferenceIndex:(NSInteger)index {
    TRTCVideoQosPreference qos = index == 0 ? TRTCVideoQosPreferenceSmooth : TRTCVideoQosPreferenceClear;
    [self.settingsManager setQosPreference:qos];
}

- (void)onSelectResolutionModelIndex:(NSInteger)index {
    TRTCVideoResolutionMode mode = index == 0 ? TRTCVideoResolutionModeLandscape : TRTCVideoResolutionModePortrait;
    [self.settingsManager setResolutionMode:mode];
}

- (void)onSelectFillModeIndex:(NSInteger)index {
    TRTCVideoFillMode mode = index == 0 ? TRTCVideoFillMode_Fill : TRTCVideoFillMode_Fit;
    [self.settingsManager setVideoFillMode:mode];
}

- (void)onEnableVideo:(BOOL)isOn {
    [self.settingsManager setVideoEnabled:isOn];
}

- (void)onMuteVideo:(BOOL)isMuted {
    [self.settingsManager setVideoMuted:isMuted];
}

- (void)onPauseScreenCapture:(BOOL)isPaused {
    [self.settingsManager pauseScreenCapture:isPaused];
}

- (void)onSelectLocalMirror:(NSInteger)index {
    [self.settingsManager setLocalMirrorType:index];
}

- (void)onEnableRemoteMirror:(BOOL)isOn {
    [self.settingsManager setRemoteMirrorEnabled:isOn];
}

- (void)onEnableWatermark:(BOOL)isOn {
    if (isOn) {
        UIImage *image = [UIImage imageNamed:@"watermark"];
        [self.settingsManager setWaterMark:image inRect:CGRectMake(0.7, 0.1, 0.2, 0)];
    } else {
        [self.settingsManager setWaterMark:nil inRect:CGRectZero];
    }
}

- (void)snapshotLocalVideo {
    __weak __typeof(self) wSelf = self;
    [self.settingsManager.trtc snapshotVideo:nil
                                        type:TRTCVideoStreamTypeBig
                             completionBlock:^(TXImage *image) {
        if (image) {
            [wSelf shareImage:image];
        }
    }];
}

- (void)updateBitrateItemWithResolution:(TRTCVideoResolution)resolution {
    TRTCBitrateRange *range = [TRTCVideoConfig bitrateRangeOf:resolution
                                                        scene:self.settingsManager.scene];
    self.bitrateItem.maxValue = range.maxBitrate;
    self.bitrateItem.minValue = range.minBitrate;
    self.bitrateItem.step = range.step;
    self.bitrateItem.sliderValue = range.defaultBitrate;
    
    [self.settingsManager setVideoBitrate:(int)range.defaultBitrate];
    [self.tableView reloadData];
}

- (void)shareImage:(UIImage *)image {
    UIActivityViewController *vc = [[UIActivityViewController alloc]
                                    initWithActivityItems:@[image]
                                    applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
