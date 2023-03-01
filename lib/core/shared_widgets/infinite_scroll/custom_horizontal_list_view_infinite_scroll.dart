import '../text_form_fields/custom_search_text_form_field.dart';
import '../Loader/custom_circular_progress_indicator.dart';
import '../../../core/utils/api_conflict_resolver.dart';
import '../message_alerts/custom_message_alert.dart';
import '../checkboxes/custom_checkbox.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/snackbar.dart';
import '../text/custom_body_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

enum RequestType {
  startRequest,
  continueRequest
}

class CustomHorizontalListViewInfiniteScroll extends StatefulWidget {

  final double height;
  final bool disabled;
  final String? searchWord;
  final bool showSearchBar;
  final bool debounceSearch;
  final String catchErrorMessage;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry listPadding;
  final EdgeInsetsGeometry headerPadding;

  /// Content to show above the search bar
  final Widget? contentBeforeSearchBar;

  /// Content to show below the search bar
  final Widget? contentAfterSearchBar;

  /// Method to implement the Api Request
  final Future<http.Response> Function(int page, String searchWord) onRequest;

  /// Method to implement conversion of the Api Request
  /// data retrieved into the desired Model data output
  /// We feed the data which is a Map of json data and
  /// the method converts it into a properly structured
  /// Model, for instance using Store.fromJson(). This
  /// method must return an output.
  final Function(Map) onParseItem;

  /// Method to implement the build of each list item
  final Widget Function(dynamic item, int index, List<dynamic> items) onRenderItem;

  /// Mesage to show when there is no content to show
  final String noContent;

  /// Widget to show when there is no more content to show
  final Widget? noMoreContentWidget;

  /// Mesage to show when there is no more content to show
  final String noMoreContent;

  /// Widget to show when there is no content to show
  final Widget? noContentWidget;

  /// The margin of the loader that is show when the
  /// showFirstRequestLoader has been set to false
  final EdgeInsets loaderMargin;

  /// Whether to show the loader that hides all the content on
  /// the first request or to hide this loader so that part of
  /// the content can appear e.g the contentBeforeSearchBar
  /// and contentAfterSearchBar can be shown while the
  /// content is still loading
  final bool showFirstRequestLoader;

  /// Notify the parent widget on the loading status
  final Function(bool)? onLoading;

  /// Notify the parent widget on the loading status after first request
  final Function(bool)? onLoadingAfterFirstRequest;

  /// Notify the parent widget on the loading status
  final Function(bool)? onSearching;

  /// Show the no more content text when we don't have
  /// anymore content to load while scrolling down
  final bool showNoMoreContent;

  const CustomHorizontalListViewInfiniteScroll({
    Key? key,
    this.margin,
    this.onLoading,
    this.searchWord,
    this.onSearching,
    this.height = 200,
    this.noContentWidget,
    this.disabled = false,
    required this.onRequest,
    this.noMoreContentWidget,
    this.showSearchBar = true,
    required this.onParseItem,
    required this.onRenderItem,
    this.contentAfterSearchBar,
    this.contentBeforeSearchBar,
    this.debounceSearch = false,
    this.showNoMoreContent = true,
    this.onLoadingAfterFirstRequest,
    required this.catchErrorMessage,
    this.showFirstRequestLoader = true,
    this.noContent = 'No results found',
    this.noMoreContent = 'No more results found',
    this.loaderMargin = const EdgeInsets.symmetric(vertical: 16),
    this.listPadding = const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
    this.headerPadding = const EdgeInsets.only(top: 20, bottom: 0, left: 16, right: 16),
  }) : super(key: key);

  @override
  State<CustomHorizontalListViewInfiniteScroll> createState() => CustomHorizontalInfiniteScrollState();
}

class CustomHorizontalInfiniteScrollState extends State<CustomHorizontalListViewInfiniteScroll> {

  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  final ScrollController controller = ScrollController();
  RequestType requestType = RequestType.startRequest;
  
