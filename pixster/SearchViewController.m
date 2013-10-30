//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (nonatomic, strong) NSMutableArray *imageResults;

- (IBAction)onCollectionViewTap:(id)sender;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;

@end

const int NUM_SECTIONS = 1;
NSString* const CELL_REUSE_IDENTIFIER = @"PixsterImageCell";

@implementation SearchViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        self.topConstraint =
        [NSLayoutConstraint constraintWithItem:self.searchBar
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.topLayoutGuide
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:0];
    } else {
        self.topConstraint =
        [NSLayoutConstraint constraintWithItem:self.searchBar
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:0
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:0];
    }
    [self.view addConstraint:self.topConstraint];
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    
    UINib* cellNib = [UINib nibWithNibName:@"ImageCollectionCell" bundle:nil];
    [self.imageCollectionView registerNib:cellNib forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return NUM_SECTIONS;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.imageResults count] == 0) {
        return 0;
    }
    
    return [self.imageResults count]/NUM_SECTIONS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    const int IMAGE_TAG = 1;
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
    
    // Clear the previous image
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.item] valueForKeyPath:@"url"]]];
    
    return cell;
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            // Filtering out images from eofdreams domain, since they didn't seem to load properly
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (url like[c] %@)", @"*eofdreams*"];
            [self.imageResults addObjectsFromArray:[results filteredArrayUsingPredicate:predicate]];
            [self.imageCollectionView setContentOffset:CGPointZero animated:YES];
            [self.imageCollectionView reloadData];
        }
    } failure:nil];
    
    [operation start];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (IBAction)onCollectionViewTap:(id)sender {
    [self.searchBar resignFirstResponder];
}
@end
