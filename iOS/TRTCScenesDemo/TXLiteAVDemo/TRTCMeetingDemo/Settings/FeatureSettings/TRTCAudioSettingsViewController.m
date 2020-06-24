/*
* Module:   TRTCAudioSettingsViewController
*
* Function: 音频设置页
*
*    1. 通过TRTCCloudManager来设置音频参数。
*
*    2. TRTCAudioRecordManager用来控制录音，demo录音停止后会弹出分享。
*
*/

#import "TRTCAudioSettingsViewController.h"

@interface TRTCAudioSettingsViewController()

@property (strong, nonatomic) TRTCSettingsButtonItem *recordItem;

@end

@implementation TRTCAudioSettingsViewController

- (NSString *)title {
    return @"Audio";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TRTCAudioConfig *config = self.settingsManager.audioConfig;
    __weak __typeof(self) wSelf = self;
    
    self.recordItem = [[TRTCSettingsButtonItem alloc] initWithTitle:@"Audio recording"
                                      buttonTitle:self.recordManager.isRecording ? @"Stop" : @"Record"
                                           action:^{
        [wSelf onClickRecordButton];
    }];
    
    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Audio sampling rate"
                                                 items:@[@"48K", @"16K"]
                                         selectedIndex:config.sampleRate == 48000 ? 0 : 1
                                                action:^(NSInteger index) {
            [wSelf onSelectSampleRateIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Volume type"
                                                 items:@[@"Automatic", @"Media", @"Call"]
                                         selectedIndex:config.volumeType
                                                action:^(NSInteger index) {
            [wSelf onSelectVolumeTypeIndex:index];
        }],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"Acquisition volume"
                                                value:self.settingsManager.captureVolume min:0 max:100 step:1
                                           continuous:YES
                                               action:^(float volume) {
            [wSelf onUpdateCaptureVolume:(NSInteger)volume];
        }],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"Play volume"
                                                value:self.settingsManager.playoutVolume min:0 max:100 step:1
                                           continuous:YES
                                               action:^(float volume) {
            [wSelf onUpdatePlayoutVolume:(NSInteger)volume];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Auto gain"
                                                 isOn:config.isAgcEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableAgc:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Noise cancellation"
                                                 isOn:config.isAnsEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableAns:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on the ear"
                                                 isOn:config.isEarMonitoringEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableEarMonitoring:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Sound collection"
                                                 isOn:config.isEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableAudio:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Hands-free mode"
                                                 isOn:config.route == TRTCAudioModeSpeakerphone
                                               action:^(BOOL isOn) {
            [wSelf onEnableHandsFree:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Volume prompt"
                                                 isOn:config.isVolumeEvaluationEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableVolumeEvaluation:isOn];
        }],
        self.recordItem,
    ];
}

#pragma mark - Actions

- (void)onSelectSampleRateIndex:(NSInteger)index {
    NSInteger sampleRate = index == 0 ? 48000 : 16000;
    [self.settingsManager setSampleRate:sampleRate];
}

- (void)onSelectVolumeTypeIndex:(NSInteger)index {
    TRTCSystemVolumeType type = (TRTCSystemVolumeType)index;
    [self.settingsManager setVolumeType:type];
}

- (void)onUpdateCaptureVolume:(NSInteger)volume {
    [self.settingsManager setCaptureVolume:volume];
}

- (void)onUpdatePlayoutVolume:(NSInteger)volume {
    [self.settingsManager setPlayoutVolume:volume];
}

- (void)onEnableAgc:(BOOL)isOn {
    [self.settingsManager setAgcEnabled:isOn];
}

- (void)onEnableAns:(BOOL)isOn {
    [self.settingsManager setAnsEnabled:isOn];
}

- (void)onEnableEarMonitoring:(BOOL)isOn {
    [self.settingsManager setEarMonitoringEnabled:isOn];
}

- (void)onEnableAudio:(BOOL)isOn {
    [self.settingsManager setAudioEnabled:isOn];
}

- (void)onEnableHandsFree:(BOOL)isOn {
    TRTCAudioRoute route = isOn ? TRTCAudioModeSpeakerphone : TRTCAudioModeEarpiece;
    [self.settingsManager setAudioRoute:route];
}

- (void)onEnableVolumeEvaluation:(BOOL)isOn {
    [self.settingsManager setVolumeEvaluationEnabled:isOn];
}

- (void)onClickRecordButton {
    if (self.recordManager.isRecording) {
        [self.recordManager stopRecord];
        [self shareAudioFile];
    } else {
        [self.recordManager startRecord];
    }
    self.recordItem.buttonTitle = self.recordManager.isRecording ? @"Stop" : @"Record";
    [self.tableView reloadData];
}

- (void)shareAudioFile {
    if (self.recordManager.audioFilePath.length == 0) {
        return;
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:self.recordManager.audioFilePath];
    UIActivityViewController *activityView =
    [[UIActivityViewController alloc] initWithActivityItems:@[fileUrl]
                                      applicationActivities:nil];
    [self presentViewController:activityView animated:YES completion:nil];
}

@end
