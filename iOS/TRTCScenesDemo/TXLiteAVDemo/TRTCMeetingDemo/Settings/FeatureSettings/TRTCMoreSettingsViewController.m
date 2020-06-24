/*
* Module:   TRTCMoreSettingsViewController
*
* Function: 其它设置页
*
*    1. 其它设置项包括: 流控方案、双路编码开关、默认观看低清、重力感应和闪光灯切换
*
*    2. 发送自定义消息和SEI消息，两种消息的说明可参见TRTC的文档或TRTCCloud.h中的接口注释。
*
*/

#import "TRTCMoreSettingsViewController.h"

@interface TRTCMoreSettingsViewController ()

@end

@implementation TRTCMoreSettingsViewController

- (NSString *)title {
    return @"Other";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TRTCVideoConfig *config = self.settingsManager.videoConfig;
    __weak __typeof(self) wSelf = self;
    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Flow control"
                                                 items:@[@"Client", @"Cloud"]
                                         selectedIndex:config.qosConfig.controlMode
                                                action:^(NSInteger index) {
            [wSelf onSelectQosControlModeIndex:index];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on dual encoding"
                                                 isOn:config.isSmallVideoEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableSmallVideo:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Watch the low definition by default"
                                                 isOn:config.prefersLowQuality
                                               action:^(BOOL isOn) {
            [wSelf onEnablePrefersLowQuality:isOn];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on gravity sensing"
                                                 isOn:config.isGSensorEnabled
                                               action:^(BOOL isOn) {
            [wSelf onEnableGSensor:isOn];
        }],
        [[TRTCSettingsButtonItem alloc] initWithTitle:@"Switch flash" buttonTitle:@"Switch" action:^{
            [wSelf onToggleTorchLight];
        }],
        [[TRTCSettingsSwitchItem alloc] initWithTitle:@"Turn on autofocus"
                                                 isOn:config.isAutoFocusOn
                                               action:^(BOOL isOn) {
            [wSelf onEnableAutoFocus:isOn];
        }],
        [[TRTCSettingsMessageItem alloc] initWithTitle:@"Custom message" placeHolder:@"Test message" action:^(NSString *message) {
            [wSelf sendMessage:message];
        }],
        [[TRTCSettingsMessageItem alloc] initWithTitle:@"SEI news" placeHolder:@"Test SEI messages" action:^(NSString *message) {
            [wSelf sendSeiMessage:message];
        }],
    ];
}

#pragma mark - Actions

- (void)onSelectQosControlModeIndex:(NSInteger)index {
    [self.settingsManager setQosControlMode:index];
}

- (void)onEnableSmallVideo:(BOOL)isOn {
    [self.settingsManager setSmallVideoEnabled:isOn];
}

- (void)onEnablePrefersLowQuality:(BOOL)isOn {
    [self.settingsManager setPrefersLowQuality:isOn];
}

- (void)onEnableGSensor:(BOOL)isOn {
    [self.settingsManager setGSensorEnabled:isOn];
}

- (void)onEnableAutoFocus:(BOOL)isOn {
    [self.settingsManager setAutoFocusEnabled:isOn];
}

- (void)onToggleTorchLight {
    [self.settingsManager switchTorch];
}

- (void)sendMessage:(NSString *)message {
    [self.settingsManager sendCustomMessage:message];
}

- (void)sendSeiMessage:(NSString *)message {
    [self.settingsManager sendSEIMessage:message repeatCount:1];
}

@end
