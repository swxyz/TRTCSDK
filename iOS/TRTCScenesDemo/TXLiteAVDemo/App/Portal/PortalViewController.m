
#import "PortalViewController.h"
#import <TRTCCloudDef.h>

#import "ColorMacro.h"
#import "MainMenuCell.h"
#import "TXLiteAVDemo-Swift.h"

#if DEBUG
#define SdkBusiId (18069)
#else
#define SdkBusiId (18070)
#endif


@interface PortalViewMenuLayout : UICollectionViewFlowLayout

@end

@implementation PortalViewMenuLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGFloat width                = [UIScreen mainScreen].bounds.size.width;
    
    self.sectionInset            = UIEdgeInsetsMake(0, width * 0.08, 0, width * 0.08);
    self.itemSize                = CGSizeMake(width * 0.36, width * 0.24);
    self.minimumLineSpacing      = width * 0.1;
    self.minimumInteritemSpacing = 10.0f;
}

@end

@interface PortalViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>


@property (nonatomic,   weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,   weak) IBOutlet UILabel *versionLabel;

@property (nonatomic, strong) VideoCallMainViewController *videoCallVC;
@property (nonatomic, strong) AudioCallMainViewController *audioCallVC;

@property (nonatomic, strong) TRTCLiveRoomImpl *liveRoom;
@property (nonatomic, strong) TRTCVoiceRoomImp *voiceRoom;

@property (nonatomic, strong) NSArray<MainMenuItem *> *mainMenuItems;

@end

@implementation PortalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)[UIColor colorWithRed:19.0 / 255.0 green:41.0 / 255.0 blue:75.0 / 255.0 alpha:1].CGColor, (__bridge id)[UIColor colorWithRed:5.0 / 255.0 green:12.0 / 255.0 blue:23.0 / 255.0 alpha:1].CGColor, nil];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    
    _videoCallVC = [[VideoCallMainViewController alloc] init];
    _audioCallVC = [[AudioCallMainViewController alloc] init];
    [[TRTCVideoCall shared] setup];
    [TRTCVideoCall shared].delegate = _videoCallVC;
    
    [[TRTCAudioCall shared] setup];
    [TRTCAudioCall shared].delegate = _audioCallVC;
    
    _liveRoom = [[TRTCLiveRoomImpl alloc] init];
    _voiceRoom = [TRTCVoiceRoomImp shared];
    __weak __typeof(self) wSelf = self;
    
    self.mainMenuItems = @[
        [[MainMenuItem alloc] initWithIcon:[UIImage imageNamed:@"MenuMeeting"]
                                     title:@"Video conferencing"
                                   content:@"Automatic voice noise reduction, ultra-high-definition video quality, suitable for scenes such as online meetings, remote training, small classes, etc."
                                  onSelect:^{ [wSelf gotoMeetingView]; }],
        [[MainMenuItem alloc] initWithIcon:[UIImage imageNamed:@"MenuVoiceRoom"]
                                     title:@"Voice chat room"
                                   content:@"Contains sound changes, sound effects, accompaniment, background music and other sounds, suitable for scenes such as chat rooms, karaoke rooms and open black rooms"
                                  onSelect:^{ [wSelf gotoVoiceRoomView]; }],
        [[MainMenuItem alloc] initWithIcon:[UIImage imageNamed:@"MenuLive"]
                                     title:@"Video live"
                                   content:@"The audience delay is as low as 800ms, and loading and unloading is not required. It is suitable for large-scale interactive live broadcast with low latency and high concurrency of 100,000 people."
                                  onSelect:^{ [wSelf gotoLiveView]; }],
        [[MainMenuItem alloc] initWithIcon:[UIImage imageNamed:@"MenuAudioCall"]
                                     title:@"Voice calls"
                                   content:@"48kHz high-quality voice, 60% packet loss can be normal voice, leading industry 3A processing, to eliminate echo and howling"
                                  onSelect:^{ [wSelf gotoAudioCallView]; }],
        [[MainMenuItem alloc] initWithIcon:[UIImage imageNamed:@"MenuVideoCall"]
                                     title:@"Video call"
                                   content:@"Support 1080P ultra-clear video, 50% packet loss rate can be normal video, bring your own beauty effects, bring high-quality video call experience"
                                  onSelect:^{ [wSelf gotoVideoCallView]; }]
    ];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"Tencent Cloud TRTC v%@(%@)", [TRTCCloud getSDKVersion], version];
}

