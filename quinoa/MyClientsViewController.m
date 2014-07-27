//
//  MyClientsViewController.m
//  quinoa
//
//  Created by Chirag Davé on 7/13/14.
//  Copyright (c) 2014 3eesho. All rights reserved.
//

#import "MyClientsViewController.h"
#import "ClientRowCell.h"
#import <Parse/Parse.h>
#import "User.h"
#import "UILabel+QuinoaLabel.h"
#import "ActivitiesCollectionViewController.h"
#import "ChatViewController.h"

@interface MyClientsViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *myClientsCollection;
@property (strong, nonatomic) NSArray *clients;

@end

@implementation MyClientsViewController

static NSString *CellIdentifier = @"ClientRowCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"My Clients";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.myClientsCollection registerClass:[ClientRowCell class] forCellWithReuseIdentifier:CellIdentifier];

    self.myClientsCollection.dataSource = self;
    self.myClientsCollection.delegate = self;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(300, 85)];
    
    // Spacing for flowlayout
    [flowLayout setMinimumLineSpacing:8];
    [flowLayout setMinimumInteritemSpacing:4];
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [self.myClientsCollection setCollectionViewLayout:flowLayout];
    [self.myClientsCollection setBackgroundColor:[UIColor whiteColor]];
    
    [self fetchClients];
    
    // I can only make the navigation bar opaque by setting it on each page
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchClients {
    User *currentUser = [User currentUser];
    PFQuery *query = [User query];
    [query whereKey:@"currentTrainer" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.clients = objects;
            [self.myClientsCollection reloadData];
        } else {
            NSLog(@"Error Fetching Clients: %@", error);
        }
    }];
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.clients count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ClientRowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                 forIndexPath:indexPath];
    cell.client = self.clients[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    User *client = self.clients[indexPath.row];
    ActivitiesCollectionViewController *activitiesController = [[ActivitiesCollectionViewController alloc] initWithUser:client];
    [self.navigationController pushViewController:activitiesController animated:YES];
}


@end