  bool hasShownSearchBarBefore = false;
  bool sentFirstRequest = false;
  bool isLoading = false;
  String searchWord = '';
  bool hasError = false;
  List data = [];
  int? lastPage;
  int page = 1;

  int forceRenderListView = 0;
  int get totalItems => data.length;
  double get height => widget.height;
  bool get disabled => widget.disabled;
  String get noContent => widget.noContent;
  bool get showSearchBar => widget.showSearchBar;
  bool get debounceSearch => widget.debounceSearch;
  String get noMoreContent => widget.noMoreContent;
  Function(bool)? get onLoading => widget.onLoading;
  EdgeInsets get loaderMargin => widget.loaderMargin;
  Function(Map) get onParseItem => widget.onParseItem;
  Widget? get noContentWidget => widget.noContentWidget;
  Function(bool)? get onSearching => widget.onSearching;
  bool get showNoMoreContent => widget.showNoMoreContent;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  String get catchErrorMessage => widget.catchErrorMessage;
  Widget? get noMoreContentWidget => widget.noMoreContentWidget;
  bool get showFirstRequestLoader => widget.showFirstRequestLoader;
  Widget? get contentAfterSearchBar => widget.contentAfterSearchBar;
  Widget? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  bool get isStartingRequest => requestType == RequestType.startRequest;
  bool get loadedLastPage => lastPage == null ? false : page > lastPage!;
  bool get isContinuingRequest => requestType == RequestType.continueRequest;
  Future<http.Response> Function(int, String) get onRequest => widget.onRequest;
  bool get isSearching => isStartingRequest && isLoading && searchWord.isNotEmpty;
  Function(bool)? get onLoadingAfterFirstRequest => widget.onLoadingAfterFirstRequest;
  Widget Function(dynamic item, int index, List<dynamic> items) get onRenderItem => widget.onRenderItem;

  bool get canLoadMore {
    /**
     *  We can load more if:
     * 
     *  1) We are not currently loading
     *  2) We want to load a page before the last page or the last page itself
     */
    return !isLoading && page <= lastPage!;
  }

  @override
  void initState() {
    
    super.initState();

    /// Set the local state searchWord using the widget searchWord (if provided)
    if(widget.searchWord != null) searchWord = widget.searchWord!; 

    /// Load initial content (page 1)
    startRequest();
    
    /**
     *  This controller is used to check if we have scrolled to the
     *  bottom of the scroll view so that we can load more content 
     */
    controller.addListener(() {

      /// Get the screen height and divide by two
      final double halfScreenHeight = MediaQuery.of(context).size.height;

      /// Get the available scroll height
      final double availableScrollableHeight = controller.position.maxScrollExtent;

      /// Check if we are half the screen height from the bottom of the scrollable area
      final bool isHalfScreenHeightFromTheBottom = controller.offset > (availableScrollableHeight - halfScreenHeight);
      
      /// If we have scrolled half the screen size from the bottom, 
      /// then check if we can start loading more content
      if( isHalfScreenHeightFromTheBottom ) {

        /// Check if we can load anymore more content
        if(!canLoadMore) return;

        /// Load additional content (page 2, 3, 4, e.t.c)
        continueRequest();

      }

    });

  }
  
  @override
  void didUpdateWidget(covariant CustomHorizontalListViewInfiniteScroll oldWidget) {

    super.didUpdateWidget(oldWidget);

    /// If the search word changed
    if(widget.searchWord != oldWidget.searchWord && oldWidget.searchWord != null) {

      /// Set the search word
      searchWord = widget.searchWord!;
          
      /// Start search
      onSearch(searchWord);

    }

  }

  void setHasError(bool status) {
    if(!mounted) return;
    setState(() => hasError = status);
  }

  int removeItemAt(int index) {
    if(!mounted) return 0;
    setState(() => data.removeAt(index));
    return totalItems;
  }

  void updateItemAt(int index, item) {
    if(!mounted) return;
    setState(() => data[index] = item);
  }

