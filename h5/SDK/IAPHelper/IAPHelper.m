//
//  IAPHelper.m
//  ＋
//
//  Created by ken on 15/5/27.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "IAPHelper.h"
#import "KKUtility.h"
#import "SVProgressHUD.h"
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


//开始购买商品
- (void)buyProductIdentifier:(NSString *)kkproductIdentifier {
    if (kkproductIdentifier != nil) {
            NSLog(@"Purchase purchaseProduct: %@", kkproductIdentifier);
            if ([SKPaymentQueue canMakePayments]) {
                [self requestProducts:kkproductIdentifier];
            } else {
                [KKUtility justAlert:@"此设备未开启支付功能，请确认！"];
            }
    
        } else {
            [KKUtility justAlert:@"购买的商品Id为空，请联系客服或重试。"];
        }
}
//请求商品列表
- (void)requestProducts:(NSString *) kkproductIdentifier {
    NSMutableSet * purchasedProducts = [NSMutableSet set];
    [purchasedProducts addObject:kkproductIdentifier];
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:purchasedProducts];
    self.request.delegate = self;
    [self.request start];
    
    [SVProgressHUD showWithStatus:@"购买正在进行中\n完成前请先不要离开......" maskType:SVProgressHUDMaskTypeGradient];
}
//请求商品列表完成事件
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Received products results...");
    self.products = response.products;
    self.request = nil;
    SKProduct *kkProduct=[self.products objectAtIndex:0];
    if([self.products count]==0)
    {
        [SVProgressHUD showErrorWithStatus:@"根据商品id未获取到商品，\n请联系客服或重试"];
        
    }
    //开始购买
     SKPayment *payment = [SKPayment paymentWithProduct:kkProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];

}




//交易中
- (void)PurchasingTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"PurchasingTransaction...");
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    // 调试
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"队列状态变化 %@", transaction);
        
        
        switch (transaction.transactionState)
                {
                    case SKPaymentTransactionStatePurchased://交易完成
                        [self completeTransaction:transaction];
                        break;
                    case SKPaymentTransactionStateFailed://交易失败
                        [self failedTransaction:transaction];
                        break;
                    case SKPaymentTransactionStateRestored: // 恢复已购
                        [self restoreTransaction:transaction];
                        break;
                    case SKPaymentTransactionStatePurchasing://购买中更新状态
                        [self PurchasingTransaction:transaction];
                        break;
                    default:
                        break;
                }

        // 如果小票状态是购买完成
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
           
        } else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
          
        }
    }
}

//交易成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    // 更新界面或者数据，把用户购买得商品交给用户
    // ...
    // 验证购买凭据
    // [self verifyPruchase];
    // 将交易从交易队列中删除
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSLog(@"购买完成 %@", transaction.payment.productIdentifier);
    [self provideContent: transaction];
    [SVProgressHUD dismiss];
}
//交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"购买失败 %@", transaction.payment.productIdentifier);
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
    [SVProgressHUD dismiss];
}
//恢复已购
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"恢复购买成功 %@", transaction.payment.productIdentifier);
    // 更新界面或者数据，把用户购买得商品交给用户
    // ...
    // 将交易从交易队列中删除
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [SVProgressHUD dismiss];
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
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    
    
    NSString *rawString=[[NSString alloc]initWithData:receiptData encoding:enc];
     NSLog(@"receiptData: %@",rawString);
    
    
    NSString *aString = [[NSString alloc] initWithData:receiptData encoding:NSUTF8StringEncoding];
    NSLog(@"receiptData: %@",aString);

    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if(encodeStr==nil || [encodeStr length]==0)
    {
        return;
    }
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    

    
    NSLog(@"Purchased: %@",payload);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:payload];
   
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
    

         if (dict != nil) {
                 // 比对字典中以下信息基本上可以保证数据安全
                 // bundle_id&application_version&product_id&transaction_id
                 NSLog(@"验证成功");
                NSLog(@"%@", dict);
             
             }
}



@end
