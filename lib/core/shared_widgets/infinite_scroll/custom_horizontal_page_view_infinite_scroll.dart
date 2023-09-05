import '../../../core/shared_widgets/Loader/custom_circular_progress_indicator.dart';
import '../../../core/shared_widgets/text/custom_body_text.dart';
import '../text_form_field/custom_search_text_form_field.dart';
import '../../../core/utils/api_conflict_resolver.dart';
import '../message_alert/custom_message_alert.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';
import 'dart:async';

enum RequestType {
  startRequest,
  continueRequest
}

class CustomHorizontalPageViewInfiniteScroll extends StatefulWidget {

  final bool disabled;
  final bool showSearchBar;
  final bool showSeparater;
  final bool debounceSearch;
  final String catchErrorMessage;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry listPadding;
  final EdgeInsetsGeometry headerPadding;

  /// Method to notify parent widget when the page number has changed
  final Function(int)? onPageChanged;

  /// Content to show above the search bar
  final Widget? contentBeforeSearchBar;

  /// Content to show below the search bar
  final Widget? contentAfterSearchBar;

  /// Method to implement the Api Request
  final Future<dio.Response> Function(int page, String searchWord) onRequest;

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

  /// Mesage to show when there is no more content to show
  final String noMoreContent;

  /// Widget to show when there is no more content to show
  final Widget? noMoreContentWidget;

  /// Whether to show the loader that hides all the content on
  /// the first request or to hide this loader so that part of
  /// the content can appear e.g the contentBeforeSearchBar
  /// and contentAfterSearchBar can be shown while the
  /// content is still loading
  final bool showFirstRequestLoader;

  /// The index of the initial page to show of the item list
  final int initialPage;

  const CustomHorizontalPageViewInfiniteScroll({
    Key? key,
    this.margin,
    this.onPageChanged,
    this.initialPage = 0,
    this.disabled = false,
    required this.onRequest,
    this.noMoreContentWidget,
    this.showSearchBar = true,
    this.showSeparater = true,
    required this.onParseItem,
    required this.onRenderItem,
    this.contentAfterSearchBar,
    this.contentBeforeSearchBar,
    this.debounceSearch = false,
    required this.catchErrorMessage,
    this.showFirstRequestLoader = true,
    this.noContent = 'No results found',
    this.noMoreContent = 'No more results found',
    this.listPadding = const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
    this.headerPadding = const EdgeInsets.only(top: 20, bottom: 0, left: 16, right: 16),
  }) : super(key: key);

  @override
  State<CustomHorizontalPageViewInfiniteScroll> createState() => CustomHorizontalPageViewInfiniteScrollState();
}

class CustomHorizontalPageViewInfiniteScrollState extends State<CustomHorizontalPageViewInfiniteScroll> {

  final ApiConflictResolverUtility apiConflictResolverUtility = ApiConflictResolverUtility();
  final DebouncerUtility debouncerUtility = DebouncerUtility(milliseconds: 1000);
  RequestType requestType = RequestType.startRequest;
  late PageController controller;
  
  bool hasShownSearchBarBefore = false;
  bool sentFirstRequest = false;
  bool isLoading = false;
  String searchWord = '';
  bool hasError = false;
  List data = [];
  int? lastPage;
  int page = 1;
  
  int get totalItems => data.length;
  bool get disabled => widget.disabled;
  String get noContent => widget.noContent;
  int get initialPage => widget.initialPage;
  bool get showSearchBar => widget.showSearchBar;
  bool get showSeparater => widget.showSeparater;
  bool get debounceSearch => widget.debounceSearch;
  String get noMoreContent => widget.noMoreContent;
  Function(Map) get onParseItem => widget.onParseItem;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  Function(int)? get onPageChanged => widget.onPageChanged;
  String get catchErrorMessage => widget.catchErrorMessage;
  bool get isSearching => isLoading && searchWord.isNotEmpty;
  Widget? get noMoreContentWidget => widget.noMoreContentWidget;
  bool get showFirstRequestLoader => widget.showFirstRequestLoader;
  Widget? get contentAfterSearchBar => widget.contentAfterSearchBar;
  Widget? get contentBeforeSearchBar => widget.contentBeforeSearchBar;
  bool get isStartingRequest => requestType == RequestType.startRequest;
  bool get loadedLastPage => lastPage == null ? false : page > lastPage!;
  bool get isContinuingRequest => requestType == RequestType.continueRequest;
  Future<dio.Response> Function(int, String) get onRequest => widget.onRequest;
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

