#import "NYPLConfiguration.h"
#import "NYPLReaderSettings.h"
#import "NYPLReaderTOCCell.h"
#import "NYPLReaderTOCElement.h"
#import "NYPLReadium.h"
#import <PureLayout/PureLayout.h>
#import "NYPLReaderTOCViewController.h"
#import "NYPLReadiumViewSyncManager.h"

#import "NYPLReaderReadiumView.h"
#import "SimplyE-Swift.h"
#import "NSDate+NYPLDateAdditions.h"


@interface NYPLReaderTOCViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *noBookmarksLabel;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL darkColorScheme;

- (IBAction)didSelectSegment:(id)sender;

@end

static NSString *const reuseIdentifierTOC = @"contentCell";
static NSString *const reuseIdentifierBookmark = @"bookmarkCell";


@implementation NYPLReaderTOCViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  self.title = NSLocalizedString(@"ReaderTOCViewControllerTitle", nil);
  
  [self createViews];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.barTintColor = nil;
  
  [self.tableView reloadData];
  
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:
      if ([self.tableView.subviews containsObject:self.refreshControl]){
        [self.refreshControl removeFromSuperview];
      }
      break;
    case 1:
      self.refreshControl = [[UIRefreshControl alloc] init];
      [self.refreshControl addTarget:self action:@selector(userDidRefresh:) forControlEvents:UIControlEventValueChanged];
      [self.tableView addSubview:self.refreshControl];
      break;
    default:
      break;
  }

  switch([NYPLReaderSettings sharedSettings].colorScheme) {
    case NYPLReaderSettingsColorSchemeBlackOnSepia:
    self.tableView.backgroundColor = [NYPLConfiguration backgroundSepiaColor];
    self.view.backgroundColor = [NYPLConfiguration backgroundSepiaColor];
    self.segmentedControl.tintColor = [NYPLConfiguration mainColor];
    break;
    case NYPLReaderSettingsColorSchemeBlackOnWhite:
    self.tableView.backgroundColor = [NYPLConfiguration backgroundColor];
    self.view.backgroundColor = [NYPLConfiguration backgroundColor];
    self.segmentedControl.tintColor = [NYPLConfiguration mainColor];
    break;
    case NYPLReaderSettingsColorSchemeWhiteOnBlack:
    self.tableView.backgroundColor = [NYPLConfiguration backgroundDarkColor];
    self.view.backgroundColor = [NYPLConfiguration backgroundDarkColor];
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.darkColorScheme = YES;
    break;
  }

  [self.tableView reloadData];
}

- (void)userDidRefresh:(UIRefreshControl *)refreshControl
{
  NYPLReaderReadiumView *rv = [[NYPLReaderSettings sharedSettings] currentReaderReadiumView];
  [rv.syncManager syncBookmarksWithCompletion:^(BOOL success, NSArray *bookmarks) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (success) {
        self.bookmarks = bookmarks.mutableCopy;
        [self.tableView reloadData];
      }
      [refreshControl endRefreshing];
    });
  }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(__attribute__((unused)) UITableView *)tableView
 numberOfRowsInSection:(__attribute__((unused)) NSInteger)section
{
  NSUInteger numRows = 0;
  
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:
      numRows = self.tableOfContents.count;
      break;
    case 1:
      numRows = self.bookmarks.count;
      break;
    default:
      break;
  }
  
  return numRows;
}

