//
//  KSLocalCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalCell.h"

@interface KSLocalCell()

@property (nonatomic,weak) KSPreviewLayer *previewLayer;

@end

@implementation KSLocalCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSPreviewLayer *previewLayer = [[KSPreviewLayer alloc] init];
    previewLayer.videoGravity    = AVLayerVideoGravityResizeAspectFill;//填充模式
    _previewLayer                = previewLayer;
    [self.layer addSublayer:previewLayer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _previewLayer.frame = self.bounds;
}

-(void)setConnection:(KSMediaConnection *)connection {
    _connection           = connection;
    _previewLayer.session = connection.captureSession;
    _previewLayer.hidden  = connection.captureSession == nil ? YES : NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _previewLayer.session = nil;
    _previewLayer.hidden  = YES;
}

@end
