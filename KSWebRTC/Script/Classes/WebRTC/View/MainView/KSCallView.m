//
//  KSCallView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallView.h"
#import "KSLocalView.h"
#import "KSProfileView.h"
#import "KSAnswerBarView.h"
#import "KSCallBarView.h"
#import "KSRemoteCell.h"
#import "KSLocalCell.h"

@interface KSCallView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,weak  ) UIScrollView    *scrollView;
@property (nonatomic,weak  ) KSLocalView     *localView;
@property (nonatomic,weak  ) KSProfileView   *profileView;
@property (nonatomic,weak  ) KSAnswerBarView *answerBarView;
@property (nonatomic,weak  ) KSCallBarView   *callBarView;

@property (nonatomic,strong) NSMutableArray  *remoteKits;
@property (nonatomic,strong) KSTileLayout    *remoteLayout;
@property (nonatomic,assign) KSCallType      callType;
@property (nonatomic,assign) CGPoint         tilePoint;

@property(nonatomic,weak)UICollectionView    *collectionView;

@end

static NSString *const remoteCellIdentifier = @"remoteCellIdentifier";
static NSString *const localCellIdentifier = @"localCellIdentifier";

@implementation KSCallView

- (instancetype)initWithFrame:(CGRect)frame layout:(KSTileLayout *)layout callType:(KSCallType)callType {
    if (self = [super initWithFrame:frame]) {
        self.remoteLayout = layout;
        self.callType     = callType;
        //[self initKit];
        [self initCollectionView];
    }
    return self;
}

- (void)initKit {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView = scrollView;
    [self addSubview:scrollView];
}

- (void)initCollectionView {
    CGFloat padding                        = 10;
    CGFloat cell_wh                        = (self.bounds.size.width - padding)/2;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                    = CGSizeMake(cell_wh, cell_wh);
    flowLayout.minimumLineSpacing          = 0;
    flowLayout.minimumInteritemSpacing     = KS_Extern_Point04;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _topPadding, self.frame.size.width, self.bounds.size.height)
                                                                collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor ks_grayBar];
    
    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    _collectionView                        = collectionView;
    [collectionView registerClass:[KSRemoteCell class] forCellWithReuseIdentifier:remoteCellIdentifier];
    [collectionView registerClass:[KSLocalCell class] forCellWithReuseIdentifier:localCellIdentifier];
    
    [self addSubview:collectionView];
}

- (void)createLocalViewWithLayout:(KSTileLayout *)layout resizingMode:(KSResizingMode)resizingMode callType:(KSCallType)callType {
    CGRect rect = CGRectZero;
    switch (resizingMode) {
        case KSResizingModeTile:
            rect = CGRectMake(layout.layout.hpadding, layout.layout.vpadding, layout.layout.width, layout.layout.height);
            break;
        case KSResizingModeScreen:
            rect = self.bounds;
            break;
        default:
            break;
    }
    KSLocalView *localView = [[KSLocalView alloc] initWithFrame:rect scale:layout.scale mode:layout.mode callType:callType];
    _localView             = localView;
    [self.scrollView addSubview:localView];
}

- (void)zoomOutLocalView {
    CGRect target        = CGRectMake(self.bounds.size.width - 10 - 96, _topPadding + 32, 96,
                                      96 / self.localView.scale.width * self.localView.scale.height);
    self.localView.frame = target;
    [self localToFront];
}