- (UITableViewCell *)tableView:(__attribute__((unused)) UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *const)indexPath
{
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:{
      NYPLReaderTOCCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifierTOC];
      NYPLReaderTOCElement *const toc = self.tableOfContents[indexPath.row];
  
      cell.leadingEdgeConstraint.constant = 0;
      cell.leadingEdgeConstraint.constant = toc.nestingLevel * 20 + 10;
      cell.titleLabel.text = toc.title;

      //GODO
      cell.background.layer.borderColor = [NYPLConfiguration mainColor].CGColor;
      cell.background.layer.borderWidth = 1;
      cell.background.layer.cornerRadius = 3;

      cell.backgroundColor = [UIColor clearColor];
      if (self.darkColorScheme) {
        cell.titleLabel.textColor = [UIColor whiteColor];
      }

      
      if ([self.currentChapter isEqualToString:toc.title])
      {
        cell.background.hidden = NO;
      }
      else {
        cell.background.hidden = YES;
      }
      return cell;
    }
    case 1:{
      NYPLReaderBookmarkCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifierBookmark];
      cell.backgroundColor = [UIColor clearColor];
      
      NYPLReaderBookmarkElement *const bookmark = self.bookmarks[indexPath.row];
      
      cell.chapterLabel.text = bookmark.chapter;
      
      NSDateFormatter *const dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.timeStyle = NSDateFormatterShortStyle;
      dateFormatter.dateStyle = NSDateFormatterShortStyle;
      
      NSDate *date = [NSDate dateWithRFC3339String:bookmark.time];
      NSString *prettyDate = [dateFormatter stringFromDate:date];

      cell.pageNumberLabel.text = [NSString stringWithFormat:@"%@ - %@ through chapter",prettyDate, bookmark.percentInChapter];
      
      if (self.darkColorScheme) {
        cell.chapterLabel.textColor = [UIColor whiteColor];
        cell.pageNumberLabel.textColor = [UIColor whiteColor];
      }
      
      return cell;
    }
    default:
      return nil;
  }
}

#pragma mark UITableViewDelegate

- (void)tableView:(__attribute__((unused)) UITableView *const)tableView
didSelectRowAtIndexPath:(NSIndexPath *const)indexPath
{
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:{
      NYPLReaderTOCElement *const TOCElement = self.tableOfContents[indexPath.row];
      [self.delegate TOCViewController:self
               didSelectOpaqueLocation:TOCElement.opaqueLocation];
      break;
    }
    case 1:{
      NYPLReaderBookmarkElement *const bookmark = self.bookmarks[indexPath.row];
      [self.delegate TOCViewController:self didSelectBookmark:bookmark];
      break;
    }
    default:
      break;
  }
}

-(CGFloat)tableView:(__attribute__((unused)) UITableView *)tableView estimatedHeightForRowAtIndexPath:(__attribute__((unused)) NSIndexPath *)indexPath
{
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:
      return 56;
    case 1:
      return 100;
    default:
      return 44;
  }
}

-(CGFloat)tableView:(__attribute__((unused)) UITableView *)tableView heightForRowAtIndexPath:(__attribute__((unused)) NSIndexPath *)indexPath
{
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:
    case 1:
      return UITableViewAutomaticDimension;
    default:
      return 44;
  }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (editingStyle == UITableViewCellEditingStyleDelete)
  {
    
    NYPLReaderBookmarkElement *bookmark = self.bookmarks[indexPath.row];
    
    NYPLReaderReadiumView *rv = [[NYPLReaderSettings sharedSettings] currentReaderReadiumView];
    [rv deleteBookmark:bookmark];
    
    [self.bookmarks removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
    
  }
}

- (IBAction)didSelectSegment:(__attribute__((unused)) UISegmentedControl*)sender
{
  if (self.segmentedControl.selectedSegmentIndex == 1) {
    if (self.bookmarks.count == 0 || self.bookmarks == nil) {
      self.tableView.hidden = YES;
    }
  } else {
    if (self.tableView.isHidden) {
      self.tableView.hidden = NO;
    }
  }
  [self.tableView reloadData];
  switch (self.segmentedControl.selectedSegmentIndex) {
    case 0:
      if ([self.tableView.subviews containsObject:self.refreshControl]){
        [self.refreshControl removeFromSuperview];
      }
      break;
    case 1:
      self.refreshControl = [[UIRefreshControl alloc] init];
      [self.refreshControl addTarget:self action:@selector(userDidRefresh:) forControlEvents:UIControlEventValueChanged];
      [self.tableView addSubview:self.refreshControl];
      break;
    default:
      break;
  }
}

#pragma mark -

- (void) createViews
{
  NSString *label;
  if (self.bookTitle) {
    label = [NSString stringWithFormat:@"There are no bookmarks for %@", self.bookTitle];
  } else {
    label = [NSString stringWithFormat:@"There are no bookmarks for this book."];
  }
  self.noBookmarksLabel.text = label;
  
  [self.view insertSubview:self.noBookmarksLabel belowSubview:self.tableView];
  
  [self.noBookmarksLabel autoCenterInSuperview];
  [self.noBookmarksLabel autoSetDimension:ALDimensionWidth toSize:250];
}

@end
