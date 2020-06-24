//
//  AudioEffectSettingViewModel.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "AudioEffectSettingViewModel.h"
#import "TCAudioScrollMenuCellModel.h"
#import "TCMusicSelectedModel.h"
#import "TCAudioSettingManager.h"

@interface AudioEffectSettingViewModel ()<TCAudioMusicPlayStatusDelegate>

@property (nonatomic, strong) TCASKitTheme *theme;
@property (nonatomic, strong) TCAudioSettingManager* manager;

@end

@implementation AudioEffectSettingViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.theme = [[TCASKitTheme alloc] init];
        [self createDataSource];
    }
    return self;
}

- (TCAudioSettingManager *)manager {
    if (!_manager) {
        _manager = [[TCAudioSettingManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

- (void) setAudioEffectManager:(TXAudioEffectManager *)manager {
    [self.manager setAudioEffectManager:manager];
}

- (void)createDataSource {
    self.voiceChangeSources = [self createVoiceChangeDataSource];
    self.reverberationSources = [self createReverberationDataSource];
    self.musicSources = [self createMusicDataSources];
}

- (NSArray<TCAudioScrollMenuCellModel *> *)createVoiceChangeDataSource{
    NSArray *titleArray = @[@"Original", @"Bear child", @"Lolita", @"uncle", @"heavy metal", @"cold", @"alien", @"trapped Beast", @"dead fat House", @"strong current", @"heavy machinery", @"ethereal"];
    NSArray *iconNameArray = @[@"voiceChange_normal_close", @"voiceChange_xionghaizi", @"voiceChange_luoli", @"voiceChange_dashu", @"voiceChange_zhongjinshu", @"voiceChange_ganmao", @"voiceChange_waiguo", @"voiceChange_kunshou", @"voiceChange_feizhai", @"voiceChange_qiangdianliu", @"voiceChange_jixie", @"voiceChange_konglin"];
    NSArray *iconSelectedNameArray = @[@"voiceChange_normal_open", @"voiceChange_xionghaizi", @"voiceChange_luoli", @"voiceChange_dashu", @"voiceChange_zhongjinshu", @"voiceChange_ganmao", @"voiceChange_waiguo", @"voiceChange_kunshou", @"voiceChange_feizhai", @"voiceChange_qiangdianliu", @"voiceChange_jixie", @"voiceChange_konglin"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    for (int index = 0; index < titleArray.count; index += 1) {
        NSString *title = titleArray[index];
        NSString *normalIconName = iconNameArray[index];
        NSString *selectedIconName = iconSelectedNameArray[index];
        TCAudioScrollMenuCellModel *model = [[TCAudioScrollMenuCellModel alloc] init];
        model.title = title;
        model.actionID = index;
        if ([title isEqualToString:@"Original"]) {
            model.selected = YES;
        } else {
            model.selected = NO;
        }
        model.icon = [self.theme imageNamed:normalIconName];
        model.selectedIcon = [self.theme imageNamed:selectedIconName];
        model.action = ^{
            [self.manager setVoiceChangerTypeWithValue:index];
        };
        if (model.icon) {
            [result addObject:model];
        }
    }
    return result;
}

- (NSArray<TCAudioScrollMenuCellModel *> *)createReverberationDataSource{
    NSArray *titleArray = @[@"No effect", @"KTV", @"small room", @"town hall", @"low", @"loud", @"metallic", @"magnetic"];
    NSArray *iconNameArray = @[@"Reverb_normal_close", @"Reverb_KTV", @"Reverb_literoom", @"Reverb_dahuitang", @"Reverb_dicheng", @"Reverb_hongliang", @"Reverb_zhongjinshu", @"Reverb_cixin"];
    NSArray *iconSelectedNameArray =  @[@"Reverb_normal_open", @"Reverb_KTV", @"Reverb_literoom", @"Reverb_dahuitang", @"Reverb_dicheng", @"Reverb_hongliang", @"Reverb_zhongjinshu", @"Reverb_cixin"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    for (int index = 0; index < titleArray.count; index += 1) {
        NSString *title = titleArray[index];
        NSString *normalIconName = iconNameArray[index];
        NSString *selectedIconName = iconSelectedNameArray[index];
        TCAudioScrollMenuCellModel *model = [[TCAudioScrollMenuCellModel alloc] init];
        model.actionID = index;
        model.title = title;
        if ([title isEqualToString:@"No effect"]) {
            model.selected = YES;
        } else {
            model.selected = NO;
        }
        model.icon = [self.theme imageNamed:normalIconName];
        model.selectedIcon = [self.theme imageNamed:selectedIconName];
        model.action = ^{
            [self.manager setReverbTypeWithValue:index];
        };
        if (model.icon) {
            [result addObject:model];
        }
    }
    return result;
}

- (NSArray<TCMusicSelectedModel *> *)createMusicDataSources {
    NSArray* musicsData = @[
        @{
            @"name": @"SoundTest1",
            @"singer": @"Anonymous",
            @"url": @"http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic1.mp3"
        },
        @{
            @"name": @"SoundTest2",
            @"singer": @"Anonymous",
            @"url": @"http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic2.mp3"
        },
        @{
            @"name": @"SoundTest3",
            @"singer": @"Anonymous",
            @"url": @"http://dldir1.qq.com/hudongzhibo/LiteAV/demomusic/testmusic3.mp3"
        }
    ];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];
    __weak __typeof(self) weakSelf = self;
    for (int index = 0; index < musicsData.count; index += 1) {
        NSDictionary* dic = musicsData[index];
        TCMusicSelectedModel* model = [[TCMusicSelectedModel alloc] init];
        model.musicID = 1000 + index;
        model.musicName = dic[@"name"];
        model.singerName = dic[@"singer"];
        model.resourceURL = dic[@"url"];
        model.isLocal = NO;
        
        model.action = ^(BOOL isSelected){
            NSLog(@"Selected music %@", dic[@"name"]);
            [weakSelf stopPlay];
            [weakSelf playMusicWithPath:dic[@"url"] bgmID:1000 + index];
        };
        [result addObject:model];
    }
    
    return result;
}

- (void)setMusicVolum:(NSInteger)volum {
    [self.manager setBGMVolume:volum];
}

- (void)setVoiceVolum:(NSInteger)volum {
    [self.manager setVoiceVolume:volum];
}

- (void)setPitchVolum:(CGFloat)volum {
    [self.manager setBGMPitch:volum];
}

/// 播放音乐
/// @param path 音乐路径
/// @param bgmID 音乐ID
- (void)playMusicWithPath:(NSString *)path bgmID:(NSInteger)bgmID {
    [self.manager playMusicWithPath:path bgmID:bgmID];
}

- (void)stopPlay {
    [self.manager stopPlay];
}

- (void)pausePlay {
    [self.manager pausePlay];
}

- (void)resumePlay {
    [self.manager resumePlay];
}

- (void)resetStatus {
    [self.manager clearStates];
}

-(void)onStartPlayMusic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStartPlayMusic)]) {
        [self.delegate onStartPlayMusic];
    }
}

- (void)onPlayingWithCurrent:(NSInteger)currentSec total:(NSInteger)totalSec{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayingWithCurrent:total:)]) {
        [self.delegate onPlayingWithCurrent:currentSec total:totalSec];
    }
}

- (void)onStopPlayerMusic {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onStopPlayerMusic)]) {
        [self.delegate onStopPlayerMusic];
    }
}

@end