- (void)localToFront {
    [self.scrollView bringSubviewToFront:self.localView];
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
    if(_localView.frame.size.width < self.bounds.size.width) {
        if(point.x > _localView.frame.origin.x && point.y > _localView.frame.origin.y) {
            if(point.x < (_localView.frame.origin.x + _localView.frame.size.width)) {
                if(point.y < (_localView.frame.origin.y + _localView.frame.size.height)) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)localViewAddPanGesture {
    UIPanGestureRecognizer *panSwipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer)];
    [_localView addGestureRecognizer:panSwipeGesture];
}

- (void)setLocalViewSession:(AVCaptureSession *)session {
    [_localView setLocalViewSession:session];
}

-(CGPoint)pointOfIndex:(NSInteger)index {
    int x = _remoteLayout.layout.hpadding;
    int y = 0;
    if (index == 0) {
        x = _remoteLayout.layout.width + _remoteLayout.layout.hpadding * 2;
        y = _remoteLayout.layout.vpadding;
    }
    else {
        if ((index % 2) == 0) {
            x = _remoteLayout.layout.width + _remoteLayout.layout.hpadding * 2;
        }
        y = _remoteLayout.layout.vpadding + (index / 2) * _remoteLayout.layout.height + _remoteLayout.layout.vpadding * (index / 2);
    }
    return CGPointMake(x, y);
}

-(void)layoutRemoteViews {
    for (int index = 0; index < _remoteKits.count; index++) {
        CGPoint point= [self pointOfIndex:(int)_remoteKits.count + 1];
        KSRemoteView *remoteView = _remoteKits[index];
        remoteView.frame = CGRectMake(point.x, point.y, _remoteLayout.layout.width, _remoteLayout.layout.height);
    }
    if (_remoteKits.lastObject) {
        KSRemoteView *remoteView = _remoteKits.lastObject;
        if (remoteView.frame.origin.y + _remoteLayout.layout.height > self.bounds.size.height) {
            _scrollView.contentSize = CGSizeMake(self.bounds.size.width, remoteView.frame.origin.y + _remoteLayout.layout.height);
        }
    }
}

- (void)leaveOfHandleId:(NSNumber *)handleId {
    for (KSRemoteView *videoView in _remoteKits) {
        if (videoView.handleId == handleId) {
            [_remoteKits removeObject:videoView];
            [videoView removeVideoView];
            [videoView removeFromSuperview];
            break;
        }
    }
    if (_remoteKits.count > 0) {
        [self layoutRemoteViews];
    }
}

- (KSRemoteView *)createRemoteViewOfHandleId:(NSNumber *)handleId {
    CGRect rect = CGRectZero;
    switch (_callType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            rect = self.bounds;
        }
            break;
        case KSCallTypeManyAudio:
        case KSCallTypeManyVideo:
        {
            CGPoint point = [self pointOfIndex:self.remoteKits.count];
            rect = CGRectMake(point.x, point.y, _remoteLayout.layout.width, _remoteLayout.layout.height);
        }
            break;
            break;
        default:
            break;
    }
    
    KSRemoteView *remoteView = [[KSRemoteView alloc] initWithFrame:rect scale:_remoteLayout.scale mode:_remoteLayout.mode callType:_callType];
    remoteView.handleId      = handleId;
    [self.scrollView addSubview:remoteView];
    [self.remoteKits addObject:remoteView];
    return remoteView;
}

- (RTCEAGLVideoView *)remoteViewOfHandleId:(NSNumber *)handleId {
    for (KSRemoteView *itemView in self.remoteKits) {
        if (itemView.handleId == handleId) {
            return itemView.remoteView;
        }
    }
    KSRemoteView *remoteView = [self createRemoteViewOfHandleId:handleId];
    
    if (self.callType == KSCallTypeSingleVideo) {//测试
        [self zoomOutLocalView];
    }
    return remoteView.remoteView;
}

-(NSMutableArray *)remoteKits {
    if (_remoteKits == nil) {
        _remoteKits = [NSMutableArray array];
    }
    return _remoteKits;
}

#pragma mark - KSProfileView
- (void)setProfileConfigure:(KSProfileConfigure *)configure {
    if (_profileView == nil) {
        KSProfileView *profileView = [[KSProfileView alloc] initWithFrame:CGRectMake(0, configure.topPaddding, self.bounds.size.width, 204) configure:configure];
        _profileView = profileView;
        [self addSubview:profileView];
        
    }
    else{
        [_profileView updateConfiure:configure];
    }
}

- (void)hideProfile {
    if (_profileView.isHidden == NO) {
        _profileView.hidden = YES;
    }
}

#pragma mark - KSAnswerBarView
- (void)setAnswerState:(KSAnswerState)state {
    if (_answerBarView == nil) {
        CGFloat y                      = self.bounds.size.height - (68 + 62);
        KSAnswerBarView *answerBarView = [[KSAnswerBarView alloc] initWithFrame:CGRectMake(56, y, self.bounds.size.width - 56 * 2, 90)];
        answerBarView.answerState      = state;
        _answerBarView                 = answerBarView;
        [answerBarView setEventCallback:self.callback];
        [self addSubview:answerBarView];
    }
    else{
        _callBarView.hidden        = NO;
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
    [self hideProfile];
    
    if (_callBarView == nil) {
        CGFloat y                  = self.bounds.size.height - (40 + 48);
        KSCallBarView *callBarView = [[KSCallBarView alloc] initWithFrame:CGRectMake(KS_Extern_12Font, y, self.bounds.size.width - KS_Extern_Point12 * 2, KS_Extern_Point48)];
        _callBarView               = callBarView;
        [callBarView setEventCallback:self.callback];
        [self addSubview:callBarView];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(callView:numberOfItemsInSection:)]) {
        return [self.dataSource callView:self numberOfItemsInSection:section];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSMediaConnection *connection = nil;
    if ([self.dataSource respondsToSelector:@selector(callView:itemAtIndexPath:)]) {
        connection = [self.dataSource callView:self itemAtIndexPath:indexPath];
    }
    if (connection == nil) {
        return nil;
    }
    if (connection.mediaInfo.isLocal) {
        KSLocalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:localCellIdentifier forIndexPath:indexPath];
        cell.connection   = connection;
        return cell;
    }
    else{
        KSRemoteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:remoteCellIdentifier forIndexPath:indexPath];
        cell.connection    = connection;
        return cell;
    }
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView insertItemsAtIndexPaths:@[indexPath]];
}

- (void)deleteItemsAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)reloadCollectionView {
    [_collectionView reloadData];
}
@end