  Future<void> startRequest() {
    return makeApiRequest(RequestType.startRequest);
  }

  Future<void> continueRequest() {
    return makeApiRequest(RequestType.continueRequest);
  }

  Future<http.Response> makeApiRequest(RequestType requestType) async {

    /// Disable showing any errors
    if(hasError) setHasError(false);

    //  Capture the request type
    this.requestType = requestType;
    
    /// Reset the page to 1 if we are starting a request
    if(isStartingRequest) page = 1;

    /// The apiConflictResolverUtility resoloves the comflict of 
    /// retrieving data returned by the wrong request. Whenever
    /// we make multiple requests, we only ever want the data 
    /// of the last request and not any other request.
    return apiConflictResolverUtility.addRequest(
      
      /// The request we are making
      onRequest: () => onRequest(page, searchWord), 
      
      /// The response returned by the last request
      onCompleted: (response) {

        if(mounted) {

          if( response.statusCode == 200) {

            final responseBody = jsonDecode(response.body);

            setState(() {
              
              /// Add the list of items to the existing data items
              final requestData = (responseBody['data'] as List).map((item) {

                /// Convert the json data into a structured Model
                return onParseItem(item);

              }).toList();

              if(isStartingRequest) {
                
                /// Overide existing data
                data = requestData;

                /// Force Re-render so that we do not have a confusion of item keys in the case
                /// that we have made an initial request before and loaded content, but then 
                /// decided to make another "startRequest" to replace this current data 
                /// instead of making a "continueRequest" to prepend data. In such a
                /// situation Flutter might want to keep some widgets that seem to
                /// be the same, but usually the widgets are the same in structure
                /// but containing different data. To be on the safe side, we want
                /// to force a re-render so that we don't have to worry about this
                forceRenderListView++;

              }else if(isContinuingRequest) {
                
                /// Append to existing data
                data.addAll(requestData);

              }

              /// Set the last page
              lastPage = responseBody['lastPage'];

              /// Increment the page to load the next batch of data items
              if(page <= lastPage!) page++;

              /// Indicate that we have made the first request
              sentFirstRequest = true;

            });

          }
          
          if( response.statusCode >= 400 ) {

            /// We have a server side error
            setHasError(true);

          }

        }

      }, 
      
      /// What to do while the request is loading
      onStartLoader: () {
        if(mounted) _startLoader();
        if(onLoading != null) onLoading!(true);
        if(onLoadingAfterFirstRequest != null && sentFirstRequest) onLoadingAfterFirstRequest!(true);

        /// Note that the onSearching() must be declared after the 
        /// _startLoader() because it depends on the isLoading property
        if(onSearching != null && isSearching) onSearching!(true);
      },
      
      /// What to do when the request completes
      onStopLoader: () {
        if(mounted) _stopLoader();
        if(onLoading != null) onLoading!(false);
        if(onLoadingAfterFirstRequest != null && sentFirstRequest) onLoadingAfterFirstRequest!(false);

        /// Note that the onSearching() must be declared after the 
        /// _startLoader() because it depends on the isLoading property
        if(onSearching != null && !isSearching) onSearching!(false);
      },

    /// On Error
    ).catchError((e) {

      if(mounted) {

        /// We have a client side error
        setHasError(true);

        /// Show the Snackbar error message
        SnackbarUtility.showErrorMessage(message: catchErrorMessage);

      }

    });

  }

  void onSearch(String searchWord) {
    if(debounceSearch) {
      debouncerUtility.run(() {
        startRequest();
      });
    }else{
      startRequest();
    }
  }

  Widget buildItem(int index) {

    final item = data[index];

    /// Build the custom Item Widget
    return onRenderItem(item, index, data);
  
  }
  
