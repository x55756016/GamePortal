//
//  IAPHelper.m
//  ＋
//
//  Created by Administrator on 15/5/27.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "IAPHelper.h"
#import "KKUtility.h"
//@interface IAPHelper(){
//    NSSet * _productIdentifiers;
//    NSArray * _products;
//    NSMutableSet * _purchasedProducts;
////    SKProductsRequest * _request;
//}
//@end

@implementation IAPHelper

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        // Store product identifiers
        // Check for previously purchased products
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in productIdentifiers) {
//            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
//            if (productPurchased) {
//                [purchasedProducts addObject:productIdentifier];
//                NSLog(@"Previously purchased: %@", productIdentifier);
//            }
            [purchasedProducts addObject:productIdentifier];

            NSLog(@"Add product: %@", productIdentifier);
        }
        self.purchasedProducts = purchasedProducts;
        
    }
    return self;
}
//请求商品列表
- (void)requestProducts {
    if([SKPaymentQueue canMakePayments])
    {
        //Display a store to the user
    }
    else
    {
        //Warn the user that purchases are disabled.
        [KKUtility justAlert:@"the user that purchases are disabled"];
        return;
    }
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    self.request.delegate = self;
    [self.request start];
    
}
//请求商品列表完成事件
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Received products results...");
    self.products = response.products;
    self.request = nil;
    
     [[NSNotificationCenter defaultCenter]postNotificationName:kProductsLoadedNotification object:_products];
}

//开始购买商品
- (void)buyProductIdentifier:(NSString *)productIdentifier {
    
    NSLog(@"Buying %@...", productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
//    
//    if (productIdentifier != nil) {
//        
//        NSLog(@"EBPurchase purchaseProduct: %@", productIdentifier);
//        
//        if ([SKPaymentQueue canMakePayments]) {
//            // Yes, In-App Purchase is enabled on this device.
//            // Proceed to purchase In-App Purchase item.
//            
//            // Assign a Product ID to a new payment request.
//            SKPayment *paymentRequest = [SKPayment paymentWithProduct:requestedProduct];
//            
//            // Assign an observer to monitor the transaction status.
//            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//            
//            // Request a purchase of the product.
//            [[SKPaymentQueue defaultQueue] addPayment:paymentRequest];
//            
//            return YES;
//            
//        } else {
//            // Notify user that In-App Purchase is Disabled.
//            
//            NSLog(@"EBPurchase purchaseProduct: IAP Disabled");
//            
//            return NO;
//        }
//        
//    } else {
//        
//        NSLog(@"EBPurchase purchaseProduct: SKProduct = NIL");
//        
//        return NO;
//    }

}
//- (void)buyProductIdentifier:(SKProduct *)product {
//    
//
//    NSLog(@"Buying %@...", product.productIdentifier);
//    
//    SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct: product];
//    myPayment.quantity = 1;
//    [[SKPaymentQueue defaultQueue] addPayment:myPayment];
//    
//}

//购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
            case SKPaymentTransactionStatePurchasing://购买中更新状态
                [self PurchasingTransaction:transaction];
            default:
                break;
        }
    }
}

//交易中
- (void)PurchasingTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"PurchasingTransaction...");
//    [self recordTransaction: transaction];
//    [self provideContent: transaction.payment.productIdentifier];
//    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}
//交易成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...");
    [self provideContent: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}
//交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"购买失败");
    } else {
        NSLog(@"用户取消交易");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}
//交易重复
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...");
    
//    [self recordToServerTransaction: transaction];
    [self provideContent: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

//本地记录交易结果
- (void)provideContent:(SKPaymentTransaction *)transaction  {
    
    NSLog(@"Toggling flag for: %@", transaction.payment.productIdentifier);
    
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.purchasedProducts addObject:transaction.payment.productIdentifier];
    
    
    
    
    NSData *receiptData;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[[NSBundle mainBundle] appStoreReceiptURL]];
        NSError *error = nil;
        receiptData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&error];
    }
    else {//iOS 6.1 or earlier.
        receiptData = transaction.transactionReceipt;
    }
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    
//    NSString *aString = [[NSString alloc] initWithData:receiptData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Purchased: %@",payload);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:receiptData];
   
    NSLog(@"Purchased: %@", transaction.payment.productIdentifier);
    
    [self verifyPruchase];
}

//通知web服务器记录购买信息
//- (void)recordToServerTransaction:(SKPaymentTransaction *)transaction {
//    // Optional: Record the transaction on the server side...
//    NSString * productIdentifier = transaction.payment.productIdentifier;
////    transaction.transactionReceipt
//   
//}

- (void)verifyPruchase
 {
     return;
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        // 从沙盒中获取到购买凭据
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];

        // 发送网络POST请求，对购买凭据进行验证
        NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
         // 国内访问苹果服务器比较慢，timeoutInterval需要长一点
         NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    
         request.HTTPMethod = @"POST";
    
         // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
         // 传输的是BASE64编码的字符串
         /**
            20      BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
            21      BASE64是可以编码和解码的
            22      */
         NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
         NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
         NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    
         request.HTTPBody = payloadData;
    
         // 提交验证请求，并获得官方的验证JSON结果
         NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
         // 官方验证结果为空
         if (result == nil) {
                 NSLog(@"验证失败");
             }
    
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
    
         NSLog(@"%@", dict);
    
         if (dict != nil) {
                 // 比对字典中以下信息基本上可以保证数据安全
                 // bundle_id&application_version&product_id&transaction_id
                 NSLog(@"验证成功");
             }
}



@end
