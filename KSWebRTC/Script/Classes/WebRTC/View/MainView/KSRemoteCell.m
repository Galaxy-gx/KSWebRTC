//
//  KSRemoteCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRemoteCell.h"
#import "KSRemoteView.h"

@interface KSRemoteCell()

@property (nonatomic,weak)KSRemoteView *remoteView;

@end
@implementation KSRemoteCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSRemoteView *remoteView = [[KSRemoteView alloc] initWithFrame:self.bounds];
    _remoteView              = remoteView;
    [self addSubview:remoteView];
}

-(void)setConnection:(KSMediaConnection *)connection {
    _connection            = connection;
    _remoteView.connection = connection;
}

@end
