
#import "ShopTableViewController.h"
//#import "IAPHelper.h"
#import "InAppRageIAPHelper.h"
#import "Reachability.h"
#import "ProductTableViewCell.h"
#import "KKUtility.h"
#import "UIImageView+WebCache.h"
#import "ASIFormDataRequest.h"
#import "h5kkContants.h"

@interface ShopTableViewController ()
{
    NSDictionary *userInfo;

    ASIFormDataRequest *request;
}

@end

@implementation ShopTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        [KKUtility justAlert:@"无可用网络，请联系网络后再试。"];
    } else {
//        if ([InAppRageIAPHelper sharedHelper].products == nil) {
//            
//            [[InAppRageIAPHelper sharedHelper] requestProducts];
//          
//            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//            
//            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
//            
//        }
        [self getProductFromKkServer];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //获取用户信息
    userInfo=[KKUtility getUserInfoFromLocalFile];
}




//--------------------------------------加载好友数据-----------------------------------------------//
-(void)getProductFromKkServer
{

    
    NSString *urlStr = GET_ProductItem;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
     [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"1"]] forKey:@"TypeId"];
    [request setDidFailSelector:@selector(loadProductItemFail:)];
    [request setDidFinishSelector:@selector(loadProductItemFinish:)];
    [request startAsynchronous];
}

- (void)loadProductItemFinish:(ASIHTTPRequest *)req
{
    NSLog(@"loadFriendsFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    //    NSLog(@"friendsdict[%@]",dict);
    
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadFriendsData:dict];
    }
    else
    {
        [KKUtility justAlert:@"未获取到在线商品，请联系客服或重试。"];
    }
    
}

- (void)loadProductItemFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取商品列表信息失败 " :req.error];
}

//好友数据刷表
-(void)loadFriendsData:(NSDictionary *)dict
{
    @try {
        self.kkproducts = [dict objectForKey:@"ObjData"];
        //    NSLog(@"friendsArray[%lu]%@", (unsigned long)friendsArray.count, friendsArray);
        //加载的人的数据保存至本地
        //[self savePeopleDate:0];
        //结束刷新状态
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
    
}
//-----------------------------------------





- (void)dismissHUD:(id)arg {
    
   [SVProgressHUD dismiss];
    
}

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];

    self.tableView.hidden = FALSE;
    
    [self.tableView reloadData];
    
}

- (void)timeout:(id)arg {
    
    [SVProgressHUD showWithStatus:@"超时，请重试。。。"];
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
return [[InAppRageIAPHelper sharedHelper].products count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *reuseIdentifier = @"ProductTableViewCell";
    [tableView registerNib:[UINib nibWithNibName:@"ProductTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *playerDict = self.kkproducts[indexPath.row];
        

    cell.ProductName.text = [playerDict objectForKey:@"Name"];
    cell.ProductDescription.text = [playerDict objectForKey:@"Desc"];
    
    NSString *IMGstring = [playerDict objectForKey:@"Pic"];
    [cell.ProductImage sd_setImageWithURL:[NSURL URLWithString:IMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    CALayer * l = [cell.ProductImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    
    NSString *strBtnPrice=[@"¥" stringByAppendingString:[playerDict objectForKey:@"Price"]];
    [cell.ProductBuyButton setTitle:strBtnPrice forState:UIControlStateNormal];
    [cell.ProductBuyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (IBAction)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[InAppRageIAPHelper sharedHelper] buyProductIdentifier:product];
    
      [SVProgressHUD showWithStatus:@"正在购买中。。。"];
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
    
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    [self.tableView reloadData];
    
}

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];

    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误!"
                                                         message:transaction.error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    
}
@end
