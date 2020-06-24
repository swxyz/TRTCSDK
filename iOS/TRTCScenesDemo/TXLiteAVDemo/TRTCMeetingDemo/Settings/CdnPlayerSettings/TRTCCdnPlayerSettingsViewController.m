/*
* Module:   TRTCCdnPlayerSettingsViewController
*
* Function: CDN播放置页
*
*/

#import "TRTCCdnPlayerSettingsViewController.h"

@implementation TRTCCdnPlayerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CDN settings";
    
    TRTCCdnPlayerConfig *config = self.manager.config;
    __weak __typeof(self) wSelf = self;

    self.items = @[
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Picture rotation (clockwise)"
                                                 items:@[@"0", @"90", @"180", @"270"]
                                         selectedIndex:[self indexOfOrientation:config.orientation]
                                                action:^(NSInteger index) {
            [wSelf onSelectRotationIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Fill mode"
                                                 items:@[@"Filling", @"Adaptive"]
                                         selectedIndex:config.renderMode
                                                action:^(NSInteger index) {
            [wSelf onSelectRenderModeIndex:index];
        }],
        [[TRTCSettingsSegmentItem alloc] initWithTitle:@"Buffering method"
                                                 items:@[@"Fast", @"Smooth", @"Auto"]
                                         selectedIndex:config.cacheType
                                                action:^(NSInteger index) {
            [wSelf onSelectCacheTypeIndex:index];
        }]
    ];
}

#pragma mark - Action

- (void)onSelectRotationIndex:(NSInteger)index {
    [self.manager setOrientation:[self orientationOfIndex:index]];
}

- (void)onSelectRenderModeIndex:(NSInteger)index {
    [self.manager setRenderMode:index];
}

- (void)onSelectCacheTypeIndex:(NSInteger)index {
    [self.manager setCacheType:index];
}

#pragma mark - Private

- (NSInteger)indexOfOrientation:(TX_Enum_Type_HomeOrientation)orientation {
    switch (orientation) {
        case HOME_ORIENTATION_DOWN:
            return 0;
        case HOME_ORIENTATION_RIGHT:
            return 1;
        case HOME_ORIENTATION_UP:
            return 2;
        case HOME_ORIENTATION_LEFT:
            return 3;
    }
}

- (TX_Enum_Type_HomeOrientation)orientationOfIndex:(NSInteger)index {
    NSArray *orientations = @[
        @(HOME_ORIENTATION_DOWN),
        @(HOME_ORIENTATION_RIGHT),
        @(HOME_ORIENTATION_UP),
        @(HOME_ORIENTATION_LEFT)
    ];
    return [orientations[index] integerValue];
}

@end
