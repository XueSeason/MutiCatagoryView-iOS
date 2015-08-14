//
//  XSMutiCatagoryViewController.m
//  XSMutiCatagoryView
//
//  Created by 薛纪杰 on 15/8/13.
//  Copyright (c) 2015年 薛纪杰. All rights reserved.
//

#import "XSMutiCatagoryViewController.h"
#import "XSMutiCatagoryCollectionViewCell.h"
#import "XSHeaderCollectionReusableView.h"

#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "MJExtension.h"

#define kThemeColor [UIColor colorWithRed:223 / 255.0 green:24 / 255.0 blue:37 / 255.0 alpha:1.0];
#define kMenuColor [UIColor colorWithRed:206 / 255.0 green:206 / 255.0 blue:206 / 255.0 alpha:1.0];

NSString * const protocol = @"http";
NSString * const address  = @"127.0.0.1";
NSString * const port     = @"3000";
NSString * const path     = @"/";

NSString * const tableCellId        = @"menu";
NSString * const collectionCellId   = @"item";
NSString * const collectionFooterId = @"footer";
NSString * const collectionHeaderId = @"header";

/**
 *  模型
 */
@interface JSONData : NSObject
@property (strong, nonatomic) NSArray *menus;
@property (strong, nonatomic) NSString *status;
@end
@implementation JSONData
@end

@interface Menu : NSObject
@property (strong, nonatomic) NSString *menuName;
@property (strong, nonatomic) NSArray  *groups;
@end
@implementation Menu
@end

@interface Group : NSObject
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSArray  *movies;
@end
@implementation Group
@end

@interface Movie : NSObject
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;
@end
@implementation Movie
@end


@interface XSMutiCatagoryViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>

//@property (strong, nonatomic)        NSDictionary     *jsonData;
@property (strong, nonatomic)        JSONData         *jsonData;
@property (strong, nonatomic)        Menu             *selectMenu;

@property (weak, nonatomic) IBOutlet UITableView      *tableView;
@property (assign, nonatomic)        NSInteger        selectMenuIndex;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation XSMutiCatagoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    /**
     *  关联对应模型
     */
    [JSONData setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"menus": @"Menu",
                 @"status": @"status"
                 };
    }];
    
    [Menu setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"menuName": @"menuName",
                 @"groups": @"Group"
                 };
    }];
    
    [Group setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"groupName": @"groupName",
                 @"movies": @"Movie"
                 };
    }];
    
    [Movie setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"imageURL": @"imageURL",
                 @"name": @"name",
                 @"url": @"url"
                 };
    }];
    

    /**
     *  设置导航栏
     */
    self.navigationItem.title = @"商品分类";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.backgroundColor = kThemeColor;
    self.navigationController.navigationBar.barTintColor = kThemeColor;
    
    /**
     *  设置标签栏
     */
    self.tabBarController.tabBar.backgroundColor = kThemeColor;
    self.tabBarController.tabBar.barTintColor = kThemeColor;
    
    /**
     *  设置 Table View
     */
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kMenuColor;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableCellId];
    
    /**
     *  设置 Collection View
     */
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[XSMutiCatagoryCollectionViewCell class] forCellWithReuseIdentifier:collectionCellId];
    [_collectionView registerNib:[UINib nibWithNibName:@"XSMutiCatagoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:collectionCellId];
    
    [_collectionView registerClass:[XSHeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderId];
    [_collectionView registerNib:[UINib nibWithNibName:@"XSHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderId];
    
    /**
     *  获取JSON数据
     */
    [self loadJSONData];
    
}

- (void)loadJSONData {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时操作
        [self loadJSONDataFromService];
        
        // 切换到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

- (void)loadJSONDataFromService {
    NSString *URLString = [NSString stringWithFormat:@"%@://%@:%@%@", protocol, address, port, path];
    NSDictionary *parameters = @{};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    [manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        // 回调函数
        NSError *error;
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        _jsonData = [JSONData objectWithKeyValues:data];
        
        if (error) {
            NSLog(@"Parser: %@", error);
            return;
        }
        
        if (!([_jsonData.status isEqualToString:@"200"])) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取数据异常" message:@"无法从服务器获取正确的数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
            NSLog(@"Status Exception.");
            return;
        }
        // 加载数据
        [_tableView reloadData];
        [self tableView:_tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取数据失败" message:@"无法连接到服务器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"GET JSON Error: %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _jsonData.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellId forIndexPath:indexPath];
    
    Menu *menu = (Menu *)_jsonData.menus[indexPath.row];
    cell.textLabel.text = menu.menuName;
    
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.backgroundColor = kMenuColor;
    cell.contentView.backgroundColor = kMenuColor;
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor whiteColor];
    // 滚动到顶部
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    _selectMenuIndex = indexPath.row;
    _selectMenu = (Menu *)_jsonData.menus[_selectMenuIndex];
    
    [_collectionView reloadData];
}

#pragma mark - Collection View Data Source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _selectMenu.groups.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return [[[_jsonData.menus[_selectMenuIndex] groups] objectAtIndex:section] movies].count;
    return [_selectMenu.groups[section] movies].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XSMutiCatagoryCollectionViewCell *cell = (XSMutiCatagoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];
    
    // 填写数据
    Movie *movie = (Movie *)[[_selectMenu.groups[indexPath.section] movies] objectAtIndex:indexPath.row];
    cell.name.text = movie.name;
    cell.picture.backgroundColor = [UIColor grayColor];
    [cell.picture sd_setImageWithURL:[NSURL URLWithString:movie.imageURL]];
    return cell;
}

#pragma mark - Collection Flow Layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    XSMutiCatagoryCollectionViewCell * cell = (XSMutiCatagoryCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"%d %d %d 被点击", (int)_selectMenuIndex, (int)indexPath.section, (int)indexPath.row);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *reusedId;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        reusedId = collectionFooterId;

    } else {
        reusedId = collectionHeaderId;
        XSHeaderCollectionReusableView *header =  [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeaderId forIndexPath:indexPath];
        header.colorLabel.backgroundColor = [UIColor redColor];
        header.titleLabel.text = [_selectMenu.groups[indexPath.section] groupName];
        return header;
    }
    return nil;
}

@end