  bool get canShowSearchBar {
    /**
     *  Show the search bar if
     * 
     *  1) We made it clear that we want to enable search
     *  2) We made our first request with a search term or we made 
     *     our first request without a search term and the entire 
     *     dataset is separated into more than one page or we
     *     have shown the search bar at least once before
     *     
     */
    final bool hasSearchTerm = searchWord.isNotEmpty;
    final bool hasNoSearchTermButHasManyPages = searchWord.isEmpty && (lastPage == null ? false : lastPage! > 1);
    
    if(showSearchBar && sentFirstRequest && (hasSearchTerm || hasNoSearchTermButHasManyPages || hasShownSearchBarBefore)) {
      return hasShownSearchBarBefore = true;
    }else{
      return false;
    }
  }

  Widget get _noContentWidget {
    return noContentWidget == null ? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.ac_unit_sharp, size: 80, color: Colors.grey.shade300,),
        const SizedBox(height: 16,),
        CustomBodyText(
          noContent, 
          textAlign: TextAlign.center
        ),
      ],
    ) : noContentWidget!;
  }

  Widget get _noMoreContentWidget {
    return noMoreContentWidget == null ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.ac_unit_sharp, size: 80, color: Colors.grey.shade300,),
        const SizedBox(height: 16,),
        CustomBodyText(
          noMoreContent, 
          textAlign: TextAlign.center
        ),
      ],
    ) : noMoreContentWidget!;
  }

  Widget get searchInputField {  
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: CustomSearchTextFormField(
        initialValue: searchWord,
        isLoading: isSearching,
        enabled: !disabled,
        onChanged: (searchWord) {
        
          if(!mounted) return;

          /// Update local state
          setState(() => this.searchWord = searchWord);
          
          /// Start search
          onSearch(this.searchWord);

        }
      ),
    );
  }
  
  Widget get contentListWidget {

    final showWidgetLoader = !showFirstRequestLoader && !sentFirstRequest && isLoading;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// On Error
        if(hasError) Column(
          children: [
            
            /// Show Catch Error Message
            CustomMessageAlert(
              catchErrorMessage,
              margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16)
            ),

            /// Warning Icon
            Icon(Icons.warning_amber_rounded, size: 100, color: Colors.grey.shade200),

          ],
        ),
        
        if(hasError == false) Container(
          padding: widget.headerPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    
              /// Content Before Search Bar Widget
              if(contentBeforeSearchBar != null) contentBeforeSearchBar!,
    
              /// Search Input Field Widget
              if(canShowSearchBar) searchInputField,
    
              /// Content After Search Bar Widget
              if(contentAfterSearchBar != null) contentAfterSearchBar!,
    
            ],
          ),
        ),

        /// Loader (Show while loading and when we haven't sent our first request)
        if(showWidgetLoader) CustomCircularProgressIndicator(
          margin: loaderMargin,
        ),

        /// ListView
        if(!showWidgetLoader) AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: isStartingRequest && isLoading ? 0.3 : 1,
          child: (sentFirstRequest && !isLoading && totalItems == 0) 
            /// No content
            ? _noContentWidget
            /// List items
            : SizedBox(
            height: height,
            child: ListView.builder(
              key: ValueKey(forceRenderListView),
              shrinkWrap: true,
              controller: controller,
              itemCount: totalItems + 1,
              padding: widget.listPadding,
              scrollDirection: Axis.horizontal,
              itemBuilder: ((context, index) {
                
                /// If this is the last item
                if(index == totalItems) {
                  
                  /// If we are loading more 
                  if(sentFirstRequest && isLoading) {
            
                    /// Loader (Shows up when more content is loading)
                    return const CustomCircularProgressIndicator(size: 20, margin: EdgeInsets.only(left: 16),);
                      
                  }else if(showNoMoreContent && sentFirstRequest) {

                    /// No more content widget
                    return _noMoreContentWidget;

                  }else{
                    
                    /// Return nothing
                    return Container();

                  }
        
                }else{
                  
                  /// Build Custom Item Widget
                  return buildItem(index);

                }
            
              })
            ),
          ),
        ),
      
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 500),
      child: (showFirstRequestLoader && isLoading && !sentFirstRequest) 
        ? const CustomCircularProgressIndicator()
        : contentListWidget,
    );
  }
}