- (void)dealloc {
    [[TRTCVideoCall shared] destroy];
    [[TRTCAudioCall shared] destroy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupToast];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *userID = [[ProfileManager shared] curUserID];
    NSString *userSig = [GenerateTestUserSig genTestUserSig:userID];
    
    if (![[[V2TIMManager sharedInstance] getLoginUser] isEqual:userID]) {
        [[ProfileManager shared] IMLoginWithUserSig:userSig success:^{
//            [self makeToastWithMessage:@"登录IM成功"];
            [self makeToastWithMessage:@"Login successful"];
            [[TRTCAudioCall shared] loginWithSdkAppID:SDKAPPID user:userID userSig:userSig success:^{
            } failed:^(NSInteger code, NSString *error) {
                
            }];
            
            [[TRTCVideoCall shared] loginWithSdkAppID:SDKAPPID user:userID userSig:userSig success:^{
            } failed:^(NSInteger code, NSString *error) {
                
            }];
            TRTCLiveRoomConfig *config = [[TRTCLiveRoomConfig alloc] init];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_useCDNFirst"] != nil) {
                config.useCDNFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_useCDNFirst"] boolValue];
            }
            
            if (config.useCDNFirst && [[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_cndPlayDomain"] != nil) {
                config.cdnPlayDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"liveRoomConfig_cndPlayDomain"];
            }
            
            [self.liveRoom loginWithSdkAppID:SDKAPPID userID:userID userSig:userSig config:config callback:^(NSInteger code, NSString * error) {
                
            }];
            [self.voiceRoom loginWithSdkAppID:SDKAPPID userId:userID userSig:userSig callback:^(int32_t code, NSString * _Nonnull message) {
                NSLog(@"login voiceroom success.");
            }];
            LoginResultModel *curUser = [[ProfileManager shared] curUserModel];
            [self.liveRoom setSelfProfileWithName:curUser.name avatarURL:curUser.avatar callback:^(NSInteger code, NSString * error) {
                
            }];
            
            [[TRTCMeeting sharedInstance] login:SDKAPPID userId:userID userSig:userSig callback:^(NSInteger code, NSString *message) {
               
            }];
            [self.voiceRoom setSelfProfileWithUserName:curUser.name avatarURL:curUser.avatar callback:^(int32_t code, NSString * _Nonnull message) {
                NSLog(@"voiceroom: set self profile success.");

            }];
            
        } failed:^(NSString * error) {
            [self makeToastWithMessage:@"Login failed"];
        }];
    }
}

- (void)gotoVideoCallView {
    [self.navigationController pushViewController:self.videoCallVC animated:YES];
}

- (void)gotoLiveView {
    LiveRoomMainViewController *vc = [[LiveRoomMainViewController alloc] initWithLiveRoom:_liveRoom];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoAudioCallView {
    [self.navigationController pushViewController:self.audioCallVC animated:YES];
}

- (void)gotoMeetingView {
    TRTCMeetingNewViewController *vc = [[TRTCMeetingNewViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoVoiceRoomView {
    UIViewController* vc = [[[TRTCVoiceRoomDependencyContainer alloc] init] makeEntranceViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)logout:(id)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to log out？" message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ProfileManager shared] removeLoginCache];
        [[AppUtils shared] showLoginController];
        [[V2TIMManager sharedInstance] logout:^{
            
        } fail:^(int code, NSString *msg) {
            
        }];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.mainMenuItems[indexPath.row].selectBlock();
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mainMenuItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MainMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MainMenuCell" forIndexPath:indexPath];
    cell.item = self.mainMenuItems[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
