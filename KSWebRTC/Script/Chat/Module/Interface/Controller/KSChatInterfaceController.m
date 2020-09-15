//
//  KSKitsController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSChatInterfaceController.h"
#import "KSCallBarView.h"
#import "KSTopBarView.h"
#import "KSAnswerBarView.h"
#import "KSProfileView.h"
#import "KSMeetingThemeView.h"
#import "KSTileMediaView.h"
#import "KSWaitingAnswersGroupView.h"
#import "KSLayoutButton.h"
#import "KSCoolHUB.h"
#import "KSSuperController+Category.h"
#import "UIButton+Category.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
#import "KSWebRTCManager.h"
#import "KSTableViewCell.h"
#import "KSCollectionViewCell.h"
#import "KSChatController.h"
@interface KSChatMenu : NSObject
@property(nonatomic,assign)KSCallType callType;
@property(nonatomic,copy)NSString *title;
+ (NSMutableArray *)chatMenus;
@end

@implementation KSChatMenu
+ (NSMutableArray *)chatMenus {
    NSMutableArray *array = [NSMutableArray array];
    KSChatMenu *cm = [[KSChatMenu alloc] init];
    cm.callType = KSCallTypeSingleAudio;
    cm.title = @"KSCallTypeSingleAudio";
    [array addObject:cm];
    
    cm = [[KSChatMenu alloc] init];
    cm.callType = KSCallTypeManyAudio;
    cm.title = @"KSCallTypeManyAudio";
    [array addObject:cm];
    
    cm = [[KSChatMenu alloc] init];
    cm.callType = KSCallTypeSingleVideo;
    cm.title = @"KSCallTypeSingleVideo";
    [array addObject:cm];
    
    cm = [[KSChatMenu alloc] init];
    cm.callType = KSCallTypeManyVideo;
    cm.title = @"KSCallTypeManyVideo";
    [array addObject:cm];
    return array;
}
@end

@interface KSChatInterfaceController ()<UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDataSource,
UICollectionViewDelegate>

@property (nonatomic,weak  ) KSCoolHUB        *coolHUB;
@property (nonatomic,strong) NSMutableArray   *chatMenus;
@property (nonatomic,weak  ) UITableView      *tableView;
@property (nonatomic,weak  ) UICollectionView *collectionView;
@property (nonatomic,assign) BOOL             isCollection;

@end

static NSString *const collectionViewCellIdentifier = @"KSCollectionViewCell";
@implementation KSChatInterfaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor                = [UIColor whiteColor];
    _chatMenus                              = [KSChatMenu chatMenus];
    _isCollection                           = YES;
    if (_isCollection) {
        [self initCollectionView];
    }
    else{
        [self initTableView];
    }

    UIBarButtonItem *addBarItem             = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(onAddClick)];
    UIBarButtonItem *deleteBarItem          = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(onDeleteClick)];
    self.navigationItem.rightBarButtonItems = @[addBarItem,deleteBarItem];
    
    if ([KSWebRTCManager shared].testType == KSTestTypeJanus) {
        [KSWebRTCManager socketConnectServer:@"ws://10.0.115.144:8188"];
    }
    else if ([KSWebRTCManager shared].testType == KSTestTypeSignalling) {
        [KSWebRTCManager socketConnectServer:@"ws://10.0.115.144:6080"];
    }
}

-(KSCoolHUB *)coolHUB {
    if (_coolHUB == NULL) {
        KSCoolHUB *coolHUB = [[KSCoolHUB alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:coolHUB];
        _coolHUB = coolHUB;
    }
    return _coolHUB;
}

- (void)initCollectionView {
    CGFloat cell_w                         = self.view.bounds.size.width - KS_Extern_Point10;
    CGFloat cell_h                         = KS_Extern_Point40;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                    = CGSizeMake(cell_w, cell_h);
    flowLayout.minimumLineSpacing          = KS_Extern_Point10;
    flowLayout.minimumInteritemSpacing     = KS_Extern_Point04;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                                collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor whiteColor];
    
    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    _collectionView                        = collectionView;
    [collectionView registerClass:[KSCollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellIdentifier];
    
    [self.view addSubview:collectionView];
}

-(void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate     = self;
    tableView.dataSource   = self;
    _tableView             = tableView;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatMenus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KSChatMenu *cm = _chatMenus[indexPath.row];
    KSTableViewCell *cell = [KSTableViewCell initWithTableView:tableView];
    cell.textLabel.text = cm.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KSChatMenu *cm                     = _chatMenus[indexPath.row];

    [self callWithType:cm.callType];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _chatMenus.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSChatMenu *cm             = _chatMenus[indexPath.item];
    KSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text        = cm.title;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KSChatMenu *cm                     = _chatMenus[indexPath.item];
    [self callWithType:cm.callType];
}

//更新cell前，先更新数据
- (void)onAddClick {
    KSChatMenu *cm = [[KSChatMenu alloc] init];
    cm.callType    = KSCallTypeManyVideo;
    cm.title       = [NSString stringWithFormat:@"KSCallTypeManyVideo %lu",(unsigned long)_chatMenus.count];
    [_chatMenus addObject:cm];
    
//    cm = [[KSChatMenu alloc] init];
//    cm.callType = KSCallTypeSingleVideo;
//    cm.title = [NSString stringWithFormat:@"KSCallTypeManyVideo %lu",(unsigned long)_chatMenus.count];
//    [_chatMenus addObject:cm];
    
    [self insertItemsAtIndex:(int)_chatMenus.count-1];
}

- (void)onDeleteClick {
    int index = (int)_chatMenus.count - 2;//-1删除最后一个，-2删除倒数第二个
    if (index < 0) {
        return;
    }
    [_chatMenus removeObjectAtIndex:index];
    [self deleteItemsAtIndex:index];
}

- (void)insertItemsAtIndex:(int)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    if (_isCollection) {
        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
    }
    else{
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)deleteItemsAtIndex:(int)index {
    //int index = (int)_chatMenus.count;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    if (_isCollection) {
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
    else{
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)callWithType:(KSCallType)type {
    _peerId = 100;
    [KSChatController callWithType:type callState:KSCallStateMaintenanceCaller isCaller:YES peerId:(int)_peerId target:self];
}

@end

