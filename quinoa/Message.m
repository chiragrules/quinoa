//
//  Message.m
//  quinoa
//
//  Created by Chirag Davé on 7/6/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import "Message.h"
#import <Parse/PFObject+Subclass.h>

@implementation Message

@dynamic text;
@dynamic sender;
@dynamic recipient;
@dynamic threadId;

+ (NSString *)parseClassName {
    return @"Message";
}

// This assumes all conversations are between expert and user.
// threadId will always be EXPERTID_USER_ID
+ (NSString *)calcThreadIdWithSender:(PFUser *)sender recipient:(PFUser *)recipient {
    if ([sender[@"role"] isEqualToString:@"expert"]) {
        return [NSString stringWithFormat:@"%@_%@", sender.objectId, recipient.objectId];
    } else {
        return [NSString stringWithFormat:@"%@_%@", recipient.objectId, sender.objectId];
    }

}

- (void)setThreadId {
    self.threadId = [Message calcThreadIdWithSender:self.sender recipient:self.recipient];
}

+ (Message *)sendMessageToUser:(PFUser *)recipient fromUser:(PFUser *)sender message:(NSString *)message {
    Message *newMessage = [Message object];
    newMessage.text = message;
    newMessage.sender = sender;
    newMessage.recipient = recipient;
    [newMessage setThreadId];
    [newMessage saveInBackground];
    return newMessage;
}

@end
