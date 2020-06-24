/*
* Module:   TRTCBgmSettingsViewController
*
* Function: BGM设置页，用于控制BGM的播放，以及设置混响和变声效果
*
*    1. 通过TRTCBgmManager来管理BGM播放，以及混响和变声的设置
*
*    2. BGM的操作定义在TRTCBgmSettingsCell中
*
*/

#import "TRTCBgmSettingsViewController.h"
#import "TRTCBgmSettingsCell.h"

@interface TRTCBgmSettingsViewController()

@property (nonatomic, strong) TRTCSettingsSliderItem *bgmPlayoutVolumeItem;

@property (nonatomic, strong) TRTCSettingsSliderItem *bgmPublishVolumeItem;

@end

@implementation TRTCBgmSettingsViewController

- (NSString *)title {
    return @"BGM";
}

- (void)makeCustomRegistrition {
    [self.tableView registerClass:TRTCBgmSettingsItem.bindedCellClass
           forCellReuseIdentifier:TRTCBgmSettingsItem.bindedCellId];
}

- (NSArray<NSString *> *)voiceChanger {
    return @[
        @"Turn off voice changer",
        @"Bear child",
        @"Lori",
        @"Uncle",
        @"Heavy metal",
        @"Cold",
        @"Foreigners",
        @"Sleepy Beast",
        @"Fat bastard",
        @"Strong current",
        @"Heavy machinery",
        @"Ethereal",
    ];
}

- (NSArray<NSString *> *)reverbs {
    return @[
        @"Turn off reverb",
        @"KTV",
        @"Small room",
        @"General Assembly Hall",
        @"Low",
        @"Loud",
        @"Metallic sound",
        @"Magnetic",
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self) wSelf = self;
    
    self.bgmPlayoutVolumeItem = [[TRTCSettingsSliderItem alloc] initWithTitle:@"Local volume"
                                            value:self.manager.bgmPlayoutVolume
                                              min:0
                                              max:100
                                             step:1
                                       continuous:YES
                                           action:^(float value) {
        [wSelf onChangeBgmPlayoutVolume:(NSInteger) value];
    }];
    
    self.bgmPublishVolumeItem = [[TRTCSettingsSliderItem alloc] initWithTitle:@"Remote volume"
                                            value:self.manager.bgmPublishVolume
                                              min:0
                                              max:100
                                             step:1
                                       continuous:YES
                                           action:^(float value) {
        [wSelf onChangeBgmPublishVolume:(NSInteger) value];
    }];
    
    self.items = @[
        [[TRTCBgmSettingsItem alloc] initWithTitle:@"BGM" bgmManager:self.manager],
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"BGM volume"
                                                value:self.manager.bgmVolume
                                                  min:0
                                                  max:100
                                                 step:1
                                           continuous:YES
                                               action:^(float value) {
            [wSelf onChangeBgmVolume:(NSInteger) value];
        }],
        self.bgmPlayoutVolumeItem,
        self.bgmPublishVolumeItem,
        [[TRTCSettingsSliderItem alloc] initWithTitle:@"MIC volume"
                                                value:self.manager.micVolume
                                                  min:0
                                                  max:100
                                                 step:1
                                           continuous:YES
                                               action:^(float value) {
            [wSelf onChangeMicVolume:(NSInteger) value];
        }],
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"Reverb settings"
                                                  items:[self reverbs]
                                          selectedIndex:self.manager.reverb
                                                 action:^(NSInteger index) {
            [wSelf onSelectReverbIndex:index];
        }],
        [[TRTCSettingsSelectorItem alloc] initWithTitle:@"Voice change settings"
                                                  items:[self voiceChanger]
                                          selectedIndex:self.manager.voiceChanger
                                                 action:^(NSInteger index) {
            [wSelf onSelectVoiceChangerIndex:index];
        }],
    ];
}

#pragma mark - Actions

- (void)onChangeBgmVolume:(NSInteger)volume {
    [self.manager setBgmVolume:volume];
    self.bgmPlayoutVolumeItem.sliderValue = volume;
    self.bgmPublishVolumeItem.sliderValue = volume;
}

- (void)onChangeBgmPlayoutVolume:(NSInteger)volume {
    [self.manager setBgmPlayoutVolume:volume];
}

- (void)onChangeBgmPublishVolume:(NSInteger)volume {
    [self.manager setBgmPublishVolume:volume];
}

- (void)onChangeMicVolume:(NSInteger)volume {
    [self.manager setMicVolume:volume];
}

- (void)onSelectReverbIndex:(NSInteger)index {
    [self.manager setReverb:index];
}

- (void)onSelectVoiceChangerIndex:(NSInteger)index {
    [self.manager setVoiceChanger:index];
}

@end