    /// Load initial content (page 1)
    startRequest();

    /// Set the selected order by index
    controller = PageController(initialPage: widget.initialPage);
    
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
      
      /// Check if the page changed
      if(isInteger(controller.page!) && onPageChanged != null) {
        onPageChanged!(controller.page!.toInt());
      }

    });

  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  /// Check if the value is a whole number (integer) or non decimal
  /// Reference: https://stackoverflow.com/questions/58010627/dart-flutter-check-if-value-is-an-integer-whole-number#:~:text=The%20slightly%20harder%20task%20is,it%20to%20the%20original%20value.
  bool isInteger(num value) {
    return value is int || value == value.roundToDouble();
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

  Future<dio.Response> makeApiRequest(RequestType requestType) async {

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

            setState(() {
              
              /// Add the list of items to the existing data items
              final requestData = (response.data['data'] as List).map((item) {

                /// Convert the json data into a structured Model
                return onParseItem(item);

              }).toList();

              if(isStartingRequest) {
                
                /// Overide existing data
                data = requestData;

              }else if(isContinuingRequest) {
                
                /// Append to existing data
                data.addAll(requestData);

              }

              /// Set the last page
              lastPage = response.data['lastPage'];

              /// Increment the page to load the next batch of data items
              if(page <= lastPage!) page++;

              /// Indicate that we have made the first request
              sentFirstRequest = true;

            });

          }
          
          if( response.statusCode! >= 400 ) {

            /// We have a server side error
            setHasError(true);

          }

        }

      }, 
      
      /// What to do while the request is loading
      onStartLoader: () {
        if(mounted) _startLoader();
      },
      
      /// What to do when the request completes
      onStopLoader: () {
        if(mounted) _stopLoader();
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

  Widget get noContentWidget {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.ac_unit_sharp, size: 80, color: Colors.grey.shade300,),
        const SizedBox(height: 16,),
        CustomBodyText(
          noContent, 
          textAlign: TextAlign.center
        ),
      ],
    );
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
        onChanged: (value) {
        
          if(!mounted) return;

          /// Update local state
          setState(() => searchWord = value);

          /// Notify parent
          if(debounceSearch) {
            debouncerUtility.run((){
              startRequest();
            });
          }else{
            startRequest();
          }
        }
      ),
    );
  }

  Widget buildItem(int index) {

    /// Build the custom Item Widget
    return onRenderItem(data[index], index, data);
  
  }

  Widget get contentListWidget {
    /**
     * SingleChildScrollView is required to show other widgets in a Column along with the
     * ListView widget. Setting the "shrinkWrap=true" forces ListView to take only the required space, 
     * and not the entire screen. Setting "physics=NeverScrollableScrollPhysics()" disables scrolling 
     * functionality of ListView, which means now we have only SingleChildScrollView who provide the 
     * scrolling functionality.
     * 
     * Reference: https://stackoverflow.com/questions/56131101/how-to-place-a-listview-inside-a-singlechildscrollview-but-prevent-them-from-scr
     * 
     * The controller helps us to track the scrolling e.g how much we scrolled up or down.
     * We can use this information to decide whether to load more content or not.
     */
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
    
        Expanded(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isStartingRequest && isLoading ? 0.3 : 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: PageView.builder(
                controller: controller,
                itemCount: totalItems + 1,
                itemBuilder: ((context, index) {
                  
                  /// If this is the last item
                  if(index == totalItems) {
                    
                    /// If we are loading more 
                    if(sentFirstRequest && isLoading) {
              
                      /// Loader (Shows up when more content is loading)
                      return const CustomCircularProgressIndicator(size: 20);
                        
                    }else if(sentFirstRequest) {

                      /// No content / No more content widget
                      return  totalItems == 0 ? noContentWidget : _noMoreContentWidget;

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
        ),
      
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
        child: (showFirstRequestLoader && isLoading && !sentFirstRequest) 
          ? const CustomCircularProgressIndicator()
          : contentListWidget,
      ),
    );
  }
}