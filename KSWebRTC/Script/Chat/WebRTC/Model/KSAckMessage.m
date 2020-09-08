//
//  KSAckMessage.m
//  Telegraph
//
//  Created by saeipi on 2020/8/17.
//

#import "KSAckMessage.h"
#import "MJExtension.h"
#import "NSString+Category.h"
#import "KSUserInfo.h"
@implementation KSAckMessage

+ (KSAckMessage *)ackWithMessage:(NSDictionary *)message {
    KSAckMessage *obj = nil;
    NSString *action = message[@"action"];
    if ([action isEqualToString:@"message"]) {
        obj = [KSAckCurrentMessage mj_objectWithKeyValues:message];
        obj.ackType = KSAckTypeCurrentMessage;
    }
    else if ([action isEqualToString:@"call"]) {
        obj             = [KSAckCall mj_objectWithKeyValues:message];
        KSAckCall *call = (KSAckCall *)obj;
        call.user_id    = call.from;
        obj.ackType     = KSAckTypeCall;
    }
    else if ([action isEqualToString:@"ring"]) {
        obj = [KSAckRing mj_objectWithKeyValues:message];
        obj.ackType = KSAckTypeRing;
    }
    else if ([action isEqualToString:@"answer"]) {
        obj                 = [KSAckAnswer mj_objectWithKeyValues:message];
        KSAckAnswer *answer = (KSAckAnswer *)obj;
        answer.call_type    = [[message[@"message"] ks_toDictionary][@"call_type"] intValue];
        obj.ackType         = KSAckTypeAnswer;
    }
    else if ([action isEqualToString:@"answered"]) {
        obj = [KSAckAnswered mj_objectWithKeyValues:message];
        obj.ackType = KSAckTypeAnswered;
    }
    else if ([action isEqualToString:@"joined"]) {
        obj = [KSAckJoined mj_objectWithKeyValues:message];
        obj.ackType = KSAckTypeJoined;
    }
    else if ([action isEqualToString:@"left"]) {
        obj             = [KSAckLeft mj_objectWithKeyValues:message];
        KSAckLeft *left = (KSAckLeft *)obj;
        left.user_id    = left.from;
        obj.ackType     = KSAckTypeLeft;
    }
    else if ([action isEqualToString:@"decline"]) {
        obj = [KSAckDecline mj_objectWithKeyValues:message];
        obj.ackType = KSAckTypeDecline;
    }
    else if ([action isEqualToString:@"start"]) {
        obj = [KSAckStart mj_objectWithKeyValues:message];
        obj.ackType = KSAckTypeStart;
    }
    return obj;
}

@end

@implementation KSAckCall
-(void)setVideo:(int)video {
    _video    = video;
    _callType = video;
}

@end

@implementation KSAckRing
@end

@implementation KSAckJoined
-(void)setOffer:(NSString *)offer {
    _offer   = offer;
    if ([offer length] > 0) {
        _payload = [offer ks_toDictionary];
    }
}
-(void)setMember:(int)member {
    _member = member;
    _isMe = ([KSUserInfo myID] == member);
    if (_isMe == NO) {
        _user_id     = member;
        _user_name   = [KSUserInfo myself].name;
    }
}

@end

@implementation KSAckCurrentMessage

-(void)setMessage:(NSString *)message {
    _message = message;
    if ([message length] > 0) {
        _payload = [message ks_toDictionary];
        if ([_payload[@"type"] isEqualToString:@"offer"]) {
            _messageType       = KSCurrentMessageTypeOffer;
            _jsep              = _payload[@"payload"];
            //NSString *jsep     = _payload[@"payload"];
            //_jsep              = [jsep ks_toDictionary];
        }
        else if ([_payload[@"type"] isEqualToString:@"answer"]) {
            _messageType       = KSCurrentMessageTypeAnswer;
            _jsep              = _payload[@"payload"];
            //NSString *jsep     = _payload[@"payload"];
            //_jsep              = [jsep ks_toDictionary];
        }
        else if ([_payload[@"type"] isEqualToString:@"candidate"]) {
            _messageType       = KSCurrentMessageTypeCandidate;
            _jsep              = _payload[@"payload"];
        }
        else if ([_payload[@"type"] isEqualToString:@"peerdesc_req"]) {
            _messageType       = KSCurrentMessageTypePeerdescReq;
            _jsep              = _payload[@"payload"];
            _isOffer           = [_jsep[@"type"] isEqualToString:@"offer"];
        }
        else if ([_payload[@"type"] isEqualToString:@"peerdesc_ack"]) {
            _messageType       = KSCurrentMessageTypePeerdescAck;
        }
        else if ([_payload[@"type"] isEqualToString:@"switch"]) {
            _messageType       = KSCurrentMessageTypeSwitch;
            NSDictionary *body = _payload[@"payload"];
            _switchType        = [body[@"switch_type"] intValue];
            _user_name         = _payload[@"user_name"];
            _user_id           = [_payload[@"user_id"] intValue];
        }
        else if ([_payload[@"type"] isEqualToString:@"change_media"]) {
            _messageType       = KSCurrentMessageTypeChangeMedia;
            NSDictionary *body = _payload[@"payload"];
            _mediaType         = [body[@"media_type"] intValue];
            _user_name         = _payload[@"user_name"];
            _user_id           = [_payload[@"user_id"] intValue];
        }
        else if ([_payload[@"type"] isEqualToString:@"line_busy"]) {
            _messageType       = KSCurrentMessageTypeLineBusy;
        }
    }
}

@end

@implementation KSAckLeft
@end

@implementation KSAckDecline
@end

@implementation KSAckAnswer
@end

@implementation KSAckAnswered
@end

@implementation KSAckStart
@end

@implementation KSRequestError
@end
