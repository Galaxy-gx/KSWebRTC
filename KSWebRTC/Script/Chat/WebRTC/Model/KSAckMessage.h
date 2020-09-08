//
//  KSAckMessage.h
//  Telegraph
//
//  Created by saeipi on 2020/8/17.
//

#import <Foundation/Foundation.h>
#import "KSConfigure.h"
#import "KSCallState.h"

typedef NS_ENUM(NSInteger, KSAckType) {
    KSAckTypeUnknown,
    KSAckTypeCall,
    KSAckTypeAnswer,
    KSAckTypeAnswered,
    KSAckTypeRing,
    KSAckTypeDecline,
    KSAckTypeStart,
    KSAckTypeCurrentMessage,//通过消息
    KSAckTypeLeft,
    KSAckTypeCurrent,
    KSAckTypeJoined,
    KSAckTypeCandidate,
};

typedef NS_ENUM(NSInteger, KSRequestType) {
    KSRequestTypeUnknown,
    KSRequestTypeNewCall,
    KSRequestTypeCandidate,
    KSRequestTypeAnswoer,
    KSRequestTypeRinged,
    KSRequestTypeStart,
    KSRequestTypeSendOffer,
    KSRequestTypeSendAnswer,
    KSRequestTypeLeave,
    KSRequestTypeRTCInfo,
    KSRequestTypeJoinOffer,
    KSRequestTypeMessage,
};

typedef NS_ENUM(NSInteger, KSCurrentMessageType) {
    KSCurrentMessageTypeUnknown,
    KSCurrentMessageTypeOffer,
    KSCurrentMessageTypeAnswer,
    KSCurrentMessageTypeCandidate,
    KSCurrentMessageTypePeerdescReq,
    KSCurrentMessageTypePeerdescAck,
    KSCurrentMessageTypeSwitch,
    KSCurrentMessageTypeChangeMedia,
    KSCurrentMessageTypeLineBusy,
};

//typedef NS_ENUM(NSInteger, KSSwitchType) {
//    KSSwitchTypeUnknown    = 0,
//    KSSwitchTypeOpenVoice  = 1,
//    KSSwitchTypeCloseVoice = 2,
//    KSSwitchTypeOpenVideo  = 3,
//    KSSwitchTypeCloseVideo = 4,
//};

typedef NS_ENUM(NSInteger, KSChangeMediaType) {
    KSChangeMediaTypeUnknown = 0,
    KSChangeMediaTypeVoice   = 1,
    KSChangeMediaTypeVideo   = 2,
};

@interface KSAckMessage : NSObject

@property (nonatomic,copy   ) NSString  *action;
@property (nonatomic,assign ) KSAckType ackType;
@property (nonatomic,strong ) NSNumber  *handleId;
@property (nonatomic,copy   ) NSString  *session_id;

+ (KSAckMessage *)ackWithMessage:(NSDictionary *)message;

@end

@interface KSAckCall : KSAckMessage
@property (nonatomic,assign ) int          call_start;
@property (nonatomic,assign ) int          callback;
@property (nonatomic,copy   ) NSString     *client_type;
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          member;
@property (nonatomic,assign ) int          member_count;
@property (nonatomic,copy   ) NSString     *message;
@property (nonatomic,copy   ) NSString     *offer;
@property (nonatomic,strong ) NSDictionary *payload;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,assign ) int          revision;
@property (nonatomic,copy   ) NSString     *room;
@property (nonatomic,assign ) int          to;
@property (nonatomic,assign ) int          video;
@property (nonatomic,assign) KSCallType callType;
@property (nonatomic,assign ) int          user_id;//他人ID
@end

@interface KSAckRing : KSAckMessage
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,assign ) int          revision;
@end

@interface KSAckJoined : KSAckMessage
@property (nonatomic,assign ) int          call_start;
@property (nonatomic,assign ) int          callback;
@property (nonatomic,copy   ) NSString     *client_type;
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          member;
@property (nonatomic,assign ) BOOL         isMe;
@property (nonatomic,assign ) int          member_count;
@property (nonatomic,copy   ) NSString     *message;
@property (nonatomic,strong ) NSString     *offer;
@property (nonatomic,strong ) NSDictionary *payload;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,copy   ) NSString     *room;
@property (nonatomic,assign ) int          to;
@property (nonatomic,assign ) BOOL         video;
@property (nonatomic,assign ) int          user_id;//他人ID
@property (nonatomic,copy   ) NSString     *user_name;//他人用户名
@end

@interface KSAckCurrentMessage : KSAckMessage
@property (nonatomic,assign ) KSCurrentMessageType messageType;
@property (nonatomic,assign ) int                  call_start;
@property (nonatomic,assign ) int                  callback;
@property (nonatomic,copy   ) NSString             *client_type;
@property (nonatomic,assign ) int                  from;
@property (nonatomic,assign ) int                  member;
@property (nonatomic,assign ) int                  member_count;
@property (nonatomic,copy   ) NSString             *message;
@property (nonatomic,copy   ) NSString             *offer;
@property (nonatomic,strong ) NSDictionary         *payload;
@property (nonatomic,strong ) NSDictionary         *jsep;
@property (nonatomic,assign ) int                  prev_id;
@property (nonatomic,assign ) int                  revision;
@property (nonatomic,copy   ) NSString             *room;
@property (nonatomic,assign ) int                  to;
@property (nonatomic,assign ) int                  video;
@property (nonatomic,assign ) BOOL                 isOffer;
@property (nonatomic,assign ) KSMediaState         switchType;
@property (nonatomic,assign ) int                  user_id;
@property (nonatomic,assign ) KSChangeMediaType    mediaType;
@property (nonatomic,copy   ) NSString             *user_name;
@end

@interface KSAckLeft : KSAckMessage
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,copy   ) NSString     *room;
@property (nonatomic,assign ) int          revision;
@property (nonatomic,assign ) int          user_id;//他人ID
@end

@interface KSAckDecline : KSAckMessage
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,copy   ) NSString     *room;
@property (nonatomic,assign ) int          revision;
@end

@interface KSAckAnswer : KSAckMessage
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,copy   ) NSString     *room;
@property (nonatomic,assign ) int          revision;
@property (nonatomic,assign ) int          call_type;
@end

@interface KSAckAnswered : KSAckMessage
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,copy   ) NSString     *room;
@property (nonatomic,assign ) int          revision;
@end

@interface KSAckStart : KSAckMessage
@property (nonatomic,assign ) int          from;
@property (nonatomic,assign ) int          prev_id;
@property (nonatomic,copy   ) NSString     *room;
@end

//@interface KSAckChangeIce : KSAckMessage
//@property (nonatomic,copy   ) NSString     *message;
//@property (nonatomic,strong ) NSDictionary *payload;
//@property (nonatomic,strong ) NSDictionary *jsep;
//@end

@interface KSRequestError : NSObject
@property (nonatomic,assign ) KSRequestType type;
@property (nonatomic,copy   ) NSString     *errorInfo;
@property (nonatomic,assign ) BOOL          isRespond;
@end



