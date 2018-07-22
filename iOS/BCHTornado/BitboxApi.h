//
//  BitBoxApi.h
//  BCHTornado
//
//  Created by Song Xiaofeng on 21/07/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitboxApi : NSObject


// Makes sync request for unspent outputs and parses the outputs.
- (NSArray*) unspentOutputsWithAddress:(NSString*)address error:(NSError**)errorOut;


// Broadcasting transaction

// Request to broadcast a raw transaction data.
- (NSMutableURLRequest*) requestForTransactionBroadcastWithData:(NSData*)data;
@end
