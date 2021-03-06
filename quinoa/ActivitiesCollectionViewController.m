//
//  ActivitiesCollectionViewController.m
//  quinoa
//
//  Created by Amie Kweon on 7/12/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//
//  This is used for three different flows:
//  - Seeker / Profile: Show header  "Profile"
//  - Expert / Profile: Show header  "Profile"  initWithUser
//  - Expert / Activities: No header  "Activities"
//
//  `isProfile` indicates this is a Profile view
//  `isExpert` indicates the current user is an expert

#import "ActivitiesCollectionViewController.h"
#import "ProfileViewController.h"
#import "Activity.h"
#import "ActivityLike.h"
#import "Goal.h"

#import "ActivityCell.h"
#import "ProfileCell.h"
#import "UILabel+QuinoaLabel.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "ChatViewController.h"
#import "GoalEditView.h"

#import "QuinoaFlowLayout.h"

@interface ActivitiesCollectionViewController ()
{

    User *user;
    BOOL isExpert;
    BOOL isProfile;
    BOOL showChat;
    BOOL goalDisplayed;
}


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) ActivityCell *stubCell;
@property (strong, nonatomic) GoalEditView *goalEditView;
@property (strong, nonatomic) NSArray *activities; // may have to change to NSMutableArray later on
@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) Goal *goal;
@end

@implementation ActivitiesCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isProfile = NO;
        user = [User currentUser];
        isExpert = [user isExpert];
        self.stubCell = [[ActivityCell alloc] init];
        self.title = @"Activity";
        self.likes = [[NSMutableArray alloc] init];
        showChat = NO;
        goalDisplayed = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onActivityLiked:)
                                                     name:@"activityLiked"
                                                   object:nil];
    }
    return self;
}

- (id)initWithUser:(User *)profileUser {
    if ( self = [super init] ) {
        isProfile = YES;
        isExpert = [user isExpert];
        user = profileUser;

        self.stubCell = [[ActivityCell alloc] init];
        //self.title = isExpert ? @"Activity": user.firstName;
        self.title = isExpert ? user.firstName : @"Activity";
        self.likes = [[NSMutableArray alloc] init];
        showChat = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onActivityLiked:)
                                                     name:@"activityLiked"
                                                   object:nil];
        
    }
    return self;
}


