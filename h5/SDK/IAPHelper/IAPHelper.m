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
//- (void)buyProductIdentifier:(NSString *)productIdentifier {
//    
//    NSLog(@"Buying %@...", productIdentifier);
//    
//    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//    
//}
- (void)buyProductIdentifier:(SKProduct *)product {
    

    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct: product];
    myPayment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:myPayment];
    
}

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
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

//交易成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...");
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
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
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

//本地记录交易结果
- (void)provideContent:(NSString *)productIdentifier {
    
    NSLog(@"Toggling flag for: %@", productIdentifier);
    
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.purchasedProducts addObject:productIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:productIdentifier];
    
}

//通知web服务器记录购买信息
- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    // Optional: Record the transaction on the server side...
    NSString * productIdentifier = transaction.payment.productIdentifier;
//    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
    }
}





@end
