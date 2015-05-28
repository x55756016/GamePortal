//
//  IAPHelper.h
//  ＋
//
//  Created by Administrator on 15/5/27.
//  Copyright (c) 2015年 hf. All rights reserved.
//
#import <StoreKit/StoreKit.h>

#import <Foundation/Foundation.h>
#define kProductsLoadedNotification         @"ProductsLoaded"//获取到商品信息
#define kProductPurchasedNotification       @"ProductPurchased"//支付成功
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"//支付失败


@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (retain) NSSet *productIdentifiers;
@property (retain) NSArray * products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

- (void)requestProducts;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

//- (void)buyProductIdentifier:(SKProduct *)product;

- (void)buyProductIdentifier:(NSString *)productIdentifier;

@end