/*- (id)initWithUser:(User *)user initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
            self.stubCell = [[ActivityCell alloc] init];
         self.title = user.firstName;
        self.likes = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onActivityLiked:)
                                                     name:@"activityLiked"
                                                   object:nil];
    }
    return self;
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupUI];

    [self.collectionView registerClass:[ActivityCell class] forCellWithReuseIdentifier:@"ActivityCell"];
    [self.collectionView registerClass:[ProfileCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileCell"];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    // I can only make the navigation bar opaque by setting it on each page
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCell"
                                                                 forIndexPath:indexPath];
    Activity *activity = self.activities[indexPath.row];
    cell.liked = [self liked:activity];
    [cell setActivity:activity showHeader:YES showLike:isExpert];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    [self.stubCell setActivity:self.activities[indexPath.row] showHeader:YES showLike:isExpert];
    CGSize size = [self.stubCell cellSize];

    return size;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (isProfile && kind == UICollectionElementKindSectionHeader) {
        ProfileCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileCell" forIndexPath:indexPath];
        headerView.isExpertView = isExpert;
        headerView.goalDelegate = self;
        headerView.user = user;
        [headerView.profileView.chatButton addTarget:self action:@selector(chatClick:) forControlEvents:UIControlEventTouchUpInside];
        reusableView = headerView;
    }
    return reusableView;
}

- (void)chatClick:(id)sender {
    ChatViewController *chatView = [[ChatViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:chatView animated:YES];
}


- (void)onActivityLiked:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"activityLiked"]) {
        NSDictionary *activityData = [notification valueForKey:@"object"];
        Activity *activity = activityData[@"activity"];
        User *expert = activityData[@"expert"];
        if ([activityData[@"liked"] isEqual:@(YES)]) {
            NSLog(@"[ActivitiesCollection] liked");
            [ActivityLike likeActivity:activity user:activity.user expert:expert];
            [self.likes addObject:activity.objectId];
        } else {
            NSLog(@"[ActivitiesCollection] unliked");
            [ActivityLike unlikeActivity:activity expert:expert];
            [self.likes removeObject:activity.objectId];
        }
    }
}

- (void)fetchData {
    // TODO: Add paging here
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self fetchActivityLikes];
    if (isExpert && !isProfile) {
        [Activity getClientActivitiesByExpert:user success:^(NSArray *activities) {
            BOOL reload = self.activities.count != activities.count;
            if (reload) {
                // clear out old activities
                // TODO : This cannot be the best way...
                self.activities = [[NSArray alloc] init];
                [self.collectionView reloadData];
                [self.collectionView performBatchUpdates:^{
                    self.activities = activities;
                    NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
                    for (NSInteger i = 0; i < self.activities.count; i++) {
                        [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
                } completion:nil];
            }

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } error:^(NSError *error) {
            NSLog(@"[ActivitiesCollection clients] error: %@", error.description);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    } else {
        [Activity getActivitiesByUser:user success:^(NSArray *activities) {
            BOOL reload = self.activities.count != activities.count;
            if (reload) {
                self.activities = [[NSArray alloc] init];
                [self.collectionView reloadData];
                
                [self.collectionView performBatchUpdates:^{
                    self.activities = activities;
                    NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
                    for (NSInteger i = 0; i < self.activities.count; i++) {
                        [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
                } completion:nil];

            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } error:^(NSError *error) {
            NSLog(@"[ActivitiesCollection my activities] error: %@", error.description);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    [Goal getCurrentGoalByUser:user success:^(Goal *goal) {
        NSLog(@"[ActivitiesCollection my goal]: %@", goal);
        self.goal = goal;
    } error:^(NSError *error) {
        NSLog(@"[ActivitiesCollection my goal] error: %@", error.description);
    }];
}

- (void)fetchActivityLikes {
    User *expert = (isExpert) ? user : user.currentTrainer;
    // This query won't work if expert changed, but we're not worrying about that now.
    [ActivityLike getActivityLikesByExpert:expert success:^(NSArray *activityLikes) {
        for (ActivityLike *activityLike in activityLikes) {
            [self.likes addObject:activityLike.activity.objectId];
        }
    } error:^(NSError *error) {
        NSLog(@"[ActivitiesCollection activityLikes] error: %@", error.description);
    }];
}

- (void)setupUI {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundView = view;

    QuinoaFlowLayout *flowLayout = [[QuinoaFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    if (isProfile) {
        [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width-20, 180)];
    }
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [self.collectionView setCollectionViewLayout:flowLayout];

    if (isProfile && !isExpert) {
        UIBarButtonItem *profileButton = [[UIBarButtonItem alloc]
                                          initWithTitle:@"Edit"
                                          style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(showProfile:)];
        self.navigationItem.rightBarButtonItem = profileButton;
    }
}

- (void)showProfile:(id)sender {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    UINavigationController *navBar = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    [self presentViewController:navBar animated:YES completion:nil];
}

- (BOOL)liked:(Activity *)activity {
    return [self.likes indexOfObject:activity.objectId] != NSNotFound;
}

- (void)showGoalUIClicked {
    if (goalDisplayed) {
        if (!self.goal) {
            self.goal = [Goal object];
            self.goal.user = user;
            self.goal.expert = [user currentTrainer];
            self.goal.startAt = [NSDate date];
        }
        self.goal.endAt = [self.goal.startAt dateByAddingTimeInterval:60*60*24*[self.goalEditView.targetDate intValue]];
        self.goal.targetDailyDuration = self.goalEditView.targetDailyDuration;
        self.goal.targetWeight = self.goalEditView.targetWeight;
        [self.goal saveInBackground];

        [self.goalEditView removeFromSuperview];
        self.goalEditView = nil;
    } else {
        self.goalEditView = [[GoalEditView alloc] initWithFrame:CGRectMake(0, 180, self.view.frame.size.width, 300)];
        self.goalEditView.user = user;
        if (self.goal) {
            self.goalEditView.goal = self.goal;
        } else {
            self.goalEditView.goal = [[Goal alloc] init];
        }
        [self.view addSubview:self.goalEditView];
    }
    goalDisplayed = !goalDisplayed;
}
@end
