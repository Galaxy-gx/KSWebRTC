//
//  KSCallView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallView.h"
#import "KSScreenMediaView.h"
#import "KSProfileView.h"
#import "KSAnswerBarView.h"
#import "KSCallBarView.h"
#import "KSTileMediaCell.h"
#import "UIColor+Category.h"
#import "KSFunctionalBarView.h"
#import "KSLayoutButton.h"
#import "UIFont+Category.h"

@interface KSCallView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,KSCallBarViewDataSource>

@property (nonatomic,weak  ) UIView              *mediaView;
@property (nonatomic,weak  ) KSScreenMediaView   *screenMediaView;//全屏
@property (nonatomic,weak  ) KSTileMediaView     *tileMediaView;//小窗
@property (nonatomic,weak  ) KSAnswerBarView     *answerBarView;
@property (nonatomic,weak  ) KSCallBarView       *callBarView;
@property (nonatomic,weak  ) KSFunctionalBarView *functionalBarView;
@property (nonatomic,weak  ) KSLayoutButton      *switchButton;
@property (nonatomic,strong) KSTileLayout        *tileLayout;
@property (nonatomic,assign) CGPoint             tilePoint;
@property (nonatomic,weak  ) UICollectionView    *collectionView;
@property (nonatomic,assign,readonly) KSCallType myType;
@property (nonatomic,weak  ) KSDeviceSwitch      *deviceSwitch;
@end

static NSString *const tileCellIdentifier  = @"tileCellIdentifier";

@implementation KSCallView

- (instancetype)initWithFrame:(CGRect)frame tileLayout:(KSTileLayout *)tileLayout deviceSwitch:(KSDeviceSwitch *)deviceSwitch {
    if (self = [super initWithFrame:frame]) {
        self.tileLayout   = tileLayout;
        self.deviceSwitch = deviceSwitch;
    }
    return self;
}

- (void)initKits {
    switch (self.myType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            [self initMediaView ];
            if (_tileLayout.isCalled) {
                [self initSwitch];
            }
        }
            break;
        case KSCallTypeManyAudio:
        case KSCallTypeManyVideo:
            [self initCollectionView];
            break;
        default:
            break;
    }
}

- (void)initMediaView  {
    UIView *mediaView = [[UIView alloc] initWithFrame:self.bounds];
    _mediaView        = mediaView;
    [self addSubview:mediaView];
}

- (void)initSwitch {
    NSString *title = (self.myType == KSCallTypeSingleAudio) ? @"ks_app_global_text_switch_to_video" : @"ks_app_global_text_switch_to_voice";
    KSLayoutButton *switchButton = [[KSLayoutButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 100 - 37, self.bounds.size.height - 162 - 46, 100, 46)
                                                              layoutType:KSButtonLayoutTypeTitleBottom
                                                                   title:title
                                                                    font:[UIFont ks_fontRegularOfSize:KS_Extern_14Font]
                                                               textColor:[UIColor ks_white]
                                                               normalImg:@"icon_bar_rings_small_white"
                                                               selectImg:@"icon_bar_rings_small_white"
                                                                   space:KS_Extern_Point08
                                                              imageWidth:20
                                                             imageHeight:20];
    _switchButton                = switchButton;
    [switchButton addTarget:self action:@selector(onSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchButton];
}

- (void)initCollectionView {
    CGFloat cell_w                         = _tileLayout.layout.width;
    CGFloat cell_h                         = _tileLayout.layout.height;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                    = CGSizeMake(cell_w, cell_h);
    flowLayout.minimumLineSpacing          = KS_Extern_Point10;
    flowLayout.minimumInteritemSpacing     = KS_Extern_Point04;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
                                                                                                _tileLayout.topPadding,
                                                                                                self.frame.size.width,
                                                                                                self.bounds.size.height - _tileLayout.topPadding)
                                                                collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor clearColor];
    
    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    _collectionView                        = collectionView;
    [collectionView registerClass:[KSTileMediaCell class] forCellWithReuseIdentifier:tileCellIdentifier];
    
    [self addSubview:collectionView];
}

- (void)updateSwitchOfCalltype:(KSCallType)callType {
    //此时calltype为最新的
    if (callType == KSCallTypeSingleAudio || callType == KSCallTypeSingleVideo) {
        NSString *title = (callType == KSCallTypeSingleAudio) ? @"ks_app_global_text_switch_to_video" : @"ks_app_global_text_switch_to_voice";
        [_switchButton updateTitle:title];
    }
}

