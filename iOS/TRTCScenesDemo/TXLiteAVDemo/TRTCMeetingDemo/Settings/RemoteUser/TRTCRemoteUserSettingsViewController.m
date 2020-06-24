/*
* Module:   TRTCRemoteUserSettingsViewController
*
* Function: 房间内其它用户（即远端用户）的设置页
*
*    1. 通过TRTCRemoteUserManager来管理各项设置
*
*/

#import "TRTCRemoteUserSettingsViewController.h"
#import "ColorMacro.h"

@implementation TRTCRemoteUserSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.userId;
    self.view.backgroundColor = UIColorFromRGB(0x262626);
    
    TRTCRemoteUserConfig *userSettings = self.userManager.remoteUsers[self.userId];
    __weak __typeof(self) wSelf = self;
    self.items = @[
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Open video"
                                                 isOn:!userSettings.isVideoMuted
                                               action:^(BOOL isOn) {
            [wSelf onMuteVideo:!isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on audio"
                                                 isOn:!userSettings.isAudioMuted
                                               action:^(BOOL isOn) {
            [wSelf onMuteAudio:!isOn];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Fill mode"
                                                 items:@[@"Filling", @"Adaptive"]
                                         selectedIndex:userSettings.fillMode == TRTCVideoFillMode_Fill ? 0 : 1
                                                action:^(NSInteger index) {
            [wSelf onSelectFillModeIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Picture rotation"
                                                 items:@[@"0", @"90", @"180", @"270"]
                                         selectedIndex:userSettings.rotation
                                                action:^(NSInteger index) {
            [wSelf onSelectRotationIndex:index];
        }],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"Volume"
                                                value:userSettings.volume
                                                  min:0
                                                  max:100
                                                 step:1
                                           continuous:YES
                                               action:^(float volume) {
            [wSelf onChangeVolume:volume];
        }],
        [[TRTCSettingsButtonItem alloc] initWithTitle:@"Screenshot sharing" buttonTitle:@"Share it" action:^{
            [wSelf snapshotMainVideo];
        }],
        [[TRTCSettingsButtonItem alloc] initWithTitle:@"Auxiliary screenshot sharing" buttonTitle:@"Share it" action:^{
            [wSelf snapshotSubVideo];
        }]
    ];
}

#pragma mark - Actions

- (void)onMuteVideo:(BOOL)isMuted {
    [self.userManager setUser:self.userId isVideoMuted:isMuted];
}

- (void)onMuteAudio:(BOOL)isMuted {
    [self.userManager setUser:self.userId isAudioMuted:isMuted];
}

- (void)onSelectFillModeIndex:(NSInteger)index {
    TRTCVideoFillMode mode = index == 0 ? TRTCVideoFillMode_Fill : TRTCVideoFillMode_Fit;
    [self.userManager setUser:self.userId fillMode:mode];
}

- (void)onSelectRotationIndex:(NSInteger)index {
    [self.userManager setUser:self.userId rotation:index];
}

- (void)onChangeVolume:(NSInteger)volume {
    [self.userManager setUser:self.userId volume:volume];
}

- (void)snapshotMainVideo {
    __weak __typeof(self) wSelf = self;
    [self.userManager.trtc snapshotVideo:self.userId
                                    type:TRTCVideoStreamTypeBig
                         completionBlock:^(TXImage *image) {
        if (image) {
            [wSelf shareImage:image];
        }
    }];
}

- (void)snapshotSubVideo {
    __weak __typeof(self) wSelf = self;
    [self.userManager.trtc snapshotVideo:self.userId
                                    type:TRTCVideoStreamTypeSub
                         completionBlock:^(TXImage *image) {
        if (image) {
            [wSelf shareImage:image];
        }
    }];
}

- (void)shareImage:(UIImage *)image {
    UIActivityViewController *vc = [[UIActivityViewController alloc]
                                    initWithActivityItems:@[image]
                                    applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
