//
//  BitboxApi.m
//  BCHTornado
//
//  Created by Song Xiaofeng on 21/07/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

#import "BitboxApi.h"
#import <CoreBitcoin/BTCTransactionOutput.h>
#import <CoreBitcoin/BTCScript.h>
#import <CoreBitcoin/BTCData.h>

@implementation BitboxApi

// Builds a request from a list of BTCAddress objects.
- (NSMutableURLRequest*) requestForUnspentOutputsWithAddresses:(NSString*)address {
    if (address.length == 0) return nil;
    
    NSString* urlstring = [NSString stringWithFormat:@"https://rest.bitbox.earth/v1/address/utxo/%@", address];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    request.HTTPMethod = @"GET";
    return request;
}

// List of BTCTransactionOutput instances.
- (NSArray*) unspentOutputsForResponseData:(NSData*)responseData error:(NSError**)errorOut {
    if (!responseData) return nil;
    NSError* parseError = nil;
    NSArray* utxos = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
    if (!utxos || ![utxos isKindOfClass:[NSArray class]]) {
        // Blockchain.info returns "No free outputs to spend" instead of a valid JSON.
        NSString* responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (responseString && [responseString rangeOfString:@"No free outputs to spend"].length > 0) {
            return @[];
        }
        if (errorOut) *errorOut = parseError;
        return nil;
    }
    
    NSMutableArray* outputs = [NSMutableArray array];
    
    for (NSDictionary* item in utxos) {
        BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
        
        txout.value = [item[@"satoshis"] longLongValue];
        txout.script = [[BTCScript alloc] initWithData:BTCDataFromHex(item[@"scriptPubKey"])];
        txout.index = [item[@"vout"] intValue];
        txout.confirmations = [item[@"confirmations"] unsignedIntegerValue];
        txout.transactionHash = BTCReversedData((BTCDataFromHex(item[@"txid"]))); //  here txid is  reversed
        
        [outputs addObject:txout];
    }
    
    return outputs;
    
    /*
     [
     {
     "txid": "ea6cb5eb17e8e1ed298e8865a489978ef0638013812717f3385d435af052c250",
     "vout": 0,
     "scriptPubKey": "76a9144651ac75ab03abcc1e41cc80a22b90811f33d1a788ac",
     "amount": 0.02,
     "satoshis": 2000000,
     "height": 539937,
     "confirmations": 5,
     "legacyAddress": "17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc",
     "cashAddress": "bitcoincash:qpr9rtr44vp6hnq7g8xgpg3tjzq37v735utl4s7s66"
     }
     ]
     */
    
}

- (NSArray*) unspentOutputsWithAddress:(NSString*)address error:(NSError**)errorOut {
    NSURLRequest* req = [self requestForUnspentOutputsWithAddresses:address];
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:errorOut];
    if (!data) {
        return nil;
    }
    return [self unspentOutputsForResponseData:data error:errorOut];
}

- (NSMutableURLRequest*) requestForTransactionBroadcastWithData:(NSData*)data {
    if (data.length == 0) return nil;
    
    NSString* urlstring = [NSString stringWithFormat:@"https://rest.bitbox.earth/v1/rawtransactions/sendRawTransaction/%@", BTCHexFromData(data)];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]];
    request.HTTPMethod = @"POST";
//    NSString* form = [NSString stringWithFormat:@"tx=%@", BTCHexFromData(data)];
//    request.HTTPBody = [form dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (BOOL) broadcastTransactionData:(NSData*)data error:(NSError**)errorOut {
    NSURLRequest* req = [self requestForTransactionBroadcastWithData:data];
    NSURLResponse* response = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:errorOut];
    if (!resultData) {
        return NO;
    }
    
    // TODO: parse the response to determine if it was successful or not.
    
    return YES;
}


@end