- (void)setSwitchButtonHidden:(BOOL)hidden {
    _switchButton.hidden = hidden;
}

- (void)onSwitchClick:(KSLayoutButton *)button {
    //此时calltype还没有改，取反
    KSCallMenuType menuType = KSCallMenuTypeVideo;
    KSCallType callType = KSCallTypeSingleVideo;
    if (self.myType == KSCallTypeSingleAudio) {
    }
    else if (self.myType == KSCallTypeSingleVideo){
        menuType = KSCallMenuTypeVoice;
        callType = KSCallTypeSingleAudio;
    }
    
    [self updateSwitchOfCalltype:callType];
    
    if (self.callback) {
        KSMediaSwitch *ms = [[KSMediaSwitch alloc] init];
        ms.mediaType      = menuType;
        ms.callType       = callType;
        self.callback(KSEventTypeStartSwitch, ms);
    }
}

- (void)setScreenMediaTrack:(KSMediaTrack *)mediaTrack {
    self.screenMediaView.mediaTrack = mediaTrack;
}

- (void)setTileMediaTrack:(KSMediaTrack *)mediaTrack {
    self.tileMediaView.hidden     = NO;
    self.tileMediaView.mediaTrack = mediaTrack;
}

- (void)clearRender {
    _screenMediaView.mediaTrack = nil;
    _tileMediaView.mediaTrack   = nil;
}

- (void)localToFront {
    [self.mediaView bringSubviewToFront:self.screenMediaView];
}

- (void)panSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
    UIView *tileView = gestureRecognizer.view;
    if (tileView.tag != KSDragStateActivity) {
        return;
    }
    _tilePoint = [gestureRecognizer locationInView:self];
    if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        tileView.center = _tilePoint;
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat hpadding = 10;
        CGFloat vpadding = 64;
        CGFloat x        = _tilePoint.x - tileView.frame.size.width/2;
        CGFloat y        = _tilePoint.y - tileView.frame.size.height/2;
        if (_tilePoint.x > self.bounds.size.width/2) {
            x = self.bounds.size.width - tileView.frame.size.width - hpadding;
        }
        else{
            x = hpadding;
        }
        
        if (_tilePoint.y > (self.bounds.size.height - tileView.frame.size.height/2 - vpadding)) {
            y = self.bounds.size.height - tileView.frame.size.height - vpadding;
        }
        
        if (y < vpadding) {
            y = vpadding;
        }
        //NSLog(@"-----x:%f, y:%f vx:%f, vy:%f----",x,y,tileView.frame.origin.x,tileView.frame.origin.y);
        [UIView animateWithDuration: 0.2 animations:^{
            tileView.frame = CGRectMake(x, y, tileView.frame.size.width, tileView.frame.size.height);
        }];
    }
}

