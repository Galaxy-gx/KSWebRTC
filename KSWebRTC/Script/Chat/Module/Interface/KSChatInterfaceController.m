//
//  KSKitsController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSChatInterfaceController.h"
#import "KSWebRTCManager.h"
#import "KSTableViewCell.h"
#import "KSChatController.h"
#import "KSAlertController.h"
#import "KSLogicMsg.h"
#import "UILabel+Category.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
@interface KSChatInterfaceController ()<
UITableViewDelegate,
UITableViewDataSource,
KSWebRTCManagerDelegate>

@property (nonatomic,strong) NSMutableArray *users;
@property (nonatomic,weak  ) UITableView    *tableView;
@property (nonatomic,strong) KSUserInfo     *mySelf;
@end

static NSString *const collectionViewCellIdentifier = @"KSCollectionViewCell";
@implementation KSChatInterfaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor         = [UIColor whiteColor];
    [self initKits];
    
    _mySelf                           = [KSUserInfo myself];
    [KSWebRTCManager shared].delegate = self;
    [KSWebRTCManager connectToMessageServer:KS_Extern_Message_Server user:_mySelf];
}

-(void)initKits {
    self.title                             = @"在线用户数量:0";
    UITableView *tableView                 = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate                     = self;
    tableView.dataSource                   = self;
    _tableView                             = tableView;
    [self.view addSubview:tableView];
    /*
    UIBarButtonItem *refreshBarItem        = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(onRefreshClick)];
    self.navigationItem.rightBarButtonItem = refreshBarItem;
     */
}

-(void)onRefreshClick {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KSUserInfo *user      = self.users[indexPath.row];
    KSTableViewCell *cell = [KSTableViewCell initWithTableView:tableView];
    if (user.ID == _mySelf.ID) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@(自己)",user.name];
    }
    else{
        cell.textLabel.text = user.name;
    }
    
    return cell;
}
#pragma mark - UICollectionViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KSUserInfo *user = self.users[indexPath.row];
    [self callToUser:user];
}

-(void)callToUser:(KSUserInfo *)user {
    if (user.ID == _mySelf.ID) {
        return;
    }
    int room     = 1234;
    KSAlertInfo *info = [[KSAlertInfo alloc] initWithType:KSAlertTypeIntegrity
                                                    title:nil
                                                  message:[NSString stringWithFormat:@"向%@发起通话请求",user.name]
                                                   cancel:@"视频聊天"
                                                 confirml:@"语音聊天"
                                                   target:self];
    [KSAlertController showInfo:info callback:^(KSAlertType actionType) {
        KSCallType type = (actionType == KSAlertTypeCancel) ? KSCallTypeSingleVideo : KSCallTypeSingleAudio;
        [KSChatController callWithType:type callState:KSCallStateMaintenanceCaller isCalled:NO room:room target:self];
        [KSWebRTCManager callToUserId:user.ID room:room];
    }];
}

//KSWebRTCManagerDelegate
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSLogicMsg *)message {
    switch (message.type) {
        case KSMsgTypeRegistert:
        {
            KSRegistert *registert = (KSRegistert *)message;
            _users                 = registert.users;
            self.title             = [NSString stringWithFormat:@"在线用户数量:%lu",(unsigned long)_users.count];
            [self.tableView reloadData];
        }
        default:
            break;
    }
}

#pragma mark - 懒加载
-(NSMutableArray *)users {
    if (_users == nil) {
        _users = [NSMutableArray array];
    }
    return _users;
}
@end

