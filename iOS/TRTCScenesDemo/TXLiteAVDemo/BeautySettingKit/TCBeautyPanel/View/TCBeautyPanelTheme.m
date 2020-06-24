//
//  TCPanelTheme.m
//  TC
//
//  Created by cui on 2019/12/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TCBeautyPanelTheme.h"
#import <objc/runtime.h>

@interface TCBeautyPanelTheme () {
    @public
    NSMutableDictionary<NSString *, UIImage *> *_imageDict;
    NSMutableDictionary<NSString *, UIImage *> *_filterIconDictionary;
}
@property (strong, nonatomic) NSBundle *resourceBundle;
- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;
@end

static UIImage *getImageByName(TCBeautyPanelTheme *self, SEL selector) {
    NSString *selName = NSStringFromSelector(selector);
    NSString *key = [[[selName substringToIndex:1] lowercaseString] stringByAppendingString:[selName substringFromIndex:1]];
    UIImage *image = [self imageForKey:key];
    if (nil == image) {
        image = [UIImage imageNamed:NSStringFromSelector(selector) inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    }
    if (nil == image) {
        NSLog(@"%@ %@ image not found", NSStringFromClass([self class]), key);
    }
    return image;
}

static void setImageForKey(id self, SEL selector, UIImage *image) {
    NSString *selName = NSStringFromSelector(selector);
    NSString *attrName = [[selName substringFromIndex:3] stringByTrimmingCharactersInSet:
                          [NSCharacterSet characterSetWithCharactersInString:@":"]];
    NSString *key = [[[attrName substringToIndex:1] lowercaseString] stringByAppendingString:[attrName substringFromIndex:1]];
    [self setImage:image forKey:key];
}


@implementation TCBeautyPanelTheme
@synthesize backgroundColor=_backgroundColor;
@synthesize beautyPanelTitleColor=_beautyPanelTitleColor;
@synthesize beautyPanelSelectionColor=_beautyPanelSelectionColor;
@synthesize speedControlSelectedTitleColor=_speedControlSelectedTitleColor;
@synthesize sliderMinColor=_sliderMinColor;
@synthesize sliderMaxColor=_sliderMaxColor;
@synthesize sliderValueColor=_sliderValueColor;
@dynamic beautyPanelSmoothBeautyStyleIcon;
@dynamic beautyPanelEyeScaleIcon;
@dynamic beautyPanelPTuBeautyStyleIcon;
@dynamic beautyPanelNatureBeautyStyleIcon;
@dynamic beautyPanelRuddyIcon;
@dynamic beautyPanelBgRemovalIcon;
@dynamic beautyPanelWhitnessIcon;
@dynamic beautyPanelFaceSlimIcon;
@dynamic beautyPanelGoodLuckIcon;
@dynamic beautyPanelChinIcon;
@dynamic beautyPanelFaceVIcon;
@dynamic beautyPanelFaceScaleIcon;
@dynamic beautyPanelNoseSlimIcon;
@dynamic beautyPanelToothWhitenIcon;
@dynamic beautyPanelEyeDistanceIcon;
@dynamic beautyPanelForeheadIcon;
@dynamic beautyPanelFaceBeautyIcon;
@dynamic beautyPanelEyeAngleIcon;
@dynamic beautyPanelNoseWingIcon;
@dynamic beautyPanelLipsThicknessIcon;
@dynamic beautyPanelWrinkleRemoveIcon;
@dynamic beautyPanelMouthShapeIcon;
@dynamic beautyPanelPounchRemoveIcon;
@dynamic beautyPanelSmileLinesRemoveIcon;
@dynamic beautyPanelEyeLightenIcon;
@dynamic beautyPanelNosePositionIcon;
@dynamic menuDisableIcon;
@dynamic beautyPanelMenuSelectionBackgroundImage;
@dynamic sliderThumbImage;

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *selName = NSStringFromSelector(sel);
    if ([selName hasPrefix:@"set"]) {
        if ([selName hasSuffix:@"Icon:"] || [selName hasSuffix:@"Image:"]) {
            class_addMethod([self class], sel, (IMP)setImageForKey, "@@:@");
            return YES;
        }
    } else if ([selName hasSuffix:@"Icon"] || [selName hasSuffix:@"Image"]) {
        class_addMethod([self class], sel, (IMP)getImageByName, "@@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"UGCKitResources" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:resourcePath];
        if (nil == bundle) {
            bundle = [NSBundle mainBundle];
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TCBeautyPanelResources" ofType:@"bundle"];
        if (!path) {
            path = [bundle pathForResource:@"TCBeautyPanelResources" ofType:@"bundle"];
        }
        NSBundle *panelResBundle = [NSBundle bundleWithPath:path];
        if (panelResBundle) {
            bundle = panelResBundle;
        }
        _imageDict = [NSMutableDictionary dictionary];

        _resourceBundle = bundle ?: [NSBundle mainBundle];

        _beautyPanelTitleColor = [UIColor whiteColor];
        _beautyPanelSelectionColor = [UIColor colorWithRed:0xff/255.0 green:0x58/255.0 blue:0x4c/255.0 alpha:1];
        _backgroundColor = [UIColor blackColor];
        _sliderValueColor = [UIColor colorWithRed:1.0 green:0x58/255.0 blue:0x4c/255.0 alpha:1];
    }
    return self;
}
- (NSURL *)goodLuckVideoFileURL {
    return [_resourceBundle URLForResource:@"goodluck" withExtension:@"mp4"];
}

- (UIImage *)iconForFilter:(nonnull NSString *)filter {
    UIImage *image = _filterIconDictionary[filter];
    if (image) {
        return image;
    }

    if (nil == filter) {
        return [UIImage imageNamed:@"original" inBundle:_resourceBundle compatibleWithTraitCollection:nil];
    } else if ([filter isEqualToString:@"white"]) {
        return [UIImage imageNamed:@"fwhite" inBundle:_resourceBundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:filter inBundle:_resourceBundle compatibleWithTraitCollection:nil];
    }
}


- (UIImage *)imageNamed:(nonnull NSString *)name {
    return [UIImage imageNamed:name inBundle:_resourceBundle compatibleWithTraitCollection:nil];
}

- (UIImage *)imageForKey:(NSString *)key
{
    return _imageDict[key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    _imageDict[key] = image;
}

- (NSString *)localizedString:(nonnull NSString *)key {
    static NSDictionary *defaultStringMap = nil;
    NSString *string = [_resourceBundle localizedStringForKey:key value:@"" table:nil];
    if (![string isEqualToString:key]) {
        return string;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStringMap = @{
            @"TC.Common.Clear": @"Clear",
            @"TC.BeautySettingPanel.None" : @"No effect",
            @"TC.BeautySettingPanel.GoodLuck" : @"Good Luck",
            @"TC.BeautySettingPanel.BeautySmooth" : @"Beauty (Smooth)",
            @"TC.BeautySettingPanel.Beauty-Natural" : @"Beauty (Natural)",
            @"TC.BeautySettingPanel.Beauty-P" : @"Beauty (PS)",
            @"TC.BeautySettingPanel.White" : @"Whitening",
            @"TC.BeautySettingPanel.Ruddy" : @"Rosy",
            @"TC.BeautySettingPanel.BigEyes" : @"Big eyes",
            @"TC.BeautySettingPanel.ThinFace" : @"Face-lift",
            @"TC.BeautySettingPanel.VFace" : @"V face",
            @"TC.BeautySettingPanel.Chin" : @"Chin",
            @"TC.BeautySettingPanel.ShortFace" : @"Short face",
            @"TC.BeautySettingPanel.ThinNose" : @"Thin nose",
            @"TC.BeautySettingPanel.EyeLighten" : @"Dazzling",
            @"TC.BeautySettingPanel.ToothWhiten" : @"White teeth",
            @"TC.BeautySettingPanel.WrinkleRemove" : @"Wrinkle",
            @"TC.BeautySettingPanel.PounchRemove" : @"Eye bags",
            @"TC.BeautySettingPanel.SmileLinesRemove" : @"Qufa lines",
            @"TC.BeautySettingPanel.Forehead" : @"Hairline",
            @"TC.BeautySettingPanel.EyeDistance" : @"Eye distance",
            @"TC.BeautySettingPanel.EyeAngle" : @"Corner of eye",
            @"TC.BeautySettingPanel.MouthShape" : @"Mouth type",
            @"TC.BeautySettingPanel.NoseWing" : @"Nose",
            @"TC.BeautySettingPanel.NosePosition" : @"Nose position",
            @"TC.BeautySettingPanel.LipsThickness" : @"Lip thickness",
            @"TC.BeautySettingPanel.FaceBeauty" : @"Face shape",
            @"TC.BeautyPanel.Menu.Beauty" : @"Beauty",
            @"TC.BeautyPanel.Menu.Filter" : @"Filter",
            @"TC.BeautyPanel.Menu.VideoEffect" : @"Animation",
            @"TC.BeautyPanel.Menu.BlendPic" : @"Cheat",
            @"TC.BeautyPanel.Menu.GreenScreen" : @"Green screen",
            @"TC.BeautyPanel.Menu.Gesture" : @"Gesture",
            @"TC.BeautyPanel.Menu.Cosmetic" : @"Makeups",
            @"TC.Common.Filter_original" : @"Original image",
            @"TC.Common.Filter_normal" : @"Standard",
            @"TC.Common.Filter_yinghong" : @"Fuchsia",
            @"TC.Common.Filter_yunshang" : @"Yun Shang",
            @"TC.Common.Filter_chunzhen" : @"Innocence",
            @"TC.Common.Filter_bailan" : @"Bai Lan",
            @"TC.Common.Filter_yuanqi" : @"Vitality",
            @"TC.Common.Filter_chaotuo" : @"Detached",
            @"TC.Common.Filter_xiangfen" : @"Fragrance",
            @"TC.Common.Filter_white" : @"Whitening",
            @"TC.Common.Filter_langman" : @"Romantic",
            @"TC.Common.Filter_qingxin" : @"Fresh",
            @"TC.Common.Filter_weimei" : @"Beautiful",
            @"TC.Common.Filter_fennen" : @"Pink",
            @"TC.Common.Filter_huaijiu" : @"Nostalgia",
            @"TC.Common.Filter_landiao" : @"Blues",
            @"TC.Common.Filter_qingliang" : @"Cool",
            @"TC.Common.Filter_rixi" : @"Japan",
        };
    });
    return defaultStringMap[key] ?: key;
}

@end