- (BOOL)inLocalView:(CGPoint)point {
    if(self.screenMediaView.frame.size.width < self.bounds.size.width) {
        if(point.x > _screenMediaView.frame.origin.x && point.y > _screenMediaView.frame.origin.y) {
            if(point.x < (_screenMediaView.frame.origin.x + _screenMediaView.frame.size.width)) {
                if(point.y < (_screenMediaView.frame.origin.y + _screenMediaView.frame.size.height)) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)tileViewAddPanGesture {
    UIPanGestureRecognizer *panSwipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSwipeGesture:)];
    [self.screenMediaView addGestureRecognizer:panSwipeGesture];
}

#pragma mark - KSProfileView
- (void)setProfileInfo:(KSProfileInfo *)profileInfo {
    self.screenMediaView.profileInfo = profileInfo;
}

- (void)hiddenProfileView {
    if (self.myType == KSCallTypeSingleAudio) {
        [self.screenMediaView displayAvatar];
    }
    else{
        [self.screenMediaView hiddenProfileView];
    }
}

#pragma mark - KSAnswerBarView
- (void)setAnswerState:(KSAnswerState)state {
    if (_answerBarView == nil) {
        CGFloat y                      = self.bounds.size.height - (68 + 62);
        KSAnswerBarView *answerBarView = [[KSAnswerBarView alloc] initWithFrame:CGRectMake(0, y, self.bounds.size.width, 90) callType:self.myType];
        answerBarView.answerState      = state;
        _answerBarView                 = answerBarView;
        [answerBarView setEventCallback:self.callback];
        [self addSubview:answerBarView];
    }
    else{
        _answerBarView.answerState = state;
    }
}

- (void)hideAnswerBar {
    if (_answerBarView.isHidden == NO) {
        _answerBarView.hidden = YES;
    }
}

#pragma mark - KSCallBarView
- (void)displayCallBar {
    [self hideAnswerBar];
    [self hiddenProfileView];
    [self setSwitchButtonHidden:YES];
    
    if (_callBarView == nil) {
        CGFloat y                  = self.bounds.size.height - (40 + 48);
        KSCallBarView *callBarView = [[KSCallBarView alloc] initWithFrame:CGRectMake(KS_Extern_12Font, y, self.bounds.size.width - KS_Extern_Point12 * 2, KS_Extern_Point48)];
        callBarView.dataSource     = self;
        _callBarView               = callBarView;
        [callBarView setEventCallback:self.callback];
        [callBarView initKits];
        [self addSubview:callBarView];
    }
    else{
        [_callBarView reloadBar];
    }
}

- (void)setCallBarHidden:(BOOL)hidden {
    self.callBarView.hidden = hidden;
}

//KSCallBarViewDataSource
-(KSDeviceSwitch *)deviceSwitchOfCallBarView:(KSCallBarView *)callBarView {
    return self.deviceSwitch;
}

-(KSCallType)callTypeOfCallBarView:(KSCallBarView *)callBarView {
    return self.myType;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(callView:numberOfItemsInSection:)]) {
        return [self.dataSource callView:self numberOfItemsInSection:section];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSMediaTrack *mediaTrack = nil;
    if ([self.dataSource respondsToSelector:@selector(callView:itemAtIndexPath:)]) {
        mediaTrack = [self.dataSource callView:self itemAtIndexPath:indexPath];
    }
    if (mediaTrack == nil) {
        return nil;
    }
    KSTileMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:tileCellIdentifier forIndexPath:indexPath];
    cell.mediaTrack       = mediaTrack;
    return cell;
}

/*
//将要加载某个Item时调用的方法
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}
*/

#pragma mark - UICollectionView
- (void)reloadItemsAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)insertItemsAtIndex:(NSInteger)index {
    NSLog(@"|============| insert: %ld |============|",(long)index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView insertItemsAtIndexPaths:@[indexPath]];
}

- (void)deleteItemsAtIndex:(NSInteger)index {
    NSLog(@"|============| delete: %ld |============|",(long)index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)reloadSection {
    int index                  = 0;
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if(cell != nil) {
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:index];
        [UIView performWithoutAnimation:^{
          [self.collectionView reloadSections:indexSet];
        }];
    }
}

- (void)reloadCollectionView {
    //[self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
    
    [UIView performWithoutAnimation:^{
      [self.collectionView reloadData];
    }];
}

//Get
-(KSCallType)myType {
    if ([self.dataSource respondsToSelector:@selector(callTypeOfCallView:)]) {
        return [self.dataSource callTypeOfCallView:self];
    }
    return KSCallTypeSingleVideo;
}
-(void)setMyType:(KSCallType)myType {
}

#pragma mark - 懒加载
-(KSFunctionalBarView *)functionalBarView {
    if (_functionalBarView == nil) {
        CGFloat y                              = self.bounds.size.height - (68 + 62 + 90 + 20);
        KSFunctionalBarView *functionalBarView = [[KSFunctionalBarView alloc] initWithFrame:CGRectMake(0, y, self.bounds.size.width, 90)];
        _functionalBarView                     = functionalBarView;
        [self addSubview:functionalBarView];
    }
    return _functionalBarView;;
}

-(KSScreenMediaView *)screenMediaView {
    if (_screenMediaView == nil) {
        KSScreenMediaView *screenMediaView = [[KSScreenMediaView alloc] initWithFrame:self.bounds];
        _screenMediaView                   = screenMediaView;
        [self.mediaView addSubview:screenMediaView];
    }
    return _screenMediaView;
}

-(KSTileMediaView *)tileMediaView {
    if (_tileMediaView == nil) {
        CGRect rect                    = CGRectMake(self.bounds.size.width - _tileLayout.layout.width - _tileLayout.layout.hpadding,
                                                    _tileLayout.topPadding,
                                                    _tileLayout.layout.width,
                                                    _tileLayout.layout.height);
        KSTileMediaView *tileMediaView = [[KSTileMediaView alloc] initWithFrame:rect];
        _tileMediaView                 = tileMediaView;
        [self.mediaView addSubview:tileMediaView];
        tileMediaView.hidden         = YES;
    }
    return _tileMediaView;
}

@end

@implementation KSMediaSwitch
@end
